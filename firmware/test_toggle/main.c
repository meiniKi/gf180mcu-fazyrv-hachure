
#include "../soc.h"

#define CSR_GPOE_OFFSET 2

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;

  while(1)
  {
    GPO = 0xff;
    GPO = 0x00;
  }
}
