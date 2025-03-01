/*
 * Copyright (c) 2017 Jean-Paul Etienne <fractalclone@gmail.com>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @file SoC configuration macros for the Beehive processor
 */

#ifndef __RISCV32_BEEHIVE_RISCV32_SOC_H_
#define __RISCV32_BEEHIVE_RISCV32_SOC_H_

#include <soc_common.h>

/* UART Configuration */
#define RISCV_BEEHIVE_UART_BASE      0x80000004

/* Timer configuration */
#define RISCV_MTIME_BASE             0x40000000
#define RISCV_MTIMECMP_BASE          0x40000008
#define BEEHIVE_MTIMECTRL_BASE       0x40000010

/* lib-c hooks required RAM defined variables */
#define RISCV_RAM_BASE               CONFIG_RISCV_RAM_BASE_ADDR
#define RISCV_RAM_SIZE               CONFIG_RISCV_RAM_SIZE

#endif /* __RISCV32_BEEHIVE_RISCV32_SOC_H_ */
