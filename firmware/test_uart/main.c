
// Adapted from:
// https://github.com/mole99/greyhound-ihp/blob/main/firmware/access_peripheral/access_peripheral.c

#include "../types.h"
#include "../soc.h"

#include "EF_UART.h"

// Sim is running at 100 MHz
// change for actual device
#define F_CPU 100000000
#define BAUDRATE 115200

#define UART0_BASE ((uint32_t)(ADR_UART))

void main(void)
{
  EF_UART_setGclkEnable(UART0_BASE, 1);
  EF_UART_enable(UART0_BASE);
  EF_UART_enableRx(UART0_BASE);
  EF_UART_enableTx(UART0_BASE);
  EF_UART_disableLoopBack(UART0_BASE);
  EF_UART_disableGlitchFilter(UART0_BASE);

  EF_UART_setDataSize(UART0_BASE, 8);
  EF_UART_setTwoStopBitsSelect(UART0_BASE, 0);
  EF_UART_setParityType(UART0_BASE, NONE);
  EF_UART_setTimeoutBits(UART0_BASE, 0);
  // baudrate = clock_f / ((PR+1)*8)
  EF_UART_setPrescaler(UART0_BASE, F_CPU/(BAUDRATE*8)-1);

  while(1)
  {
    EF_UART_writeChar(UART0_BASE, EF_UART_readChar(UART0_BASE));
  }
 
}
