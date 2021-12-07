#pragma once
typedef signed short fix88;	// 8.8 bit fixed point

//#define SDCC

// Less spew from SDCC and more debugging info for Visual Studio
#ifdef SDCC

#define enumRgb char
#define enumGhostNames char
#define enumGhostDrawStates char
#define enumGhostProcessingState char
#define enumMovePattern char
#define enumtargeting char
#define enumGhostHouseGoal char
#define enumActorState char
#define enumDir char
#define enumSounds char
#define enumFruits char
#define enumSprite char

#else

#define enumRgb enum rgb
#define enumGhostNames enum eGhostNames
#define enumGhostDrawStates enum ghostDrawStates
#define enumGhostProcessingState enum ghostProcessingState
#define enumMovePattern enum MovePattern
#define enumtargeting enum eTargeting
#define enumGhostHouseGoal enum eGhostHouseGoal
#define enumActorState enum eActorState 
#define enumDir enum eDir
#define enumSounds enum eSounds
#define enumFruits enum eFruits
#define enumSprite enum eSprite
#endif

// 8.8 bit fixed point
struct tagVector
{
	fix88	x;
	fix88	y;
	fix88	x_speed;	// Distance travelled in .01632 of a second
	fix88	y_speed;
};

struct tagXY
{
	signed char x;
	signed char y;
};

struct tagBlitTable
{
	char style;
	char width;
	char *data;
};

enum eDir
{
	D_UP, D_RIGHT, D_LEFT, D_DOWN, D_NONE
};

//	D_DOWN, D_LEFT, D_RIGHT,D_UP
#define REVERSED_DIR(x) (3-x)
#define DIR_TO_BIT(x) (1<<x)
#define ABS(x) ((x)<0?-(x):x)

extern struct tagXY DOTS[176];
extern unsigned short SETTIMER;
extern struct tagBlitTable ZEROP[1];
extern char RANTAB[4];
extern char requestedDir(void);
extern char MAZE[];

extern void XY(unsigned char x, unsigned char y); 
void leave(void);
extern void FRUITD(char f, char x, char y, char onoff);
extern void MAZER(void);
void memswap(void *s1, void *t1, int len);
signed char keyAvail(void);
void procConsole(void);
unsigned short getStack(void);



