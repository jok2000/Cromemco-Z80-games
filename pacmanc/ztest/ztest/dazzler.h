#pragma once

enum rgb
{
	RGB_BLACK,
	RGB_RED,
	RGB_GREEN,
	RGB_YELLOW,
	RGB_BLUE,
	RGB_MAGENTA,
	RGB_CYAN,
	RGB_WHITE
};

extern unsigned short PNUM(char charVal, char x, char y);
extern void DAZMOD(void);
extern void DAZMOD3(void);
extern void DAZINIT(void);
extern enumRgb ONOFF; // Be careful to set SDCC when compiling for target (data size)
extern void PTEST3(void);
extern void PROFILE3(void);
extern void SETINTS(void);
extern void CLEARINTS(void);
extern void CROSS(void);
extern char RAND(void);
extern void getTime(unsigned short *s, unsigned long *l);
extern void setTime(unsigned short s, unsigned long l);
extern void clearTimers(void);
extern void CLS(void);