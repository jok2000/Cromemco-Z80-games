#include <stdlib.h>
#include <stdio.h>

#include "ztest/ztest/dazzler.h"

extern void exit(void);
extern short SETTIMER;
extern long LONGTIMER;


unsigned short PNUM1(char c, char x, char y);

typedef void(*PTS)(void); 

PTS intTable[128];

// Tested
void getTime(unsigned short *shortTime, unsigned long *longTime)
{
   	__asm
		di
	__endasm;
	*shortTime = SETTIMER;
	*longTime = LONGTIMER;
	__asm
		ei
	__endasm;
}

unsigned short getStack(void)
{
	__asm
		ld	hl, #0
		add hl, sp
		ret
	__endasm;
}

signed char keyAvail()
{
	return (unsigned char)_kbhit();
}

void setTime(unsigned short shortTime, unsigned long longTime)
{
	__asm
	di
		__endasm;
	SETTIMER = shortTime;
	LONGTIMER = longTime;
	__asm
	ei
		__endasm;
}

char RAND(void)
{
	__asm
		call	RAND
		ld		l, a
		ret
	__endasm;
	return 1;
}

void makeSound(enum eSound sound)
{
	__asm
		LD	A, L
		OUT(#0X20), A
	__endasm;
	sound = sound;
}

void leave(void)
{
	exit();
}

extern char ONOFF;

// Tested
void FRUITD(char f, char x, char y, char onoff)
{
    __asm
		ld	hl, #5
		add hl, sp
		ld  a, (hl)
		dec hl
		ld  c, (hl)
		dec hl
		ld  b, (hl)
        dec hl
        ld e,(hl)
		jp DRAW_FRUIT
    
        __endasm;
        f=f;
        x=x;
        y=y;
        onoff=onoff;
}

static char dummyChar;
#if 1
unsigned short PNUM(char c, char x, char y)
{
	if (peekPnum)
	{
		switch (c)
		{
		case CHAR_GHOST_EYES:
		case CHAR_GHOST_PUPILS:
		case CHAR_SCARED_GRIMACE:
			break;
		default:
			printf("PNUM %c (%d,%d) o=%d @ t=%d\n", c, (int)x, (int)y, ONOFF, SETTIMER);
			break;
		}
	}
    return PNUM1(c,x,y);
}
#endif

// Tested
unsigned short PNUM1(char c, char x, char y)
{
    dummyChar = y;
	__asm
		ld	hl, #4
		add hl, sp
		ld  c, (iy)
		ld  b, -1(iy)
		ld  a, -2(iy)
        push ix
		call  PNUM3
        ld  l,c
        ld  h,b
        pop ix
		ret
		__endasm;
	// Compiler warnings
	c = c;
	x = x;
	y = y;
    return 0;
}

#if 0
extern void MESOUT1(char *msg, char x, char y);
void MESOUT(char *msg, char x, char y)
{
    if (*msg=='U')
    {
        printf("%s %d %d\n",msg,(int)x,(int)y);
    }
    MESOUT1(msg,x,y);
}
#endif

// Tested
void MESOUT(char *msg, char x, char y)
{
	__asm
		ld		hl,#5
		add		hl,sp
		ld		c,(hl)
		dec     hl
		ld		b,(hl)
		pop		de
		pop		hl
		push	hl
		push	de
		jp		MESOUT
		__endasm;
	// Compiler warnings
	msg = msg;
	x = x;
	y = y;
}

void LINEH(char x, char y, char w)
{
	__asm
		ld		hl, #4
		add		hl, sp
		ld      d,(hl)
		dec		hl
		ld		c, (hl)
		dec		hl
		ld		b, (hl)
		jp		LINEH
		__endasm;
	// Compiler warnings
	x = x;
	y = y;
	w = w;
}

void LINEV(char x, char y, char h)
{
	__asm
		ld		hl, #4
		add		hl, sp
		ld      d,(hl)
		dec		hl
		ld		c, (hl)
		dec		hl
		ld		b, (hl)
		jp		LINEV
		__endasm;
	// Compiler warnings
	x = x;
	y = y;
	h = h;
}

// Returns bit map of requested directions (max 2)
char requestedDir(void)
{
	__asm
	; Return the requested directions from the joystick in a nybble form x,y
		; Follows DIR_TO_BIT in C data.h
        JOYSTK .equ 32
        JS1_JOY_1X      .equ 0x19       ; right = +ve, left = -ve
        JS1_JOY_1Y      .equ 0x1a       ; up = +ve, down = -ve
        JS1_JOY_2X      .equ 0x1b
        JS1_JOY_2Y      .equ 0x1c
            LD  B,#0
			IN	A, (#JS1_JOY_1X)
			OR	A
			JP	M, 1$
			CP	#JOYSTK
			JR	C, YAXISJ
            LD B,#2<<4     ; up=1, right=2, left=3, down = 4
			JR  YAXISJ
        1$: CP #-JOYSTK
			JR	NC, YAXISJ
			LD B,#3<<4
		YAXISJ: IN	A, (#JS1_JOY_1Y)
			OR	A
			JP	M, 3$ ; M is down
			CP	#JOYSTK
			LD	A, #1
			JR  NC,2$
            XOR A
            JR 2$
		3$: CP #-JOYSTK
			LD	A, #4
			JR  C, 2$
			LD	A, #0
        2$: OR A,B
            LD  L,A
            LD  H,#0
			RET
		__endasm;
        return 1;
}

void XY(unsigned char x, unsigned char y)
{
	__asm
		ld		hl, #3
		add		hl, sp
		ld		c, (hl)
		dec		hl
		ld		b, (hl)
		jp		XY
		__endasm;
	// Compiler warnings
	x = x;
	y = y;
}

// Tested
void memswap(void *s1, void *t1, int len)
{
	__asm
		pop af
		pop de
		pop hl
		pop bc
		push bc
		push hl
		push de
		push af

		; bc = len, de = a destination, hl = a source
	1$:	ld a, (de)
		ldi
		dec hl
		ld (hl), a
		inc hl
		ret po
		jr 1$
		__endasm;
}