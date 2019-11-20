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

struct altera_sevenseg
{
  void *regs;
  char buffer[BUF_SIZE];
  int size;
  struct miscdevice misc;
};

/*
 * @brief This function gets executed on fread.
 */
static int sevenseg_read(struct file *filep, char *buf, size_t count,
                         loff_t *offp)
{
  struct altera_sevenseg *sevenseg = container_of(filep->private_data,
                                                  struct altera_sevenseg, misc);
  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return 0;

  /* limit number of readable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* copy data from kernel space buffer into user space */
  if (count > 0)
    count = count - copy_to_user(buf, sevenseg->buffer + *offp, count);

  *offp += count;
  return count;
}

/*
 * @brief This function gets executed on fwrite.
 */
static int sevenseg_write(struct file *filep, const char *buf,
                          size_t count, loff_t *offp)
{
  int i = 0;
  struct altera_sevenseg *sevenseg = container_of(filep->private_data,
                                                  struct altera_sevenseg, misc);

  /* check out of bound access */
  if ((*offp < 0) || (*offp >= BUF_SIZE))
    return -EINVAL;

  /* limit number of writeable bytes to maximum which is still possible */
  if ((*offp + count) > BUF_SIZE)
    count = BUF_SIZE - *offp;

  /* copy data from user space into kernel space buffer */
  if (count > 0)
    count = count - copy_from_user(sevenseg->buffer + *offp, buf, count);

  *offp += count;

  /* write char values */
  for (i = 0; i < HEX_NUM; i += 2)
  {
    /* combine two raw bytes into a single byte, which equals two sevenseg digits */
    u8 hex = ((sevenseg->buffer[i] - '0') << 4) | (sevenseg->buffer[i + 1] - '0');
    iowrite8(hex, sevenseg->regs + MEM_OFFSET_VALUE + (HEX_NUM - i - 1) / 2);
  }

  /* write brightness value */
  iowrite8(sevenseg->buffer[6], sevenseg->regs + MEM_OFFSET_BRIGHTNESS);

  /* write enable values */
  iowrite8(sevenseg->buffer[7], sevenseg->regs + MEM_OFFSET_ENABLE);

  return count;
}

static const struct file_operations sevenseg_fops = {
    .owner = THIS_MODULE,
    .read = sevenseg_read,
    .write = sevenseg_write};

static int sevenseg_probe(struct platform_device *pdev)
{
  struct altera_sevenseg *sevenseg;
  struct resource *io;
  int retval;

  sevenseg = devm_kzalloc(&pdev->dev, sizeof(*sevenseg), GFP_KERNEL);
  if (sevenseg == NULL)
    return -ENOMEM;
  platform_set_drvdata(pdev, sevenseg);

  io = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  sevenseg->regs = devm_ioremap_resource(&pdev->dev, io);
  if (IS_ERR(sevenseg->regs))
    return PTR_ERR(sevenseg->regs);

  sevenseg->size = io->end - io->start + 1;
  sevenseg->misc.name = DRIVER_NAME;
  sevenseg->misc.minor = MISC_DYNAMIC_MINOR;
  sevenseg->misc.fops = &sevenseg_fops;
  sevenseg->misc.parent = &pdev->dev;
  retval = misc_register(&sevenseg->misc);
  if (retval)
  {
    dev_err(&pdev->dev, "Register misc device failed!\n");
    return retval;
  }

  dev_info(&pdev->dev, "Sevensegment driver loaded!");

  return 0;
}

static int sevenseg_remove(struct platform_device *pdev)
{
  struct altera_sevenseg *sevenseg = platform_get_drvdata(pdev);

  misc_deregister(&sevenseg->misc);
  platform_set_drvdata(pdev, NULL);

  return 0;
}

static const struct of_device_id sevenseg_of_match[] = {
    {
        .compatible = "hof,sevensegment-1.0",
    },
    {},
};
MODULE_DEVICE_TABLE(of, sevenseg_of_match);

static struct platform_driver sevenseg_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .of_match_table = of_match_ptr(sevenseg_of_match),
    },
    .probe = sevenseg_probe,
    .remove = sevenseg_remove,
};

module_platform_driver(sevenseg_driver);

MODULE_AUTHOR("M.Wurm");
MODULE_DESCRIPTION("Altera/Terasic seven segment driver");
MODULE_LICENSE("GPL v2");
