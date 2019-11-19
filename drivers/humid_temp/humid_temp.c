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

#define HEX_NUM 6
#define PWM_BYTES 2
#define BUF_SIZE (HEX_NUM + PWM_BYTES)

#define MEM_OFFSET_VALUE (0x0)
#define MEM_OFFSET_BRIGHTNESS (0x4)
#define MEM_OFFSET_ENABLE (0x8)

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

  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

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
  int i = 0;
  struct humid_temp *dev = container_of(filep->private_data,
                                        struct humid_temp, misc);

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return -EINVAL;

  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  if (count > 0)
    count = count - copy_from_user(dev->buffer + *offp, buf, count);

  /* write char values */
  for (i = 0; i < HEX_NUM; i += 2)
  {
    /* combine two raw bytes into a single byte, which equals two dev digits */
    u8 hex = ((dev->buffer[i] - '0') << 4) | (dev->buffer[i + 1] - '0');
    iowrite8(hex, dev->regs + MEM_OFFSET_VALUE + (HEX_NUM - i - 1) / 2);
  }

  /* write brightness value */
  iowrite8(dev->buffer[6], dev->regs + MEM_OFFSET_BRIGHTNESS);

  /* write enable values */
  iowrite8(dev->buffer[7], dev->regs + MEM_OFFSET_ENABLE);

  *offp += count;
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
