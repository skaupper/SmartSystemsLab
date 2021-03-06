/*
 * Terasic DE1-SoC Sensor Driver for MPU9250 Gyroscope/Accelerometer/Magnetometer Sensor
 *
 * Copyright (C) 2019 Michael Wurm <michael.wurm@students.fh-hagenberg.at>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/io.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/interrupt.h>
#include <linux/ioctl.h>
#include <linux/sched/signal.h>

#define DRIVER_NAME "mpu9250"

#define SIGNAL_EVENT 10 // User space has to listen for this event number

#define NUM_BYTE_SENSOR_DATA (3 * 3 * sizeof(uint16_t))
#define NUM_BYTE_TIMESTAMP (2 * sizeof(uint32_t))
#define NUM_BYTE_SHOCK_DATA (1024 * 3 * 3 * sizeof(uint16_t))

#define SIZEOF_POLLING_DATA_T (NUM_BYTE_SENSOR_DATA + NUM_BYTE_TIMESTAMP)
#define SIZEOF_BUFFER_DATA_T (NUM_BYTE_SHOCK_DATA + NUM_BYTE_TIMESTAMP * 1024)

#define MEM_OFFSET_DATA_GYRO_X (0x0)
#define MEM_OFFSET_DATA_GYRO_Y (0x4)
#define MEM_OFFSET_DATA_GYRO_Z (0x8)
#define MEM_OFFSET_DATA_ACC_X (0xC)
#define MEM_OFFSET_DATA_ACC_Y (0x10)
#define MEM_OFFSET_DATA_ACC_Z (0x14)
#define MEM_OFFSET_DATA_MAG_X (0x18)
#define MEM_OFFSET_DATA_MAG_Y (0x1C)
#define MEM_OFFSET_DATA_MAG_Z (0x20)
#define MEM_OFFSET_TIMESTAMP_LOW (0x24)
#define MEM_OFFSET_TIMESTAMP_HIGH (0x28)
#define MEM_OFFSET_BUF_CTRL_STATUS (0X2C)
#define MEM_OFFSET_BUF_IEN (0X30)
#define MEM_OFFSET_BUF_ISR (0X34)
#define MEM_OFFSET_SHOCK_THRESHOLD (0X38)
#define MEM_OFFSET_BUF_DATA (0X3C)

/* IO Control (IOCTL) */
#define IOC_MODE_POLLING 0
#define IOC_MODE_BUFFER 1
#define IOC_SET_PID 2
#define IOC_SET_THRESHOLD 3
#define IOC_CMD_SET_READ_POLLING _IO(4711, IOC_MODE_POLLING)
#define IOC_CMD_SET_READ_BUFFER _IO(4711, IOC_MODE_BUFFER)
#define IOC_CMD_SET_PID _IO(4711, IOC_SET_PID)
#define IOC_CMD_SET_THRESHOLD _IOW(4711, IOC_SET_THRESHOLD, uint32_t *)

typedef struct
{
  uint32_t timestamp_lo;
  uint32_t timestamp_hi;
  uint16_t gyro_x;
  uint16_t gyro_y;
  uint16_t gyro_z;
  uint16_t acc_x;
  uint16_t acc_y;
  uint16_t acc_z;
  uint16_t mag_x;
  uint16_t mag_y;
  uint16_t mag_z;
} __attribute__((packed)) polling_data_t;

typedef struct
{
  uint32_t timestamp_lo[1024];
  uint32_t timestamp_hi[1024];
  uint16_t buf_acc_x[1024];
  uint16_t buf_acc_y[1024];
  uint16_t buf_acc_z[1024];
  uint16_t buf_gyro_x[1024];
  uint16_t buf_gyro_y[1024];
  uint16_t buf_gyro_z[1024];
  uint16_t buf_mag_x[1024];
  uint16_t buf_mag_y[1024];
  uint16_t buf_mag_z[1024];
} __attribute__((packed)) buffer_data_t;

struct data
{
  void *regs;
  buffer_data_t buffer_data;
  polling_data_t polling_data;
  int mode; /* 0..polling, 1..buffer, 2..set pid */
  int pid;
  int size;
  int irq_nr;
  int irq_count;
  int irqs_active;
  int buf_data_available;
  struct miscdevice misc;
};

/*
 * @brief Reads the sensor polling data once.
 */
static int read_polling_data(struct data *dev, char *buf, size_t count, loff_t *offp)
{
  /* check out of bound access */
  if ((*offp < 0) || (*offp >= SIZEOF_POLLING_DATA_T))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > SIZEOF_POLLING_DATA_T)
    count = SIZEOF_POLLING_DATA_T - *offp;

  /* read data from FPGA and store into kernel space buffer */
  dev->polling_data.gyro_x = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_X);
  dev->polling_data.gyro_y = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_Y);
  dev->polling_data.gyro_z = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_Z);

  dev->polling_data.acc_x = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_X);
  dev->polling_data.acc_y = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_Y);
  dev->polling_data.acc_z = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_Z);

  dev->polling_data.mag_x = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_X);
  dev->polling_data.mag_y = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_Y);
  dev->polling_data.mag_z = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_Z);

  dev->polling_data.timestamp_lo = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_LOW);
  dev->polling_data.timestamp_hi = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_HIGH);

  /* copy data from kernel space buffer into user space */
  if (count > 0)
    count = count - copy_to_user(buf, (char *)&dev->polling_data + *offp, count);

  *offp += count;

  return count;
}

/*
 * @brief Reads the sensor buffer data .
 */
static int read_buffer_data(struct data *dev, char *buf, size_t count, loff_t *offp)
{
  int i;

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= SIZEOF_BUFFER_DATA_T))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > SIZEOF_BUFFER_DATA_T)
    count = SIZEOF_BUFFER_DATA_T - *offp;

  /* Check for buffers that are ready
   * NOTE: This is only done once when initiating the buffer read procedure,
   *       because the FPGA resets the registers on a read. */
  if (*offp == 0)
  {
    dev->buf_data_available = ioread32(dev->regs + MEM_OFFSET_BUF_CTRL_STATUS);

    if (dev->irqs_active == 0x1)
    {
      if (dev->buf_data_available == 0x2)
      {
        pr_info("read_buffer_data: Reading buffer 0 data");

        /* Read data from single address
       * NOTE: FPGA returns all the data from the same register address.
       * The sequence is:
       *   acc_X, acc_Y, acc_Z,
       *   gyro_X, gyro_Y, gyro_Z,
       *   mag_X, mag_Y, mag_Z,
       *   timestamp_lo, timestamp_hi
       */
        for (i = 0; i < 1024; i++)
        {
          dev->buffer_data.buf_acc_x[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_acc_y[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_acc_z[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);

          dev->buffer_data.buf_gyro_x[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_gyro_y[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_gyro_z[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);

          dev->buffer_data.buf_mag_x[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_mag_y[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.buf_mag_z[i] = ioread16(dev->regs + MEM_OFFSET_BUF_DATA);

          dev->buffer_data.timestamp_lo[i] = ioread32(dev->regs + MEM_OFFSET_BUF_DATA);
          dev->buffer_data.timestamp_hi[i] = ioread32(dev->regs + MEM_OFFSET_BUF_DATA);
        }
      }
      else
        printk(KERN_ERR "read_buffer_data: Interrupt 0 occured, but buffer 0 is not ready.\n");
    }
    else
    {
      printk(KERN_ERR "read_buffer_data: Unexpected interrupt 0x%08x\n", dev->irqs_active);
    }
  }

  /* copy data from kernel space buffer into user space */
  if (count > 0)
    count = count - copy_to_user(buf, (char *)&dev->buffer_data + *offp, count);

  *offp += count;

  /* Mark interrupts as handled, when the entire buffer was read.
   * NOTE: To read the entire buffer once, the function dev_read may be called multiple times
   *       by the kernel. This is due to the large size of the data buffer structure in here.
   *       The read process is not done in a single kernel call, but is splitted, like following
   *       example:
   *          1. The kernel requests a read for the first 20.000 byte
   *          2. read_buffer_data advances the offp to 20.000 and returns
   *          3. The kernel requests a read for the next 4.000 byte (the rest to EOF)
   *          4. read_buffer_data advances the offp to 24.000 (EOF)
   *          5. Since the file was read entirely to EOF, read_buffer_data resets the FPGA
   *             to be ready for a new interrupt.
   */
  if (*offp >= SIZEOF_BUFFER_DATA_T)
  {
    /* Reset internal status. */
    dev->irqs_active = 0;
    dev->buf_data_available = 0;

    /* Enable buffer 0 again (it's disabled internally on every interrupt to keep the data valid) */
    iowrite32(0x1, dev->regs + MEM_OFFSET_BUF_CTRL_STATUS);
  }

  return count;
}

static irqreturn_t irq_handler(int nr, void *data_ptr)
{
  struct data *dev = data_ptr;
  struct siginfo info;
  struct task_struct *t;

  pr_info("Interrupt occured\n");

  /* Determine which interrupt occured */
  dev->irqs_active = ioread32(dev->regs + MEM_OFFSET_BUF_ISR);

  if (dev->irqs_active == 0x1)
  {
    dev->irq_count++;
    pr_info("Received buffer 0 interrupt [Occured %i times so far.]\n", dev->irq_count);
  }
  else
  {
    /* Another device asserted the shared interrupt line */
    return IRQ_NONE;
  }

  /* Reset interrupts (Write '1' to clear) */
  iowrite32(dev->irqs_active, dev->regs + MEM_OFFSET_BUF_ISR);

  /* Send signal to user space */
  t = pid_task(find_vpid(dev->pid), PIDTYPE_PID);
  if (t == NULL)
  {
    printk(KERN_ERR "A Task with PID %i does not exist.\n", dev->pid);
    return IRQ_HANDLED;
  }

  memset(&info, 0, sizeof(struct siginfo));
  info.si_signo = SIGNAL_EVENT;
  info.si_code = SI_QUEUE;
  info.si_int = 4711;

  send_sig_info(SIGNAL_EVENT, &info, t);

  return IRQ_HANDLED;
}

/*
 * @brief This function gets executed on fread.
 */
static int dev_read(struct file *filep, char *buf, size_t count,
                    loff_t *offp)
{
  struct data *dev = container_of(filep->private_data,
                                  struct data, misc);

  if (SIZEOF_POLLING_DATA_T != sizeof(dev->polling_data))
  {
    printk(KERN_ERR "Data struct polling_data_t is not allocated as expected.\n");
    return -ENOEXEC;
  }

  if (SIZEOF_BUFFER_DATA_T != sizeof(dev->buffer_data))
  {
    printk(KERN_ERR "Data struct buffer_data_t is not allocated as expected.\n");
    return -ENOEXEC;
  }

  /* Read data, depending on current mode */
  switch (dev->mode)
  {
  case IOC_MODE_POLLING:
    pr_info("dev_read: Reading polling data.\n");
    return read_polling_data(dev, buf, count, offp);
    break;
  case IOC_MODE_BUFFER:
    pr_info("dev_read: Reading shock buffer data.\n");
    return read_buffer_data(dev, buf, count, offp);
    break;
  default:
    pr_info("dev_read: Unknown mode is currently set.\n");
    return -EINVAL;
  }
}

/*
 * @brief This function gets executed on ioctl.
 */
static long dev_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
{
  struct data *dev = container_of(filep->private_data, struct data, misc);
  uint32_t threshold;
  uint32_t tmp;

  switch (cmd)
  {
  case IOC_CMD_SET_READ_POLLING:
    pr_info("dev_ioctl: Set cmd to 'read polling'.\n");
    dev->mode = IOC_MODE_POLLING;
    break;
  case IOC_CMD_SET_READ_BUFFER:
    pr_info("dev_ioctl: Set cmd to 'read buffer'.\n");
    dev->mode = IOC_MODE_BUFFER;
    break;
  case IOC_CMD_SET_PID:
    /* Get the PID of the currently executing process.
     * The `current` variable is defined in linux/sched/signal.h */
    dev->pid = task_pid_nr(current);
    pr_info("dev_ioctl: Set current PID to %i.\n", dev->pid);
    /* Enable buffer 0 again (it's disabled internally on every interrupt to keep the data valid) */
    iowrite32(0x1, dev->regs + MEM_OFFSET_BUF_CTRL_STATUS);

    break;
  case IOC_CMD_SET_THRESHOLD:
    tmp = copy_from_user(&threshold, (uint32_t *)arg, sizeof(threshold));
    pr_info("dev_ioctl: Set acceleration threshold for shock detection to %i.\n", threshold);
    iowrite32(threshold, dev->regs + MEM_OFFSET_SHOCK_THRESHOLD);
    break;
  default:
    /* it seems like ioctl is also called for all invocations of fread with cmd 0x5041 (TCGETS) */
    // pr_info("dev_ioctl: Unknown cmd (%u). Exit.\n", cmd);
    break;
  }
  return 0;
}

static const struct file_operations dev_fops = {
    .owner = THIS_MODULE,
    .read = dev_read,
    .unlocked_ioctl = dev_ioctl};

static int dev_probe(struct platform_device *pdev)
{
  struct data *dev;
  struct resource *io;
  int retval;

  /* Allocate memory for private data */
  dev = devm_kzalloc(&pdev->dev, sizeof(*dev), GFP_KERNEL);
  if (dev == NULL)
    return -ENOMEM;
  platform_set_drvdata(pdev, dev);

  /* Get resources */
  io = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  dev->regs = devm_ioremap_resource(&pdev->dev, io);
  if (IS_ERR(dev->regs))
    return PTR_ERR(dev->regs);

  dev->size = io->end - io->start + 1;
  dev->misc.name = DRIVER_NAME;
  dev->misc.minor = MISC_DYNAMIC_MINOR;
  dev->misc.fops = &dev_fops;
  dev->misc.parent = &pdev->dev;
  retval = misc_register(&dev->misc);
  if (retval)
  {
    dev_err(&pdev->dev, "Register misc device failed!\n");
    return retval;
  }

  /* Get interrupt */
  dev->irq_nr = platform_get_irq(pdev, 0);
  retval = devm_request_irq(&pdev->dev, dev->irq_nr, &irq_handler,
                            IRQF_SHARED, dev_name(&pdev->dev), dev);
  if (retval != 0)
  {
    dev_err(&pdev->dev, "Request interrupt failed!\n");
    return retval;
  }

  /* Enable interrupt generation in FPGA device */
  iowrite32(0x3, dev->regs + MEM_OFFSET_BUF_IEN);
  /* Enable buffer 0 */
  iowrite32(0x1, dev->regs + MEM_OFFSET_BUF_CTRL_STATUS);

  dev_info(&pdev->dev, "MPU9250 Gyroscope/Accelerometer/Magnetometer Sensor driver loaded!");

  return 0;
}

static int dev_remove(struct platform_device *pdev)
{
  struct data *dev = platform_get_drvdata(pdev);

  /* Disable interrupt generation in FPGA device */
  iowrite32(0x0, dev->regs + MEM_OFFSET_BUF_IEN);
  devm_free_irq(&pdev->dev, dev->irq_nr, dev);

  misc_deregister(&dev->misc);
  platform_set_drvdata(pdev, NULL);

  return 0;
}

static const struct of_device_id dev_of_match[] = {
    {
        .compatible = "goe,mpu9250-1.0",
    },
    {},
};
MODULE_DEVICE_TABLE(of, dev_of_match);

static struct platform_driver dev_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .of_match_table = of_match_ptr(dev_of_match),
    },
    .probe = dev_probe,
    .remove = dev_remove,
};

module_platform_driver(dev_driver);

MODULE_AUTHOR("M.Wurm");
MODULE_DESCRIPTION("Altera/Terasic MPU9250 Gyroscope/Accelerometer/Magnetometer Sensor driver");
MODULE_LICENSE("GPL v2");
