	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.module dazzler
	.optsdcc -mz80

	.include "dazzler.mac"
	.include "dazzler.abs"
	
	.area	_DATA
WHITE           .equ    C11
BLACK           .equ    C00
RED             .equ    C01
BLUE            .equ    C10
XLEN	.gblequ	80 	
DAZTABS:	.db	1, 4, 2, 8, 0x10, 0x40, 0x20, 0x80
DAZTB1S:	.db	1, 1<<1, 1<<4, 1<<5, 1<<2, 1<<3, 1<<6, 1<<7	; Official Dazzler memory layout (x+y*4) 

;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE

_DAZINIT::
DAZINIT::
	LD	HL,#DAZTABS
	LD	DE,#DAZTAB
	LD	BC,#8
	LDIR
	LD	HL,#DAZTB1S
	LD	DE,#DAZTB1
	LD	BC,#8
	LDIR
	LD	HL,#RANTAB  	
RSET:	CALL	RAND
	LD	(HL),A  
	INC	L  
	JR	NZ,RSET  
	CALL	MKZERO
	JP	CLS

XY::	
YX:	PUSH	BC 
	EXX	  
	POP	BC  
	LD	H,#SC1/512  
	BIT	6,B  
	JR	Z,XY1  
	INC	H  
XY1:	BIT	6,C
	JR	Z,XY2  
	INC	H  
	INC	H  
XY2:	LD	A,#0x3C 
	AND	B  
	SHIFT	R,2  
	LD	L,A  
	LD	A,#0x3E  
	AND	C  
	SHIFT	L,2  
	ADD	A,A  
	RL	H  
	OR	L  
	LD	L,A  
	LD	A,#3  
	AND	B  
	RRC	C  
	RLA	  
	LD	C,A  
	LD	B,#DAZTAB/256  
XYACMP::
	LD	A,(BC)  
;	JR	C01  
;ONOFF	.gblequ	.-1
	.db	0x18
ONOFF::	.db	2

; Couldn't get the assembler to do the math... God help you if you change those macros
C00	.gblequ 0
	CPL	  
	XYPM	AND  
	LD	A,(BC)  
	CPL	  
	XYLM	AND  
	
C01	.gblequ 11
	XYPM	OR  
	LD	A,(BC)  
	CPL	  
	XYLM	AND  
	
C10	.gblequ 0x15
	CPL	  
	XYPM	AND  
	LD	A,(BC)  
	XYLM	OR  
	
C11	.gblequ 0x1f
	XYPM	OR  
	LD	A,(BC)  
	XYLM	OR  
	
CTEST	.gblequ 0x28
	AND	(HL)  
; PAGE 3 FOLLOWS
	LD	D,#1  
	JR	NZ,CTST1  
	LD	D,#0  
CTST1:	SET	3,H
	LD	A,(BC)  
	AND	(HL)  
	LD	A,D  
	JR	Z,CTST2  
	OR	#2  
CTST2:	EXX	 
	RET	  
	
; This version of XY only plots in first quadrant in one color

XY16:	LD	HL,#SC1
	LD	A,#0x3E
	AND	C
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,#0
	ADD	HL,DE
	ADD	HL,DE
	LD	A,B
	SRL	A
	SRL	A
	LD	E,A
	ADD	HL,DE
	LD	A,#3
	AND	B
	BIT	0,C
	JR	Z,XY16A
	ADD	A,#4
XY16A:	LD	D,#DAZTB1/256
	LD	E,A
	LD	A,(DE)
	OR	(HL)
	LD	(HL),A
	RET

CLEAR::	
CLS::	LD	HL,#SC1
	LD	DE,#SC1+1
	LD	BC,#4095
	LD	(HL),#0
	LDIR
	RET
	
; Clear first character on screen plus bit blit dimensions

CLSZ:	LD	DE,#16
	LD	B,#4
	LD	IX,#SC1
CLSZ1:	LD	(IX),#0
	LD	+1(IX),#0
	LD	+2(IX),#0
	ADD	IX,DE
	DJNZ 	CLSZ1
	RET


; Make ZEROB table (bit blit table)

; Hand compiled from the C version

; C version does gymnastics so it can print pretty comments

YBIT:	.ds	1
	
MKZERO::
	LD	IY,#ZEROB
	LOOPB	ZCHAR,#NUMZER
	LOOPB	ZYOFF,#2
	LOOPB	ZXOFF,#4
MKZRX1:	CALL	CLSZ	; Uses IX
	LD	B,#5
MKZERX:	LD	C,#5
	MOV	(YBIT),#1<<5
MKZRC1:	LD	A,(ZCHAR)   ; int color = zero[c][x] & (1 << y);
	ADD	A,A   ; max 108
	LD	E,A
	LD	D,#0
	LD	L,A
	LD	H,#0
	ADD	HL,HL
	ADD	HL,DE   ; C * 6
	LD	E,B
	ADD	HL,DE
	LD	DE,#ZERO
	ADD	HL,DE
	LD	A,(YBIT)
	AND	A,(HL)
	JR 	Z,MKNOBT
	PUSH	BC
	LD	A,#5   ; xy(5-y + xOff, 5-x + yOff, color);
	SUB	C   ; 5 - y
	LD	HL,#ZXOFF
	ADD	A,(HL)   ; + xOff
	LD	 E,A
	LD	A,#5
	SUB	B   ; 5 - x
	LD	HL,#ZYOFF
	ADD	A,(HL)   ; + yOff
	LD	C,A   ; xy Y parm = 5-x+yOff
	LD	B,E   ; xy X parm = 5-y + xOff
	CALL 	XY16
	POP 	BC
MKNOBT:	DEC C   ; 2 closing braces in C
	LD	A,(YBIT)
	RRCA
	LD	(YBIT),A
	JP 	P,MKZRC1
	DEC	B
	JP 	P,MKZERX

; Dump the bytes from the screen after the XY plot of the character is done

	PUSH	BC
	LD	C,#0   ; for (int y = 0; y < 4; y++)
MKDUY:	LD	B,#0   ; for (int x = 0; x < 3; x++)
MKDUX:	LD	A,C   ; screen[x + (y << 4)]
	SHIFT	L,4
	ADD	A,B
	LD	L,A
	LD	H,#SC1/256
	LD	A,(HL)
	LD	(IY),A
	INC	IY
	INC	B
	LD	A,#3
	CP	B
	JR	NZ,MKDUX	;	x<3
	INC	C
	LD	A,#4
	CP	C
	JR 	NZ,MKDUY   ; 2 closing braces in C
	
	POP 	BC   ; Retrieve x, y
	ENDLPB	ZXOFF
	ENDLPB	ZYOFF
	ENDLPB	ZCHAR
	RET
	
CHARO::	LD	A,#6
	LD	(CR),A
PL1:	LD	E,#6
	LD	D,B
	LD	A,(HL)
PL:	RRCA
	PUSH	AF
	CALL	C,XY
	DEC	B
	POP	AF
	DEC	E
	JR	NZ,PL
	LD	B,D
	DEC	C
	LD	A,#0
CR	.EQU	.-1
	DEC	A
	LD	(CR),A
	INC	HL
	JR	NZ,PL1
	RET
	
PNUMS::	LD	E,A
	LD	D,#0
	LD	HL,#0
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	LD	D,H
	LD	E,L
	LD	HL,#ZERO
	ADD	HL,DE
	ADD	HL,DE
	PUSH	BC
	CALL	CHARO
	POP	BC
	LD	A,#6
	ADD	A,B
	LD	B,A
	RET
	
; Just draw the character on top of whatever is already there.

PNUM::	push	bc
	ld	hl,#-5*256-5	; This should be -6,-6 but the game assumes -1 areas will not be plotted
	add	hl,bc
	ld	b,h
	ld	c,l
	LD	L,A
	LD	H,#0
	LD	E,A
	LD	D,#0
	ADD	HL,HL
	ADD	HL,DE   ; * 3
	ADD	HL,HL
	ADD	HL,HL   ; * 12
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL   ; A * 12 * 8
	LD	IX,#ZEROB
	EX 	DE,HL
	ADD	IX,DE   ; Offset of bit blit table for this character
	LD	D,#12*4
	BIT 	0,C   ; Y
	JR 	NZ,Y1
	LD	D,#0
Y1:	LD	A,B
	AND	#3   ; x portion
	LD	E,A
	ADD	A,A
	ADD	A,E   ; 3 * x portion
	ADD	A,A   ; * 6 (MAX 18)
	ADD	A,A   ; * 12 (MAX 36)
	ADD	A,D   ; MAX 84
	LD	E,A
	LD	D,#0
	ADD	IX,DE   ; Offset into the table for this character
	LD	A,C   ; IX has ZEROB table position
; Compute memory position on screen from x & y in BC

	AND	#0x3E
	LD	L,A
	LD	H,#0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL   ; y portion * 16 bytes per line
	LD	A,B
	AND	#0x3C
	SHIFT	R,2
	LD	E,A
	LD	D,#0
	ADD	HL,DE   ; + x portion
	LD	DE,#SC1
	ADD	HL,DE   ; Offset of byte on screen
	LD	DE,#BLACK*256+BLUE
SCLOOP:	PUSH	HL
	PUSH	DE
	LD 	A,(ONOFF)   ; Note macros take care of quadrant for HL
	CP	D
	JP 	Z,ANDMEM
	CP	E
	JP 	Z,ANDMEM
	BLT	ORMEM   ; Generates 256 bytes of instructions
	JP	NXTSC2
ANDMEM:	BLT	ANDMEM
NXTSC2:	POP	DE
	POP	HL
	LD	A,#RED
	CP	E
	JR	Z,$1
	LD	A,#-6	; Restart character
	ADD	A,C
	MOV	C,A
	LD	A,#2048/256
	ADD	A,H
	LD	H,A
	LD	DE,#BLACK*256+RED
	JP	SCLOOP
$1:	POP	BC
	LD	A,#6
	ADD	A,B
	LD	B,A
	RET

LINEH::	CALL	XY
	INC	B  
	DEC	D  
	JP	NZ,LINEH  
	RET	 
MESOUT::
	LD	A,(HL) 
	CP	#255  
	RET	Z  
	PUSH	HL  
	CALL	PNUM  
	POP	HL  
	INC	HL  
	JP	MESOUT  

RAND::	PUSH	HL 
	PUSH	BC  
	LD	HL,#RANTAB  
	LD	B,#8  
	LD	A,(HL)  
RAND1:	RLCA	 
	RLCA	  
	RLCA	  
	XOR	(HL)  
	RLA	  
	RLA	  
	DEC	HL  
	DEC	HL  
	DEC	HL  
	RL	(HL)  
	INC	HL  
	RL	(HL)  
	INC	HL  
	RL	(HL)  
	INC	HL  
	LD	A,(HL)  
	RLA	  
	LD	(HL),A  
	DJNZ	RAND1  
	POP	BC  
	POP	HL  
	RET	  

_PNUMTS::
	CALL	CLS
	COLOR	#WHITE
	LD	BC,#6+6*256 
CGRP:
	LOOPB	CNUM,#NUMZER
	PUSH	BC  
	CALL	PNUM  
PNUMFC	.equ	.-2 
	POP	BC  
	LD	A,#6 
	ADD	A,B  
	LD	B,A  
	CP	#128  
	JR	C,NEXTC  
	LD	B,#6  
	LD	A,#6  
	ADD	C  
	LD	C,A  
	CP	#128  
	RET	NC
NEXTC:	ENDLPB	CNUM 
	JR	CGRP
	
	.area	_DATA
	.db	0x29, 0x98, 0xDA, 0x1B
RANTAB	.equ	.-1 

ZERO::	.db	14, 25, 21, 19, 14, 0; 0 
	.db	14, 4, 4, 12, 4, 0; 1 
	.db	31, 8, 6, 17, 14, 0; 2 
	.db	14, 1, 6, 1, 14, 0; 3 
	.db	2, 2, 31, 18, 18, 0; 4 
	.db	30, 1, 30, 16, 31, 0; 5 
	.db	14, 17, 30, 16, 15, 0; 6 
	.db	8, 4, 2, 1, 31, 0; 7 
	.db	14, 17, 14, 17, 14, 0; 8 
	.db	14, 1, 31, 17, 14, 0; 9 
	.db	0, 0, 0, 0, 0, 0; SPACE 
	.db	17, 31, 17, 10, 4, 0; A 
	.db	30, 17, 30, 17, 30, 0; B 
	.db	14, 17, 16, 17, 14, 0; C 
	.db	30, 17, 17, 17, 30, 0; D 
	.db	31, 16, 30, 16, 31, 0; E 
	.db	16, 16, 31, 16, 31, 0; F 
	.db	14, 18, 23, 16, 14, 0; G 
	.db	17, 17, 31, 17, 17, 0; H 
	.db	14, 4, 4, 4, 14, 0; I 
	.db	14, 17, 1, 1, 1, 0; J 
	.db	9, 10, 12, 10, 9, 0; K 
	.db	31, 16, 16, 16, 16, 0; L 
	.db	17, 17, 21, 31, 27, 0; M 
	.db	17, 19, 21, 25, 17, 0; N 
	.db	14, 17, 17, 17, 14, 0; O 
	.db	16, 16, 30, 17, 30, 0; P 
	.db	15, 19, 21, 17, 14, 0; Q 
	.db	17, 18, 30, 17, 30, 0; R 
	.db	30, 1, 14, 16, 15, 0; S 
	.db	4, 4, 4, 4, 31, 0; T 
	.db	14, 17, 17, 17, 17, 0; U 
	.db	4, 10, 17, 17, 17, 0; V 
	.db	17, 27, 21, 17, 17, 0; W 
	.db	17, 10, 4, 10, 17, 0; X 
	.db	4, 4, 4, 10, 17, 0; Y 
	.db	31, 8, 4, 2, 31, 0; Z 
	.db	4, 0, 6, 17, 14, 0; ? 
	.db	0, 31, 0, 31, 0, 0; = 
	.db	32, 49, 31, 21, 4, 4; 39 & 40 CITY WHITE 41 42 CITY FM Color 
	.db	1, 63, 27, 26, 16, 16, 31, 14, 0, 0, 0, 0, 62, 8, 0, 0, 0, 0; 
	.db	24, 24, 0, 0, 0, 0, 7, 7, 7, 0, 0, 0
	.db	21, 14, 31, 14, 21, 0; #'*' 
	.db	0, 4, 0, 4, 0, 0; #':' 
NUMZER	.gblequ (.-ZERO) / 6
ZEROB:  .ds	4*3*8*NUMZER
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
	