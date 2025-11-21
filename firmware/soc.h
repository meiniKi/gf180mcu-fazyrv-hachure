
#include "types.h"

#define ADR_ROM     ((volatile uint32_t*)(0x00000000))
#define ADR_SRAM    ((volatile uint32_t*)(0x10000000))
#define ADR_RAM     ((volatile uint32_t*)(0x20000000))
#define ADR_UART    ((volatile uint32_t*)(0x30000000))
#define ADR_SPI     ((volatile uint32_t*)(0x40000000))
#define ADR_CSR     ((volatile uint32_t*)(0x50000000))
#define ADR_EF_SPI  ((volatile uint32_t*)(0x60000000))
#define ADR_EF_XIP  ((volatile uint32_t*)(0x70000000))

#define GPI         (*(ADR_CSR))
#define GPO         (*(ADR_CSR+1UL))
#define GPEN        (*(ADR_CSR+2UL))
