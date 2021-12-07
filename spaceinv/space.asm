	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.module space
	.optsdcc -mz80

	.include "dazzler.mac"
	.include "dazzler.abs"
	
	.globl MKZERO, RAND, MESOUT, PNUM, XY, RED, WHITE, BLACK, BLUE, XY, LINEH, ONOFF, NUMZER, TESTP, CLS, XLEN, INVCHR, DAZMOD, DAZINIT
	.globl CHAR_BLOCK
	.globl BUTTNL, BUTTNR  
	.globl FORT, LB, SDRAWR, XPLDR1
	
	.area _CODE
_STARTA::	
STARTA::
	CALL	DAZINIT
	XOR	A 
	LD	(SCORE),A  
	LD	(SCORE+1),A  
	CALL	HIGHZ  
	MOV	(SCR1),#SC1/512+0x80 
	MOV	(SCR2),#SC2/512+0x80  
	; CALL	MKZERO  
START:	
	; LD	A,#SC1/512+0x80 
	; OUT	(#14),A  
	XOR	A  
	OUT	(#0x34),A  
	;LD	A,#0x7E  
	;OUT	(#15),A  
; 0286
	XOR	A  
	OUT	(#TUARTA_MASK),A  
	CALL	CLS  ; All above commented out lines are now handled in DAZINIT
	COLOR	#RED  
	LD	BC,#24*256+30  
	LD	HL,#SINVAD  
	CALL	MESOUT  
	LD	BC,#21*256+12  
	LD	HL,#SMES  
	CALL	MESOUT  
	CALL	WS  
	LD	BC,#36*256+54  
	LD	HL,#MEND1  
	CALL	MESOUT  
	LD	BC,#36*256+61  
	LD	HL,#MEND2  
	CALL	MESOUT  
	LD	BC,#36*256+68  
	LD	HL,#MEND3  
	CALL	MESOUT  
	LD	BC,#36*256+75  
	LD	HL,#MEND4  
	CALL	MESOUT  
	LD	BC,#24*256+102  
	LD	HL,#P4  
	CALL	MESOUT  
	LD	BC,#12*256+114  
	LD	HL,#P1  
	CALL	MESOUT  
	LD	BC,#12*256+120  
	LD	HL,#P2  
	CALL	MESOUT  
	JP	WAIT  

; Todo:  Turn off Tuart interupts
__exit::
	LD	A,#0
	OUT	(#TUARTA_MASK),A
	LD	C,#0
	CALL	#5
	
	.area _DATA
SINVAD:	.db	0x01D, 0x01A, 0x0B, 0x0D, 0x0F, 0x0A, 0x13, 0x18, 0x20, 0x0B, 0x0E, 0x0F, 0x1C, 0x1D, 0x0FF
SMES:	.db	0x1A, 0x1C, 0x0F, 0x1D, 0x1D, 0x0A, 0x03, 0x0A, 0x1E, 0x19, 0x0A, 0x1D, 0x1E, 0x0B, 0x1C, 0x1E, 0x0FF	; PRESS 3 TO START 
MEND1:	.db	0x27, 0x26, 0x03, 0x00, 0x0A, 0x1A, 0x19, 0x13, 0x18, 0x1E, 0x1D, 0x0FF					; <triangle invader>=30 POINTS 
MEND2:	.db	0x28, 0x26, 3, 0, 0x0A, 0x1A, 0x19, 0x13, 0x18, 0x1E, 0x1D, 0x0FF					; <bubble invader>=30 POINTS 
MEND3:	.db	0x29, 0x26, 2, 0, 0x0A, 0x1A, 0x19, 0x13, 0x18, 0x1E, 0x1D, 0x0FF					; <armed invader>=20 POINTS 
MEND4:	.db	0x2A, 0x26, 01, 0, 0x0A, 0x1A, 0x19, 0x13, 0x18, 0x1E, 0x1D, 0x0FF					; <skeleton invader>=10 POINTS 
P1:	.db	26, 28, 15, 29, 29, 10, 1, 10, 30, 25, 10, 0x11, 0x19, 0x0A, 0x16, 0x0F, 0x10, 0x1E, 0x0FF		; PRESS 1 TO GO LEFT 
P4:	.db	0x1A, 0x1C, 0x0F, 0x1D, 0x1D, 0x0A, 4, 0x0A, 0x1E, 0x19, 0x0A, 0x10, 0x13, 0x1C, 0x0F, 0x0FF		; PRESS 4 TO FIRE 
P2:	.db	0x1A, 0x1C, 0x0F, 0x1D, 0x1D, 0x0A, 2, 0x0A, 0x1E, 0x19, 0x0A, 0x11, 0x19, 0x0A, 0x1C, 0x13, 0x11, 0x12, 0x1E, 0x0FF; PRESS 2 TO GO RIGHT 
HSCOM:	.db	0x12, 0x13, 0x11, 0x12, 0x0A, 0x1D, 0x0D, 0x19, 0x1C, 0x0F, 0x1D, 0x0FF					; HIGH SCORES 
	.area _CODE
	
WAIT:	LD	HL,#0 
	CALL	WAITL  
	CALL	CLS 
	LD	A,#0x7F  
	OUT	(#DAZZ_COLOR),A  
	LD	BC,#31*256+5  
	LD	HL,#HSCOM  
	COLOR	#WHITE  
	CALL	MESOUT  
	LD	BC,#13+5*256  
	MOV	(LLEFT),#20 ; 20 LINES
	LD	HL,#INVDAT  
WAIT3:	MOV	(CLEFT),#14 ; 14 CHARACTERS NAME
WAIT4:	LD	A,(HL) 
	INC	HL  
	PUSH	HL  
	CALL	PNUM  
	POP	HL  
	LD	A,#0  
CLEFT	.equ	.-1 
; 0368

	DEC	A  
	LD	(CLEFT),A  
	JR	NZ,WAIT4  
	PUSH	HL  
	PUT	#10  
	PUT	#10 ; 2 SPACES
		  
		  
	POP	HL  
	XOR	A  
	RLD		; GET FIRST NYBBLE FROM (HL)
	PUSH	HL  
	PUSH	AF  
	CALL	PNUM  
	POP	AF  
	POP	HL  
	RLD	  
	PUSH	HL  
	PUSH	AF  
	CALL	PNUM  
	POP	AF  
	POP	HL  
	RLD	  
	INC	HL  
	RLD	  
	PUSH	HL  
	PUSH	AF  
	CALL	PNUM  
	POP	AF  
	POP	HL  
	RLD	  
	PUSH	HL  
	PUSH	AF  
	CALL	PNUM ; 4 DIGIT SCORE
	XOR	A  
	CALL	PNUM ; PRINT OUT A 0 FOR FIFTH DIGIT
	POP	AF  
	POP	HL  
	RLD	  
	INC	HL  
	LD	B,#5 ; ADVANCE SCREEN POSITION TO X=5, Y=C+6
	LD	A,#6  
	ADD	A,C  
	LD	C,A  
	LD	A,#0  
LLEFT	.equ	.-1 
	DEC	A  
	LD	(LLEFT),A  
	JP	NZ,WAIT3  
	LD	HL,#0  
WAITI:	CALL	WAITL
	JP	START  
WAITL:	LD	B,#6 
WAITL1:	LD	HL,#0 
WAITL2:	IN	A,(#0x18)
; 0425

	AND	#BUTTNP  
	JR	Z,WAITO  
	DEC	HL  
	LD	A,H  
	OR	L  
	JR	NZ,WAITL2  
	DJNZ	WAITL1  
	RET	  
WAITO:	MOV	(SET),#-1 
	LD	(LEV),A  
	MOV	(LBASES),#3  
	MOV	(BBASES),#1  
	LD	HL,#0  
	LD	(SCORE),HL  
	XOR	A  
	LD	(SETDIS),A  
START1:	LD	HL,#0 
	MOV	(SWH1),#0x7F  	  
	XOR	A  
	LD	(DROPW),A  
	LD	(SHIP),A  
	LD	(SHIPOC),A  
	LD	(DALIEN),A  
	INC	A  
	LD	(SLEN),A  
	LD	(SHIPE),A  
STLOP:	DEC	HL 
	LD	A,L  
	OR	H  
	JP	NZ,STLOP  
	XOR	A  
	LD	(SPCC),A  
	LD	(SD),A  
	MOV	(SD),#2  
		  
		  
	CALL	CLS 
	LD	A,(LEV)  
	INC	A  
	CP	#9  
	JR	NZ,OKL  
	LD	A,#1  
OKL:	LD	(LEV),A 
	LD	A,(SET)  
	INC	A  
	CP	#17  
	JP	NZ,OKS  
	LD	A,#9  
OKS:	LD	(SET),A 
	LD	A,#0  
; 0482

SETDIS	.equ	.-1 
	INC	A  
	DAA	  
	LD	(SETDIS),A  
	XOR	A  
	LD	(SINC),A  
	CALL	SCR  
	LD	HL,#LEVD  
	MOV	E,(LEV)  
	LD	D,#0  
	ADD	HL,DE  
	LD	E,(HL)  
	LD	D,#0  
	LD	HL,#LEVD1  
	ADD	HL,DE  
	MOV	(LEVP),(HL)  
	SUB	#50  
	LD	(LEVP1),A  
	MOV	E,(SET)  
	LD	D,#0  
	LD	HL,#SETD1  
	ADD	HL,DE  
	LD	E,(HL)  
	LD	D,#0  
	LD	HL,#0  
	ADD	HL,DE  
	ADD	HL,HL  
	ADD	HL,HL  
	ADD	HL,HL  
	ADD	HL,DE  
	ADD	HL,DE  
	ADD	HL,DE  
	LD	D,H  
	LD	E,L  
	ADD	HL,HL  
	ADD	HL,HL  
	ADD	HL,DE  
	LD	DE,#SETD  
	ADD	HL,DE  
	LD	(SETP),HL  
	LD	SP,#STACK 
	IM	0  
	LD	C,#107  
LEVP	.equ	.-1 
	LD	HL,#ROW1  
SET1:	LD	B,#110 
SET2:	XOR	A 
	LD	(HL),A  
	INC	HL  
	LD	(HL),B  
; 0539

	INC	HL  
	LD	(HL),C  
	INC	HL  
	LD	A,#-8  
	ADD	A,B  
	LD	B,A  
	CP	#22  
	JP	NZ,SET2  
	LD	A,#-10  
	ADD	C  
	LD	C,A  
	CP	#57  
LEVP1	.equ	.-1 
	JP	NZ,SET1  
	XOR	A  
	LD	(MIS),A  
	LD	(MIS1),A  
	LD	(MPOS),A  
	LD	HL,#ROW1  
	LD	DE,#0  
SETP	.equ	.-2 
	LD	B,#55  
STY1:	MOV	(HL),(DE) 
	INC	DE  
	INC	HL  
	INC	HL  
	INC	HL  
	DJNZ	STY1  
	MOV	(RP),#10  
	LD	(OP),A  
	XOR	A  
	LD	(DOWNP),A  
	MOV	(CM),#54  
	XOR	A  
	LD	(COUNT),A  
	LD	A,#0x0C3  
	LD	(0),A  
	LD	(8),A  
	LD	(0x18),A  
	LD	(0x30),A  
;	LD	(0x38),A  
	LD	HL,#INTER1  
	LD	(1),HL  	; Timer 1
	LD	HL,#XPLO_INT  
	LD	(9),HL  	; Timer 2
	LD	HL,#DAZTRK
	LD	(0x19),HL  	; Timer 3
	LD	HL,#SHH_INT  
; JOK temporary hack, can't use these and the debugger at the same time
; Debugger uses RST 38 for break point

;	LD	(0x31),HL  	; Timer 4 not compatible with debugger
;	LD	HL,#SWHOOP  
;	LD	(0x39),HL  	; Timer 5
; 0596

;	LD	A,#0x0CB  	; Can't use timer 5 with the debugger
	ld	a,#0x0b
	OUT	(#TUARTA_MASK),A  	; Interrupt mask
	LD	A,#8  
	OUT	(#TUARTA_CMD),A  	; Command (interrupt enable)
	EI	  
	LD	A,#62  
	OUT	(TIMERA_3),A  	; Timer 3
	CALL	DAZMOD  
	LD	A,#100  
	OUT	(TIMERA_1),A  	; Timer 1
	LD	A,#255  
	OUT	(TIMERA_4),A  	; Timer 4
	OUT	(TIMERA_5),A  	; Timer 5
	MOV	(BOM),#-1  
	LD	BC,#119+19*256  
	CALL	FORT  
	LD	BC,#119+45*256  
	CALL	FORT  
	LD	BC,#119+70*256  
	CALL	FORT  
	LD	BC,#119+94*256  
	CALL	FORT  
	LD	BC,#5+97*256  
	COLOR	#BLUE  
	PUT	(LBASES)  
	MOV	D,(LBASES)  
	LD	HL,#BASESX  
BPO1:	LD	C,#5 
	LD	B,(HL)  
	INC	HL  
	DEC	D  
	JR	Z,BPO2  
	PUSH	HL  
	PUSH	DE  
	CALL	LB  
	POP	DE  
	POP	HL  
	JR	BPO1  
BPO2:	COLOR	#BLACK 
	LD	BC,#113+27*256  
	LD	A,(SETDIS)  
	AND	#0x0F  
	LD	(STD1),A  
	CALL	PNUM  
	LD	BC,#113+53*256  
	LD	A,#0  
; 0653

STD1	.equ	.-1 
	CALL	PNUM  
	LD	BC,#113+78*256  
	PUT	(STD1)  
	LD	BC,#113+102*256  
	PUT	(STD1)  
	MOV	(DIREC),#2  
LOOPB:	MOV	(DIRECR),(DIREC) 
	COLOR	#BLACK  
	LD	BC,#7  
LOOPB1::	CALL	XY
	INC	B  
	JP	P,LOOPB1  
	LD	B,#0  
	INC	C  
	LD	A,#107  
	CP	C  
	JR	NZ,LOOPB1  
	LD	B,#55  
	LD	HL,#ROW1  
	LD	DE,#ROW1A  
INV1:	MOV	(DE),(HL) 
	INC	HL  
	INC	DE  
	MOV	(DE),(HL)  
	INC	HL  
	INC	DE  
	LD	A,(HL)  
	SUB	#126  
	LD	(DE),A  
	INC	HL  
	INC	DE  
	DJNZ	INV1  
INV2:	LD	B,#55 ; 55 invaders
	LD	HL,#ROW1A+2  
	LD	A,(ROW1+2)  
	CP	(HL)  
	JP	Z,LOOPZ  
	DEC	HL  
	DEC	HL  
	MOV	(DOWN),#3  
; 0710 / 0711

	XOR	A  
	LD	(DIREC),A  
INV3:	LD	D,(HL) 
	INC	HL  
	PUSH	BC  
	LD	B,(HL)  
	INC	HL  
	INC	(HL)  
	INC	(HL)  
	INC	(HL)  
	LD	C,(HL)  
	INC	HL  
	LD	A,C  
	AND	A  
	JP	M,INV4 ; -ve, no one there
	CP	#15 ; 15 = blinked off
	JP	C,INV4  
	LD	A,D  
	AND	A  
	JR	Z,INV4  
	CP	#5  
	JP	NC,INV4  
	PUSH	DE  
	PUSH	HL  
	CALL	MD ; draw one invader
	POP	HL  
	POP	DE  
INV4:	POP	BC
	DJNZ	INV3  
	LD	A,(PHASE)  
	INC	A  
	LD	(PHASE),A  
	MOV	(DUR),#20  
	JP	INV2  
LOOPZ:	XOR	A 
	LD	(DOWN),A  
	LD	A,#2  
DIRECR	.equ	.-1 
	LD	(DIREC),A  
LOOP:	LD	A,#0 
COUNTR	.equ	.-1 
	INC	A  
	LD	(COUNTR),A  
	AND	#3  
	CALL	Z,INT1  
	LD	A,#0  
IBOMBC	.equ	.-1 
	INC	A  
	LD	(IBOMBC),A  
	CP	#5  
	JP	NZ,IBOMBL  
	XOR	A  
	LD	(IBOMBC),A  
	CALL	IBOMB  
; 0767

IBOMBL:	COLOR	#BLACK 
	LD	A,#0  
AFMATH	.equ	.-1 
	AND	A  
	JP	Z,AFMTH1  
	DEC	A  
	LD	(AFMATH),A  
	CP	#0x070  
	JP	NZ,AFMTH2  
	LD	C,#13  
	LD	A,#0  
LKILL1	.equ	.-1 	; Display the score for hitting the saucer
	LD	B,A  
	COLOR	#RED  
	LD	A,#0  
LKILL	.equ	.-1 
	AND	#0x0F0  
	RRCA	  
	RRCA	  
	RRCA	  
	RRCA	  
	CALL	PNUM  
	LD	A,(LKILL)  
	AND	#0x0F  
	CALL	PNUM  
	XOR	A  
	CALL	PNUM  
AFMTH2:	LD	A,(AFMATH) 
	CP	#1  
	JP	NZ,AFMTH1  
	MOV	B,(LKILL1)  
	DEC	B  
	DEC	B  
	DEC	B  
	DEC	B  
	LD	C,#13  
	COLOR	#BLACK  
	LD	E,#5  
TAF:	LD	D,#19 
	PUSH	BC  
	CALL	LINEH  
	POP	BC  
	DEC	C  
	DEC	E  
	JP	NZ,TAF  
AFMTH1:	MOV	(AFM3),(RP) 
; 0824

	LD	A,(OP)  
	CP	#0  
AFM3	.equ	.-1 
	JR	Z,AFM4  
	LD	B,A  
	LD	C,#127  
	CALL	LB  
AFM4:	COLOR	#RED 
		 
	MOV	(OP),(RP)  
	LD	B,A  
	LD	C,#127  
	CALL	LB  
	LD	A,#0  
POOF	.equ	.-1 
	AND	A  
	JP	Z,CONT  
	DEC	A  
	LD	(POOF),A  
	CALL	Z,XPLOER  
	JP	LOOP1  
CONT:	LD	A,#0 
MIS	.equ	.-1 
	AND	A  
	JP	Z,MREAD  
	DEC	A  
	CP	#11  
	JR	Z,MERA  
	LD	(MIS),A  
	LD	C,A  
	COLOR	#TESTP
	MOV	B,(MPOS)  
	CALL	XY  
	JR	NZ,MERA  
	COLOR	#WHITE  
	CALL	XY  
	INC	C  
	INC	C  
	INC	C  
	COLOR	#BLACK  
; 0881        

	CALL	XY  
	JP	LOOP1  
MERA:	MOV	(MIS1),(MIS) 	; Did the saucer get hit?
	CALL	CHMAN  
	LD	A,(SHIP)  
	AND	A  
	JP	Z,NOHIT  
	LD	B,A  
	LD	A,(MPOS)  
	SUB	B  
	CP	#11  
	JP	NC,NOHIT  
	LD	A,(MIS)  
	CP	#14  
	JP	NC,NOHIT  
	CP	#9  
	JP	C,NOHIT  
	LD	A,(SHIPOC)  
	CP	#2  
	JP	NZ,SCKS1  
	LD	A,(BLINKR)  
	CP	#5  
	JP	NC,NOHIT  
SCKS1:	XOR	A 
	LD	(SHIPE),A  
	MOV	(AFMATH),#0x0A0  
	CALL	BOOM  
	MOV	E,(COUNT)  
	LD	E,A  
	LD	D,#0  
	LD	HL,#CDAT  
	ADD	HL,DE  
	LD	A,(SHIPOC)  
	CP	#2  
	JP	NZ,SCKS2  
	LD	HL,#TWOHUN  
SCKS2:	MOV	(SINC),(HL) 
; LINE 923 (BELOW) MISSING ALL THAT REMAINS IS "KV" AT THE END OF THE LINE BUT IT IS JUST A MACRO EXPANSION

;KV

	LD	(LKILL),A  
	CALL	SCR  
	MOV	(LKILL),(SHIP)  
NOHIT:	LD	A,(MIS1) 
	LD	C,A  
	MOV	B,(MPOS)  
	XOR	A  
	LD	(MIS),A  
; 0938        

	COLOR	#BLACK  
	CALL	XY  
	INC	C  
	CALL	XY  
	INC	C  
	CALL	XY ; MISSING LINE, RECOVERED FROM HEX
	INC	C  
	CALL	XY  
	COLOR	#WHITE  
	CALL	XPLODR  
	MOV	(POOF),#40  
		  
; 0954

	JP	LOOP1  
TWOHUN:	.db	0x20
MREAD:	IN	A,(#0x18)
	AND	#BUTTNF  
	JP	NZ,LOOP1A  
	LD	A,#0  
BHOLD	.equ	.-1 
	AND	A  
	JP	Z,LOOP1  
	XOR	A  
	LD	(BHOLD),A  
	LD	A,#50  
	OUT	(SHH_TIMER),A  
	LD	A,(COUNT)  
	INC	A  
	CP	#15  
	JP	NZ,COUNT1  
	LD	A,(SHIP)  
	AND	A  
	JP	NZ,FORGCD  
	LD	A,(SD)  
	NEG	  
	LD	(SD),A  
FORGCD:	XOR	A 
COUNT1:	LD	(COUNT),A 
	LD	A,(OP)  
	ADD	A,#3  
	LD	(MPOS),A  
	MOV	(MIS),#122  
	JR	LOOP1  
LOOP1A:	MOV	(BHOLD),#1 
LOOP1:	LD	A,(COUNTR) 
	AND	#3  
	CALL	Z,PR  
	LD	A,#0  
; 0995        

SPCC	.equ	.-1 
	INC	A  
	LD	(SPCC),A  
	CP	#14  
	JP	NZ,LOOP2  
	XOR	A  
	LD	(SPCC),A  
	LD	A,#0  
SHIP	.equ	.-1 
	AND	A  
	JP	Z,NOSHIP  
	COLOR	#BLACK  
	LD	E,#5  
	LD	C,#13  
	LD	A,(SHIP)  
	DEC	A  
	DEC	A  
	LD	B,A  
TL:	LD	D,#15 
	PUSH	BC  
	CALL	LINEH  
	POP	BC  
	DEC	C  
	DEC	E  
	JP	NZ,TL  
	INC	B  
	INC	B  
	LD	A,#0  
SHIPE	.equ	.-1 
	AND	A  
	MOV	(SHIPE),#1  
	LD	A,#1  
	LD	(SHIPE),A  
	JP	NZ,NOH  
	XOR	A  
	LD	(SHIP),A  
	JP	NOSHIP  
NOH:	LD	A,#0 
DROPW	.equ	.-1 
	AND	A  
	JP	NZ,SD2  
	LD	A,#0  
SD	.equ	.-1 
	ADD	A,B  
	LD	(SHIP),A  
	CP	#118  
	JP	NZ,SD1  
	XOR	A  
	LD	(SHIP),A  
	JP	NOSHIP  
SD1:	AND	A 
	JP	NZ,SD2  
	LD	(SHIP),A  
	JP	NOSHIP  
SD2:	COLOR	#RED 
	LD	C,#13  
	LD	A,(SHIPOC)  
	CP	#2  
	JP	NZ,SD2A  
	LD	A,#0  
; 1061

BLINKR	.equ	.-1 
	INC	A  
	LD	(BLINKR),A  
	CP	#5  
	JP	C,BLIN1  
	CP	#10  
	JP	NZ,BLIN2  
	XOR	A  
	LD	(BLINKR),A  
BLIN2:	COLOR	#BLACK 
BLIN1:	CALL	BLSHDR
	JP	LCOUNT  
SD2A:	CALL	SDRAWR
	JP	LCOUNT  
BLSHDR:	LD	A,#5 
	ADD	A,B  
	LD	B,A  
	PUT	#45  	; Blinking saucer left
	PUT	#52  	; Blinking saucer right
	RET	  
	
NOSHIP:	LD	A,(SLEN) 
	AND	A  
	JP	NZ,LCOUNT  
	LD	A,(SD)  
	AND	A  
	LD	A,#2  
	JP	P,DOK  
	LD	A,#116  
DOK:	LD	(SHIP),A 
	XOR	A  
	LD	(SLEN),A  
	LD	A,#0  
SHIPOC	.equ	.-1 
	INC	A  
	LD	(SHIPOC),A  
LCOUNT:	LD	A,#0 
SLEN	.equ	.-1 
	INC	A  
	LD	(SLEN),A  
LOOP2:	CALL	RAND
	AND	#0x1F  
	JP	NZ,LOOP3  
	LD	A,(SHIP)  
	AND	A  
	JP	Z,LOOP3  
	LD	A,(DROPW)  
	AND	A  
	JP	NZ,LOOP3  
	LD	A,(SET)  
	CP	#2  
	JP	C,LOOP3  
	LD	E,#11  
	LD	HL,#ROW5  
L2C:	LD	A,(HL) 
	AND	A  
; 1175        

	JP	NZ,L2A  
	INC	HL  
	LD	A,(HL)  
	CP	#10  
	JP	C,L2A1  
	CP	#110  
	JP	NC,L2A1  
	LD	A,(SHIP)  
	ADD	A,#8  
	SUB	(HL)  
	JP	P,L2B  
	NEG	  
L2B:	CP	#3 
	JP	NC,L2A1  
	DEC	HL  
	LD	(HL),#13  
	MOV	(DROPW),#1  
	JP	LOOP3  
L2A:	INC	HL 
L2A1:	INC	HL 
	INC	HL  
	DEC	E  
	JR	NZ,L2C  
LOOP3:	LD	A,#0 
DALI1	.equ	.-1 
	INC	A  
	LD	(DALI1),A  
	AND	#3  
	JP	Z,LOOP4  
	LD	A,#0  
DALIEN	.equ	.-1 
	AND	A  
	JP	Z,LOOP4  
	LD	E,A  
	LD	IX,#ALIENT  
L3A:	LD	B,(IX) 
	LD	C,+1(IX)  
	PUSH	BC  
	PUSH	DE  
	COLOR	#BLACK  
	PUT	#44  
	POP	DE  
	POP	BC  
	INC	C  
	INC	C  
	LD	A,#1  
	OR	C  
	LD	C,A  
	LD	+1(IX),A  
	PUSH	AF  
	PUSH	BC  
	PUSH	DE  
	COLOR	#WHITE  
; 1236        

	PUT	#44  
	POP	DE  
	POP	BC  
	POP	AF  
	CP	#121  
	JR	NZ,L3B  
	PUSH	DE  
	PUSH	BC  
	PUSH	HL  
	LD	A,E  
	ADD	A,A  
	LD	C,A  
	LD	B,#0  
	PUSH	IX  
	POP	DE  
	LD	H,D  
	LD	L,E  
	INC	HL  
	INC	HL  
	LDIR	  
	POP	HL  
	POP	BC  
	POP	DE  
	LD	A,(DALIEN)  
	DEC	A  
	LD	(DALIEN),A  
	DEC	E  
	JR	Z,LOOP4  
	JP	L2A  
L3B:	INC	IX 
	INC	IX  
	DEC	E  
	JP	NZ,L2A  
LOOP4:	LD	A,#0 
INVEXC	.equ	.-1 
	AND	A  
	JP	Z,LOOP5  
	LD	E,A  
	LD	IX,#INVEXP  
L4A:	DEC	(IX) 
	JR	NZ,L4B  
	COLOR	#BLACK  
	LD	B,+1(IX)  
	LD	C,+2(IX)  
	CALL	XPLDR1  
	PUSH	DE  
; 1289        

	LD	D,#0  
	LD	HL,#0  
	ADD	HL,DE  
	ADD	HL,DE  
	ADD	HL,DE  
	LD	B,H  
	LD	C,L  
	PUSH	IX  
	PUSH	DE  
	LD	H,D  
	LD	L,E  
	INC	HL  
	INC	HL  
	INC	HL  
	LDIR	  
	POP	DE  
	LD	A,(INVEXC)  
	DEC	A  
	LD	(INVEXC),A  
	DEC	E  
	JP	Z,LOOP5  
	JP	L4A  
L4B:	INC	IX 
	INC	IX  
	INC	IX  
	DEC	E  
	JR	NZ,L4A  
LOOP5:	JP	LOOP
IBOMB:	LD	IY,#BOM 
ABCD:	LD	B,(IY) 
	LD	C,+1(IY)  
	LD	A,B  
	INC	A  
	JP	Z,DRP  
	COLOR	#BLACK  
	PUSH	BC  
	INC	B  
	PUT	+2(IY)  
	LD	A,+2(IY)  
	XOR	#1  
	LD	+2(IY),A  
	POP	BC  
	INC	C  
	INC	C  
	LD	A,C  
	CP	#126  
	JR	NC,HISE  
	COLOR	#TESTP
	CALL	XY  
	JR	NZ,HISE  
	LD	A,(MIS)  
	SUB	C  
	JP	P,JEF1  
; 1350
	NEG	  
JEF1:	CP	#4 
	JP	NC,JEF2  
	LD	A,(MPOS)  
	SUB	B  
	JP	P,JEF3  
	NEG	  
JEF3:	CP	#2 
	JP	C,HISE  
JEF2:	COLOR	#WHITE 
	PUSH	BC  
	INC	B  
	PUT	+2(IY)  
	POP	BC  
	LD	+1(IY),C  
	INC	IY  
	INC	IY  
	INC	IY  
	JP	ABCD  
HISE:	PUSH	BC 
	PUSH	IY  
	POP	DE  
	PUSH	IY  
	POP	HL  
	INC	HL  
	INC	HL  
	INC	HL  
	LD	BC,#50  
	LDIR	  
	POP	BC  
	MOV	E,(INVEXC)  
	LD	D,#0  
	LD	HL,#INVEXP  
	ADD	HL,DE  
	ADD	HL,DE  
	ADD	HL,DE  
	LD	(HL),#20  
	INC	HL  
	LD	(HL),B  
	INC	HL  
	INC	C  
JEF9:	LD	(HL),C 
	INC	E  
	MOV	(INVEXC),E  
	PUSH	BC  
; 1404        
	COLOR	#WHITE  
	CALL	XPLDR1  
	POP	BC  
	LD	A,C  
	CP	#123  
	JP	C,ABCD  
	LD	A,(RP)  
	SUB	B  
	NEG	  
	CP	#8  
	JP	NC,ABCD  
	JP	CRASH  
DRP:	LD	A,#0 
CA4	.equ	.-1 
	OR	A  
	JR	Z,DRP1  
	DEC	A  
	LD	(CA4),A  
	RET	  
DRP1:	CALL	RAND
	AND	#3  
	JR	Z,DRP1A  
DRP1B:	CALL	RAND
	AND	#15  
	CP	#11  
	JR	NC,DRP1B  
	LD	C,A  
	LD	B,#0  
	LD	IX,#ROW1  
	ADD	IX,BC  
	ADD	IX,BC  
	ADD	IX,BC  
	LD	C,#33  
	LD	E,#5  
DRP1C:	LD	A,(IX) 
	AND	A  
	JR	NZ,DRP1D  
DRP1DA:	ADD	IX,BC 
	DEC	E  
	JR	NZ,DRP1C  
	JP	DRP1A  
DRP1D:	CP	#5 
	JR	NC,DRP1DA  
	LD	A,+2(IX)  
	CP	#120  
	RET	NC  
	JR	DROP  
DRP1A:	LD	IX,#ROW1 
	LD	B,#55  
AZW5:	LD	A,(IX) 
	OR	A  
	JP	Z,NODROP  
	CP	#5  
	JP	NC,NODROP  
	LD	A,+2(IX)  
	CP	#120  
	RET	NC  
; 1464        
	LD	A,+1(IX)  
	DEC	A  
	DEC	A  
	LD	C,A  
	LD	A,(RP)  
	SUB	C  
	NEG	  
	JR	Z,DROP  
	CP	#8  
	JR	C,DROP  
NODROP:	INC	IX 
	INC	IX  
	INC	IX  
	DJNZ	AZW5  
	RET	  
DROP:	LD	B,+1(IX) 
	LD	C,+2(IX)  
	DEC	B  
	DEC	B  
	INC	C  
	INC	C  
	INC	C  
	LD	(IY),B  
	LD	+1(IY),C  
FLUBN:	CALL	RAND
	AND	#6  
	JR	Z,FLUBN  
	ADD	A,#44  
	LD	+2(IY),A  
	LD	+3(IY),#255  
	LD	+4(IY),#255  
	MOV	(CA4),A  
	RET	  
CRASH:	COLOR	#BLACK 
	LD	A,#0  
LBASES	.equ	.-1 
	PUSH	AF  
	LD	BC,#5+97*256  
	CALL	PNUM  
	LD	B,#97  
	COLOR	#BLUE  
	POP	AF  
	DEC	A  
	PUSH	AF  
	CALL	PNUM  
	LD	A,#10  
; 1518        
	LD	(RP),A  
	COLOR	#BLACK  
	LD	HL,#BASESX  
	LD	A,(LBASES)  
	DEC	A  
	JR	Z,BPO4  
BPO3:	DEC	A 
	JR	Z,BPO5  
	INC	HL  
	JR	BPO3  
BPO5:	LD	C,#5 
	LD	B,(HL)  
	CALL	LB  
BPO4:	POP	AF
	LD	(LBASES),A  
	JP	Z,EOG  
	CALL	BOOM  
	LD	HL,#0 ; Need interrupt delay count here
LBAS1:	DEC	HL 
	LD	A,L  
	OR	H  
	JR	NZ,LBAS1  
	JP	LOOPB  
CHMAN:	LD	HL,#ROW1 
	LD	C,A  
	MOV	B,(MPOS)  
; 1548        
	MOV	(CC),#55  
LC:	LD	A,(HL) 
	AND	A  
	JP	Z,NC  
	CP	#5  
	EX	AF,AF'  
	LD	A,#0  
	LD	(NPOINT),A  
	EX	AF,AF'  
	JR	C,CHM3  
	EX	AF,AF'  
	LD	A,#100  
	LD	(NPOINT),A  
	EX	AF,AF'  
	LD	E,A  
	INC	HL  
	LD	D,(HL)  
	INC	HL  
	JR	CHM4  
CHM3:	INC	HL 
	LD	D,(HL)  
	DEC	D  
	INC	HL  
	LD	E,(HL)  
CHM4:	DEC	E 
	LD	A,D  
	SUB	B  
; 1578        
	JP	C,NC1  
	CP	#6  
	JP	NC,NC1  
	LD	A,E  
	SUB	C  
	JP	C,NC1  
	CP	#6  
	JP	NC,NC1  
	DEC	HL  
	DEC	HL  
	LD	A,(HL)  
	CP	#5  
	JR	C,CHM5  
	XOR	A  
	LD	(DROPW),A  
	LD	A,#1  
CHM5:	LD	(SCRCH),A 
	XOR	A  
	LD	(HL),A  
	PUSH	HL  
	LD	B,D  
	LD	C,E  
	LD	E,#6  
	LD	A,#-5  
	ADD	B  
	LD	B,A  
	COLOR	#BLACK  
CHM1:	LD	D,#6 	; Erase a killed alien
	CALL	LINEH  
	LD	A,#-6  
	ADD	B  
	LD	B,A  
	DEC	C  
	DEC	E  
	JP	NZ,CHM1  
	LD	A,#1  
	LD	(XPLO),A  
	LD	A,#0  
NPOINT	.equ	.-1 
	LD	(X5),A  
	AND	A  
	JR	Z,CHM6  
	LD	A,(DALIEN)  
	INC	A  
	LD	(DALIEN),A  
	PUSH	HL  
	LD	L,A  
	LD	H,#0  
	ADD	HL,HL  
	LD	DE,#ALIENT  
	ADD	HL,DE  
; 1632        
	POP	HL  
	INC	HL  
	LD	BC,#2  
	LDIR	  
CHM6:	LD	HL,#TDAT 	; Score for this invader kill
	LD	DE,#0  
SCRCH	.equ	.-2 
	DEC	DE  
	ADD	HL,DE  
	LD	A,(HL)  
	LD	(SINC),A  
	CALL	SCR  
	LD	A,(LEV)  
	POP	HL  
	AND	A  
	JP	Z,NOSPLT  
	LD	A,(SCRCH)  
	CP	#2  
	JP	NZ,NOSPLT  
	LD	(HL),#4  
	PUSH	HL  
	INC	HL  
	LD	B,(HL)  
	INC	HL  
	LD	C,(HL)  
	DEC	C  
	PUSH	BC  
	COLOR	#BLACK  
	PUT	#54  
	POP	BC  
	COLOR	#WHITE  
	DEC	B  
	PUT	#40  
	POP	HL  
	DEC	HL  
	LD	C,(HL)  
	DEC	HL  
	LD	B,(HL)  
	DEC	HL  
	LD	(HL),#4  
	DEC	C  
	PUSH	BC  
	COLOR	#BLACK  
	PUT	#54  
	POP	BC  
	COLOR	#WHITE  
; 1693        
	DEC	B  
	PUT	#53  
NOSPLT:	LD	B,#55 
	LD	HL,#ROW1  
EOSL:	LD	A,(HL) 
	AND	A  
	JP	NZ,OK  
	INC	HL  
	INC	HL  
	INC	HL  
	DJNZ	EOSL  
	LD	A,#0x50  
	LD	(SINC),A  
	LD	A,#10  
	LD	(BM1),A  
	LD	A,#5  
	LD	(BM1+1),A  
	LD	A,(SCRCH)  
	CP	#3  
	JP	NZ,NO500  
	CALL	SCR  
	LD	A,(CC)  
	CP	#45  
	JP	NZ,ONLY5  
	LD	A,#1  
	LD	(BM1),A  
	XOR	A  
	LD	(BM1+1),A  
	CALL	SCR  
ONLY5:	LD	A,(CC) 
	CP	#50  
	JP	NZ,ONLY5A  
	LD	A,#8  
	LD	(BM1+1),A  
	LD	A,#0x30  
	LD	(SINC),A  
	CALL	SCR  
ONLY5A:	LD	BC,#21*256+61 
	COLOR	#BLUE  
	LD	HL,#BM1  
	CALL	MESOUT  
	JP	BONUSE  
	.area _DATA
BM1:	.db	1, 0, 0, 0, 10, 26, 25, 19, 24, 30, 10, 12, 255
	.area _CODE
; 1744
BONUSE:	LD	C,#30 
WHOOP:	LD	A,B 
WHOOP1:	DEC	A 
	JP	NZ,WHOOP1  
	LD	A,#0x7F  
WHOOP2	.equ	.-1 
	CPL	  
	LD	(WHOOP2),A  
	OUT	(#0x19),A ; NEED INTERRUPT DELAY HERE
	DEC	B  
	JP	NZ,WHOOP  
	DEC	C  
	JP	NZ,WHOOP  
	COLOR	#BLACK  
	LD	BC,#21*256+61  
	LD	HL,#BM1  
	CALL	MESOUT  
NO500:	LD	A,(SCRCH) 
	ADD	A,#38  
	CP	#39  
	JP	Z,NO500A  
	INC	A  
	CP	#43  
	JP	C,NO500A  
	LD	A,#40  
NO500A:	LD	(SCRCH1),A 
	LD	A,(CC)  
	NEG	  
	ADD	A,#55  
	LD	E,A  
	LD	D,#0  
	LD	HL,#ROW1  
	ADD	HL,DE  
	ADD	HL,DE  
	ADD	HL,DE  
	INC	HL  
	LD	B,(HL)  
	INC	HL  
	LD	C,(HL)  
	LD	A,#1  
	LD	(SOSD),A  
	LD	(SHIP),A  
	LD	A,#0x3F  
	LD	(SWH1),A  
	LD	A,#6  
	LD	(SOSDU),A  
SOSLOP:	COLOR	#BLACK 
	CALL	SOSPUT  
	LD	A,#0  
SOSD	.equ	.-1 
	ADD	A,B  
	LD	B,A  
	CP	#117  
	JP	NZ,SOSD1  
; 1804        
SOSD4:	LD	A,(SOSD) 
	NEG	  
	LD	(SOSD),A  
	PUSH	BC  
	LD	HL,#SOS  
	LD	A,B  
	CP	#30  
	JP	C,GT30  
	LD	B,#5  
	JR	LT30  
GT30:	LD	B,#127-42 
LT30:	COLOR	#RED 
	CALL	MESOUT  
	LD	A,#-1  
	POP	BC  
SOSD1:	CP	#0 
	JP	Z,SOSD4  
SOSD2:	LD	A,#0 
SOSDU	.equ	.-1 
	DEC	A  
	LD	(SOSDU),A  
	JP	NZ,SOSD3  
	LD	A,#6  
	LD	(SOSDU),A  
	DEC	C  
	LD	A,#10  
	CP	C  
	JP	Z,START1  
SOSD3:	COLOR	#RED 
	CALL	SOSPUT  
	PUSH	BC  
	LD	BC,#800  
SOSPT:	DEC	BC 
	LD	A,B  
	OR	C  
; 1845        
	JR	NZ,SOSPT  
	POP	BC  
	LD	A,B  
	CP	#64  
	JP	NZ,SOSLOP  
	CALL	RAND  
	AND	#7  
	JP	NZ,SOSLOP  
	DEC	C  
	LD	A,#-2  
	LD	(DOWN),A  
; 1855        
	XOR	A  
	LD	(DIREC),A  
	LD	(SHIP),A  
	LD	HL,#ENGTRO  	; Engine trouble
	PUSH	BC  
	LD	A,#6  
	ADD	A,C  
	LD	C,A  
	LD	B,#22  
	CALL	MESOUT  
	POP	BC  
	LD	A,#8  
	ADD	A,B  
	LD	B,A  
	LD	A,#-4  
	ADD	A,C  
	LD	C,A  
ELOP:	LD	A,(SCRCH) 
	LD	D,A  
	LD	A,(PHASE)  
	INC	A  
	LD	(PHASE),A  
	PUSH	BC  
	CALL	MD  
	POP	BC  
	DEC	C  
	DEC	C  
	LD	HL,#15000  
ETOBW:	DEC	HL 
	LD	A,H  
	OR	L  
	JR	NZ,ETOBW ; NEED INTERRUPT DELAY HERE
	LD	A,#7  
	CP	C  
	JP	NC,START1  
	JP	ELOP  
	.area _DATA
ENGTRO:	.db	15, 24, 17, 19, 24, 15, 10, 30, 28, 25, 0x1f, 0xc, 0x16, 0xf, 0xff ; Engine Trouble
SOS:	.db	29, 25, 29, 10, 43, 43, 43, 255	; 'SOS !!!' 
	.area _CODE
SOSPUT:	PUSH	BC 
	CALL	SDRAWR  
	POP	BC  
	PUSH	BC  
	LD	A,#8  
	ADD	A,B  
	LD	B,A  
	LD	A,#-4  
	ADD	A,C  
	LD	C,A  
	LD	A,#0  
SCRCH1	.equ	.-1 
	CALL	PNUM  
	POP	BC  
	RET	  
OK:	RET	 
; 1910
NC:	INC	HL 
	INC	HL  
NC1:	INC	HL 
	LD	A,#0  
CC	.equ	.-1 
	DEC	A  
	LD	(CC),A  
	JP	NZ,LC  
	RET	  
PR:	LD	A,(X5) 
	AND	A  
	JR	NZ,PROK  
	LD	A,(XPLO)  	; Wait for explosion of base or of invader kill to finish before advancing again
	CP	#XLEN-1  	; This value means there is no explosion happening
	RET	NZ		; Explosion is happening so do not advance aliens.
	
; Advance the invaders, check when we finish with all 55.
PROK:	IN	A,(#0x18)	; Button port
	AND	#0x80  	
	LD	A,#0  
CM	.equ	.-1 
	INC	A  
	CP	#55  
	JP	NZ,RP1  
	LD	A,#20  
	LD	(DUR),A  
	LD	A,#0  
PHASE	.equ	.-1 
	DEC	A  
	LD	(PHASE),A  
	LD	A,(DOWNP)  
	LD	(DOWN),A  
	AND	A  
	JP	Z,SKIPD  
	LD	A,(DIREC)  
	NEG	  
	LD	(DIREC),A  
SKIPD:	XOR	A 
	LD	(DOWNP),A  
RP1:	LD	(CM),A 
	LD	E,A  
	XOR	A  
	LD	D,A  
	LD	HL,#ROW1  
	ADD	HL,DE  
	ADD	HL,DE  
	ADD	HL,DE  
	LD	D,(HL)  
	LD	A,D  
	CP	#5  
	JP	C,RP4  
	INC	A  
	LD	(HL),A  
	LD	C,A  
	LD	D,#1  
	LD	(YCMP),A  
	INC	HL  
; 1965        
	LD	B,(HL)  
	INC	HL  
	LD	E,(HL)  
	DEC	HL  
	DEC	HL  
	LD	A,#0  
YCMP	.equ	.-1 
	CP	E  
	JR	NZ,YCMP1  
	LD	(HL),#1  
	XOR	A  
	LD	(DROPW),A  
YCMP1:	INC	HL 
	INC	HL  
	LD	A,(CM)  
	DEC	A  
	LD	(CM),A  
	PUSH	BC  
	DEC	C  
	JP	MD1  	; Draw this invader
RP4:	INC	HL 
	LD	A,(DIREC)  
	ADD	(HL)  
	LD	(HL),A  
	LD	B,A  
	LD	A,D  
	AND	A  
	JP	Z,RP3  
	LD	A,B  
	CP	#8  
	JP	NZ,RP2  
	LD	A,#5  
	LD	(DOWNP),A  
RP2:	CP	#126 
	JP	NZ,RP3  
	LD	A,#5  
	LD	(DOWNP),A  
RP3:	INC	HL 
	LD	A,(DOWN)  
	ADD	(HL)  
	LD	(HL),A  
	LD	C,A  
	LD	A,D  
	AND	A  
	JP	Z,PR  
	LD	A,C  
	CP	#127  
	JP	Z,EOG  
MD:	PUSH	BC 
	LD	A,(DIREC)  
	NEG	  
	ADD	A,B  
	DEC	B  
	DEC	B  
	LD	B,A  
	LD	A,(DOWN)  
	NEG	  
	ADD	A,C  
	LD	C,A  
MD1:	DEC	C 
; 2025
	dec	b
	;LD	A,#-6  
	;ADD	A,B  
	;LD	B,A  
	PUSH	DE  
	COLOR	#BLACK  

	LD	A,#CHAR_BLOCK  
	CALL	PNUM ; New code 2020
	POP	DE  
	POP	BC  
	LD	A,D  
	CP	#3  
	LD	A,#RED ; D=4
	JR	C,MDIN  
	LD	A,#WHITE  
	JR	Z,MDIN ; D=3
	LD	A,(PHASE)  
	AND	#1  
	LD	A,#BLUE  
	JR	Z,MDIN  
	LD	A,#RED  
MDIN:	LD	(ONOFF),A 
	DEC	B  
	DEC	C  
	LD	A,(PHASE)  
; 2058        
	AND	#1 ; Which phase are the invaders in
	RLC	D ; D * 2
	OR	D ; phase + D*2
	SUB	#2 ; phase + d*2 -2
	ADD	A,#INVCHR  
	JP	PNUM ; Bit blit the invader
	.area _DATA
; 2127     
	.area _GSINIT
DIREC:	.ds	1
DOWNP:	.ds	1
DOWN:	.ds	1
ROW1:	.ds	33
ROW2:	.ds	33
ROW3:	.ds	33
ROW4:	.ds	33
ROW5:	.ds	33
SET:	.ds	1
	.area _DATA
SETD:	.db	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.db	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.db	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.db	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.db	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.db	3, 3, 3, 3, 2, 2, 2, 3, 3, 3, 3
	.db	1, 1, 0, 2, 2, 0, 2, 2, 0, 1, 1
	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.db	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	.db	3, 2, 2, 2, 0, 3, 0, 2, 2, 2, 3
	.db	1, 0, 2, 2, 2, 0, 2, 2, 2, 0, 1
	.db	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
; 2151        

	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.db	3, 2, 3, 3, 3, 3, 3, 3, 3, 2, 3
	.db	3, 3, 0, 2, 2, 2, 2, 2, 0, 3, 3
	.db	3, 3, 0, 2, 2, 2, 2, 2, 0, 3, 3
	.db	4, 0, 1, 0, 2, 1, 2, 0, 1, 0, 4
	.db	4, 4, 2, 0, 1, 1, 1, 0, 2, 4, 4
	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.db	3, 3, 2, 2, 2, 2, 2, 2, 2, 3, 3
	.db	3, 3, 2, 2, 2, 2, 2, 2, 2, 3, 3
	.db	1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1
	.db	1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1
	.db	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
SETD1:	.db	0, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 1, 3, 3, 2, 2
BASESX:	.db	105, 113, 121
LEVD:	.db	0, 1, 2, 3, 3, 3, 4, 4, 4
LEVD1:	.db	62, 87, 97, 102, 107
LEV:	.ds	1
MIS1:	.ds	1
	.area _CODE
BOOM:	DI	 
	LD	A,#0x3C  
	LD	(KABOOM),A  
	LD	A,#0x18  
	OUT	(#TUARTA_CMD),A  
	LD	A,#0xb  
	OUT	(#TUARTA_MASK),A  
	LD	HL,#BOOM1  
	LD	(1),HL  
	XOR	A  
	LD	(FDUR1),A  
	LD	A,#4  
	LD	(FDUR),A  
; 2181        
	LD	A,#8  
	OUT	(#TIMERA_1),A  
	EI	  
	RET	  
BOOM1:	DI	 
	PUSH	AF  
	PUSH	HL  
	LD	A,#0  
FDUR	.equ	.-1 
	DEC	A  
	LD	(FDUR),A  
	JP	NZ,BOOM2  
	LD	A,#XLEN-1  
	LD	(XPLO),A  
	LD	A,#6  
BMLEN	.equ	.-1 
	LD	(FDUR),A  
	LD	A,#0  
FDUR1	.equ	.-1 
	INC	A  
KABOOM	.equ	.-1 
	LD	(FDUR1),A  
	JP	NZ,BOOM3  
	LD	HL,#INTER1  
	LD	(1),HL  
	LD	A,#0  
	OUT	(#TUARTA_CMD),A  
	LD	A,#62  
	OUT	(#TIMERA_3),A  
	LD	A,#100  
	OUT	(#TIMERA_1),A  
	LD	A,#255  
	OUT	(#SHH_TIMER),A  
	OUT	(#TIMERA_5),A  
	POP	HL  
	LD	A,#0x0CB  
	OUT	(#TUARTA_MASK),A  
	LD	A,#8  
	OUT	(#TUARTA_CMD),A  
	POP	AF  
	EI	  
	CALL	DAZMOD  
	RET	  
BOOM2	.equ	. 
BOOM3:	LD	A,(BOOM4) 
	INC	A  
	LD	(BOOM4),A  
	LD	A,(RANTAB)  
BOOM4	.equ	.-2 
	LD	H,A  
	LD	A,(FDUR1)  
	OR	H  
	OUT	(#0x1B),A  
BMOUT	.equ	.-1 
	LD	A,(FDUR1)  
; 2235        

	POP	HL  
	OUT	(#5),A  
	POP	AF  
	EI	  
	RET	  
INTER1:	DI	 
	PUSH	AF  
	LD	A,#0  
DUR	.equ	.-1 
	AND	A  
	JP	Z,XIN1  
	DEC	A  
	LD	(DUR),A  
	LD	A,#0x7F  
SOUND	.equ	.-1 
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
XIN1:	LD	A,#60 
	OUT	(#TIMERA_1),A  	; Timer 1
	POP	AF  
	EI	  
	RET	  
INT1:	IN	A,(#0x18)
	CPL	  
	AND	#BUTTNL|BUTTNR  
	RET	Z  
	AND	#BUTTNL  
	LD	A,(RP)  
; 2328        

	JP	NZ,LEFT  
RIGHT:	CP	#107 
	RET	Z  
	INC	A  
	LD	(RP),A  
	RET	  
LEFT:	CP	#10 
	RET	Z  
	DEC	A  
	LD	(RP),A  
	RET	  
MPOS:	.ds	1
RP:	.db	10
OP:	.db	10
SHH_INT:
	DI	 
	PUSH	AF  
	LD	A,(SHH)  
	INC	A  
	LD	(SHH),A  
	JP	Z,XIT  
	LD	A,(RANTAB)  
; 2349        
SHH	.equ	.-2 
	OUT	(#0x19),A  
	LD	A,#20  
	OUT	(SHH_TIMER),A  
XIT:	POP	AF
	EI	  
	RET	  
DAZTRK:	DI	 
	PUSH	AF  
	GET	PACEDZ  
	DEC	A  
	LD	(PACEDZ),A  
	JR	NZ,DAZTR3  
	CALL	DAZMOD  
	MOV	(PACEDZ),#30  
	JR	DAZTR3 ; Use simulated page flipping in DAZMOD, Dec 2020
		 
	DI	  
	EI	  
	RET	  
	PUSH	AF  
	LD	A,#0  
DAZTR1	.equ	.-1 
	INC	A  
	LD	(DAZTR1),A  
	AND	#1  
	JP	Z,DAZTR2  
	LD	A,#0x79  
	OUT	(#DAZZ_COLOR),A  
	LD	A,#SC1/512+0x80
SCR1	.equ	.-1 
	OUT	(#14),A  
	JP	DAZTR3  
DAZTR2:	LD	A,#0x7E 
	OUT	(#DAZZ_COLOR),A  
	LD	A,#SC2/512+0x80  
SCR2	.equ	.-1 
	OUT	(#DAZZ_ADDR),A  
DAZTR3:	LD	A,#181 
	OUT	(TIMERA_3),A  
	POP	AF  
	EI	  
	RET	  
SWHOOP:	DI	 
	PUSH	AF  
	LD	A,(SHIP)  
	AND	A  
	LD	A,#-1  
	JP	Z,WHLEV  
	LD	A,#0x7F  
WHS	.equ	.-1 
	CPL	  
	LD	(WHS),A  
	OUT	(#0x1B),A  
	LD	A,#1  
FREQ	.equ	.-1 
	DEC	A  
	DEC	A  
	AND	#0x7F  
SWH1	.equ	.-1 
	LD	(FREQ),A  
WHLEV:	OUT	(#TIMERA_5),A 
	POP	AF  
	EI	  
	RET	

; The invaders will halt while there is an explosion in progress
; and as a side-effect, they will also stop if this interrupt is not running.	
XPLO_INT:
	DI	 
	PUSH	AF  
	LD	A,#0  
X5	.equ	.-1 
	AND	A  
	JR	Z,X6  
	DEC	A  
	LD	(X5),A  
; 2410        
	LD	A,#5  
X7	.equ	.-1 
	DEC	A  
	LD	(X7),A  
	LD	A,(XPLO)  
	JP	NZ,X8  
	LD	A,#10  
	LD	(X7),A  
X6:	LD	A,#0 
XPLO	.equ	.-1 
	INC	A  
	CP	#XLEN  
	JR	Z,X4  
	LD	(XPLO),A  
X8:	OUT	(#XPLO_TIMER),A 
	LD	A,(SOUND)  
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
	POP	AF  
	EI	  
	RET	  
X4:	LD	A,#255 
	OUT	(#XPLO_TIMER),A  
	POP	AF  
	EI	  
	RET	  
COUNT:	.db	0	; Shot counter for setting saucer score
; 2438
CDAT:	.db	0x10, 5, 5, 0x10, 5, 0x10, 5, 5, 0x30, 0x10, 0x10, 0x10, 5, 0x15, 0x50	; saucer scores
TDAT:	.db	3, 2, 1, 3 ; Invader killed score for type
BDAT:	.db	0x20
SCORE:	.dw	0
SCR:	COLOR	#BLACK 
	CALL	WS  
	LD	A,(SCORE+1)  
	ADD	A,#0  
SINC	.equ	.-1 
	DAA	  
	LD	(SCORE+1),A  
	LD	A,(SCORE)  
	ADC	A,#0  
	DAA	  
	LD	(SCORE),A  
	COLOR	#BLUE  
; 2460        
	CALL	WS  
	LD	A,#0  
BBASES	.equ	.-1 
	AND	A  
	RET	Z  
	LD	A,(SCORE)  
	CP	#3  
	RET	C  
	LD	A,(LBASES)  
	INC	A  
	LD	(LBASES),A  
	XOR	A  
	LD	(BBASES),A  
	COLOR	#BLACK  
	PUSH	BC  
	PUSH	DE  
	PUSH	HL  
	LD	A,#0x3D  
	CALL	BOOM+3  
	LD	BC,#97*256+5  
	LD	A,(LBASES)  
	DEC	A  
	CALL	PNUM  
	COLOR	#BLUE  
	LD	BC,#97*256+5  
	PUT	(LBASES)  
	LD	HL,#BASESX  
	LD	A,(LBASES)  
	DEC	A  
BBAS1:	DEC	A 
	JR	Z,BBAS2  
	INC	HL  
	JR	BBAS1  
BBAS2:	LD	B,(HL) 
	CALL	LB  
	POP	HL  
; 2504        
	POP	DE  
	POP	BC  
	RET	  
	RET	  
	
; Display the score	
WS:	LD	BC,#36*256+5	; Originally has "4" because this plots the character at line 0 instead of line 1, but pnum doesn't blit negatives. 
	LD	A,(SCORE)  
	AND	#0x0F0  
	RRCA	  
	RRCA	  
	RRCA	  
	RRCA	  
	CALL	PNUM  
	LD	A,(SCORE)  
	AND	#0x0F  
	CALL	PNUM  
	LD	A,(SCORE+1)  
	AND	#0x0F0  
	RRCA	  
	RRCA	  
	RRCA	  
	RRCA	  
	CALL	PNUM  
	LD	A,(SCORE+1)  
	AND	#0x0F  
	CALL	PNUM  
	XOR	A  
	CALL	PNUM  
	RET	  
INVFNM:	.ascii	'INVADEHI.SCO'
	.db	0x1f
HIGHZ:	XOR	A 
	LD	(SCR1),A  
	LD	(SCR2),A  
	LD	(SHIP),A  
	LD	DE,#DISBUF  
	LD	C,#26  
	CALL	5  
	LD	DE,#INVFCB  
	LD	HL,#INVFNM  
	LD	C,#134  
	CALL	5  
	LD	DE,#INVFCB  
	LD	C,#15  
	CALL	5  
	CP	#-1  
	JP	Z,HIGHGN  
	CALL	DISKR  
	LD	HL,#INVDAT+14  
	LD	B,#20  
	LD	DE,#16  
HIGH1:	LD	A,(SCORE) 
	CP	(HL)  
	JP	C,HIGH2  
	JP	NZ,HIGH3  
	INC	HL  
	LD	A,(SCORE+1)  
	CP	(HL)  
	DEC	HL  
	JP	C,HIGH2  
	JP	Z,HIGH2  
HIGH3:	LD	C,B 
	PUSH	HL  
	LD	DE,#335+INVDAT  
	LD	HL,#319+INVDAT  
HIGH4:	LD	A,#16 
	LD	(HIGH5),A  
HIGH6:	LD	A,(HL) 
	LD	(DE),A  
	DEC	DE  
	DEC	HL  
	LD	A,#0  
HIGH5	.equ	.-1 
	DEC	A  
	LD	(HIGH5),A  
	JR	NZ,HIGH6  
	DEC	C  
	JR	NZ,HIGH4  
	POP	HL  
	LD	A,(SCORE)  
	LD	(HL),A  
	INC	HL  
	LD	A,(SCORE+1)  
	LD	(HL),A  
	LD	DE,#-15  
	ADD	HL,DE  
	LD	B,#14  
HIGH7:	LD	(HL),#10 
	INC	HL  
	DJNZ	HIGH7  
	LD	DE,#-14  
	ADD	HL,DE  
	LD	DE,#HMES  
HIGH8:	LD	A,(DE) 
	INC	DE  
	CP	#255  
	JR	Z,HIGH9  
	CALL	OUTP  
	JP	HIGH8  
	.area	_DATA
HMES:	.db	13, 10
	.ascii	'YOU HAVE ACHIEVED A TRULY INCREDIBLE SCORE!!!'
	.db	13, 10
	.ascii	'PLEASE ENTER YOUR NAME (WITHIN 14 LETTERS):'
; 2678        
	.db	13, 10, 13, 10, 255
	.area _CODE
HIGH9:	LD	B,#14 
HIGHA:	CALL	INP
	CP	#13  
	JR	Z,HIGHB  
	CP	#0x20  
	JR	Z,HIGHC  
	CP	#0x41  
	JR	C,HIGHA  
	CP	#0x58  
	JR	NC,HIGHA  
	CALL	OUTP  
	SUB	#54  
HIGHD:	LD	(HL),A 
	INC	HL  
	DJNZ	HIGHA  
	JP	HIGHB  
HIGHC:	CALL	OUTP
	LD	A,#10  
	JR	HIGHD  
HIGHB:	JP	DISKW
HIGH2:	ADD	HL,DE 
	DEC	B  
	JP	NZ,HIGH1  
DISKW:	LD	DE,#INVFCB 
	LD	HL,#INVFNM  
	LD	C,#134  
	CALL	5  
	LD	DE,#INVFCB  
	LD	C,#22  
	CALL	5  
	LD	DE,#INVFCB  
	LD	C,#15  
	CALL	5  
	LD	A,#3  
	LD	(DISKW1),A  
	LD	HL,#INVDAT-128  
DISKW2:	LD	DE,#128 
	ADD	HL,DE  
	PUSH	HL  
	LD	BC,#128  
	LD	DE,#DISBUF  
	LDIR	  
	LD	DE,#INVFCB  
; 2722        
	LD	C,#21  
	CALL	5  
	POP	HL  
	LD	A,#0  
DISKW1	.equ	.-1 
	DEC	A  
	LD	(DISKW1),A  
	JR	NZ,DISKW2  
	LD	DE,#INVFCB  
	LD	C,#16  
	CALL	5  
	RET	  
DISKR:	LD	HL,#INVDAT-128 ; FILE IS 3*128 LONG AND IS STORED AT INVDAT
	LD	A,#3  
	LD	(DISKR1),A  
	PUSH	HL  
DISKR2:	LD	DE,#INVFCB 
	LD	C,#20  
	CALL	5  
	LD	DE,#128  
	POP	HL  
	ADD	HL,DE  
	LD	A,#0  
DISKR1	.equ	.-1 
	DEC	A  
	LD	(DISKR1),A  
	JP	M,DISKR3  
	PUSH	HL  
	LD	BC,#128  
	LD	DE,#DISBUF  
	EX	DE,HL  
	LDIR	  
	JR	DISKR2  
DISKR3:	LD	DE,#INVFCB 
	LD	C,#16  
	CALL	5  
	RET	  
HIGHGN:	LD	HL,#ERRMES 
HIGHG1:	LD	A,(HL) 
	CP	#255  
	JR	Z,HIGHG2  
	CALL	OUTP  
	INC	HL  
	JR	HIGHG1  
HIGHG2:	HALT	 
ERRMES:	.db	13, 10
; 2779

	.ascii	'NO "INVADEHI.SCO" FILE WAS FOUND PLEASE RESET MACHINE AND'
	.db	13, 10
	.ascii	'XFER THE "ZIP.ZIP" FILE TO THE CURRENT DISK. THIS FILE CAN'
	.db	13, 10
	.ascii	'BE FOUND ON DISK 3A...'
	.db	13, 10, 13, 10, 255
INP:	IN	A,(#0 )
	AND	#0x40  
	JR	Z,INP  
	IN	A,(#1) 
	RET	  
OUTP:	EX	AF,AF'
OUTP1:	IN	A,(#0 )
	AND	#0x80  
	JR	Z,OUTP1  
	EX	AF,AF'  
	OUT	(#1),A  
	RET	  
EOG:	LD	A,#0x19 
	LD	(BMOUT),A  
	LD	A,#16  
	LD	(BMLEN),A  
	CALL	BOOM  
	LD	B,#16  
D1:	LD	HL,#0 
D2:	DEC	HL 
	LD	A,L  
	OR	H  
	JR	NZ,D2 ; NEED INTERRUPT DELAY HERE
	DJNZ	D1  
	LD	A,#4  
	LD	(BMLEN),A  
	LD	A,#0x1B  
	LD	(BMOUT),A  
	LD	A,#0  
	OUT	(#0x0E),A  
	CALL	HIGHZ  
	MOV	(SCR1),#0x81  
	MOV	(SCR2),#0x85  
	LD	A,#SC1/512+0x80  
	OUT	(#0x0E),A  
	JP	START  


; Math lib

;Inputs:

;     DEHL

;Outputs:

;     DEHL is the quotient

;     A is the remainder

;     BC is 10

		 
Div10:	ld	bc,#0x0D0A 
	xor	a  
	ex	de,hl  
	add	hl,hl  
	rla	  
	add	hl,hl  
	rla	  
	add	hl,hl  
	rla	  
		 
	add	hl,hl  
	rla	  
	cp	c  
	jr	c,.+4  
	sub	c  
	inc	l  
	djnz	.-7  
		 
	ex	de,hl  
	ld	b,#16  
		 
	add	hl,hl  
	rla	  
	cp	c  
	jr	c,.+4  
	sub	c  
	inc	l  
	djnz	.-7  
	ret	  
		  
CONOUT:	LD	C,#TUARTA+TDATA 
	OTIR	  
	RET	  
XPLOER::
	COLOR	#BLACK 
XPLODR:	LD	A,(MIS1) 
	LD	C,A  
	LD	A,(MPOS)  
	LD	B,A  
	JP	XPLDR1
	.area _DATA
INTRO:	.ascii	'savespaceinv.com '
SSIZE:	.db	''
INTLEN	.equ	.-INTRO 
	.area _GSINIT
INVFCB:	.ds	33
INVDAT:	.ds	384
DISBUF:	.ds	128
ROW1A:	.ds	55*3
BOM:	.ds	100
ALIENT:	.ds	10
INVEXP:	.ds	150
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
