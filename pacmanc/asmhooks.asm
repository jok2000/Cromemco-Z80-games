;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (MINGW64)
;--------------------------------------------------------
	.module asmhooks
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _memswap
	.globl _XY
	.globl _requestedDir
	.globl _LINEV
	.globl _LINEH
	.globl _MESOUT
	.globl _FRUITD
	.globl _leave
	.globl _makeSound
	.globl _exit
	.globl _printf
	.globl _intTable
	.globl _getTime
	.globl _RAND
	.globl _PNUM
	.globl _PNUM1
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_intTable::
	.ds 256
_dummyChar:
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;asmhooks.c:17: void getTime(unsigned short *shortTime, unsigned long *longTime)
;	---------------------------------
; Function getTime
; ---------------------------------
_getTime::
;asmhooks.c:21: __endasm;
	di
;asmhooks.c:22: *shortTime = SETTIMER;
	pop	de
	pop	bc
	push	bc
	push	de
	ld	iy, #_SETTIMER
	ld	a, 0 (iy)
	ld	(bc), a
	inc	bc
	ld	a, 1 (iy)
	ld	(bc), a
;asmhooks.c:23: *longTime = LONGTIMER;
	ld	iy, #4
	add	iy, sp
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	ld	iy, #_LONGTIMER
	ld	a, 0 (iy)
	ld	(bc), a
	inc	bc
	ld	a, 1 (iy)
	ld	(bc), a
	inc	bc
	ld	a, 2 (iy)
	ld	(bc), a
	inc	bc
	ld	a, 3 (iy)
	ld	(bc), a
;asmhooks.c:26: __endasm;
	ei
;asmhooks.c:27: }
	ret
;asmhooks.c:29: char RAND(void)
;	---------------------------------
; Function RAND
; ---------------------------------
_RAND::
;asmhooks.c:35: __endasm;
	call	RAND
	ld	l, a
	ret
;asmhooks.c:36: return 1;
	ld	l, #0x01
;asmhooks.c:37: }
	ret
;asmhooks.c:39: void makeSound(enum eSound sound)
;	---------------------------------
; Function makeSound
; ---------------------------------
_makeSound::
;asmhooks.c:44: __endasm;
	LD	A, L
	OUT(#0X20),	A
;asmhooks.c:45: sound = sound;
;asmhooks.c:46: }
	ret
;asmhooks.c:48: void leave(void)
;	---------------------------------
; Function leave
; ---------------------------------
_leave::
;asmhooks.c:50: exit();
;asmhooks.c:51: }
	jp	_exit
;asmhooks.c:54: void FRUITD(char f, char x, char y, char onoff)
;	---------------------------------
; Function FRUITD
; ---------------------------------
_FRUITD::
;asmhooks.c:68: __endasm;
	ld	hl, #5
	add	hl, sp
	ld	a, (hl)
	dec	hl
	ld	c, (hl)
	dec	hl
	ld	b, (hl)
	dec	hl
	ld	e,(hl)
	jp	DRAW_FRUIT
;asmhooks.c:72: onoff=onoff;
;asmhooks.c:73: }
	ret
;asmhooks.c:77: unsigned short PNUM(char c, char x, char y)
;	---------------------------------
; Function PNUM
; ---------------------------------
_PNUM::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;asmhooks.c:79: if (c==']')
	ld	a, 4 (ix)
	sub	a, #0x5d
	jr	NZ,00102$
;asmhooks.c:81: printf("PNUM %d,%d %c %d @ %d\n", (int)x, (int)y, c, ONOFF, SETTIMER);
	ld	a,(#_ONOFF + 0)
	ld	-4 (ix), a
	xor	a, a
	ld	-3 (ix), a
	ld	a, 4 (ix)
	ld	-2 (ix), a
	xor	a, a
	ld	-1 (ix), a
	ld	c, 6 (ix)
	ld	b, #0x00
	ld	e, 5 (ix)
	ld	d, #0x00
	ld	hl, (_SETTIMER)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	push	bc
	push	de
	ld	hl, #___str_0
	push	hl
	call	_printf
	ld	hl, #12
	add	hl, sp
	ld	sp, hl
00102$:
;asmhooks.c:83: return PNUM1(c,x,y);
	ld	h, 6 (ix)
	ld	l, 5 (ix)
	push	hl
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_PNUM1
;asmhooks.c:84: }
	ld	sp,ix
	pop	ix
	ret
___str_0:
	.ascii "PNUM %d,%d %c %d @ %d"
	.db 0x0a
	.db 0x00
;asmhooks.c:87: unsigned short PNUM1(char c, char x, char y)
;	---------------------------------
; Function PNUM1
; ---------------------------------
_PNUM1::
;asmhooks.c:89: dummyChar = y;
	ld	iy, #4
	add	iy, sp
	ld	a, 0 (iy)
	ld	(_dummyChar+0), a
;asmhooks.c:102: __endasm;
	ld	hl, #4
	add	hl, sp
	ld	c, (iy)
	ld	b, -1(iy)
	ld	a, -2(iy)
	push	ix
	call	PNUM3
	ld	l,c
	ld	h,b
	pop	ix
	ret
;asmhooks.c:107: return 0;
	ld	hl, #0x0000
;asmhooks.c:108: }
	ret
;asmhooks.c:122: void MESOUT(char *msg, char x, char y)
;	---------------------------------
; Function MESOUT
; ---------------------------------
_MESOUT::
;asmhooks.c:135: __endasm;
	ld	hl,#5
	add	hl,sp
	ld	c,(hl)
	dec	hl
	ld	b,(hl)
	pop	de
	pop	hl
	push	hl
	push	de
	jp	MESOUT
;asmhooks.c:139: y = y;
;asmhooks.c:140: }
	ret
;asmhooks.c:142: void LINEH(char x, char y, char w)
;	---------------------------------
; Function LINEH
; ---------------------------------
_LINEH::
;asmhooks.c:153: __endasm;
	ld	hl, #4
	add	hl, sp
	ld	d,(hl)
	dec	hl
	ld	c, (hl)
	dec	hl
	ld	b, (hl)
	jp	LINEH
;asmhooks.c:157: w = w;
;asmhooks.c:158: }
	ret
;asmhooks.c:160: void LINEV(char x, char y, char h)
;	---------------------------------
; Function LINEV
; ---------------------------------
_LINEV::
;asmhooks.c:171: __endasm;
	ld	hl, #4
	add	hl, sp
	ld	d,(hl)
	dec	hl
	ld	c, (hl)
	dec	hl
	ld	b, (hl)
	jp	LINEV
;asmhooks.c:175: h = h;
;asmhooks.c:176: }
	ret
;asmhooks.c:179: char requestedDir(void)
;	---------------------------------
; Function requestedDir
; ---------------------------------
_requestedDir::
;asmhooks.c:216: __endasm;
;	Return the requested directions from the joystick in a nybble form x,y
;	Follows DIR_TO_BIT in C data.h
	JOYSTK	.equ 32
	JS1_JOY_1X	.equ 0x19 ; right = +ve, left = -ve
	JS1_JOY_1Y	.equ 0x1a ; up = +ve, down = -ve
	JS1_JOY_2X	.equ 0x1b
	JS1_JOY_2Y	.equ 0x1c
	LD	B,#0
	IN	A, (#JS1_JOY_1X)
	OR	A
	JP	M, 1$
	CP	#JOYSTK
	JR	C, YAXISJ
	LD	B,#2<<4 ; up=1, right=2, left=3, down = 4
	JR	YAXISJ
	        1$:
	CP #-JOYSTK
	JR	NC, YAXISJ
	LD	B,#3<<4
	  YAXISJ:
	IN A, (#JS1_JOY_1Y)
	OR	A
	JP	M, 3$ ; M is down
	CP	#JOYSTK
	LD	A, #1
	JR	NC,2$
	XOR	A
	JR	2$
	  3$:
	CP #-JOYSTK
	LD	A, #4
	JR	C, 2$
	LD	A, #0
	        2$:
	OR A,B
	LD	L,A
	LD	H,#0
	RET
;asmhooks.c:217: return 1;
	ld	l, #0x01
;asmhooks.c:218: }
	ret
;asmhooks.c:220: void XY(unsigned char x, unsigned char y)
;	---------------------------------
; Function XY
; ---------------------------------
_XY::
;asmhooks.c:229: __endasm;
	ld	hl, #3
	add	hl, sp
	ld	c, (hl)
	dec	hl
	ld	b, (hl)
	jp	XY
;asmhooks.c:232: y = y;
;asmhooks.c:233: }
	ret
;asmhooks.c:235: void memswap(void *s1, void *t1, int len)
;	---------------------------------
; Function memswap
; ---------------------------------
_memswap::
;asmhooks.c:255: __endasm;
	pop	af
	pop	de
	pop	hl
	pop	bc
	push	bc
	push	hl
	push	de
	push	af
;	bc = len, de = a destination, hl = a shource
	ld	a, (de)
	 1$:
	ldi
	dec	hl
	ld	(hl), a
	inc	hl
	ret	po
	jr	1$
;asmhooks.c:256: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
