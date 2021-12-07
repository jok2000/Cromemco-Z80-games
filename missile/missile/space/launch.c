// space.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>

extern void STARTA(void), PNUMTS(void), DAZMOD(void), DAZINIT(void),_exit(int code);
static char done;
void dazinit(void)
{

	if (done)
		return;
	done = 1;
	DAZMOD();
	DAZINIT();
}

int main()
{
	int choice = 0;
	done = 0;
	//printf("Space Invaders for Cromemco Dazzler.  (c) 1982 2020 Jeff Kesner, Matthew Francey\n");
	//printf("Refactored from Cromemco Macro Assembler to sdcc 2020\n");
	do
	{
		int choice;
		printf("Choose Action:\n\n");
		printf("1. Start program\n");
		printf("2. Run pnum test\n");
		printf("0. Exit\n");
		choice = getchar();

		switch (choice)
		{
			case '1':
				printf("%s", "Please wait, building character bitmaps.\n");
				STARTA();
				break;
			case '2':
				dazinit();
				PNUMTS();
				break;
			case '0':
				printf("Exiting\n");
				_exit(0);

		default:
			printf("Not implemented.  Try again:\n");
			break;
		}

	} while (1);

}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
