
#include "../types.h"
#include "../soc.h"

#define CSR_GPOE_OFFSET    2
#define CSR_GUARD_OFFSET  12

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;
  GPO = 0;
  
  // We need to activate the guard!
  *(ADR_CSR + CSR_GUARD_OFFSET) = 0x01;

  // We read values from start.S that we know

  if (*(ADR_EF_XIP+0UL)  != 0x00000013) { GPO = 4; goto done; };
  if (*(ADR_EF_XIP+10UL) != 0x00000013) { GPO = 4; goto done; };
  if (*(ADR_EF_XIP+28UL) != 0x00000093) { GPO = 4; goto done; };
  if (*(ADR_EF_XIP+36UL) != 0x00000493) { GPO = 4; goto done; };

  GPO = 5;

done:
  while (1);

}
