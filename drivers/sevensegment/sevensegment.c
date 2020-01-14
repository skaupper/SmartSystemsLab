/*
 * Terasic DE1-SoC Seven segment driver
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

#define DRIVER_NAME "sevensegment"

#define HEX_NUM 6
#define PWM_BYTES 2
#define BUF_SIZE (HEX_NUM + PWM_BYTES)

#define MEM_OFFSET_VALUE (0x0)
#define MEM_OFFSET_BRIGHTNESS (0x4)
#define MEM_OFFSET_ENABLE (0x8)

typedef struct
{
  uint8_t hex_digit[HEX_NUM];
  uint8_t hex_brightness;
  uint8_t hex_enable;
} __attribute__((packed)) buffer_t;

struct data_t
{
  void *regs;
  buffer_t buffer;
  int size;
  struct miscdevice misc;
};

/*
 * @brief This function gets executed on fread.
 */
static int dev_read(struct file *filep, char *buf, size_t count, loff_t *offp)
{
  struct data_t *dev = container_of(filep->private_data,
                                    struct data_t, misc);
  if (BUF_SIZE != sizeof(dev->buffer))
  {
    printk(KERN_ERR "Data struct buffer_t is not allocated as expected.\n");
    return -ENOEXEC;
  }

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* copy data from kernel space buffer into user space */
  if (count > 0)
    count = count - copy_to_user(buf, (char *)&dev->buffer + *offp, count);

  *offp += count;
  return count;
}

/*
 * @brief This function gets executed on fwrite.
 * @details Digits to be displayed are expected in hexadecimal
 * format (i.e. 0x5->5; 0xA->A, 0xC->C, ...).
 */
static int dev_write(struct file *filep, const char *buf,
                     size_t count, loff_t *offp)
{
  int i = 0;
  u8 hex;
  struct data_t *dev = container_of(filep->private_data,
                                    struct data_t, misc);

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  /* limit number of writeable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* copy data from user space into kernel space buffer */
  if (count > 0)
    count = count - copy_from_user((char *)&dev->buffer + *offp, buf, count);

  *offp += count;

  /* write data to FPGA */
  for (i = 0; i < HEX_NUM; i += 2)
  {
    /* A HEX display can only represent digits from 0-F */
    if (dev->buffer.hex_digit[i] > 0xF || dev->buffer.hex_digit[i + 1] > 0xF)
      return -EINVAL;

    /* combine two raw bytes into a single byte, which equals two sevenseg digits */
    hex = ((dev->buffer.hex_digit[i]) << 4) | (dev->buffer.hex_digit[i + 1]);
    iowrite8(hex, dev->regs + MEM_OFFSET_VALUE + (HEX_NUM - i - 1) / 2);
  }
  iowrite8(dev->buffer.hex_brightness, dev->regs + MEM_OFFSET_BRIGHTNESS);
  iowrite8(dev->buffer.hex_enable, dev->regs + MEM_OFFSET_ENABLE);

  return count;
}

static const struct file_operations dev_fops = {
    .owner = THIS_MODULE,
    .read = dev_read,
    .write = dev_write};

static int dev_probe(struct platform_device *pdev)
{
  struct data_t *dev;
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

  dev_info(&pdev->dev, "Sevensegment driver loaded!");

  return 0;
}

static int dev_remove(struct platform_device *pdev)
{
  struct data_t *dev = platform_get_drvdata(pdev);

  misc_deregister(&dev->misc);
  platform_set_drvdata(pdev, NULL);

  return 0;
}

static const struct of_device_id dev_of_match[] = {
    {
        .compatible = "hof,sevensegment-1.0",
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
MODULE_DESCRIPTION("Altera/Terasic seven segment driver");
MODULE_LICENSE("GPL v2");
