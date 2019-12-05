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

#define DRIVER_NAME "mpu9250"

#define NUM_BYTE_DATA (2 * 3 * 3)
#define NUM_BYTE_TIMESTAMP 8
#define BUF_SIZE (NUM_BYTE_DATA + NUM_BYTE_TIMESTAMP)

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
} buffer_t;

struct data
{
  void *regs;
  struct buffer;
  int size;
  struct miscdevice misc;
};

/*
 * @brief This function gets executed on fread.
 */
static int dev_read(struct file *filep, char *buf, size_t count,
                    loff_t *offp)
{
  struct data *dev = container_of(filep->private_data,
                                  struct data, misc);
  unsigned int rdata;
  buffer_t tmpBuf;

  assert(BUF_SIZE == sizeof(tmpBuf));

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* read data from FPGA and store into kernel space buffer */
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_X);
  tmpBuf.gyro_x = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_Y);
  tmpBuf.gyro_y = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_GYRO_Z);
  tmpBuf.gyro_z = (rdata & 0x0000FFFF);

  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_X);
  tmpBuf.acc_x = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_Y);
  tmpBuf.acc_y = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_ACC_Z);
  (tmpBuf.acc_z = (rdata & 0x0000FFFF));

  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_X);
  tmpBuf.mag_x = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_Y);
  tmpBuf.mag_y = (rdata & 0x0000FFFF);
  rdata = ioread16(dev->regs + MEM_OFFSET_DATA_MAG_Z);
  tmpBuf.mag_z = (rdata & 0x0000FFFF);

  tmpBuf.timestamp_lo = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_LOW);
  tmpBuf.timestamp_hi = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_HIGH);

  /* copy data from kernel space buffer into user space */
  if (count > 0)
    count = count - copy_to_user(buf, (char *)dev->buffer + *offp, count);

  *offp += count;

  return count;
}

static const struct file_operations dev_fops = {
    .owner = THIS_MODULE,
    .read = dev_read};

static int dev_probe(struct platform_device *pdev)
{
  struct data *dev;
  struct resource *io;
  int retval;

  dev = devm_kzalloc(&pdev->dev, sizeof(*dev), GFP_KERNEL);
  if (dev == NULL)
    return -ENOMEM;
  platform_set_drvdata(pdev, dev);

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

  dev_info(&pdev->dev, "MPU9250 Gyroscope/Accelerometer/Magnetometer Sensor driver loaded!");

  return 0;
}

static int dev_remove(struct platform_device *pdev)
{
  struct data *dev = platform_get_drvdata(pdev);

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