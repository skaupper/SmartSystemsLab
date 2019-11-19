/*
 * Terasic DE1-SoC Sensor Driver for HDC1000 Temperature/Humidity Sensor
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

#define DRIVER_NAME "humid_temp"

#define NUM_BYTE_DATA 4
#define NUM_BYTE_TIMESTAMP 8

#define BUF_SIZE (NUM_BYTE_DATA + NUM_BYTE_TIMESTAMP)

#define MEM_OFFSET_DATA (0x0)
#define MEM_OFFSET_TIMESTAMP_LOW (0x4)
#define MEM_OFFSET_TIMESTAMP_HIGH (0x8)

#define MEM_DATA_HUMID_MASK (0xFFFF0000)
#define MEM_DATA_TEMP_MASK (0xFFFF0000)

struct humid_temp
{
  void *regs;
  char buffer[BUF_SIZE];
  int size;
  struct miscdevice misc;
};

/*
 * @brief This function gets executed on fread.
 */
static int humid_temp_read(struct file *filep, char *buf, size_t count,
                           loff_t *offp)
{
  struct humid_temp *dev = container_of(filep->private_data,
                                        struct humid_temp, misc);
  unsigned int rdata;

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* read data from FPGA and store into kernel space buffer */
  rdata = ioread32(dev->regs + MEM_OFFSET_DATA);
  dev->buffer[0] = ((rdata & 0x000000FF) >> 0);
  dev->buffer[1] = ((rdata & 0x0000FF00) >> 8);
  dev->buffer[2] = ((rdata & 0x00FF0000) >> 16);
  dev->buffer[3] = ((rdata & 0xFF000000) >> 24);

  rdata = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_LOW);
  dev->buffer[4] = ((rdata & 0x000000FF) >> 0);
  dev->buffer[5] = ((rdata & 0x0000FF00) >> 8);
  dev->buffer[6] = ((rdata & 0x00FF0000) >> 16);
  dev->buffer[7] = ((rdata & 0xFF000000) >> 24);

  rdata = ioread32(dev->regs + MEM_OFFSET_TIMESTAMP_HIGH);
  dev->buffer[8] = ((rdata & 0x000000FF) >> 0);
  dev->buffer[9] = ((rdata & 0x0000FF00) >> 8);
  dev->buffer[10] = ((rdata & 0x00FF0000) >> 16);
  dev->buffer[11] = ((rdata & 0xFF000000) >> 24);

  /* copy data from kernel space buffer into user space */
  if (count > 0)
  {
    count = count - copy_to_user(buf, dev->buffer + *offp, count);
    *offp += count;
  }
  return count;
}

/*
 * @brief This function gets executed on fwrite.
 */
static int humid_temp_write(struct file *filep, const char *buf,
                            size_t count, loff_t *offp)
{
  struct humid_temp *dev = container_of(filep->private_data,
                                        struct humid_temp, misc);

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return -EINVAL;

  /* limit number of writeable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* copy data from user space into kernel space buffer */
  if (count > 0)
  {
    count = count - copy_from_user(dev->buffer + *offp, buf, count);
    *offp += count;
  }

  /*
   * There is probably nothing to write in this driver..
   * We might consider to remove the entire humid_temp_write() function.
   */

  return count;
}

static const struct file_operations humid_temp_fops = {
    .owner = THIS_MODULE,
    .read = humid_temp_read,
    .write = humid_temp_write};

static int dev_probe(struct platform_device *pdev)
{
  struct humid_temp *dev;
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
  dev->misc.fops = &humid_temp_fops;
  dev->misc.parent = &pdev->dev;
  retval = misc_register(&dev->misc);
  if (retval)
  {
    dev_err(&pdev->dev, "Register misc device failed!\n");
    return retval;
  }

  dev_info(&pdev->dev, "HDC1000 Humidity/Temperature driver loaded!");

  return 0;
}

static int dev_remove(struct platform_device *pdev)
{
  struct humid_temp *dev = platform_get_drvdata(pdev);

  misc_deregister(&dev->misc);
  platform_set_drvdata(pdev, NULL);

  return 0;
}

static const struct of_device_id humid_temp_of_match[] = {
    {
        .compatible = "goe,humid_temp-1.0",
    },
    {},
};
MODULE_DEVICE_TABLE(of, humid_temp_of_match);

static struct platform_driver humid_temp_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .of_match_table = of_match_ptr(humid_temp_of_match),
    },
    .probe = dev_probe,
    .remove = dev_remove,
};

module_platform_driver(humid_temp_driver);

MODULE_AUTHOR("M.Wurm");
MODULE_DESCRIPTION("Altera/Terasic HDC1000 Humidity/Temperature driver");
MODULE_LICENSE("GPL v2");
