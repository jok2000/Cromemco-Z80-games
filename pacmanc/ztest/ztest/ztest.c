#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "data.h"
#include "dazzler.h"
#include "ghost.h"
#include "pacman.h"

#define REP0 "generic report"
#define REP1 "Unset interrupt hit"

typedef void(*PTS)(void);
extern PTS intTable[128];

void reporter(int num);

char *report[] =
{
	REP0,
	REP1
};

void drawFruits(void)
{
	s.board = 0;
	drawBonusFruit(1);
	for (char i = 1; i < F_NUM_FRUIT; i++)
		drawSetFruit((enum eFruit)i, i - 1, 1);
}

char unsetHit;
void unsetInterrupt(void)
{
	if (unsetHit)
		return;
	unsetHit = 1;
	reporter(1);
}

void simGameLoop(void)
{
	printf("simGameLoop\n");
	setInit(1);
	s.demoEndsIn = 60 * 60; // 1 min 
	s.isDemo = 1;
	while (s.isDemo)
	{
		gameLoop();
	}
}

char numToHex(char c)
{
	c = c + '0';
	if (c > '9')
		c += 7;
	return c;
}

void numberedTiles(void)
{
	MAZER();
	char x, y;
	ONOFF = RGB_WHITE;
	for (x = 0; x < 10; x++)
	{
		for (y = 0; y < 11; y++)
		{
			PNUM(numToHex(x), tiles[x][y].pos.x - 3, tiles[x][y].pos.y - 5);
			PNUM(numToHex(y), tiles[x][y].pos.x + 3, tiles[x][y].pos.y);
		}
	}
}

void plotActors(void)
{
	drawGhosts();
	drawPacman(&s.pacState);
}

extern void dumpDazzler(void);

void init(void)
{
	unsetHit = 0;
	for (unsigned char i = 0; i < 128; i++)
	{
		intTable[i] = &unsetInterrupt;
	}
	SETINTS();
	CLS();
	DAZINIT();
	DAZMOD3();
	initialize();

	initGameState();
#if 0
	dumpDazzler();
	while (1)
	{
		gameLoop();
		switch (SETTIMER)
		{
		case 301:
			dumpDazzler();
			s.attractState = 2;
			setAttract();
			break;
		default:
			if (SETTIMER>301)
				if (s.attractState==0)
					dumpDazzler();
			break;
		}			
	}
#endif
}
extern int numDots(void);
void main(void)
{
	int c;
	init();
	reporter(1);
	while (1)
	{
		printf("%s",
			"\n"
			" 1. 1 Player Start           A. Plot Actors\n"
			" 2. 2 Player Start           F. Fruits\n"
			" 3. Profile PNUM3 workflow   N. Numbered Tiles\n"
			" 4. Game Clock               M. Maze\n"
			" 5. Clipping test            L. Demo\n"
			" 6. Erase player two         S. Clear\n"
			" 7. PNUM3 Test               T. Generic Test\n"
			" 8.                          J. JoyStick\n"
			" 0. Exit                     C. memswap test\n\n"
			"Console:\n"
			"^c: Exit                 mbrg: Ghost color for info\n"
			" f: Display bonus fruit\n"
		);
		while ((c = getchar()) < ' ');
		printf("Cmd: %c\n",c);
		switch (c)
		{
		case '0':
			leave();
			break;
		case '1':
			numPlayers = 1;
			initGameState();
			setInit(1);
			for (;s.lives;)
				gameLoop();
			break;
		case '2':
			numPlayers = 2;
			initGameState();
			setInit(1);
			for (;saved[0].lives && saved[1].lives;)
				gameLoop();
			break;
		case '4':
			printf("Set clock %d.  Game clock %ld\n", SETTIMER, LONGTIMER);
			break;
		case '6':
			readyMessage(1);
			player = 1;
			break;
		case '7':
			PTEST3();
			break;
		case '3':
			PROFILE3();
			break;
		case 'a':
			DAZMOD3();
			plotActors();
			break;
		case 'c':
			break;
		case 'j':
			printf("Requested Dir: 0x%x", (int)requestedDir());
			break;
		case 'f':
			DAZMOD3();
			setInit(1);
			drawFruits();
			break;
		case 'l':
			DAZMOD3();
			simGameLoop();
			break;
		case 'm':
			DAZMOD3();
			MAZER();
			break;
		case 'n':
			numberedTiles();
			break;
		case 's':
			CLS();
			break;
		case 't':

			//printf("# of DOTS = %d\n", numDots());
			break;
		}
	}
}

void reporter(int num)
{
	printf("%s\n", report[num]);
}

void procConsole(void)
{
	unsigned short setTimer;
	unsigned long longTimer;
	getTime(&setTimer, &longTimer);
	char c;
	signed char ghostId = -1;
	unsigned short stack;
	c = (char)getchar();
	switch (c)
	{
	case 'C' - '@':
		leave();
	case 'c':
		ghostId = 0;
		break;
	case 'g':
		ghostId = 1;
		break;
	case 'r':
		ghostId = 2;
		break;

	case 'm':
		ghostId = 3;
		break;
	case 'y':
		ghostId = 4;
		break;

	case 'f':
		s.fruit.displayed++;
		s.fruit.visible = 1;
		s.fruit.disappearsIn = 9 * 60 + (RAND() & 63) + s.boardTime;
		if (s.board >= NUM_BONUS_STATES)
			s.fruit.type = F_KEY;
		else
			s.fruit.type = setFruit[s.board];
		return;


	case 'h':
		printf("Machine on hold\n");
		break; // Hold
	case 'p':
		peekPnum = !peekPnum;
		break;
	case 's':
		stack = getStack();
		printf("Stack: %4.4x (%d)\n", stack, 0x5000 - stack);
		setTime(setTimer, longTimer);
		return;
	default:
		return;
	}
	if (ghostId != -1)
	{
		struct tagGhost *g = &s.ghosts[ghostId];
		struct tagVector v = g->pos;
		v.x_speed = ABS(g->pos.x_speed);
		v.y_speed = ABS(g->pos.y_speed);
		printf("Ghost %d (%d,%d) draw=%d target=(%d,%d)"
			//" vel = (%c%d.%3d,%c3d.%3.3d)"
			" curTile pos=(%d,%d) %s\n",
			(int)ghostId, (int)g->pos8.x, (int)g->pos8.y, g->drawState, g->target.x, g->target.y, 
			//(char)(g->pos.x_speed<0?'-':'+'),v.x_speed >> 8, ((v.x_speed & 0xff) * 1000)>>8,
			//(char)(g->pos.y_speed < 0 ? '-' : '+'), v.y_speed >> 8, ((v.y_speed & 0xff) * 1000) >> 8,
			g->curTile->pos.x, g->curTile->pos.y, ghostNames[ghostId]
		);
	}
	getchar();
	setTime(setTimer, longTimer);
}

