# Cromemco-Z80-games
These games are being distributed under the GPL.  (c) Jeff Kesner 1979-1981, 2021-2022.



These are some Z80 games I wrote with a friend for the Cromemco Dazzler on a Cromemeco
Z2-D system.

Currently each of the games still has some typos that prevent playing for more than
a few seconds.   I originally tried to find the typos using the orginal Cromemco
work-flow using the Z80-pack emulator, but this was too painful so I converted to
the SDCC work-flow.  (The makefile is for Cygwin, I am using the Windows SDCC and
everything else is run under Linux using the emulator).  More to come.

Debugging in Windows under Visual Studio can be used for pacmanc.  This is intended
to be function-level testing, there are no graphics in the Windows code.

You can use "z80-pack" on github to get the emulator for the Dazzler and Cromemco Z2-D

This is the first commit after having typed all these games in from listings from 1980
and debugging them.  I hope to get back to removing the typos soon.

There are features that I have added to the Cromemco emulation.   I will be asking for 
a branch and pull request for these sometime soon over at z80-pack.  The key part of
this is the Cromemco Dazzler page flipping that was use for a multi-color display.
This does not make since within the emulation environment, so I added two non-standard
modes to the emulator and changed the Z80 code to use them instead of the interrupt-
driven page-flipping.

The assembler games have been ported to the SDCC (Small device C compiler) work-flow.
I love the old hardware, but it's a million times slower than modern PCs, literally.
The games run at arcade speed when the emulator is at about 6Mhz (The speed of my 
Cromemco).  This is mostly thanks to the small Dazzler screen.

Currently there are:
Crash -- In Fortran(see Mame arcade game of same name)
LaserBlast -- In Fortran.  Seems to be a lost arcade game from 1979
Sadly there are a few typos left in the Fortran.  I wrote these as a kid
as my first Fortran programs.  Hence the iffy variable names and commenting.

Pacman -- Ported recently to SDCC C, to complete the unfinished 1982 version.

For these ones, the original ASM is in the .z80 file
SpaceInv -- Space invaders, ported to SDCC work flow
Missile -- Missile Command, the one I worked the hardest on in 1980, also
ported to SDCC work-flow.

The sound effects were done using interrupts and the Cromemco D+7A with JS-1 joystick.
The emulator does not yet have the interrupt speed fidelity to emulate these sounds.
I am working on it when I can.  The JS-1 emulator uses a game controller hooked up to Linux,
read inside the Cromemco emulator.

The old manuals for all of this hardware and the Cromemco work-flow can be found either
in z80-pack or elsewhere on the internet, fairly easily.  After 40 years I had to download
the Z80 instruction manual.  I'm not proud of that, but it all came back very quickly.

In the tools directory you will find a python program for creating the initial
high-score file for Space Invaders.
There is also a tool that converts Cromemco Z80 macro assembler into SDCC Z80
syntax (mostly).   I've converted what I needed to and I'm done with the tool.

I'd completely forgotten I had even written half of these games until I found the listings.
