; paclib.asm
; Pacman drawing routines.
; Preserve IX
	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.module paclib
	.optsdcc -mz80

	.include "dazzler.mac"
	.include "dazzler.abs"
	
	.globl	ONOFF,  XY, PNUM, MESOUT, DAZINIT, CLS, _DAZMOD3
	.globl	LINEH, LINEV
	
	.area _CODE

_CLEAR_LIVES::
	LD	A,#3
	LD	HL,#SC2 - 4*16 - 512;
CL1:	LD	D,H
	LD	E,L
	INC	DE
	LD	BC,#16 * 4 -1
	LD	(HL),#0
	LDIR
	LD	DE,#-4*16+1+2048
	ADD	HL,DE
	DEC	A
	JR	NZ,CL1
	RET
	
_CLEAR_FRUIT::
	LD	A,#3
	LD	HL,#SC2 - 4*16;
	JR	CL1
	
; Draw a fruit
; BC = xy
; A = on or off (1/0)
; E = fruit
DRAW_SET_FRUIT::
	LD	D,#0  
	LD	HL,#_FRUITS  
	ADD	HL,DE  
	LD	E,(HL)  
DRAW_FRUIT::
	PUSH	IX
	SLA	E  
	LD	(FCOL),A 
	LD	D,#0  
	LD	HL,#FRTTAB  
	ADD	HL,DE  
	LD	E,(HL)  
	INC	HL  
	LD	H,(HL)  
	LD	L,E  
FRUI:	GET	FCOL
	AND	A
	LD	A,#BLACK  
	JR	Z,1$
	LD	A,(HL)  
1$:	LD	(ONOFF),A 
	INC	HL  
	PUSH	BC  
	LD	D,#7  
2$:	LD	A,(HL) 
	LD	E,B  
	ADD	A,A  
3$:	ADD	A,A 
	PUSH	AF  
	CALL	C,XY  
	INC	B  
	POP	AF  
	JR	NZ,3$  
	INC	HL  
	LD	B,E  
	INC	C  
	DEC	D  
	JR	NZ,2$  
	POP	BC  
	LD	A,(HL)  
	CP	#0x81  
	JR	NZ,FRUI
	POP	IX
	RET
	
_MAZER::
	PUSH	IX
	COLOR	#BLUE 
	LD	IX,#_MAZE  
	LD	DE,#_YTURN  
MAZ1:	LD	A,(DE) 
	OR	A  
	JP	M,THEEND  
	LD	C,A  
	PUSH	DE  
	LD	B,#19  
2$:	LD	A,(IX) 
	INC	IX
	LD	DE,#_POSTAB-3  
	
	; The if is for testing the opposite drawing scheme to verify MAZE data
	.if 1
	LD	H,#0
3$:	INC	DE 
	INC	DE  
	INC	DE  
	SRL	A  
	JR	NC,4$
	PUSH	AF	; 	D_UP=0, D_RIGHT=1, D_LEFT=2, D_DOWN=3, D_NONE
	LD	A,#11
	CP	C
	JR	NZ,7$
	; Extra logic to skip duplicate walls
	LD	A,H	; We are on the first row
	AND	A
	JR	Z,9$ 	; UP   Row == 0 && dir == UP, then draw (9$)
7$:
	LD	A,B
	CP	#19
	JR	NZ,10$
	LD	A,#2	; left  Col == 0 && dir==left then draw (9$)
	CP	H
	JR	Z,9$
10$:	LD	A,H
	AND	A	; UP?  SKIP
	JR	Z,8$
	CP	#2	; LEFT? SKIP
	JR	Z,8$
	.else
	LD	H,#0
3$:	INC	DE 
	INC	DE  
	INC	DE  
	SRL	A  
	JR	NC,4$
	PUSH	AF	; 	D_UP=0, D_RIGHT=1, D_LEFT=2, D_DOWN=3, D_NONE
	LD	A,#113
	CP	C
	JR	NZ,7$
	; Extra logic to skip duplicate walls
	LD	A,H	; We are on the last row
	CP	#3
	JR	Z,9$ 	; DOWN   Row == 9 && dir == UP, then draw (9$)
7$:
	LD	A,B
	CP	#119
	JR	NZ,10$
	LD	A,#1
	CP	H
	JR	Z,9$
10$:	LD	A,H
	CP	#3	;DOWN?  SKIP
	JR	Z,8$
	CP	#1	; RIGHT? SKIP
	JR	Z,8$


	.endif
9$:
	PUSH	BC  
	PUSH	DE  
	LD	A,(DE)  
	ADD	A,B  
	LD	B,A  
	INC	DE  
	LD	A,(DE)  
	ADD	A,C  
	LD	C,A  
	INC	DE  
	LD	A,(DE)  
	OR	A  
	LD	D,#11  
	JR	Z,6$
	CALL	LINEV  
	JR	5$ 
6$:	CALL	LINEH
5$:	POP	DE
	POP	BC  
8$:	POP	AF  
4$:	INC	H
	JR	NZ,3$
	LD	A,#10  
	ADD	A,B  
	LD	B,A  
	CP	#110  
	JR	C,2$  
	POP	DE  
	INC	DE  
	JR	MAZ1  
THEEND:	COLOR	#MAGENT 
	PLOT	#60,#56  

	LD	D,#9  
	CALL	LINEH  
	POP	IX
	RET

_DUMP::	EX	DE,HL
DUMP:	LD	A,(DE) 
	OR	A  
	RET	M  
	LD	B,A  
	INC	DE  
	LD	A,(DE)  
	LD	C,A  
	INC	DE  
	PUSH	DE  
	CALL	MESOUT  
	POP	DE  
	JR	DUMP  
	
	.area _DATA
_POSTAB::
	.db	-5, -5, 0, 5, -5, 1, -5, -5, 1, -5, 5, 0; up right left down 
_FRUITS::
	.db	0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
FRTTAB:	.dw	CHERRY, STRAW, LEMON, APPLE, CABAGE, GALAX, BELL
	.dw	KEY
CHERRY:	.db	GREEN, 1, 6, 26, 34, 0, 0, 0, RED, 0, 0, 0, 0, 0x77, 0x55, 0x77
	.db	WHITE, 0, 0, 0, 0, 0, 34, 0, 0x81
STRAW:	.db	GREEN, 8, 8, 0, 0, 0, 0, 0, RED, 0, 0x36, 0x6E, 0x38, 0x2E, 0x18
	.db	8, WHITE, 0, 0, 17, 68, 16, 4, 0, 0x81
LEMON:	.db	GREEN, 6, 8, 0, 0, 0, 0, 0, YELLOW, 0, 0x36, 127, 127, 127
	.db	0x3E, 0x1C, 0x81
APPLE:	.db	GREEN, 0x14, 8, 0, 0, 0, 0, 0, RED, 0, 38, 0x78, 0x7D, 0x7D
	.db	0x3E, 20, WHITE, 0, 0, 4, 2, 2, 0, 0, 0x81
CABAGE:	.db	CYAN, 0x3C, 8, 0, 0, 0, 0, 0, GREEN, 0, 0x14, 0x36, 0x5F
	.db	0x7B, 0x2E, 24, WHITE, 0, 0, 8, 32, 4, 16, 0, 0x81
GALAX:	.db	CYAN, 65, 65, 65, 0x63, 20, 8, 8, RED, 8, 20, 34, 0, 0, 0, 0
	.db	YELLOW, 0, 8, 0x1C, 0x1C, 8, 0, 0, 0x81
BELL:	.db	YELLOW, 0x1C, 0x36, 0x3A, 0x2E, 0x3A, 0x3E, 0, WHITE, 0, 0, 0
	.db	0, 0, 0, 0x55, CYAN, 0, 0, 0, 0, 0, 0, 0x2A, 0x81
KEY:	.db	CYAN, 0x3C, 0x24, 0, 8, 0, 8, 0, WHITE, 0, 24, 16, 16, 16, 16
	.db	16, 0x81
	
_DOTS::
	.db	19, 11, 24, 11, 29, 11, 34, 11, 19, 16, 19, 26, 19, 31
	.db	24, 31, 29, 31, 34, 31, 19, 36, 19, 41, 24, 41, 29, 41
	.db	34, 41, 19, 83, 24, 83, 29, 83, 34, 83, 19, 88, 24, 93
	.db	29, 93, 29, 98, 19, 103, 24, 103, 29, 103, 34, 103
	.db	19, 108, 19, 113, 24, 113, 29, 113, 34, 113
;	FIRST	SECTION

	.db	39, 11, 44, 11, 49, 11, 39, 16, 39, 21, 39, 26, 39, 31
	.db	44, 31, 49, 31, 39, 36, 39, 41, 39, 46, 39, 51, 39, 56
	.db	39, 62, 39, 68, 39, 73, 39, 78, 39, 83, 44, 83, 49, 83
	.db	39, 88, 39, 93, 44, 93, 49, 93, 39, 98, 49, 98, 39, 103
	.db	39, 113, 44, 113, 49, 113, 49, 36, 49, 41, 49, 103
;	SECOND	SECTION

	.db	54, 11, 59, 11, 59, 16, 59, 21, 59, 26, 54, 31, 59, 31
	.db	54, 41, 59, 41, 59, 46, 54, 83, 59, 83, 59, 88, 54, 93
	.db	59, 93, 54, 103, 59, 103, 59, 108, 54, 113, 59, 113
	.db	69, 11, 69, 16, 69, 21, 69, 26, 69, 31, 69, 41, 69, 46
	.db	69, 83, 69, 88, 69, 93, 69, 103, 69, 108, 69, 113
	.db	64, 31, 64, 113
;	THIRD	SECTION

	.db	74, 11, 79, 11, 84, 11, 89, 11, 89, 16, 89, 21, 89, 26
	.db	74, 31, 79, 31, 84, 31, 89, 31, 79, 36, 79, 41, 74, 41
	.db	89, 36, 89, 41, 89, 46, 89, 51, 89, 56, 89, 62, 89, 68
	.db	89, 73, 89, 78, 74, 83, 79, 83, 84, 83, 89, 83, 89, 88
	.db	74, 93, 79, 93, 84, 93, 89, 93, 79, 98, 89, 98, 74, 103
	.db	79, 103, 89, 103, 74, 113, 79, 113, 84, 113, 89, 113
;	FOURTH	TYPE

	.db	94, 11, 99, 11, 104, 11, 109, 11, 109, 16, 109, 26
	.db	94, 31, 99, 31, 104, 31, 109, 31, 109, 36, 94, 41
	.db	99, 41, 104, 41, 109, 41, 94, 83, 99, 83, 104, 83
	.db	109, 83, 109, 88, 104, 93, 99, 93, 99, 98, 99, 103
	.db	94, 103, 104, 103, 109, 103, 94, 113, 99, 113
	.db	104, 113, 109, 113, 109, 108, -1, -1
; FIFTH AND FINAL SECTION

_YTURN::
	.db	11, 21, 31, 41, 51, 62, 73, 83, 93, 103, 113, -1	
_MAZE::
	.db	5, 9, 1, 9, 3, 5, 9, 1, 9, 3
	.db	6, 15, 6, 15, 6, 6, 15, 6, 15, 6
; PAGE 26 FOLLOWS

	.db	4, 9, 0, 1, 8, 8, 1, 0, 9, 2
	.db	12, 9, 2, 12, 3, 5, 10, 4, 9, 10
	.db	13, 11, 6, 5, 8, 8, 3, 6, 13, 11
	.db	9, 9, 0, 2, 13, 11, 4, 0, 9, 9 ; 5   	; D_UP=1, D_RIGHT=2, D_LEFT=4, D_DOWN=8, D_NONE
	.db	13, 11, 6, 4, 9, 9, 2, 6, 13, 11
	.db	5, 9, 0, 8, 3, 5, 8, 0, 9, 3
	.db	12, 3, 4, 1, 8, 8, 1, 2, 5, 10
	.db	5, 8, 10, 12, 3, 5, 10, 12, 8, 3
	.db	12, 9, 9, 9, 8, 8, 9, 9, 9, 10
	
_PRESENTEDBY::
	.db	RED
	.ascis	'*** PAC-MAN ***'
	.db	WHITE,-1
	.ascis	'THE EXACT COPY'  
	.ascis	'PRESENTED HERE'  
	.ascis	'BY JEFF KESNER AND'  
	.ascis	'MATTHEW FRANCEY'
	.db	-1,RED  
