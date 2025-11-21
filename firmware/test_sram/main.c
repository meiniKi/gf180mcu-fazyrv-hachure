
#include "../types.h"
#include "../soc.h"

#define ADR_SRAM ((volatile uint32_t*)(0x10000000))
#define ADR_RAM  ((volatile uint32_t*)(0x20000000))

#define CSR_GPOE_OFFSET 2

unsigned long pattern(unsigned long addr, unsigned long seed)
{
  unsigned long x = addr + seed;
  x ^= (x >> 13);
  x += (x << 7);
  x ^= (x >> 17);
  x += (x << 5);
  return x;
}

void main(void)
{
  // Set GPIO to ouput
  *(ADR_CSR + CSR_GPOE_OFFSET) = 0xFF;

  // Ensure this does not conflict with the stack!
  // Word offsets
  uint32_t offsets[] = {0, 211, 256, 511, 512, 1023, 1024}; //, 1701};
  unsigned int n_offsets = sizeof(offsets) / sizeof(offsets[0]);
  unsigned long seed;
  uint8_t result;
  uint8_t correct;

  GPO = 1;

  // --- write ---
  // off-chip ram
  seed = 42UL;
  for(unsigned int i = 0; i < n_offsets; ++i)
  {
    uint32_t off = offsets[i];
    volatile uint32_t *addr = ADR_SRAM + off;
    *addr = pattern((unsigned long)off, (unsigned long)seed);
  }

  // on-chip ram
  seed = 43UL;
  for(unsigned int i = 0; i < n_offsets; ++i)
  {
    uint32_t off = offsets[i];
    volatile uint32_t *addr = ADR_RAM + off;
    *addr = pattern((unsigned long)off, (unsigned long)seed);
  }

  GPO = 2;
  // --- verify ---
  result = 0;
  
  // off-chip ram
  correct = 1;
  seed = 42UL;
  for(unsigned int i = 0; i < n_offsets; ++i)
  {
    uint32_t off = offsets[i];
    volatile uint32_t *addr = ADR_SRAM + off;
    uint32_t expected = pattern((unsigned long)off, (unsigned long)seed);
    uint32_t actual   = *addr;
    if (expected != actual)
    {
      correct = 0;
      break;
    }
  }
  result |= (correct << 1);

  // on-chip ram
  correct = 1;
  seed = 43UL;
  for(unsigned int i = 0; i < n_offsets; ++i)
  {
    uint32_t off = offsets[i];
    volatile uint32_t *addr = ADR_RAM + off;
    uint32_t expected = pattern((unsigned long)off, (unsigned long)seed);
    uint32_t actual   = *addr;
    if (expected != actual)
    {
      correct = 0;
      break;
    }
  }
  result |= (correct << 2);

  result |= 0x01;

  // Write GPO
  GPO = 3;
  GPO = 7;
  GPO = 15;
  GPO = result;

  while(1);

  // excpeted at GPO:
  // GPO[0] ... 0 (stuck), 1 (done)
  // GPO[1] ... 0 (ADR_SRAM error), 1 (ADR_SRAM ok)
  // GPO[2] ... 0 (ADR_RAM error), 1 (ADR_RAM ok)
  // OK: GPO[2:0] == 0b111
}
