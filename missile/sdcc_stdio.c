//-----------------------------------------------------------------------------
// sdcc_stdio.c
//-----------------------------------------------------------------------------
// Copyright 2006 Silicon Laboratories, Inc.
// http://www.silabs.com
//
// Program Description:
//
// This set of functions includes putchar (), getchar (), and gets ()
// functionality for the SDCC compiler.
//
// FID:
// Target:         C8051F33x
// Tool chain:     Keil C51 7.50 / Keil EVAL C51
// Command Line:   None
//
//
// Release 1.0
//    -Initial Revision (BW)
//    -17 OCT 2006
//
//-----------------------------------------------------------------------------

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#include "sdcc_stdio.h"
#include <stdio.h>

//-----------------------------------------------------------------------------
// GETS
//-----------------------------------------------------------------------------
//
// Return Value : Pointer to string containing buffer read from UART.
// Parameters   : <buf> to store string; <len> maximum number of characters to
//                read; <len> must be 2 or greater.
//
// This function returns a string of maximum length <n>.
//-----------------------------------------------------------------------------
char * GETS (char *buf, int len)
{
   unsigned char temp;
   unsigned char i;
   unsigned char done;

   done = FALSE;
   i = 0;

   while (done == FALSE)
   {
      temp = getchar ();

      if (temp == '\b')
      {
         if (i != 0)                   // backspace if possible
         {
            i = i - 1;
            putchar ('\b');
         }
      }
      else
      if (temp == '\r')                // handle newline
      {
         buf[i] = '\0';                // add null terminator to string
         done = TRUE;
      }
      else
      if (temp == '\0')                // handle EOF
      {
         buf[i] = '\0';                // add null terminator to string
      }
      else                             // handle new character
      {
         buf[i] = temp;
         putchar (temp);               // echo character
         i = i + 1;
         if (i == (len-1))
         {
            buf[i] = '\0';
            done = TRUE;
          }
       }
   }

   return buf;

}

//-----------------------------------------------------------------------------
// putchar
//-----------------------------------------------------------------------------
//
// Return Value : None
// Parameters   : character to send to UART
//
// This function outputs a character to the UART.
//-----------------------------------------------------------------------------
int putchar (int c)
{
__asm
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	cp  a, #0x0a
	jr	NZ,.+8

	ld	a,#13
	out	(1),a
	ld	a,#10

	out	(1),a
__endasm;
    return 0;
}

//-----------------------------------------------------------------------------
// getchar
//-----------------------------------------------------------------------------
//
// Return Value : character received from UART
// Parameters   : None
//
// This function returns a character from the UART.
//-----------------------------------------------------------------------------
int getchar(void)
{
    __asm
        IN	A,(0)
        AND	A,#0x40
        jr	z,.-4
        in	a,(1)
        ld   l,a
        ld	h, #0x00
        ret
    __endasm;

}

//-----------------------------------------------------------------------------
// End Of File
//-----------------------------------------------------------------------------