#pragma once

// Uncomment next line to use original games bugged targeting method
// #define ORIGINAL_TARGETING_BUG
#define NUM_X_TILES 10
#define NUM_Y_TILES 11
#define NUM_BONUS_STATES 13
#define FULL_SPEED 65

// Pacman's goal is NUM_DOTS + NUM_POWER_UPS
#define NUM_DOTS 174
#define NUM_POWER_UPS 4

#define SCORE1_X 0
#define SCORE1_Y 0
#define SCORE2_X (127-7*5)
#define SCORE2_Y 0

// (61, 70) -> fy= (y - 51) / 11 + 4, fx = x-14/10
#define FRUIT_X_TILE 4
#define FRUIT_Y_TILE 5

#define NUM_ATTRACT_MSGS (sizeof(attractMsgs)/sizeof(attractMsgs[0]))
#define NUM_ATTRACT_STATES (NUM_ATTRACT_MSGS+1)
#define ATTRACT_ANIMATION_STATE (NUM_ATTRACT_STATES-1)

#define MAX_DOTS_PER_TILE 3
#define DOT_RATIO .73

#define MOVE_VECTOR(p) \
	p.x += p.x_speed; \
	if (p.x <= 0) \
	{ \
		p.x -= p.x_speed; \
		if (p.x<64<<8) p.x+=p.x_speed + (0x7fff); \
	    else p.x+=p.x_speed - (0x7fff); \
	} \
	p.y += p.y_speed; \
	if (p.y<0) p.y=127<<8;

struct tagAttract {
	unsigned short duration;
	char	color;
	struct tagXY pos;
	char *text;
}; 

extern const struct tagElroy {
	unsigned char dots;
	unsigned char speed;
} elroy [20][2];

enum eSounds {
	S_EAT_DOT, S_DIE, S_GHOST_SCORED, S_BEGIN_SET, S_EAT_FRUIT, S_BONUS_LIFE, S_POWER_UP
};

enum eFruits
{
	F_CHERRY, F_STRAWBERRY, F_LEMON, F_APPLE, F_CABBAGE, F_GALAXIAN, F_BELL, F_KEY, F_NUM_FRUIT
};

enum eSprite
{
	CHAR_GHOST_COAT = ']',
	CHAR_GHOST_EYES,
	CHAR_GHOST_PUPILS,
	CHAR_SCARED_GRIMACE,
	CHAR_PACMAN_START,
	CHAR_POWER_UP = 'n',
	CHAR_GHOST_COAT2 = 'o',
	CHAR_BLOCK = 'v',
	CHAR_LINEH = 'w',
	CHAR_LINEV = 'x'
};

extern const char pacmanStates[13];

struct tagFruit
{
	unsigned short disappearsIn;
	short scored;
	enumFruits type;
	char visible;
	char displayed;
};

struct tagPacState
{
	enumGhostDrawStates drawState;
	char invisible;
	char ready;
	enumDir dir;
	int	dotsEaten;
	struct tagVector pos;
	struct tagXY pos8;
	struct tagTile *curTile;
	fix88 pacSpeed;
	char stationary;
	enumDir requestedDir;
	char frightened;
	char deathState;
	unsigned short newDrawStateIn;
	unsigned short deathIn;
	unsigned short deathStateIn;
	unsigned short readyIn;
	unsigned short visibleIn;
	short ghostScore;
};

struct tagDot {
	struct tagXY pos;
	char active;
};

struct tagTile
{
	struct tagDot dots[3];
	struct tagPowerUp *powerUp;
	struct tagXY pos;
	char walls;
	char prohibitedDir;
	char ghostSlow;
	char isTunnel;
	char isGhostHouse;
	char occupants;
};

struct tagPowerUp
{
	struct tagTile *tile;
	struct tagXY pos;
	char isActive;
	char suppressed;
};

extern struct tagGameState {
	struct tagGhost ghosts[NUM_GHOSTS];
	struct tagXY prevGhostPos[NUM_GHOSTS];
	struct tagPacState pacState;
	struct tagPowerUp powerUps[NUM_POWER_UPS];
	struct tagFruit fruit;	char score[8];
	unsigned long longBoardTime;
	unsigned long targetingChangesIn;
	int leaveHouseDots;
	unsigned short boardTime;
	unsigned short demoEndsIn;
	unsigned short powerUpFlashIn;
	unsigned short epochTimeIn;
	unsigned short whosUpIn;
	unsigned short attractStateEndsIn;
	unsigned short ghostCoatIn;
	unsigned short gameOverIn;
	unsigned short flashMazeIn;
	unsigned short ghostsFreeIn;
	unsigned short dotNotEatenTriggerIn;
	enumtargeting targetingPhase;
	enumGhostProcessingState ghostProcState;
	char player;
	char isDemo;
	char board;
	char powerUpState;
	char whosUpState;
	char ghostCoatState;
	char lives;
	char attractState;
	char flashMazeState;
} s, lastGameState, saved[2];

extern struct tagTile tiles[13][11];
extern short square[132];
extern char player, numPlayers;
extern struct tagAttract attractMsgs[18];
extern const struct tagXY dirCoord[4];
extern unsigned short SETTIMER;
extern unsigned long LONGTIMER;
extern char RANTAB[4];
extern char PRESENTEDBY[];
extern char YTURN[11];
extern char FRUITS[22];
extern char tileXtoIdxTab[128], tileYtoIdxTab[128];
extern enum eFruit setFruit[NUM_BONUS_STATES];
extern char peekPnum;
extern const char *dirNames[5];

extern char tileXtoIdx(char x);
extern char tileYtoIdx(char y);
extern void initGameState(void);
extern fix88 fix88Mult(fix88 i, fix88 j);
extern void drawSetFruit(enum eFruit fruit, char pos, char onOff), drawBonusFruit(char onOff);
extern void FRUITD(char fruit, char x, char y, char onOff), MAZER(void);
extern void DUMP(char *msg), CLEAR_FRUIT(void), CLEAR_LIVES(void), MESOUT(char *msg, char x, char y);
extern void XY(unsigned char x,unsigned char y), DAZMODB(void), DAZMOD3(void);
extern void LINEH(char x, char y, char len);
extern void makeSound(enum eSounds sound);
extern void killPacman(void);
extern void setActorSpeeds(char actor, char state, char dir, char requestedDir, struct tagVector *vec);
extern void setInit(char initTiles), gameLoop(void), updateScore(), initTiles(void), initialize(void), preComputeXY(void);
extern void scoreInc(unsigned short inc), advanceSet(void), setAttract(void), readyMessage(char erase);
extern void drawNumber32(unsigned long n, char x, char y);
extern void drawNumber16(unsigned short n, char x, char y, char leadingZero);
extern void drawPacman(struct tagPacState *p);
extern void LINEV(char x, char y, char w);
extern void repairMazeNumber(unsigned short n, char x, char y);
extern void repairTile(struct tagTile *t);