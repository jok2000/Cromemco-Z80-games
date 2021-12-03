#include <stdlib.h>
#include <string.h>
#include <stdio.h>


#include "data.h"
#include "dazzler.h"
#include "ghost.h"
#include "pacman.h"

struct tagTile tiles[13][11], playerTiles[13][11];

char peekPnum;
const char pacmanStates[13] = "budefghijklm";	// PNUM characters
const char pacmanDeathStates[9] = "bqrsp p ";   // PNUM characters
#define NUM_PACMAN_DEATH_STATES (sizeof(pacmanDeathStates)-1)
const struct tagXY dirCoord[4] = { {0,-1}, {1,0}, {-1,0}, {0,1} };

const char *dirNames[5] = { "D_UP", "D_RIGHT", "D_LEFT", "D_DOWN", "D_NONE" };

const struct tagElroy elroy[20][2] = 
{
	{{(unsigned char)(20 * DOT_RATIO), 80 * FULL_SPEED/100}, {(unsigned char)(10 * DOT_RATIO), 85 * FULL_SPEED/100} },
	{{(unsigned char)(30 * DOT_RATIO), 90 * FULL_SPEED / 100}, {(unsigned char)(15 * DOT_RATIO), 95 * FULL_SPEED / 100} },
	{{(unsigned char)(40 * DOT_RATIO), 90 * FULL_SPEED / 100}, {(unsigned char)(20 * DOT_RATIO), 95 * FULL_SPEED / 100} },
	{{(unsigned char)(40 * DOT_RATIO), 90 * FULL_SPEED / 100}, {(unsigned char)(20 * DOT_RATIO), 95 * FULL_SPEED / 100} },
	{{(unsigned char)(40 * DOT_RATIO), 90 * FULL_SPEED / 100}, {(unsigned char)(20 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(50 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(25 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(50 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(25 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(50 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(25 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(60 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(30 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(60 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(30 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(80 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(30 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(80 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(40 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(80 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(40 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(100 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(40 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(100 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(50 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(100 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(50 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(100 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(50 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(120 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(60 * DOT_RATIO), 105 * FULL_SPEED / 100} },
	{{(unsigned char)(120 * DOT_RATIO), 100 * FULL_SPEED / 100}, {(unsigned char)(60 * DOT_RATIO), 105 * FULL_SPEED / 100} },

};

unsigned char getElroy(void)
{
	char e;
	if (s.board > 19)
		e = 19;
	else
		e = s.board;
	int dotsLeft = NUM_DOTS + NUM_POWER_UPS - s.pacState.dotsEaten;
	if (dotsLeft <= elroy[e][1].dots)
		return elroy[e][1].speed;
	else if (dotsLeft <= elroy[e][0].dots)
		return elroy[e][0].speed;
	return 0;
}

const unsigned short targetingDuration[7][3] = {  // Alternates between scatter and chase, then always chase
	{ 7*60,		7 * 60,		5 * 60},	
	{20 * 60,	20 * 60,	20 * 60},
	{7 * 60,	7 * 60,		5 * 60},
	{20 * 60,	20 * 60,	20 * 60},
	{5 * 60,	5 * 60,		5 * 60},
	{20 * 60,	(unsigned short)1033 * 60,(unsigned short)1037 * 60},
	{5 * 60,	1,1}
};

char tileXtoIdxTab[128], tileYtoIdxTab[128];

unsigned short *epochTimers[] =
{
	&s.powerUpFlashIn, &s.pacState.newDrawStateIn, &s.fruit.disappearsIn,
	&s.demoEndsIn, &s.boardTime, &s.pacState.visibleIn, &s.pacState.deathStateIn, &s.flashMazeIn,
	&s.pacState.deathIn, &s.pacState.readyIn, &s.attractStateEndsIn, &s.ghostCoatIn, &s.gameOverIn,
	&s.ghostsFreeIn,
	&s.ghosts[0].notScaredIn, &s.ghosts[0].scaredFlashIn,
	&s.ghosts[1].notScaredIn, &s.ghosts[1].scaredFlashIn,
	&s.ghosts[2].notScaredIn, &s.ghosts[2].scaredFlashIn,
	&s.ghosts[3].notScaredIn, &s.ghosts[3].scaredFlashIn,
	&s.pacState.deathStateIn, &s.dotNotEatenTriggerIn
};
#define NUM_EPOCH_TIMERS sizeof(epochTimers)/sizeof(epochTimers[0])

const char actorSpeed[2][4][AS_MAX] = {
	{
		{(char)(0.8 * FULL_SPEED), (char)(.71 * FULL_SPEED), (char)(.9*FULL_SPEED), (char)(.79*FULL_SPEED)},
		{(char)(0.9 * FULL_SPEED), (char)(.79 * FULL_SPEED), (char)(.95*FULL_SPEED), (char)(.83*FULL_SPEED)},
		{(char)(FULL_SPEED), (char)(.87 * FULL_SPEED), (char)(FULL_SPEED), (char)(.87*FULL_SPEED)},
		{(char)(0.9 * FULL_SPEED), (char)(.79 * FULL_SPEED), 0, 0}
	},
	{
		{(char)(0.75 * FULL_SPEED), (char)(.4 * FULL_SPEED), (char)(.5*FULL_SPEED), 0},
		{(char)(0.85 * FULL_SPEED), (char)(.45 * FULL_SPEED), (char)(.55*FULL_SPEED), 0},
		{(char)(0.95 * FULL_SPEED), (char)(.5 * FULL_SPEED), (char)(.6*FULL_SPEED), 0},
		{(char)(0.95 * FULL_SPEED), (char)(.5 * FULL_SPEED), 0, 0}
	}
};

// Every 50 minutes, change the epoch.  This avoids the use of longs to track time.
void changeEpoch(void)
{
	unsigned short epoch = SETTIMER;
	char i;
	for (i = 0; i < NUM_EPOCH_TIMERS; i++)
	{
		if (*epochTimers[i])
			*epochTimers[i] -= epoch;
	}
	s.epochTimeIn = s.boardTime + 3000;
	SETTIMER = 0;
}

void setActorSpeeds(char actor, char state, char dir, char requestedDir, struct tagVector *vec)
{
	static struct
	{
		signed char x;
		signed char y;
	} newVec, speeds[4][4] = {
		{ {0,-1}, {1,-1}, {-1, -1}, {0,-1}},
		{ {1,-1}, {1,0}, {1, 0}, {1,1}},
		{ {-1,-1}, {-1,0}, {-1, 0}, {-1,1}},
		{ {0,1}, {1,1}, {-1, 1}, {0,1}}
	};

	fix88 speed;
	char idx;
	idx = (actor < PAC_DEMO);

	if (state == AS_EYES)
	{
		speed = 3 * FULL_SPEED;
	} 
	else {

		char levIdx = 0;
		if (s.board < 1)
			levIdx = 0;
		else if (s.board < 4)
			levIdx = 1;
		else if (s.board < 20)
			levIdx = 2;
		else
			levIdx = 3;
		speed = actorSpeed[actor][levIdx][state];
		if (state == AS_NORM && actor == BLINKY_RED)
		{
			char elroys = getElroy();
			if (elroys)
				speed = elroys;
		}
	}
	newVec = speeds[dir][requestedDir];

	// Could multiply here, but why?
	switch (newVec.x)
	{
	case -1:
		vec->x_speed = -speed;
		break;
	case 1:
		vec->x_speed = speed;
		break;
	case 0:
		vec->x_speed = 0;
		break;
	}

	switch (newVec.y)
	{
	case -1:
		vec->y_speed = -speed;
		break;
	case 1:
		vec->y_speed = speed;
		break;
	case 0:
		vec->y_speed = 0;
		break;
	}
}

unsigned short getTagetingDuration(void)
{
	if (s.targetingPhase > 6)
		return 0;
	if (s.board < 1)
		return targetingDuration[s.targetingPhase][0];
	if (s.board < 4)
		return targetingDuration[s.targetingPhase][1];
	
	return targetingDuration[s.targetingPhase][2];

}

enum eFruit setFruit[NUM_BONUS_STATES] =
{
	F_CHERRY, F_STRAWBERRY, F_LEMON, F_LEMON, F_APPLE, F_APPLE, F_CABBAGE, F_CABBAGE,
	F_GALAXIAN, F_GALAXIAN, F_BELL, F_BELL,  F_KEY
};

short fruitScore[F_NUM_FRUIT] =
{
		0x100, 0x300, 0x500, 0x700, 0x1000, 0x2000, 0x3000, 0x5000
};

struct tagGameState  s, lastGameState, saved[2];
char player, numPlayers;

void drawSetFruit(enum eFruit fruit, char pos, char onOff)
{
	char x, y;
	y = 120;
	x = 107 + 9 * pos;
	FRUITD(fruit, x, y, onOff);
}

void drawSetFruits(void)
{
	char i, x;
	char boardStart = s.board;

	CLEAR_FRUIT();
	x = 127 - 6;
	if (boardStart > 5)
		boardStart = s.board-5;
	if (boardStart > 11)
		boardStart = 11;
	for (i = boardStart; i < boardStart + 5 && i<=s.board; i++)
		FRUITD(FRUITS[i], x, 127 - 6, 1);
}

void drawBonusFruit(char onOff)
{
	char boardStart = s.board;

	if (boardStart > 11)
		boardStart = 11;

	// Compiler sorts out this mess at compile time
	FRUITD(FRUITS[boardStart], tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.x, tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.y, onOff);
}

fix88 fix88Mult(fix88 i, fix88 j)
{
	long r = (long)i * (long)j + 128;
	return (fix88)(r >> 16);
#if ASM
	__asm
		; ==================================================
			; MULTIPLY ROUTINE 32 * 32BIT = 32BIT
			; H'L'HL = B'C'BC * D'E'DE
			; NEEDS REGISTER A, CHANGES FLAGS
			;
	MUL32:
		AND     A; RESET CARRY FLAG
			SBC     HL, HL; LOWER RESULT = 0
			EXX
			SBC     HL, HL; HIGHER RESULT = 0
			LD      A, B; MPR IS AC'BC  '
			LD      B, 32; INITIALIZE LOOP COUNTER
			MUL32LOOP :
			SRA     A; RIGHT SHIFT MPR
			RR      C
			EXX
			RR      B
			RR      C; LOWEST BIT INTO CARRY
			JR      NC, MUL32NOADD
			ADD     HL, DE; RESULT += MPD
			EXX
			ADC     HL, DE
			EXX
			MUL32NOADD :
			SLA     E; LEFT SHIFT MPD
			RL      D
			EXX
			RL      E
			RL      D
			DJNZ    MUL32LOOP
			EXX

			; RESULT IN H'L'HL
			RET
	__endasm
#endif
}

char tileXtoIdx(char x)
{
	// 19 is the left edge of 0.  0-9 are in 0
	signed char rv = (x - 19) / 10;
	if (rv < 0 || rv>10)
		rv = 0;
	return rv;
}


char tileYtoIdx(char y)
{
	signed char rv;

	// 11 is the top edge of 0. 11 to 20 are in 0  
	if (y <= 51)
		rv = (y - 11) / 10;
	else if (y < 73)
		rv = (y - 51) / 11 + 4;
	else rv= (y - 73) / 10 + 6;
	if (rv < 0 || rv>12)
		rv = 0;
	return rv;
}

// Initialization
void setTileXYTab(void)
{
	unsigned char i;
	for (i = 0; i < 128; i++)
	{
		tileYtoIdxTab[i] = tileYtoIdx(i);
		tileXtoIdxTab[i] = tileXtoIdx(i);
	}
}

// Initialization
void drawDots(void)
{
	ONOFF = RGB_WHITE;
	struct tagXY *pos;
	for (pos = DOTS; pos->x != -1; pos++)
		XY(pos->x,pos->y);
}

// Initialization
void activateDots(void)
{
	static struct tagDot *d;
	static char dot;
	for (char x = 0; x < NUM_X_TILES; x++)
		for (char y = 0; y < NUM_Y_TILES; y++)
			for (d = &tiles[x][y].dots[dot], dot = 0; dot < MAX_DOTS_PER_TILE; dot++, ++d)
				if (d->pos.x)
					tiles[x][y].dots[dot].active = 1;
}

// Initialization
void drawActiveDots(void)
{
	static struct tagDot *d;
	static char dot;
	ONOFF = RGB_WHITE;
	for (char x = 0; x < NUM_X_TILES; x++)
		for (char y = 0; y < NUM_Y_TILES; y++)
			for (d = &tiles[x][y].dots[dot], dot = 0; dot < MAX_DOTS_PER_TILE; dot++, ++d)
				if (d->pos.x && d->active)
					XY(d->pos.x, d->pos.y);
}

// Initialization
void assignDotsToTiles(void)
{
	struct tagXY *pos;
	struct tagDot *d;
	char numDots;

	for (pos = DOTS; pos[0].x != -1; pos++)
	{
		numDots = 0;
		d = &tiles[tileXtoIdxTab[pos[0].x]][tileYtoIdxTab[pos[0].y]].dots[0];
		for (numDots = 0; numDots < MAX_DOTS_PER_TILE; numDots++,d++)
		{
			if (d->pos.y)
				continue;
			d->pos = *pos;
			break;
		}
	}
}



// Initialization
short square[132];
void initialize(void)
{
	short i;
	// Don't want to do all kinds of math 60 times per second.
	// Tested
	for (i = 0; i < sizeof(square) / sizeof(square[0]); i++)
		square[i] = i * i;

	initTiles();
	for (char j = 0; j < NUM_GHOSTS; j++)
		initialGhostPos[j] = tiles[initialGhostTile[j].x][initialGhostTile[j].y].pos;

	initialGhostPos[INKY_BLUE].x -= 2;
	initialGhostPos[INKY_BLUE].y -= 4;
	initialGhostPos[BLINKY_RED].x += 5;
	initialGhostPos[PINKY_PINK].x += 2;
	initialGhostPos[CLYDE_ORANGE].x += 4;
	initialGhostPos[CLYDE_ORANGE].y += 4;
	initialGhostPos[PAC_DEMO].x += 4;
}

void initTiles(void)
{
	char ix, iy, i;

	memset(tiles, 0, sizeof(tiles));
	setTileXYTab();
	char *maze = MAZE;

	for (iy = 0; iy<11;iy++)
	{
		for (i = 0, ix = 19; ix < 110; ix += 10, i++)
		{
			struct tagTile *t = &tiles[i][iy];
			t->pos.x = ix;
			t->pos.y = YTURN[iy]; // Centre of the tile
			t->prohibitedDir = D_NONE;
			t->walls = *maze++;
		}
	}

	// Tunnel
	tiles[0][5].isTunnel = 1;
	tiles[9][5].isTunnel = 1;
	tiles[0][5].ghostSlow = 1;
	tiles[9][5].ghostSlow = 1;
	
	// Ghost house
	tiles[5][5].ghostSlow = 1;
	tiles[4][5].ghostSlow = 1;
	tiles[5][5].isGhostHouse = 1;
	tiles[4][5].isGhostHouse = 1;

	// Pacman safe areas
	tiles[4][4].prohibitedDir = D_UP;
	tiles[5][4].prohibitedDir = D_UP;
	tiles[3][8].prohibitedDir = D_UP;
	tiles[6][8].prohibitedDir = D_UP;
}

void initGameState(void)
{
	printf("initGameState\n");
	memset(&s, 0, sizeof(s));
	memset(&s.score, '0', sizeof(s.score) - 1);
	s.score[sizeof(s.score) - 1] = 0;
	clearTimers();
	s.pacState.pacSpeed = FULL_SPEED;
	s.powerUpFlashIn = 0;
	s.lives = 4;
	initTiles();
	assignDotsToTiles();
	setInit(1);
	s.player = 2;
	memcpy(&saved[1], &s, sizeof(s));
	s.player = 1;
	memcpy(&saved[0], &s, sizeof(s));
	player = 1;
	memcpy(&lastGameState, &s, sizeof(s));
}

// Tested
void flashWhosUp(void)
{
	s.whosUpState ^= 1;
	s.whosUpIn = s.boardTime + 15;
	ONOFF = s.whosUpState ? RGB_WHITE : RGB_BLACK;
	PNUM(s.player + '0', 63 - 22, 0);
	MESOUT("UP\xff", 63 - 22 + 4, 0);
}

// Tested
void flashPowerUps(void)
{
	char i;
	s.powerUpFlashIn = s.boardTime + 7; // A bit less than 10x/s
	s.powerUpState ^= 1;

	ONOFF = s.powerUpState ? RGB_MAGENTA: RGB_BLACK;
	for (i = 0; i < 4; i++)
	{
		struct tagPowerUp *p;
		p = &s.powerUps[i];
		if (!p->suppressed && p->isActive)
			PNUM(CHAR_POWER_UP,p->pos.x-3, p->pos.y-2); // Adjust 
	}
}

// Handles tunnel
void drawPacman(struct tagPacState *p)
{
	if (p->deathState)
	{
		PNUM(pacmanDeathStates[p->deathState], p->pos8.x-3, p->pos8.y-3);
		return;
	}
	if (p->drawState == 0)
	{
		PNUM(CHAR_PACMAN_START, p->pos8.x-3, p->pos8.y-3);
		//if (p->pos.x<4)
		//	PNUM(CHAR_PACMAN_START, p->pos8.x+124-3, p->pos8.y-3);
	}
	else {
		if (p->drawState < 4)
		{
			PNUM(pacmanStates[(p->drawState - 1) + p->dir * 3], p->pos8.x-3, p->pos8.y - 3);
			//if (p->pos8.x < 4)
			//	PNUM(pacmanStates[(p->drawState - 1) + p->dir * 3], p->pos8.x+124 - 3, p->pos8.y - 3);
		}
		else {
			PNUM(pacmanStates[(5 - p->drawState) + p->dir * 3], p->pos8.x - 3, p->pos8.y - 3);
			//if (p->pos8.x < 4)
			//	PNUM(pacmanStates[(5 - p->drawState) + p->dir * 3], p->pos8.x+124 - 3, p->pos8.y - 3);
		}
	}
}

void pacmanDrawStateUpdate(struct tagPacState *p)
{
	if (p->stationary || p->pos.x_speed == 0 && p->pos.y_speed == 0)
	{
		p->drawState = 1;
	}
	else
	{
		if (p->newDrawStateIn <= s.boardTime)
		{
			p->newDrawStateIn = s.boardTime + 6; // 10x second
			p->drawState += 1;
			if (p->drawState == 9)
				p->drawState = 0;
		}
	}
}

void fruitUpdate(void)
{
	if (s.fruit.displayed >= 2)
		return;
	if (s.fruit.displayed==0 && s.pacState.dotsEaten>= ((unsigned char)70*DOT_RATIO) ||
		s.fruit.displayed==1 && s.pacState.dotsEaten >= ((unsigned char)170 * DOT_RATIO))
	{
		s.fruit.displayed++;
		s.fruit.visible = 1;
		s.fruit.disappearsIn = 9*60 + (RAND() &63) + s.boardTime;
		if (s.board >= NUM_BONUS_STATES)
			s.fruit.type = F_KEY;
		else
			s.fruit.type = setFruit[s.board];
		return;
	}
	if (s.fruit.disappearsIn && s.fruit.disappearsIn <= s.boardTime)
	{
		s.fruit.visible = 0;
		s.fruit.disappearsIn = 0;
	}
}

// Tested
struct tagXY powerUpTiles[4] = { {0,1}, {9,8}, {0,8}, {9,1 } };

void initPowerUps(void)
{
	char p;
	printf("initPowerUps\n");
	for (p = 0; p < 4; p++)
	{
		struct tagTile *t = &tiles[powerUpTiles[p].x][powerUpTiles[p].y];
		t->powerUp = &s.powerUps[p];
		s.powerUps[p].isActive = 1;
		s.powerUps[p].pos.x = t->pos.x;
		s.powerUps[p].pos.y = t->pos.y;
	}
}

void drawLives(void)
{
	struct tagPacState p;
	printf("drawLives\n");
	memset(&p, 0, sizeof(p));
	CLEAR_LIVES();
	int life;
	p.pos8.x = 3;
	p.pos8.y = 127 - 4;
	p.stationary = 1;
	p.dir = D_LEFT;
	p.drawState = 2;
	for (life = 0; life < s.lives; life++)
	{
		ONOFF = RGB_YELLOW;
		drawPacman(&p);
		p.pos8.x += 8;
	}
}


void setInit(char initTiles)
{
	static const char seed[4] = { 0x29, 0x98, 0xDA, 0x1B };
	printf("setInit\n");
	CLS();
	MAZER();
	readyMessage(0);

	if (initTiles)
	{
		drawDots();
		activateDots();
	} else{
		drawActiveDots();
	}
	drawLives();
	drawSetFruits();
	SETTIMER = 0;
	memcpy(RANTAB, &seed, sizeof(seed));
	updateScore();
	memset(&s.fruit, 0, sizeof(s.fruit));
	s.pacState.drawState = 0;
	s.pacState.dir = D_LEFT;
	s.pacState.stationary = 60;
	//	s.pacState.readyIn = 5 * 60; 
	s.pacState.readyIn = 1 * 60; // jok debug
	getTime(&s.boardTime, &s.longBoardTime);
	s.epochTimeIn = s.boardTime + 3000;
	s.pacState.pos.x = (s.pacState.pos8.x = initialGhostPos[PAC_DEMO].x)<<8;
	s.pacState.pos.y = (s.pacState.pos8.y = initialGhostPos[PAC_DEMO].y)<<8;
	s.pacState.pos.x_speed = s.pacState.pos.y_speed = 0;
	s.targetingChangesIn = getTagetingDuration();
	if (s.targetingChangesIn)
		s.targetingChangesIn += s.longBoardTime;
	s.targetingPhase = 0;
	initPowerUps();
	initGhosts();
	preComputeXY();
	ONOFF = RGB_YELLOW;
	s.whosUpIn = 60 * 3;
	memcpy(&lastGameState, &s, sizeof(s));
	memset(lastGameState.score, ' ', sizeof(lastGameState.score) - 1);
}

void setGhostSpeed(struct tagGhost *g)
{

	switch (g->dir)
	{
	case D_UP:
		g->speed.x = 0;
		g->speed.y = -g->currentSpeed;
		break;

	case D_DOWN:
		g->speed.x = 0;
		g->speed.y = g->currentSpeed;
		break;
	case D_LEFT:
		g->speed.x = -g->currentSpeed;
		g->speed.y = 0;
		break;
	case D_RIGHT:
		g->speed.x = g->currentSpeed;
		g->speed.y = 0;
		break;

	}
}

void switchTargeting(void)
{
	char i;
	if (s.targetingPhase > 6)
		return;
	if (s.targetingChangesIn > s.longBoardTime)
		return;
	s.targetingChangesIn = getTagetingDuration() + s.longBoardTime;
	s.targetingPhase++;

	struct tagGhost *g = &s.ghosts[0];
	for (i = 0; i < NUM_GHOSTS-1; i++, ++g)
	{
		switch (g->targetingState)
		{
		case T_CHASE:
		case T_SCATTER:
		case T_SCARED:
			g->dir = REVERSED_DIR(g->dir);
			setGhostSpeed(g);
			break;
		}
	}
}

// Tested
char numLen(unsigned short n)
{
	unsigned short mask = 0xf000;
	char i;
	signed char len = 0;
	unsigned short j;
	j = 0;
	for (i = 4; i >= 1; i--, mask >>= 4)
	{
		j = n & mask;
		if (j)
			break;
	}
	if (i == 0)
		len = 4;
	else
	{
		j >>= ((i - 1) << 2);
		len = j == 1 ? -2 : 0;
	}
	return len + (i << 2);
}

void drawNumber32(unsigned long n, char x, char y)
{
	unsigned short l, r;
	char len, lenl;
	l = n >> 16;
	r = n & 0xffff;
	len = (lenl=numLen(l)) + numLen(r);
	drawNumber16(l,(x - (len >> 1)), y, 0);
	drawNumber16(r, (x - (len >> 1)) + lenl, y, (l==0)?0:1);
}

void adjustGhostNumPosition(char len, char *x, char *y)
{
	*x -= (len >> 1);
	*y -= 3;
}

// Tested
void drawNumber16(unsigned short n, char x, char y, char leadingZero)
{
	char c;
	signed char i;
	unsigned short mask = 0xf000;
	char len = numLen(n);
	adjustGhostNumPosition(len, &x, &y);
	for (i = 3; i >= 0; i--)
	{
		c = '0' + (char)((n&mask) >> (i << 2));
		if (!(i && !leadingZero && c == '0'))
		{
			unsigned short xy;
			xy = PNUM(c, x, y);
			leadingZero = 1;
			x = xy >> 8;
		}
		mask >>= 4;
	}
}

// Animation is stopped during this repair, no chance of clock overrun.
void repairMazeNumber(unsigned short n, char x, char y)
{
	char len = numLen(n);
	char wallX, wallY;
	adjustGhostNumPosition(len, &x, &y);
	ONOFF = RGB_WHITE;
	char xt, yt, xl;
	static struct tagTile *t, *ghostTile;
	xt = tileXtoIdxTab[x];
	yt = tileYtoIdxTab[y];
	ghostTile = &tiles[xt][yt];
	for (char v = 0; v < 2; v++)
	{
		for (xl = xt, wallX = tiles[xt][yt].pos.x - 5; wallX < x + len; wallX += 10, ++xl)
		{
			t = &tiles[xl][yt + v];
			if (wallX >= x && t->walls & DIR_TO_BIT(D_LEFT))
				LINEV(wallX, y, 5);
			wallY = t->pos.y - 5;
			if (wallY >= y && wallY < y + 5 && t->walls & DIR_TO_BIT(D_UP))
				LINEH(t->pos.x - 5, t->pos.y - 5, 10);
			if (t->pos.x != ghostTile->pos.x || t->pos.y != ghostTile->pos.y)
				repairTile(t);
		}
	}
}

void killPacman(void)
{
	makeSound(S_DIE);
	s.lives--;
	s.pacState.deathIn = 120;
	s.pacState.deathStateIn = 24;
	s.pacState.deathState = 1;
	s.pacState.stationary = 60;
	s.pacState.invisible = 1;
	s.pacState.pos.x_speed = 0;
	s.pacState.pos.y_speed = 0;
	s.whosUpIn = 0;
	s.ghostProcState = GP_INVISIBLE_BLOCKED;
	s.leaveHouseDots = s.pacState.dotsEaten;
}

void checkEatDots(char requestedDir)
{
	char i;
	char eaten = 0;
	for (i = 0; i < MAX_DOTS_PER_TILE; i++)
	{
		static struct tagDot *d;
		d = &s.pacState.curTile->dots[i];
		if (!d->active || d->pos.y == 0)
			continue;
		if (s.pacState.pos8.x == d->pos.x && s.pacState.pos8.y == d->pos.y)
		{
			d->active = 0;
			s.pacState.dotsEaten++;
			eaten = 1;
			scoreInc(0x10);
			makeSound(S_EAT_DOT);
			s.pacState.stationary = 1;
			SET_DOT_EATEN;
			setActorSpeeds(PAC_DEMO, AS_NORM_DOTS, s.pacState.dir, requestedDir, &s.pacState.pos);
		}
	}

	if (eaten)
		setActorSpeeds(PAC_DEMO, AS_NORM, s.pacState.dir, requestedDir, &s.pacState.pos);
}

void movePacman(void)
{
	enum eDir requestedDir;

	if (s.pacState.deathState)
	{
		if (s.pacState.deathStateIn <= s.boardTime)
		{
			if (s.pacState.deathState < NUM_PACMAN_DEATH_STATES)
			{
				++s.pacState.deathState;
				s.pacState.deathStateIn = s.boardTime + 24;
			}
		}
		return;
	}

	if (s.pacState.stationary)
	{
		--s.pacState.stationary;
		return;
	}

	char i, g;
	static struct tagPowerUp *p;
	if (s.fruit.visible
		&& s.pacState.pos8.x == tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.x
		&& s.pacState.pos8.y == tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.y)
	{
		char fruitIdx = NUM_BONUS_STATES - 1;
		makeSound(S_EAT_FRUIT);
		if (s.board < NUM_BONUS_STATES)
			fruitIdx = s.board;
		s.fruit.visible = 0;
		scoreInc(fruitScore[setFruit[fruitIdx]]);
	}
	for (i = 0; i < 4; i++)
	{
		p = &s.powerUps[i];
		if (!p->isActive)
			continue;

		// Eat a power up
		if (s.pacState.pos8.x == p->pos.x && s.pacState.pos8.y == p->pos.y)
		{
			s.pacState.dotsEaten++;
			scoreInc(0x50);
			s.pacState.stationary = 3;
			SET_DOT_EATEN;
			p->isActive = 0;
			makeSound(S_POWER_UP);
			if (s.attractState)
			{
				s.pacState.dir = REVERSED_DIR(s.pacState.dir);
				s.pacState.pos.x_speed = -s.pacState.pos.x_speed;
				s.pacState.pos.y_speed = -s.pacState.pos.y_speed;
				s.ghosts[PAC_DEMO].target = s.ghosts[NUM_GHOSTS - 1].pos8;
			}
			static struct tagScaredParms scaredTime;
			scaredTime = *getScaredTime();
			static struct tagGhost *gp;
			gp = &s.ghosts[0]; 
			for (g = 0; g < NUM_GHOSTS - 1; g++, gp++)
			{
				if (s.board < 20)
				{
					s.pacState.frightened = NUM_GHOSTS - 1;
					gp->drawState = SCARED_BLUE;
					gp->notScaredIn = scaredTime.scaredTime;
					gp->scaredFlashIn = scaredTime.timeUntilFlash;
					gp->nextScaredFlashIn = scaredTime.flashTime;
				}
				gp->dir = REVERSED_DIR(gp->dir);
				if (gp->targetingState!= T_ATTRACT)
					gp->targetingState = T_SCARED;
			}
		}
	}

	if (s.isDemo)
	{
		memcpy(&s.pacState.pos, &s.ghosts[PAC_DEMO].pos, sizeof(s.pacState.pos));
		s.pacState.dir = s.ghosts[PAC_DEMO].dir;
		return;
	}

	if (s.pacState.curTile->pos.x == s.pacState.pos8.x && s.pacState.curTile->pos.y == s.pacState.pos8.y)
		s.pacState.dir = s.pacState.requestedDir;

	if ((char)ABS(s.pacState.curTile->pos.x - s.pacState.pos8.x)>=3 || (char)ABS(s.pacState.curTile->pos.y-s.pacState.pos8.y)>=3)
		requestedDir = s.pacState.requestedDir;
	else
		requestedDir = s.pacState.dir;

	checkEatDots(requestedDir);

	// Barriers
	if (s.pacState.pos8.x == s.pacState.curTile->pos.x)
	{
		switch (s.pacState.dir)
		{
		case D_LEFT:
			if (s.pacState.curTile->walls & DIR_TO_BIT(D_LEFT))
				s.pacState.pos.x_speed = 0;
			break;
		case D_RIGHT:
			if (s.pacState.curTile->walls & DIR_TO_BIT(D_RIGHT))
				s.pacState.pos.x_speed = 0;
			break;
		}
	}

	if (s.pacState.pos8.y == s.pacState.curTile->pos.y)
	{
		switch(s.pacState.dir)
		{
		case D_UP:
			if (s.pacState.curTile->walls & DIR_TO_BIT(D_UP))
				s.pacState.pos.y_speed = 0;
			break;
		case D_DOWN:
			if (s.pacState.curTile->walls & DIR_TO_BIT(D_DOWN))
				s.pacState.pos.y_speed = 0;
			break;
		}
	}
	MOVE_VECTOR(s.pacState.pos);
}

void preComputeXY(void)
{
	s.pacState.pos8.x = s.pacState.pos.x >> 8;
	s.pacState.pos8.y = s.pacState.pos.y >> 8;
	s.pacState.curTile = &tiles[tileXtoIdxTab[s.pacState.pos8.x]][tileYtoIdxTab[s.pacState.pos8.y]];
	struct tagGhost *g = &s.ghosts[0];
	for (char ghost = 0; ghost < NUM_GHOSTS; ghost++, g++)
	{
		g->pos8.x = g->pos.x >> 8;
		g->pos8.y = g->pos.y >> 8;
		g->curTile = &tiles[tileXtoIdxTab[g->pos8.x]][tileYtoIdxTab[g->pos8.y]];
		g->curTile->occupants = 0;
	}
}

char blinkyStr[] = { CHAR_GHOST_COAT,BLINKY_RED, 0xff };
char pinkyStr[] = { CHAR_GHOST_COAT, PINKY_PINK, 0xff };
char inkyStr[] = { CHAR_GHOST_COAT, INKY_BLUE, 0xff };
char clydeStr[] = { CHAR_GHOST_COAT, CLYDE_ORANGE, 0xff };

struct tagAttract attractMsgs[18] = {
	{120,RGB_WHITE, {64-8*4/2,64}, "GAME OVER\xff"},
	{60,RGB_CYAN, {0,0}, "\xff"},
	{60,RGB_WHITE, {64 - 6 * 5,15}, "CHARACTER / NICKNAME\xff" },
	{20,RGB_RED, {64 - 8 * 5, 25}, blinkyStr},
	{20,RGB_RED, {64 - 6 * 5, 25 - 3},"-SHADOW\xff"},
	{20,RGB_RED, {64 + 3 * 5, 25 - 3},  "\"BLINKY\"\xff"},
	{20,RGB_MAGENTA, {64 - 8 * 5, 35}, pinkyStr },
	{20,RGB_MAGENTA, {64 - 6 * 5, 35 - 3},"-SPEEDY\xff"},
	{20,RGB_MAGENTA, {64 + 3 * 5, 35 - 3},  "\"PINKY\"\xff"},
	{20,RGB_CYAN, {64 - 8 * 5, 45}, inkyStr},
	{20,RGB_CYAN, {64 - 6 * 5, 45 - 3},"-BASHFUL\xff"},
	{20,RGB_CYAN, {64 + 3 * 5, 45 - 3},  "\"INKY\"\xff"},
	{20,RGB_GREEN, {64 - 8 * 5, 55}, clydeStr},
	{20,RGB_GREEN, {64 - 6 * 5, 55 - 3},"-POKEY\xff"},
	{20,RGB_GREEN, {64 + 3 * 5, 55 - 3},  "\"CLYDE\"\xff"},
	{1,RGB_WHITE, {64 - 4 * 4, 85 - 3}, "@ 10 PTS\xff"},
	{60,RGB_WHITE, {64 - 4 * 4, 95 - 3}, "n  10 PTS\xff"},
	{1, RGB_MAGENTA, {64 - 9 * 5, 127 - 7}, "c 1982/2021 MDF & JOK\xff"}
};

void ghostMsgOut(struct tagAttract *a)
{
	if (*a->text == CHAR_GHOST_COAT)
	{
		s.ghosts[0].pos8.x = a->pos.x;
		s.ghosts[0].pos8.x = a->pos.x;
		s.ghosts[0].id = a->text[1];
		s.ghosts->drawState = NOT_SCARED;
		s.ghostCoatState = 0;
		drawGhost(&s.ghosts[0], 0);
	}
	ONOFF = a->color;
	MESOUT(a->text, a->pos.x, a->pos.y);
}

void clearTimers(void)
{
	SETTIMER = 0;
	LONGTIMER = 0;
}

static struct tagXY leftTarget = { 64 - 8 * 5, 65 };
void displayAttractState(void)
{
	char *t;
	static struct tagAttract *a;
	a = &attractMsgs[s.attractState];
	
	ONOFF = a->color;
	switch (s.attractState)
	{
	case 0:
		CLS();
		ONOFF = RGB_CYAN;
		DUMP(PRESENTEDBY);
		s.pacState.stationary = 1;
		s.ghostProcState = GP_INVISIBLE_BLOCKED;
		break;
	case ATTRACT_ANIMATION_STATE:
		s.powerUps[0].isActive = 1;
		s.powerUps[0].pos.x = 64 - 4 * 4 + 2;
		s.powerUps[0].pos.y = 85 - 3 + 2;
		s.powerUps[1].isActive = 0;
		s.powerUps[2].isActive = 0;
		s.powerUps[3].isActive = 0;
		s.pacState.dir = D_LEFT;
		s.pacState.pos.x = (64 + 3 * 5 + 10) << 8;
		s.pacState.pos.y = s.powerUps[0].pos.y << 8;
		s.pacState.stationary = 0;
		s.pacState.pacSpeed = FULL_SPEED;
		for (char g = 0; g < NUM_GHOSTS; g++)
		{
			s.ghosts[g].target = s.powerUps[0].pos;
			s.ghosts[g].currentSpeed = FULL_SPEED;
			s.ghosts[g].speed.x_speed = -FULL_SPEED;
			s.ghosts[g].speed.y_speed = 0;
			s.ghosts[g].pos.x = (64 + 3*5 + (g+1)*10) <<8;
			s.ghosts[g].pos.y = s.powerUps[0].pos.y << 8;
			s.ghosts[g].targetingState = T_ATTRACT;
		}
		s.ghostProcState = GP_ACTIVE;
		s.attractStateEndsIn = s.board + 20 * 60;
		preComputeXY();
		break;
	case 1:
		CLS();
		updateScore();
		ghostMsgOut(a);
		break;
	case NUM_ATTRACT_STATES - 2:
		s.powerUps[1].isActive = 1;
		s.powerUps[1].pos.x = 64 - 4 * 4 + 2;
		s.powerUps[1].pos.y = 85 - 3 + 2;
		ghostMsgOut(a);
		break;
	case NUM_ATTRACT_STATES:
		--s.attractState;
		s.ghostProcState = GP_INVISIBLE_BLOCKED;
		break;
	default:
		t = a->text;
		ghostMsgOut(a);
		break;
	}
	s.attractState++;
	s.attractStateEndsIn = a->duration + s.boardTime;
}

void setAttract(void)
{
	s.isDemo = 0;
	s.demoEndsIn = 0;
	s.attractStateEndsIn = 1 + s.boardTime;
	s.ghostProcState = GP_INVISIBLE_BLOCKED;
}

// input BCD
// output updated ASCII score
// tested
void scoreInc(unsigned short inc)
{
	char carry = 0;
	for (signed char i = sizeof(s.score) - 2; i >= 0 && (inc || carry); i--, inc>>=4)
	{
		s.score[i] += carry + (inc & 15);
		if (s.score[i] > '9')
		{
			s.score[i] -= 10;
			carry = 1;
			if (i == sizeof(s.score) - 2 - 4 && s.lives<5)
			{
				makeSound(S_BONUS_LIFE);
				s.lives++;
			}
		}
		else {
			carry = 0;
		}
	}
}


void updateScore()
{
	static char *pScore0 = &s.score[0];
	static char *pLastScore0 = lastGameState.score;

	if (memcmp(s.score, lastGameState.score, sizeof(s.score)-1)==0)
		return;

	char leadingZero = 0;
	char i;


	char x, y;
	if (s.player == 1)
	{
		x = SCORE1_X;
		y = SCORE1_Y;
	}
	else {
		x = SCORE2_X;
		y = SCORE2_Y;
	}
	// Get rid of different digits
	// Replacing them with the new digits
	for (i = 0; i < sizeof(s.score) - 1; i++, ++pScore0, ++pLastScore0)
	{
		if (i == sizeof(s.score) - 2 || *pScore0 != '0')
			leadingZero = 1;
		if (*pLastScore0 == *pScore0)
			continue;

		// Note blanking a blank with a blank 0 is harmless
		ONOFF = RGB_BLACK;
		PNUM(*pLastScore0, x + i * 4, y);
		ONOFF = RGB_WHITE;
		if (*pScore0 == '0' && !leadingZero)
			continue;
		PNUM(*pScore0, x + i * 4, y);
	}
}

void repairTile(struct tagTile *t)
{
	static struct tagDot *dp;
	char d;
	dp = &t->dots[0];
	for (d = 0; d < MAX_DOTS_PER_TILE; d++, ++dp)
	{
		if (dp->active)
		{
			ONOFF = RGB_WHITE;
			XY(dp->pos.x, dp->pos.y);
		}
	}
	if (t->powerUp && s.powerUpState)
	{
		ONOFF = RGB_WHITE;
		PNUM(CHAR_POWER_UP, t->pos.x, t->pos.y);
	}
	// Compiler should be able to resolve this at compile time
	if (s.fruit.visible && 
		t->pos.x == tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.x && t->pos.y == tiles[FRUIT_X_TILE][FRUIT_Y_TILE].pos.y)
		drawBonusFruit(1);
}

void repairGhostHouseDoor(void)
{
	ONOFF = RGB_MAGENTA;
	LINEH(GHOST_HOUSE_DOOR_X, GHOST_HOUSE_DOOR_Y, 7);
}

void updateSprites(void)
{
	signed char g, redrawPacman = 0;
	struct tagGhost *gp = &lastGameState.ghosts[0];
	for (g = 0; g < NUM_GHOSTS - 1; g++, gp++)
		gp->curTile->occupants++;
	lastGameState.pacState.curTile->occupants++;

	gp = &lastGameState.ghosts[0];
	struct tagGhost *cgp = &s.ghosts[0];
	for (g = 0; g < NUM_GHOSTS - 1; g++, gp++, cgp++)
	{
		if (gp->curTile->occupants > 1
			|| cgp->pos8.x != gp->pos8.x || cgp->pos8.y != gp->pos8.y
			|| s.ghostProcState == GP_INVISIBLE_BLOCKED && lastGameState.ghostProcState != GP_INVISIBLE_BLOCKED)
		{
			drawGhost(gp, 1);
			cgp->spriteErased = 1;
		}
		else {
			if (gp->curTile->powerUp)
				gp->curTile->powerUp->suppressed = 1;
		}
	}
	if (s.flashMazeState)
		return;

	if (lastGameState.lives != s.lives)
		drawLives();

	ONOFF = RGB_BLACK;
	if (lastGameState.pacState.curTile->occupants > 1
		|| lastGameState.pacState.pos8.x != s.pacState.pos8.x
		|| lastGameState.pacState.pos8.y != s.pacState.pos8.y)
	{
		redrawPacman = 1;
		drawPacman(&lastGameState.pacState);
	}
	if (s.powerUpFlashIn <= s.boardTime)
		flashPowerUps();

	if (s.whosUpIn <= s.boardTime)
		flashWhosUp();

	char needRepairGhostHouseDoor = 0;
	gp = &lastGameState.ghosts[0];
	for (g = 0; g < NUM_GHOSTS - 1; g++)
	{
		if (gp->spriteErased)
		{
			if (gp->houseTarget == GG_SEEK_FOYER || gp->houseTarget == GG_SEEK_FLOOR)
			{
				unsigned char dist = gp->pos8.y - GHOST_HOUSE_DOOR_Y;
				dist = ABS(dist);
				if (dist<=4)
					needRepairGhostHouseDoor = 1;
			}
			repairTile((gp++)->curTile);
		}
	}

	if (needRepairGhostHouseDoor)
		repairGhostHouseDoor();

	if (redrawPacman)
		repairTile(lastGameState.pacState.curTile);


	gp = &s.ghosts[0];
	for (g = NUM_GHOSTS - 1; g >= 0; g--)
		if (gp->spriteErased)
			gp->spriteErased = 0, drawGhost(gp++, 0);

	if (redrawPacman)
	{
		ONOFF = RGB_YELLOW;
		drawPacman(&s.pacState);
		if (s.pacState.curTile->powerUp)
			s.pacState.curTile->powerUp->suppressed = 1;
	}
}

void flashMaze(void)
{
	if (s.flashMazeState == 6)
	{
		DAZMOD3();
		s.flashMazeState = 0;
		s.flashMazeIn = 0;
		advanceSet();
		return;
	}
	if (s.flashMazeState & 1)
		DAZMODB();
	else
		DAZMOD3();
	s.flashMazeState++;
	s.flashMazeIn = 30 + s.boardTime;
}

void printGameState(void)
{
	static char board[NUM_Y_TILES][NUM_X_TILES+3];
	memset(&board, '.', sizeof(board));
	unsigned char x, y, g;
	for (y = 0; y < NUM_Y_TILES-1; y++)
		board[y][NUM_X_TILES + 2] = '\n';
	board[NUM_Y_TILES - 1][NUM_X_TILES + 2] = 0;
	x = tileXtoIdxTab[s.pacState.pos8.x];
	y = tileYtoIdxTab[s.pacState.pos8.y];
	board[y][x] = 'P';

	struct tagGhost *gp = &s.ghosts[0];
	for (g = 0; g < NUM_GHOSTS - 1; g++, gp++)
	{
		x = tileXtoIdxTab[gp->pos8.x];
		y = tileYtoIdxTab[gp->pos8.y];
		board[y][x] = ghostChar[gp->id];
	}
	printf("%s\n", (char *)&board[0][0]);
}

void advanceSet(void)
{
	s.board++;
	memcpy(&saved[s.player - 1], &s, sizeof(s));
	memswap(&playerTiles[0][0], tiles, sizeof(tiles));
	if (s.lives == 0)
		numPlayers--;
	if (numPlayers == 0)
	{
		s.attractState = 1;
		setAttract();
		return;
	}
	if (numPlayers == 2)
	{
		memcpy(&s, &saved[2 - s.player], sizeof(s));
		memswap(tiles, playerTiles, sizeof(tiles));
	}
	setInit(1);
}

void checkDeath(void)
{
	if (s.pacState.deathState == NUM_PACMAN_DEATH_STATES - 1)
	{
		s.lives--;
		advanceSet();
	}
}

void readyMessage(char erase)
{
	struct tagTile *t = &tiles[3][6];
	//makeSound(S_BEGIN_SET);
	ONOFF = erase ? RGB_BLACK : RGB_YELLOW;
	MESOUT("READYt\xff", t->pos.x + 3, t->pos.y - 2);

	t = &tiles[3][4];

	ONOFF = erase ? RGB_BLACK : RGB_CYAN;
	MESOUT(player == 1 ? "PLAYER ONE\xff" : "PLAYER TWO\xff", t->pos.x - 5, t->pos.y - 2);
	if (erase)
	{
		// Sprite simulation - repair maze
		if (player == 2)
		{
			ONOFF = RGB_BLUE;
			LINEV(t->pos.x + 35, t->pos.y - 2, 4);
		}
	}
}

char pacmanRequestedDir(void)
{
	char dir = requestedDir();  // Nybble with x in high nibble y in low nybble
	if (dir == 0)
		return 0;
	char xd = dir >> 4;
	char yd = dir & 15;
	if (xd == 0)
		return yd;
	if (yd == 0)
		return xd;

	if (xd == s.pacState.dir)
		return yd;
	if (yd == s.pacState.dir)
		return xd;

	if (xd == REVERSED_DIR(s.pacState.dir))
		return xd;

	return yd;

}

void gameLoop(void)
{
	static char reportedOverrun = 0;

	memcpy(&lastGameState, &s, sizeof(s));
	// Sync up the game to the next clock tick.
	do
	{
		getTime(&s.boardTime, &s.longBoardTime);
	} while (s.boardTime == lastGameState.boardTime);

	if (keyAvail())
		procConsole();
	struct tagPowerUp *p = &s.powerUps[0];
	for (char i = 0; i < 4; i++, ++p)
		p->suppressed = 0;

	if (reportedOverrun && s.pacState.stationary)
		reportedOverrun = 0;
	if (s.boardTime - lastGameState.boardTime > 1 && !reportedOverrun)
	{
		printf("gameLoop overran 1/60s time limit\n");
		reportedOverrun = 1;
	}
	if (s.epochTimeIn <= s.boardTime)
		changeEpoch();

	if (s.gameOverIn)
	{
		if (s.gameOverIn <= s.boardTime)
		{
			s.attractState = 1;
			setAttract();
			return;
		}
	}

	if (s.pacState.deathIn && s.pacState.deathIn <= s.boardTime)
	{
		memcpy(&saved[s.player - 1], &s, sizeof(s));
		if (numPlayers == 2)
		{
			player = 2 - player;
			memcpy(&s, &saved[player - 1], sizeof(s));
			memswap(tiles, &playerTiles[0][0], sizeof(tiles));
			setInit(0);
			return;
		}
		if (s.lives == 0)
		{
			setInit(1);
			s.gameOverIn = s.boardTime + 5 * 60;
			return;
		}
	}

	if (s.attractStateEndsIn)
	{
		if (s.attractStateEndsIn <= s.boardTime)
		{
			if (++s.attractState == NUM_ATTRACT_STATES)
			{
				numPlayers = 0;
				setInit(1);
				s.isDemo = 1;
				s.demoEndsIn = s.boardTime + 2 * 60 * 60;
				s.attractStateEndsIn = 0;
			}
			else {
				displayAttractState();
			}
		}
	}

	if (s.flashMazeState)
	{
		if (s.flashMazeIn <= s.boardTime)
			flashMaze();
		return;
	}
	else
	{
		if (s.pacState.dotsEaten == NUM_DOTS + NUM_POWER_UPS)

		{
			s.flashMazeState = 1;
			s.ghostProcState = GP_INVISIBLE_BLOCKED;
			flashMaze();
			updateSprites();
			s.pacState.stationary = 1;
			return;
		}
	}
	preComputeXY();
	if (s.ghostsFreeIn && s.ghostsFreeIn >= s.boardTime)
	{
		s.ghostsFreeIn = 0;
		s.ghostProcState = GP_ACTIVE;
	}
	if (s.pacState.ready)
	{
		if (s.isDemo && s.demoEndsIn < s.boardTime)
		{
			s.attractState = 2;
			setAttract();
			return;
		}
		s.pacState.requestedDir = pacmanRequestedDir();
		fruitUpdate();
		ghostStateUpdate();
		saveGhostPos();
		moveGhosts();
		movePacman();
		updateSprites();		// Sprite simulation, also needs lastGameState
		updateScore();			// Needs last game state.
		switchTargeting();		// This can reverse ghost direction
		checkDeath();
	}
	else {
		if (s.pacState.readyIn && s.pacState.readyIn <= s.boardTime)
		{
			s.pacState.readyIn = 0;
			readyMessage(1);
			s.pacState.ready = 1;
			s.pacState.stationary = 0;
			s.ghostProcState = GP_ACTIVE;
		}
	}
}