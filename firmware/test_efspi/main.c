
#include "../soc.h"

#define CSR_GPOE_OFFSET   2

#define EF_RXDATA_OFFSET  0
#define EF_TXDATA_OFFSET  1
#define EF_CFG_OFFSET     2
#define EF_CNTRL_OFFSET   3
#define EF_PR_OFFSET      4
#define EF_STATUS_OFFSET  5
#define EF_GCLK_OFFSET    16324

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;
  GPO = 0;

  // Enable clock
  *(ADR_EF_SPI + EF_GCLK_OFFSET) = 0x1UL;

  // Setup SPI
  // CPHA 0, CPOL 0
  *(ADR_EF_SPI + EF_CFG_OFFSET) = 0x00UL;

  // Peripheral select, enable
  *(ADR_EF_SPI + EF_CNTRL_OFFSET) = 0x07UL;

  // Prescaler 10
  *(ADR_EF_SPI + EF_PR_OFFSET) = 10UL;

  // send
  *(ADR_EF_SPI + EF_TXDATA_OFFSET) = 0x1D;

  // cs high
  *(ADR_EF_SPI + EF_CNTRL_OFFSET) = 0x00UL;

  while(1)
  {
    *(ADR_EF_SPI + EF_TXDATA_OFFSET) = 0x1D;


    while (1)
    {
      uint32_t v = *(ADR_EF_SPI + EF_STATUS_OFFSET);
      if ((v & (1<<2)) == 0)
        break;
    }

    if ((*(ADR_EF_SPI + EF_RXDATA_OFFSET)&0xFFUL) == 0x1D)
      GPO = 1;
    else
      GPO = 2;


    while(1);
  }
}
