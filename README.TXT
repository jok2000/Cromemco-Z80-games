Cromemeco Instructions
Start-up
-	sudo apt install libx11-dev (if needed)
-	sudo apt-get install libjpeg-dev
-	sudo apt install freeglut-dev
-	sudo apt install binutils-gold g++ g++ mesa-common-dev build-essential libglew1.5-dev libglm-dev
-	sudo apt install mesa-utils
-	sudo apt install aptitude
-	sudo aptitude install libxi-dev libxmu-dev
-	git config –global –unset http.proxy
-	git clone https://github.com/udo-munk/z80pack.git z80pack-1.38-DEV/cd ~/jok/z80pack/z80pack-1.36/z80sim/srcsim
-	Install cpmtools-2.21 into ~/jok/cpmtools-2.21
-	Patch with the Dazzler, JS-1 and Tu-Art fixes
-	Update .bashrc PATH: export PATH=$PATH:~/jok/cpmtools-2.21
-	Update .bashrc LD_LIBRARY_PATH: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH: ~/jok/z80pack/z80pack-1.36/frontpanel
-	Update ~/jok/z80pack with patches
-	Cd ~/jok/srcjok
-	Test joystick after connecting to VM with removable devices (./joystick /dev/input/js0)
-	./godazzs to see the basic Dazzler programs
-	Flip switch 4 on on front panel, click power and then run
-	Press enter a few times.
-	The above 2 lines are described here: H:\github\z80pack-3.8\cromemcosim\README
-	./goasm to see latest work on the Z80 games
Building Simulator
make -f Makefile.Linux
cd ~/jok/z80pack/z80pack-1.36/frontpanel
make -f Makefile.linux
cd ~/jok/z80pack/z80pack-1.36/cromemcosim/srcsim
make -f Makefile.linux
editing simulator source: 
~/jok/z80pack/z80pack-1.36/cromemcosim/srcsim-jok for cromemco specific code
~/jok/z80pack/z80pack-1.36/z80sim/srcsim for iosim.c and Makefile.linux
Dazzler Page Flip Mode
In the Dazzler manual under “Animation” they describe a method to flip from one buffer to another (swap screens).  I created a small interrupt for this and swapped either 2 or 3 screens to give 4 or 8 colors to my game.  The 3-page mode was rough on the eyes.   To simulate this, I have added 2 non-standard modes to the Dazzler emulator in z80pack.   I modified SPACEINV and MISSILE and PACMANC to use these modes (which are not hard on the eyes).
-	3 page mode is 0xd0
-	2 page mode is 0xd1
Summary
SPACEINV – A Space Invaders™ like game
-	Made in 1979
-	Uses the interrupts and the JS-1 for input and sound
MISSILE – A Missile Command™ like game
-	Made in 1980
-	Uses IM2 and the JS-1 for input and sound
CRASH – A Crash™ like game
-	Made in 1978 
-	Uses the interrupts and the JS-1 for input and sound
LASER – A Laser-Blast™ like game
-	Made in 1978 
-	Uses the interrupts and the JS-1 for input and sound

PACMANC – A PacMan™ like game
-	Graphics created in 1982
-	Gameplay never debugged.   Removed buggy Z80-Assembler game loop and replaced with SDCC C and SDCC ASM in 2020 
-	Uses the interrupts and the JS-1 for input and sound

CPM MEF – The Message Exchange Forum
-	Created in 1983 © Jeff Kesner, GPL License.
-	Compiled in BDSC.   BDSC is public domain now.
-	30 years before Facebook/Meta, this is what some of us at the University of Toronto used to exchange messages (on an ICMEF) Inter-Corporate-Message-Exchange-Facility
-	The console I/O was hooked up to a modem (both console and modem displayed same interface)
-	This was one of 4 MEF’s.  
o	There was a NEC version written by John Chew
o	There was a BASIC version for the SOL-20 by Jeff Kesner that only ran in 1982 (before the CPM MEF) called the SICMEF (Sol ICMEF).  The name stuck for the CPM MEF, but I rather prefer CPM MEF.
o	There was a TRS-80 BASIC version coded by several of us, mostly by mdf.  It ran in 1983ish, and was monitored by the late Jim Ohi in the 1980’s.   He sadly died in a car-crash in the early 1990’s.
o	There was a Commodore Pet version, the hakmef written in Commodore BASIC by rph.  It ran in the mid-1980s.



