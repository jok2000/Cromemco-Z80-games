#pragma once

enum eGhostNames
{
	INKY_BLUE, CLYDE_ORANGE, BLINKY_RED, PINKY_PINK, PAC_DEMO
};

enum ghostDrawStates 
{
	SCARED_BLUE,
	SCARED_WHITE,
	NOT_SCARED,
	SCARED_EYES,
	GHOST_SCORED
};

enum ghostProcessingState
{
	GP_ACTIVE,
	GP_STATIONARY,
	GP_INVISIBLE_BLOCKED
};

enum MovePattern
{
	MOVE_SCATTER,
	MOVE_CHASE,
	MOVE_FRIGHTENED
};

enum eTargeting
{
	T_CHASE, T_SCARED, T_SCATTER, T_EYES, T_GHOST_HOUSE, T_ATTRACT
};

enum eGhostHouseGoal
{
	GG_NONE, GG_SEEK_CENTER, GG_SEEK_EXIT, GG_SEEK_FOYER, GG_SEEK_HOUSE, GG_SEEK_FLOOR, GG_SEEK_ROOF, GG_SEEK_HOME
};


// Max is number of items in array (index)
enum eActorState { AS_NORM, AS_NORM_DOTS, AS_FRIGHT, AS_FRIGHT_DOTS, AS_MAX, AS_EYES, AS_TUNNEL = AS_NORM_DOTS };

#define GHOST_HOUSE_DOOR_X (64-3)
#define GHOST_HOUSE_DOOR_Y 56
#define SET_DOT_EATEN s.dotNotEatenTriggerIn = s.boardTime + (s.board >= 4 ? 3 * 60 : 4 * 60)
#define MAX_GHOSTS_IN_HOUSE (sizeof(ghostHouseOrder) / sizeof(*ghostHouseOrder))

struct tagGhost
{
	enumGhostNames id;
	struct tagVector pos;
	struct tagXY pos8;
	struct tagTile *curTile;
	struct tagVector speed;
	short currentSpeed;
	enumDir dir;
	enumGhostDrawStates drawState;
	enumRgb color;
	struct tagXY target;
	unsigned short scaredFlashIn;		// For a timer
	unsigned short nextScaredFlashIn;
	unsigned short notScaredIn;			//
	unsigned short coatStateIn;
	enumtargeting targetingState;
	char lockedInHouse;
	enumGhostHouseGoal houseTarget;
	char spriteErased;
	char initSpeed;
	int leaveHouseDots;
	short scored;
};

struct tagEyePos
{
	struct tagXY pupils;
	struct tagXY eyes;
};

struct tagScaredParms
{
	unsigned short scaredTime;
	unsigned short timeUntilFlash;
	unsigned short flashTime;
};

#define NUM_GHOSTS 5

extern char ghostChar[NUM_GHOSTS+1];
extern char *ghostNames[NUM_GHOSTS];

extern const struct tagXY initialGhostTile[NUM_GHOSTS];
extern struct tagXY initialGhostPos[NUM_GHOSTS];
extern void initGhost(struct tagGhost *state);
extern void initGhosts(void);
extern void moveGhosts(void);
extern void ghostStateUpdate(void);
extern void drawGhost(struct tagGhost *ghost, char erase);
extern void drawGhosts(void);
extern struct tagScaredParms *getScaredTime(void);
extern void setNextGhostExit(void);
extern void checkLeaveHouse(void);
extern char getHouseDots(enumGhostNames id);
extern void saveGhostPos(void);