#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>

#include "data.h"
#include "dazzler.h"
#include "ghost.h"
#include "pacman.h"

typedef void(*PTS)(void); 

char FRUITS[] = { 0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 };
char dazzler[128][129];
char YTURN[11] = { 11, 21, 31, 41, 51, 62, 73, 83, 93, 103, 113 };

// Obsolete data.  Should be copied from paclib.asm when needed again
char MAZE[] = { 5, 9, 1, 9, 3, 5, 9, 1, 9, 3,
		6, 0, 6, 0, 6, 6, 0, 6, 0, 6,
		4, 9, 0, 1, 8, 8, 1, 0, 9, 2,
		12, 9, 2, 12, 3, 5, 10, 4, 9, 10,
		0, 0, 6, 5, 8, 8, 3, 6, 0, 0,
		9, 9, 0, 2, 0, 0, 4, 0, 9, 9,
		0, 0, 6, 4, 9, 9, 2, 6, 0, 0,
		5, 9, 0, 8, 3, 5, 8, 0, 9, 3,
		12, 3, 4, 1, 8, 8, 1, 2, 5, 10,
		5, 8, 10, 12, 3, 5, 10, 12, 8, 3,
		12, 9, 9, 9, 8, 8, 9, 9, 9, 10 };
char POSTAB[] = { -5, -5, 0, 5, -5, 1, -5, -5, 1, -5, 5, 0 }; // up right left down

char PRESENTEDBY[] =
{
	"\0x01*** PAC-MAN **\0xaa"
	"\0x07THE EXACT COP\xd9"
	"PRESENTED HER\0xc5"
	"BY JEFF KESNER AN\0xc4"
	"MATTHEW FRANCEY\0xff\0x01"
};

struct tagBlitTable ZEROP[1] = { {0,0,0} };
char *SC1P = NULL;

enumRgb ONOFF;
unsigned short SETTIMER;
unsigned long LONGTIMER;

struct tagXY DOTS[176] = {
	19, 11, 24, 11, 29, 11, 34, 11, 19, 16, 19, 26, 19, 31,
	24, 31, 29, 31, 34, 31, 19, 36, 19, 41, 24, 41, 29, 41,
	34, 41, 19, 83, 24, 83, 29, 83, 34, 83, 19, 88, 24, 93,
	29, 93, 29, 98, 19, 103, 24, 103, 29, 103, 34, 103,
	19, 108, 19, 113, 24, 113, 29, 113, 34, 113,
	//	FIRST	SECTION

	39, 11, 44, 11, 49, 11, 39, 16, 39, 21, 39, 26, 39, 31,
	44, 31, 49, 31, 39, 36, 39, 41, 39, 46, 39, 51, 39, 56,
	39, 62, 39, 68, 39, 73, 39, 78, 39, 83, 44, 83, 49, 83,
	39, 88, 39, 93, 44, 93, 49, 93, 39, 98, 49, 98, 39, 103,
	39, 113, 44, 113, 49, 113, 49, 36, 49, 41, 49, 103,
	//	SECOND	SECTION

	54, 11, 59, 11, 59, 16, 59, 21, 59, 26, 54, 31, 59, 31,
	54, 41, 59, 41, 59, 46, 54, 83, 59, 83, 59, 88, 54, 93,
	59, 93, 54, 103, 59, 103, 59, 108, 54, 113, 59, 113,
	69, 11, 69, 16, 69, 21, 69, 26, 69, 31, 69, 41, 69, 46,
	69, 83, 69, 88, 69, 93, 69, 103, 69, 108, 69, 113,
	64, 31, 64, 113,
	//	THIRD	SECTION

	74, 11, 79, 11, 84, 11, 89, 11, 89, 16, 89, 21, 89, 26,
	74, 31, 79, 31, 84, 31, 89, 31, 79, 36, 79, 41, 74, 41,
	89, 36, 89, 41, 89, 46, 89, 51, 89, 56, 89, 62, 89, 68,
	89, 73, 89, 78, 74, 83, 79, 83, 84, 83, 89, 83, 89, 88,
	74, 93, 79, 93, 84, 93, 89, 93, 79, 98, 89, 98, 74, 103,
	79, 103, 89, 103, 74, 113, 79, 113, 84, 113, 89, 113,
	//	FOURTH	TYPE

	94, 11, 99, 11, 104, 11, 109, 11, 109, 16, 109, 26,
	94, 31, 99, 31, 104, 31, 109, 31, 109, 36, 94, 41,
	99, 41, 104, 41, 109, 41, 94, 83, 99, 83, 104, 83,
	109, 83, 109, 88, 104, 93, 99, 93, 99, 98, 99, 103,
	94, 103, 104, 103, 109, 103, 94, 113, 99, 113,
	104, 113, 109, 113, 109, 108, -1, -1
	// FIFTH AND FINAL SECTION
};

#if 0
int numDots(void)
{
	return (sizeof(dotsSource) - 2) / 2;
}
#endif
char RANTAB[4];

void LINEH(char x, char y, char w)
{
	for (char i = x; i < x + w; i++)
		XY(i, y);
}

void LINEV(char x, char y, char w)
{
	for (char i = y; i < y+w; i++)
		XY(x, i);
}

void MAZER(void)
{
	char *m = &MAZE[0];
	char yi, x, y;
	ONOFF = RGB_BLUE;
	for (yi = 0; yi < 11; yi++)
	{
		y = YTURN[yi];
		for (x = 19; x < 110; x += 10, ++m)
		{
			for (char dir = 0; dir < 4; dir++)
			{
				char *p = &POSTAB[dir * 3];
				if (*m & DIR_TO_BIT(dir))
				{
					switch (p[2])
					{
					case 1:
						LINEV(x + p[0], y + p[1], y==113?9:11);
						break;
					default:
						LINEH(x + p[0], y + p[1], 11);
						break;
					}
				}
			}
		}
	}
}

void CLS(void)
{
	memset(&dazzler[0][0], ' ', sizeof(dazzler));
	for (int y = 0; y < 127; y++)
		dazzler[y][128] = '\n';
	dazzler[127][128] = 0;
	printf("%s", "Cleared screen\n");
}

void dumpDazzler(void)
{
	printf("%s\n", (char *)&dazzler[0][0]);
}

PTS intTable[128];

void DUMP(char *msg)
{
	printf("DUMP: %.10s...\n", msg);
}

void leave(void)
{
	CLEARINTS();
	exit(0);
}

void SETINTS(void)
{

}

void CLEARINTS(void)
{
}

void CLEAR_LIVES(void)
{

}

char RAND(void)
{
	return rand()&255;
}

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
			for (int i = 0; i < 3; i++)
				for (int j = 0; j < 4; j++)
					dazzler[y + j][x + i] = ONOFF ? c : ' ';
			break;
		}
	}

	return ((x + 4) << 8) + y;
}

void PTEST3(void)
{

}
void PROFILE3(void)
{

}

void DAZINIT(void)
{

}

void DAZMOD3(void)
{

}

void DAZMOD(void)
{

}

void DAZMODB(void)
{
	printf("Flashed the maze\n");
}

void CROSS(void)
{
	printf("Plotted a cross\n");
}

char *fruitNames[] = { "Cherry", "Strawberry", "Lemon", "Apple", "Cabbage", "Galazian", "Bell", "Key", "Oops!"};
void FRUITD(char fruit, char x, char y, char onOff)
{
	PNUM(fruitNames[fruit][0], x, y);
	printf("Drew fruit %s @ %d,%d onOff=%d\n", fruitNames[fruit], x, y, onOff);
}

void CLEAR_FRUIT(void)
{
	printf("Cleared fruit\n");
}

char requestedDir(void)
{
	return 1<<D_LEFT;
}

void getTime(unsigned short *st, unsigned long *l)
{
	SETTIMER++;
	LONGTIMER++;
	*st = SETTIMER;
	*l = LONGTIMER;
}

void setTime(unsigned short st, unsigned long l)
{

	SETTIMER = st;
	LONGTIMER = l;
}

void MESOUT(char *msg, char x, char y)
{
#if 0
	printf("%d,%d: %s @ %d o=%d\n", x, y, msg, SETTIMER, ONOFF);
#else
	while (*msg)
	{
		PNUM(*msg++, x, y);
		x += 5;
	}
#endif
}

void XY(unsigned char x, unsigned char y)
{
	if (y > 127 || x > 127)
		dazzler[0][0] = '?';
	dazzler[y][x] = '0'+(char)ONOFF;
}

void makeSound(enum eSounds sound)
{
#if ASM
	__asm
	LD	A, L
		OUT(#0X20), A
		__endasm

}
#else
	printf("Making sound %d\n", sound);
#endif
}

// sdcc makes a hash of this, but asmhooks.c has the assembler version
void memswap(void *s1, void *t1, int len)
{
	char *s2 = (char *)s1;
	char *t2 = (char *)t1;
	char a;
	while (len--)
	{
		a = *s2;
		*s2++ = *t2;
		*t2++ = a;
	}
}

signed char keyAvail(void)
{
	return (signed char)_kbhit();
}

unsigned short getStack(void)
{
	return 0;
}