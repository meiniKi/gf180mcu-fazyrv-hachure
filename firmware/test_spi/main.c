
#include "../soc.h"

#define CSR_SPI_CONF_OFFSET 7
#define CSR_SPI_STAT_OFFSET 11
#define CSR_GPOE_OFFSET 2

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;
  GPO = 0;

  // Setup uSPI
  *(ADR_CSR + CSR_SPI_CONF_OFFSET) =
    (1 << 0) | // prescaler
    (0 << 4) | // cpo
    (1 << 5) | // auto cs
    (0 << 6);  // size

  while(1)
  {
    *(ADR_SPI) = 0x1D000000UL;

    while (1)
    {
      uint32_t v = *(ADR_CSR + CSR_SPI_STAT_OFFSET);
      if (v & (1<<2))
        break;
    }

    if ((*(ADR_SPI)&0xFFUL) == 0x1D)
      GPO = 1;
    else
      GPO = 2;

    while(1);
  }
}
