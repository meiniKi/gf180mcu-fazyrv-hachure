
#include "../types.h"
#include "../soc.h"

#define ADR_SRAM ((volatile uint32_t*)(0x10000000))
#define ADR_RAM  ((volatile uint32_t*)(0x20000000))

#define CSR_GPOE_OFFSET 2

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;
  GPO = 0;
  
  // SoC 2048 words -> 8192 bytes
  // Stack near top
  // test up to 7992 bytes = 1998 words

  // 1536 words -> 6144 bytes

  *(ADR_SRAM+10UL)   = 0xFF00FF00;
  *(ADR_SRAM+511UL)  = 0xA523AAAD;
  *(ADR_SRAM+512UL)  = 0xCAFECAFE;
  *(ADR_SRAM+1023UL) = 0x12345678;
  *(ADR_SRAM+1024UL) = 0x871A2192;
  //*(ADR_SRAM+1997UL) = 0xCCAAFFEE;
  //*(ADR_SRAM+1998UL) = 0xC1A2F3F4;

  *(ADR_RAM+10UL)    = 0x8127122D;
  *(ADR_RAM+511UL)   = 0x238913DE;
  *(ADR_RAM+512UL)   = 0xDEEDAADE;
  *(ADR_RAM+1023UL)  = 0x23723721;
  *(ADR_RAM+1024UL)  = 0xABCD1234;

  if (*(ADR_SRAM+10UL)   != 0xFF00FF00) { GPO = 4; goto done; };
  if (*(ADR_SRAM+511UL)  != 0xA523AAAD) { GPO = 4; goto done; };
  if (*(ADR_SRAM+512UL)  != 0xCAFECAFE) { GPO = 4; goto done; };
  if (*(ADR_SRAM+1023UL) != 0x12345678) { GPO = 4; goto done; };
  if (*(ADR_SRAM+1024UL) != 0x871A2192) { GPO = 4; goto done; };
  //if (*(ADR_SRAM+1997UL) != 0xCCAAFFEE) { GPO = 4; goto done; };
  //if (*(ADR_SRAM+1998UL) != 0xC1A2F3F4) { GPO = 4; goto done; };

  if (*(ADR_RAM+10UL)    != 0x8127122D) { GPO = 4; goto done; };
  if (*(ADR_RAM+511UL)   != 0x238913DE) { GPO = 4; goto done; };
  if (*(ADR_RAM+512UL)   != 0xDEEDAADE) { GPO = 4; goto done; };
  if (*(ADR_RAM+1023UL)  != 0x23723721) { GPO = 4; goto done; };
  if (*(ADR_RAM+1024UL)  != 0xABCD1234) { GPO = 4; goto done; };

  GPO = 5;

done:
  while (1);

}
