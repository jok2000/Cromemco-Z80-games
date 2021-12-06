#include <string.h>
#include <stdio.h>

#include "data.h"
#include "ghost.h"
#include "pacman.h"
#include "dazzler.h"

const struct tagXY homeTargets[NUM_GHOSTS] = { {127,0},{0,0},{0,127},{127,127} };
const struct tagXY initialGhostTile[NUM_GHOSTS] = { {4,5},  {5,5}, {4,4}, {4,5}, {4,8} };
struct tagXY initialGhostPos[NUM_GHOSTS];


char scaredTime[] = { 6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1 };
char numScaredFlashes[] = { 5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3 };
const char ghostCoats[2] = { CHAR_GHOST_COAT, CHAR_GHOST_COAT2 };
const enumGhostNames ghostHouseOrder[3] = { PINKY_PINK, INKY_BLUE, CLYDE_ORANGE };

enum rgb ghostColors[NUM_GHOSTS] =
{
	RGB_CYAN, RGB_GREEN, RGB_RED, RGB_MAGENTA
};
char ghostChar[NUM_GHOSTS+1] = "CGRMY";
char *ghostNames[NUM_GHOSTS] = {"INKY", "CLYDE", "BLINKY", "PINKY", "PACDEMO"};

const static struct tagEyePos eyePositions[NUM_GHOSTS] =
{
	// Pupil    Eyes
	{ {-2,-2},{-3,-2}}, // UP
	{ {-1,-1}, { -2,-2 } }, // RIGHT
	{ {-4,-1},{ -4,-2 } }, // LEFT
	{ {-3,0},{ -3,-1 } } // DOWN
};

//
//            FOYER
//  +-----------+------------+
//  + ROOF    EX+IT  ROOF    +
//  +           + <- CENTER  +
//  +           +            +
//  +         FL+OOR         +
//  +------------------------+
void ghostHouseTargeting(struct tagGhost *g)
{
	switch (g->houseTarget)
	{
	case GG_SEEK_CENTER: // Move to the center horizontally
		if (g->pos8.x == tiles[5][5].pos.x + 4)
		{
			g->houseTarget = GG_SEEK_EXIT;
			g->target.y = tiles[5][5].pos.y - 4;
		}
		else
			g->target.x = tiles[5][5].pos.x + 4;
		break;
	case GG_SEEK_EXIT: // Separate from SEEK_FOYER for sprite door repair flagging.
		if (g->pos8.y == g->target.y)
		{
			g->houseTarget = GG_SEEK_FOYER;
			g->target.y = tiles[4][4].pos.y;
		}
		else {
			g->target.y = tiles[4][4].pos.y;
		}
		break;
	case GG_SEEK_FOYER: // Leaving ghost house by going straight up.
		if (g->pos8.y == g->target.y)
		{
			g->targetingState = T_SCATTER;
			g->houseTarget = GG_NONE;
			g->lockedInHouse = 0;
			setNextGhostExit();
		}
		break;
	case GG_SEEK_HOUSE:	// Eyes seeking the house
		if (g->pos8.x = tiles[5][5].pos.x + 4 && g->pos8.y == tiles[5][5].pos.y)
		{
			g->target.y += 14;
			g->houseTarget = GG_SEEK_FLOOR;
		}
		break;
	case GG_SEEK_FLOOR:
		if (g->pos8.y == g->target.y)
		{
			g->drawState = NOT_SCARED;
			if (g->id == BLINKY_RED)
			{
				g->houseTarget = GG_SEEK_FOYER;
				g->target.y = tiles[4][4].pos.y;
			}
			else {
				g->target.x = initialGhostPos[g->id].x;
				g->houseTarget = GG_SEEK_HOME;
			}
		}
		break;
	case GG_SEEK_HOME:
		if (g->pos8.y == g->target.y && g->pos8.x == g->target.x)
		{
			g->lockedInHouse = 1;
			g->houseTarget = GG_SEEK_ROOF;
			g->target.y = tiles[5][5].pos.y - 4;
		}
	case GG_SEEK_ROOF:
		if (g->pos8.y == g->target.y && g->pos8.x == g->target.x)
		{
			g->target.y = tiles[5][5].pos.y - 4;
			g->houseTarget = GG_SEEK_FLOOR;
		}
		break;
	}
}

void ghostStateUpdate(void)
{
	char i, ix=0, iy=0, bx, by;
	static int dist, distx, disty;
	static struct tagXY scatterTargets[4] = { {10,11}, {0,123}, {110,0}, {110,123} };
#ifdef ORIGINAL_TARGETING_BUG
	static const struct tagXY twoVec[4] = { {-2,-2}, {-2,0}, {2,0}, {0,2} };
	static const struct tagXY fourVec[4] = { {-4,-4}, {-4,0}, {4,0}, {0,4} }; // Includes overflow bug from original game
#else
	static const struct tagXY twoVec[4] = { {0,-2}, {-2,0}, {2,0}, {0,2} };
	static const struct tagXY fourVec[4] = { {0,-4}, {-4,0}, {4,0}, {0,4} };
#endif
	enumDir dir;
	enumGhostNames ghost;
	char rand;
	char numDirs;
	char ghostMoved = 0;
	static enumDir permittedDirs[4];
	static struct tagXY delta;

	if (s.pacState.dotsEaten == NUM_DOTS + NUM_POWER_UPS)
		return;

	if (s.ghostCoatIn <= s.boardTime)
	{
		s.ghostCoatState = !s.ghostCoatState;
		s.ghostCoatIn = s.boardTime + 20;
	}

	static struct tagGhost *g;
	g = &s.ghosts[0];
	for (ghost = 0; ghost < NUM_GHOSTS; ghost++, g++)
	{
		numDirs = 0;

		switch (g->drawState)
		{
		case SCARED_WHITE:
			if (g->scaredFlashIn <= s.boardTime)
			{
				g->drawState = SCARED_BLUE;
				g->scaredFlashIn = s.boardTime + g->nextScaredFlashIn; // 3x a second
			}
			if (g->notScaredIn <= s.boardTime)
			{
				g->drawState = NOT_SCARED;
				s.pacState.frightened--;
			}
			break;
		case SCARED_BLUE:
			if (g->scaredFlashIn <= s.boardTime)
			{
				g->drawState = SCARED_WHITE;
				g->scaredFlashIn = s.boardTime + g->nextScaredFlashIn; // 3x a second
			}
			if (g->notScaredIn <= s.boardTime)
			{
				g->drawState = NOT_SCARED;
				s.pacState.frightened--;
			}
		case SCARED_EYES:
			if (g->target.x == g->pos8.x && g->target.y == g->pos8.y)
			{
				g->drawState = NOT_SCARED;
				s.pacState.frightened--;
				g->lockedInHouse = 1;
				ghostHouseTargeting(g);
				continue;
			}
			break;
		}

		if (g->id == BLINKY_RED && g->pos8.x < 90)
		{
			printf("JOK-BLINKY %d %d, %d %d, %d %d, tile=%d %d\n",
				s.prevGhostPos[ghost].x, s.prevGhostPos[ghost].y, g->pos8.x, g->pos8.y, g->curTile->pos.x, g->curTile->pos.y,
				tileXtoIdxTab[g->pos8.x], tileYtoIdxTab[g->pos8.y]);
		}
		// Targeting only needed when a ghost moves somewhere new.
		if (s.prevGhostPos[ghost].x == g->pos8.x && s.prevGhostPos[ghost].y == g->pos8.y)
			continue;

		ghostMoved = 1;
		// Not on point, but house ghosts are never on point.
		if ((g->curTile->pos.x != g->pos8.x || g->curTile->pos.y != g->pos8.y) && !g->lockedInHouse)
		{
				continue;
		}
		else {
			// A house ghost rising to on-point of a tile.
			if (g->lockedInHouse && g->curTile->prohibitedDir != D_NONE)
				continue;
		}

		if (g->id == BLINKY_RED)
		{
			int q = 1;
		}
		for (dir = 0; dir < 4; dir++)
		{
			if (g->targetingState != T_GHOST_HOUSE)
			{
				if (g->curTile->walls & DIR_TO_BIT(dir))
					continue;
				if (ghost != PAC_DEMO)
				{
					if (g->dir == REVERSED_DIR(dir))	// Not allowed to double back
						continue;
					if (g->drawState != SCARED_EYES && g->curTile->prohibitedDir == dir)
						continue;
				}
			}
			permittedDirs[numDirs++] = dir;
		}

		static struct tagGhost *gp, *closestGhost;
		static short closestDist;
		static short cdist;
		closestDist = 0x7fff;
		switch (g->targetingState)
		{
		case T_GHOST_HOUSE:
			ghostHouseTargeting(g);
			break;
		case T_ATTRACT:
			numDirs = 1;
			permittedDirs[0] = g->dir;
			break;
		case T_SCATTER:
			g->target = scatterTargets[ghost];
			break;
		case T_SCARED:
			if (numDirs == 1)
				g->dir = permittedDirs[0];
			else {
				rand = RAND();
				switch (numDirs)
				{
				case 2:
					g->dir = permittedDirs[rand & 1];
					break;
				case 3:
					while ((rand & 3) > 2)
						rand >>= 2;
					g->dir = permittedDirs[rand & 3];
					break;
				}
			}
			return;
		case T_CHASE:
			switch (ghost)
			{
			case PAC_DEMO:
				// Try to munch a ghost
				for (gp=&s.ghosts[0]; gp->id != PAC_DEMO; gp++)
				{
					if (gp->targetingState == T_SCARED)
					{
						static signed char x, y;
						x = g->curTile->pos.x - gp->curTile->pos.x;
						y = g->curTile->pos.y - gp->curTile->pos.y;
						cdist = square[ABS(x)] + square[ABS(y)];
						if (cdist < closestDist)
						{
							closestDist = cdist;
							closestGhost = gp;
						}		
					}
				}
				if (closestDist != 0x7fff)
				{
					g->target = closestGhost->pos8;
					break;
				}

				// No ghosts to munch, try to munch a power-up
				for (i = 0; i < 4; i++)
				{
					if (s.powerUps[i].isActive)
					{
						g->target = s.powerUps[i].pos;
						break;
					}
				}

				// All power-ups gone, just pick one to go to after we get to the last one.
				if (i == 4 && g->target.x == g->pos8.x && g->target.y == g->pos8.y)
				{
					i = RAND() & 3;
					g->target = s.powerUps[i].pos;
				}
				break;
			case BLINKY_RED:
				g->target = s.pacState.pos8;
				break;
			case PINKY_PINK:
				{
					struct tagXY vec;
					vec = fourVec[s.pacState.dir];
					g->target.x = s.pacState.pos8.x + vec.x;
					g->target.y = s.pacState.pos8.y + vec.y;
				}
				break;
			case CLYDE_ORANGE:
				distx = g->pos8.x - s.pacState.pos8.x;
				disty = g->pos8.y - s.pacState.pos8.y;
				dist = square[ABS(distx)] + square[ABS(disty)];
				if (dist > 64)
				{
					g->target = s.pacState.pos8;
				}
				else {
					g->target = scatterTargets[ghost];
				}
				break;
			case INKY_BLUE:
				{
					struct tagXY vec;
					vec = fourVec[s.pacState.dir];
					ix = s.pacState.pos8.x + vec.x;
					iy = s.pacState.pos8.y + vec.y;
				}
				bx = s.ghosts[BLINKY_RED].pos8.x;
				by = s.ghosts[BLINKY_RED].pos8.y;

				g->target.x = bx + 2 * (ix - bx);
				g->target.y = by + 2 * (iy - by);
				break;
			} // switch ghost
		} // Switch targeting state
		if (numDirs == 0)
		{
			printf("Ghost permitted dirs SNAFU\n");
			g->dir = REVERSED_DIR(g->dir);
			return;
		}
		if (numDirs == 1)
		{
			g->dir = permittedDirs[0];
			return;
		}
		static int dists[4];
		for (i = 0; i < numDirs; i++)
		{
			static struct tagXY *op, ofs[2][4] = {
				{ {0,-10}, {10,0}, {-10, 0}, {0,10}},
				{ {0,-1}, {1,0}, {-1, 0}, {0,1}}
			};
			op = &ofs[g->lockedInHouse][permittedDirs[i]];
			delta.x = g->curTile->pos.x + op->x - g->target.x;
			delta.y = g->curTile->pos.y + op->y - g->target.y;
			dists[i] = square[ABS(delta.x)] + square[ABS(delta.y)];
		}

		// Find shortest distance for each x,y offset in the permissible directions
		static char newDir, li, di;
		newDir = permittedDirs[0];
		li = 0;
		for (di = 1; di < numDirs; di++)
		{
			if (dists[di] < dists[li])
			{
				li = di;
				newDir = permittedDirs[di];
			}
		}
		g->dir = newDir;
	} // for ghost
	if (ghostMoved)
		checkLeaveHouse();
}


// Tested
void drawGhost(struct tagGhost *ghost, char erase)
{
	char x = ghost->pos8.x;
	char y = ghost->pos8.y;

	// jok debug
	if (ghost->id == BLINKY_RED && !erase && (ghost->pos.x_speed || ghost->pos.y_speed))
	{
		printf("Draw ghost %d %d %d %s\n", (int)ghost->drawState, (int)ghost->pos8.x, (int)ghost->pos8.y, dirNames[ghost->dir]);
	}
	if (ghost->drawState == GHOST_SCORED)
	{
		ONOFF = erase ? RGB_BLACK : RGB_CYAN;
		drawNumber16(ghost->scored, x, y - 1, 0);
		if (erase)
			repairMazeNumber(ghost->scored, x, y - 1);
		return;
	}

	enumRgb ghostColor = RGB_BLACK;
	if (!erase)
	{
		switch (ghost->drawState)
		{
		case SCARED_BLUE:
			ghostColor = RGB_BLUE;
			break;
		case GHOST_SCORED:
		case SCARED_WHITE:
			ghostColor = RGB_WHITE;
			break;
		case NOT_SCARED:
			ghostColor = ghost->color;
		}
	}
	ONOFF = ghostColor;

	if (!erase)
	{
		if (ghost->drawState != SCARED_EYES)
		{
			PNUM(ghostCoats[s.ghostCoatState], x - 4, y - 4);
			//if (x < 4)
			//	PNUM(ghostCoats[s.ghostCoatState], x + 124, y - 4);
		}
		struct tagEyePos const *eyePos;
		switch (ghost->drawState)
		{
		case SCARED_EYES:
		case NOT_SCARED:
			eyePos = &eyePositions[ghost->dir];
			ONOFF = erase ? RGB_BLACK : RGB_WHITE;
			PNUM(CHAR_GHOST_EYES, x + eyePos->eyes.x, y + eyePos->eyes.y);
			ONOFF = erase ? RGB_BLACK : RGB_BLUE;
			PNUM(CHAR_GHOST_PUPILS, x + eyePos->pupils.x, y + eyePos->pupils.y);
#if 0
			if (x < 4)
			{
				ONOFF = erase ? RGB_BLACK : RGB_WHITE;
				PNUM(CHAR_GHOST_EYES, x + 124 + eyePos->eyes.x, y + eyePos->eyes.y);
				ONOFF = erase ? RGB_BLACK : RGB_BLUE;
				PNUM(CHAR_GHOST_PUPILS, x + 124 + eyePos->pupils.x, y + eyePos->pupils.y);
			}
#endif
			break;

		case SCARED_BLUE:
			ONOFF = RGB_MAGENTA;
			PNUM(CHAR_SCARED_GRIMACE, x - 4, y - 2);

			//if (x < 4)
			//	PNUM(CHAR_SCARED_GRIMACE, x + 124, y - 2);
			break;

		case SCARED_WHITE:
			ONOFF = RGB_RED;
			PNUM(CHAR_SCARED_GRIMACE, x - 4, y - 2);
			//if (x < 4)
			//	PNUM(CHAR_SCARED_GRIMACE, x + 124, y - 2);
			break;
		}
	}
	else {
		PNUM(ghostCoats[lastGameState.ghostCoatState], x - 4, y - 4);
		//if (x < 4)
		//	PNUM(ghostCoats[lastGameState.ghostCoatState], x + 124, y - 4);
	}
}

void setNextGhostExit(void)
{
	char i;
	struct tagGhost *g;
	for (i = 0; i < 3; i++)
	{
		g = &s.ghosts[ghostHouseOrder[i]];
		if (!g->lockedInHouse)
			continue;
		g->leaveHouseDots = s.pacState.dotsEaten + getHouseDots(g->id);
		return;
	}
}

void checkLeaveHouse(void)
{
	char i;
	struct tagGhost *g;
	for (i = 0; i < MAX_GHOSTS_IN_HOUSE; i++)
	{
		g = &s.ghosts[ghostHouseOrder[i]];
		if (!g->lockedInHouse || g->houseTarget == GG_SEEK_EXIT)
			continue;

		if (s.dotNotEatenTriggerIn && s.dotNotEatenTriggerIn >= s.boardTime)
		{
			SET_DOT_EATEN;
			g->houseTarget = GG_SEEK_EXIT;
			return;
		}
		else {
			if (s.leaveHouseDots)
			{
				switch (g->id)
				{
				case INKY_BLUE:
					if (s.pacState.dotsEaten - s.leaveHouseDots >= 17 * DOT_RATIO)
						g->houseTarget = GG_SEEK_EXIT;
					break;
				case PINKY_PINK:
					if (s.pacState.dotsEaten - s.leaveHouseDots >= 7 * DOT_RATIO)
						g->houseTarget = GG_SEEK_EXIT;
				case CLYDE_ORANGE:
					if (s.pacState.dotsEaten - s.leaveHouseDots >= 32 * DOT_RATIO)
					{
						g->houseTarget = GG_SEEK_EXIT;
						s.dotNotEatenTriggerIn = 0;
					}
				}
			}
		}
	}
}

char getHouseDots(enumGhostNames id)
{
	if (s.board > 2)
		return 0;

	if (id == PINKY_PINK || id==BLINKY_RED)
		return 0;

	switch (s.board)
	{
	case 0:
		switch (id)
		{
		case INKY_BLUE:
			return (char)(30 * DOT_RATIO);
		case CLYDE_ORANGE:
			return (char)(60 * DOT_RATIO);
		}
	case 1:
		switch (id)
		{
		case INKY_BLUE:
			return 0;
		case CLYDE_ORANGE:
			return (char)(50 * DOT_RATIO);
		}
	}
	return 0;
}

void initGhost(struct tagGhost *ghost)
{
	//static struct tagXY *gt;
	//gt = &tiles[initialGhostTile[ghost->id].x][initialGhostTile[ghost->id].y].pos;
	signed char xofs = 0;
	signed char yofs = -4;
	if (ghost->id == INKY_BLUE)
		xofs = -4;
	else if (ghost->id == PINKY_PINK)
	{
		yofs = 4;
		xofs = 4;
	}

	ghost->pos8 = initialGhostPos[ghost->id];
	ghost->spriteErased = 1;
	ghost->pos.x = ghost->pos8.x << 8;
	ghost->pos.y = ghost->pos8.y << 8;
	ghost->speed.x = 0;
	ghost->speed.y = 0;
	ghost->dir = D_UP;
	ghost->drawState = NOT_SCARED;
	ghost->targetingState = T_GHOST_HOUSE;
	ghost->currentSpeed = 179;
	ghost->pos.x_speed = 0;
	ghost->pos.y_speed = 0;
	ghost->target.x = initialGhostPos[ghost->id].x;
	ghost->leaveHouseDots = NUM_DOTS + NUM_POWER_UPS;
	switch (ghost->id)
	{
	case INKY_BLUE:
		ghost->target.x = ghost->pos8.x;
		ghost->target.y = ghost->pos8.y+8;
		ghost->lockedInHouse = 1;
		ghost->dir = D_DOWN;
		ghost->houseTarget = GG_SEEK_FLOOR;
		break;
	case PINKY_PINK:
		ghost->target.x = ghost->pos8.x;
		ghost->target.y = ghost->pos8.y - 8;
		ghost->lockedInHouse = 1;
		ghost->dir = D_UP;
		ghost->houseTarget = GG_SEEK_ROOF;
		ghost->leaveHouseDots = 0;
		break;
	case CLYDE_ORANGE:
		ghost->target.x = ghost->pos8.x;
		ghost->target.y = ghost->pos8.y + 4;
		ghost->dir = D_DOWN;
		ghost->lockedInHouse = 1;
		ghost->houseTarget = GG_SEEK_FLOOR;
		break;
	case BLINKY_RED:
		ghost->target.x = s.pacState.pos8.x;
		ghost->target.y = s.pacState.pos8.y;
		ghost->dir = D_RIGHT;
		ghost->targetingState = T_SCATTER;
		ghost->leaveHouseDots = 0;
		break;
	default:
		ghost->target.x = initialGhostPos[ghost->id].x;
		break;
	}
	ghost->color = ghostColors[ghost->id];
	ghost->initSpeed = 1;
	s.ghostsFreeIn = 60;
	s.ghostProcState = GP_STATIONARY;
}

void initGhosts(void)
{
	char i;
	printf("initGhosts\n");
	memset(&s.ghosts, 0, sizeof(s.ghosts));
	for (i = 0; i < NUM_GHOSTS; i++)
	{
		s.ghosts[i].id = i;
		initGhost(&s.ghosts[i]);
	}
	s.ghostProcState = GP_INVISIBLE_BLOCKED;
	s.ghosts[PAC_DEMO].targetingState = T_CHASE;
}

void killGhost(struct tagGhost *g)
{
	if (s.pacState.ghostScore)
		s.pacState.ghostScore += s.pacState.ghostScore;
	else
		s.pacState.ghostScore = 0x200;
	if (!s.attractState)
		scoreInc(s.pacState.ghostScore);
	makeSound(S_GHOST_SCORED);
	g->scored = s.pacState.ghostScore;
	s.ghostProcState = GP_STATIONARY;
	g->drawState = SCARED_EYES;
	g->houseTarget = GG_SEEK_HOUSE;
	g->lockedInHouse = 1;
	g->targetingState = T_GHOST_HOUSE;
	g->target.x = tiles[4][5].pos.x + 4;
	g->target.y = tiles[4][5].pos.y;
	s.ghostsFreeIn = 60;
	s.pacState.stationary = 1;
}

void moveGhosts(void)
{
	char i;

	static struct tagGhost *g;
	g = &s.ghosts[0];
	if (s.ghostProcState != GP_ACTIVE)
		return;

	for (i = 0; i < NUM_GHOSTS; i++, g++)
	{

		if (s.pacState.pos8.x == g->pos8.x && s.pacState.pos8.y == g->pos8.y)
		{
			switch (g->drawState)
			{
			case NOT_SCARED:
				if (i != PAC_DEMO && g->targetingState != T_ATTRACT)
					killPacman();
				return;
			case SCARED_WHITE:
			case SCARED_BLUE:
				killGhost(g);
				return;
			}

		}
		if (g->initSpeed || g->pos8.x == g->curTile->pos.x && g->pos8.y == g->curTile->pos.y)
		{
			if (g->drawState == SCARED_BLUE || g->drawState == SCARED_WHITE)
			{
				setActorSpeeds(g->id, AS_FRIGHT, g->dir, g->dir, &g->pos);
			}
			else if (g->curTile->ghostSlow)
			{
				setActorSpeeds(g->id, AS_TUNNEL, g->dir, g->dir, &g->pos);
			}
			else {
				setActorSpeeds(g->id, AS_NORM, g->dir, g->dir, &g->pos);
			}
		}
		MOVE_VECTOR(g->pos);
	}
}


void drawGhosts(void)
{
	signed char g;
	struct tagGhost *gp;
	gp = &s.ghosts[0];
	for (g = NUM_GHOSTS - 1; g >= 0; g--)
		drawGhost(gp++, 0);
}

struct tagScaredParms *getScaredTime(void)
{
	static struct tagScaredParms sp;

	if (s.board == 16 || s.board >= 18)
	{
		sp.scaredTime = 0;
		sp.timeUntilFlash = 0;
		sp.flashTime = 0;
		return &sp;
	}
	sp.scaredTime = (unsigned short)scaredTime[s.board] * 60;
	sp.flashTime = 12;
	char numScaredFlash = numScaredFlashes[s.board];
	switch (numScaredFlash)
	{
	case 5:
		sp.timeUntilFlash = sp.scaredTime - 3 * 60;
		break;
	case 3:
		sp.timeUntilFlash = 0;
		break;
	default:
		sp.timeUntilFlash = 0;
		sp.flashTime = 0;
		break;
	}
	return &sp;
}

unsigned short getGhostFlashTime(void)
{
	if (s.board == 16 || s.board >= 18)
		return 0;

	return scaredTime[s.board] * 60;
}

/*
 * We use the previous ghost position to see if there is any work to do in ghostStateUpdate
 */
void saveGhostPos(void)
{
	static struct tagXY *p;
	static struct tagGhost *c;
	c = &s.ghosts[0];
	p = &s.prevGhostPos[0];
	for (char i = 0; i < NUM_GHOSTS; i++)
		*p++ = (c++)->pos8;
}