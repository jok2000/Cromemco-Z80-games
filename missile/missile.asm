	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.module missile
	.optsdcc -mz80

	.include "dazzler.mac"
	.include "dazzler.abs"
	
	.globl	XYACMP, ONOFF, CTEST, C00, C01, C10, C11, XY, RAND, PNUM, MESOUT, DAZINIT, CLEAR
	
	.area _CODE
	
	.macro	CDOS a
	LD	DE,#MISFCB  
	LD	C,#a  
	CALL	#5  
	.endm	  
	
	; arrow bit blit data

	.macro	AR1 
	.db	7, 79, 12, 128, 224, 32
	.endm	  
	
	.macro	AR2 
	.db	27, 223, 76, 0, 128, 0
	.endm	  
	
	.macro	AR3 
	.db	1, 13, 4, 192, 248, 176
	.endm	  
	 
INTRAB:	.dw	INT1, INT2, START, WHSI, KEYI, KEYO, OMI, MLOWI
	.dw	ESCAPE, START, START, START, START, START, START, START
_STARTA::	
STARTA::	
START:	LD	SP,#STACK
	CALL	DAZINIT
	MOV	(COL1),(COLTAB)  
	MOV	(COL2),(COLTAB+1)  
	CALL	DAZMOD
	IN	A,(#0x18) 
	AND	#8  
	JR	NZ,NOTST  
	LD	HL,#SC1  
CTSTA:	LD	A,L 
	RRCA	  
	AND	#7  
	OR	#8  
	LD	B,A  
	SHIFT	L,4  
	OR	B  
	LD	(HL),A  
	INC	HL  
	LD	A,#(SC1+512)/256  
	CP	H  
	JR	NZ,CTSTA  
	LD	DE,#SC1+28*16  
	LD	HL,#ADAT  
	LD	BC,#64  
	LDIR	  
	LD	A,#SC1/512+128  
	OUT	(#14),A  
	LD	A,#16  
	OUT	(#15),A  
CTSTB:	IN	A,(#0x18) 
	AND	#8  
	JR	NZ,NOTST  
	JR	CTSTB  
; Test pattern graphics
	.area	_DATA	
ADAT:	.db	-1, 15, 7, 7, 0, 9, 0x0E0, 0, 160, 0, 0x0D0, 0, 0x0BB, 0, 12, 192
	.db	-16, 0, 7, 7, 0x90, 0x90, 0x0E0, 0, 0x0A0, 0, 0x0D0, 0x0B0, 0, 0
	.db	0x0CC, 0x0C0
	.db	-16, 0, 7, 7, 0x90, 0x99, 0x0E0, 0, 0x0A0, 0, 0x0D0, 0x0B0, 0x0B0
	.db	11, 12, 0x0CC
	.db	-16, 0, 0x70, 0, 0x90, 0x90, 0x0E0, 0x0EE, 0x0E0, 0x0EE, 0x0D0
	.db	0, 0x0BB, 0, 12, 0x0C0
	.area	_CODE
__exit::
	ld	c,#0
	call	#5
NOTST:	CALL	CLEAR
	CALL	DISKR  
	DI	  

; PAGE 4 FOLLOWS

	MOV	I,#IIIIII/256  
	LD	HL,#INTRAB  
	LD	DE,#IIIIII  
	LD	BC,#32  
	LDIR	  
  
	IM	2  		; IIIIII-64 is now the Z80 interrupt table
	LD	A,#9  
	OUT	(#TUARTA+ICOMMP),A  
	OUT	(#TUARTB+ICOMMP),A  
	LD	a,#0x0  	; Temporary hack until interrupts debugged
	; LD	A,0CBH  ; Tuart A Interrupt Mask

	OUT	(#TUARTA+IMASKP),A  
	LD	A,#1  
	OUT	(#TUARTB+IMASKP),A ; Tuart B Interrupt Mask
	EI	  
	LD	A,#248  
	OUT	(#TIMERA_1),A  
	LD	A,#-1  
	OUT	(#TIMERA_4),A  
	OUT	(#TIMERB_1),A  
	XOR	A  
; Unknown port used in 1982 machine
;	OUT	34H,A
	LD	(SMISCT),A  
	DEC	A  
	LD	(SPACE+3),A  
	LD	HL,#PLAY1  
	LD	B,#36  
SCRCLR:	LD	(HL),#0 
	INC	HL  
	DJNZ	SCRCLR  
	JP	GBEGIN  
HIGHST:	LD	HL,#HIGHS 
	LD	B,#8  
	LD	D,#0x95  
CLHIGH:	LD	C,#3 
CHIGH1:	CALL	RAND
	CP	#25  
	JR	NZ,CHIGH1  
	ADD	A,#12  
	LD	(HL),A  
	INC	HL  
	DEC	C  
	JR	NZ,CHIGH1  
	LD	C,#3  
CHIGH2:	LD	(HL),#0 
	INC	HL  
	DEC	C  
	JR	NZ,CHIGH2  
	LD	(HL),#7  
	INC	HL  
	LD	(HL),#5  
	LD	A,D  
	SUB	#5  
	DAA	  
	LD	D,A  
	AND	#0x0F0  
	SHIFT	R,4  
	INC	HL  
	LD	(HL),A  
	LD	A,#0x0F  
	AND	D  
	INC	HL  
	LD	(HL),A  
	INC	HL  
	DJNZ	CLHIGH  
; PAGE 5

	RET	  
; This is a bad idea, but currently no Tuart B interrupts anyway 12/09/2020
ESCAPE:	DI	 
	PUSH	AF  
	IN	A,(#1)  
	CP	#0x1B  
	JR	NZ,ESCAP1  
	XOR	A  
	OUT	(#TUARTA+IMASKP),A  
	OUT	(#TUARTB+IMASKP),A  
	OUT	(#14),A  
	JP	0  
ESCAP1:	LD	A,#-1 
	OUT	(#TIMERB_1),A  
	POP	AF  
	EI	  
	RET	  
	
HIGHSC:	MOV	(HW1),#0 
	LD	HL,#PLAY1+8  
	LD	DE,#PLAY2+8  
	CALL	COMP  
	LD	DE,#PLAY2+8  
	LD	A,#2  
	JR	NC,KHKH  
	LD	DE,#PLAY1+8  
	LD	A,#1  
KHKH:	LD	(HC),A 
	CALL	HIGHC  
	LD	DE,#PLAY1+8  
	LD	A,(HC)  
	DEC	A  
	JR	NZ,DSDS  
	LD	DE,#PLAY2+8  
DSDS:	GET	HC 
	XOR	#3  
	LD	(HC),A  
	CALL	HIGHC  
	GET	HW1  
	OR	A  
	JP	Z,END  
	JP	GBEGIN  
COMP:	LD	B,#8 
COMP2:	DJNZ	COMP1
COMP3:	OR	A 
	RET	  
COMP1:	LD	A,(DE) 
	CP	(HL)  
	RET	C  
	INC	DE  
	INC	HL  
	JR	Z,COMP2  
	JR	COMP3  
HIGHC:	LD	(SPR),DE 
	LD	A,#8  
	LD	(HW2),A  
	LD	HL,#HIGHS+3  
HIGHC1:	PUSH	HL 
	LD	DE,#0  
SPR	.equ	.-2 
	CALL	COMP  
	POP	HL  
	JR	NC,HIGHC9  
	LD	BC,#10  
	ADD	HL,BC  
	GET	HW2  
	DEC	A  
	LD	(HW2),A  
; PAGE 6 FOLLOWS

	JR	NZ,HIGHC1  
	RET	  
HIGHC9:	LD	A,(HW2) 
	DEC	A  
	LD	HL,#HIGHS+70  
	JR	Z,HIGHCF  
	DEC	HL  
	LD	DE,#HIGHS+79  
HIGHC3:	LD	BC,#10 
	LDDR	  
	DEC	A  
	JR	NZ,HIGHC3  
	INC	HL  
HIGHCF:	LD	A,(HW1) 
	OR	A  
	JR	NZ,HIGHR4  
	LD	C,#5  
	MOV	(ONOFF),(BG)  
XYCA:	LD	B,#127 
XYCA1:	DOT	 
	DJNZ	XYCA1  
	DOT	  
	INC	C  
	CMP	C,#96  
	JR	NZ,XYCA  
	MOV	(ONOFF),(FM)  
	PUSH	HL  
	LD	HL,#AREADY+10  
	LD	BC,#16+41*256  
	CALL	MESOUT  
	LD	HL,#HIMES  
	LD	BC,#26+5*256  
	CALL	MESOUT  
	LD	BC,#38+5*256  
	CALL	MESOUT  
	LD	BC,#44+5*256  
	CALL	MESOUT  
	LD	BC,#50+5*256  
	CALL	MESOUT  
	LD	BC,#56+5*255  
	CALL	MESOUT  
	LD	A,#1  
	LD	(HW1),A  
	POP	HL  
HIGHR4:	LD	A,(HC) 
	XOR	#3  
	LD	D,A  
	LD	BC,#16+83*256  
	MOV	(ONOFF),(BG)  
	CALL	LOUT  
	LD	A,(HC)  
	LD	D,A  
	MOV	(ONOFF),(EM)  
	CALL	LOUT  
ASQWE:	MOV	(ONOFF),(BG) 
	LD	C,#51  
XYC3:	LD	B,#89 
XYC4:	DOT	 
	INC	B  
	CMP	B,#110  
	JR	NZ,XYC4  
	INC	C  
	CMP	C,#58  
	JR	NZ,XYC3  
	LD	BC,#57+89*256  
	LD	A,#3  
; PAGE 7 FOLLOWS

	LD	(CCNT),A  
NAME1:	LD	A,B 
	ADD	A,#6  
	LD	B,A  
	LD	D,#11  
	MOV	(ONOFF),(EX)  
	CALL	LOUT  
	LD	A,#1  
	LD	(KAQW),A  
NAME2:	IN	A,(#0x18) 
	CPL	  
	AND	#7  
	JR	NZ,ENTER  
	LD	(KAQW),A  
	IN	A,(#0x18)  
	AND	#8  
	JR	NZ,KAQW1  
ASDFE:	LD	A,(CCNT) 
	CP	#3  
	JR	Z,ASQWE  
	DEC	HL  
	LD	A,(CCNT)  
	INC	A  
	LD	(CCNT),A  
	JR	ASDFE  
KAQW1:	IN	A,(#0x19) 
	LD	E,A  
	IN	A,(#0x1A)  
	OR	E  
	JP	M,NAME9  
	CP	#64  
	JR	C,NAME2  
	MOV	(ONOFF),(BG)  
	CALL	LOUT  
	JR	NAME3  
NAME9:	NEG	 
	CP	#64  
	JR	C,NAME2  
	MOV	(ONOFF),(BG)  
	CALL	LOUT  
	DEC	D  
	DEC	D  
NAME3:	INC	D 
	LD	A,D  
	CP	#9  
	JR	NZ,NAME4  
	LD	A,#36  
NAME4:	CP	#37 
	JR	NZ,NAME5  
	LD	A,#10  
NAME5:	LD	D,A 
	MOV	(ONOFF),(EX)  
	CALL	LOUT  
	PUSH	HL  
	LD	HL,#0x4000  
	CALL	DELAY  
	POP	HL  
	JR	NAME2  
ENTER:	GET	KAQW 
	OR	A  
	JP	NZ,KAQW1  
	INC	A  
	LD	(KAQW),A  
	LD	(HL),D  
	INC	HL  
	GET	CCNT  
; PAGE 8 BELOW

	DEC	A  
	LD	(CCNT),A  
	JP	NZ,NAME1  
	LD	DE,(SPR)  
	EX	DE,HL  
	LD	BC,#7  
	LDIR	  
	RET	  
LOUT:	PUSH	HL 
	PUSH	DE  
	PUSH	BC  
	PUT	D  
	POP	BC  
	POP	DE  
	POP	HL  
	RET	  
	.area	_DATA	
 ; CONGRATULATIONS  YOU HAVE ACHIEVE A TRULY INCREDIBLE SCORE PLEASE ENTER YOU INITIALS
HIMES:	.db	45, 45, 10, 13, 25, 24, 17, 28, 11, 30, 31, 22, 11, 30, 19
	.db	25, 24, 29, 10, 45, 45, 255, 10, 35, 25, 31, 10, 18, 11
	.db	32, 15, 10, 11, 13, 18, 19, 15, 32, 15, 14, 10, 11, 255
	.db	10, 10, 30, 28, 31, 22, 35, 10, 19, 24, 13, 28, 15, 14, 19, 12
	.db	22, 15, 255, 10, 29, 13, 25, 28, 15, 43, 10, 26, 22, 15, 11
	.db	29, 15, 10, 15, 24, 30, 15, 28, 255, 35, 25, 31, 28, 10, 19
	.db	24, 19, 30, 19, 11, 22, 29, 46, 255
	.area	_CODE
GBEGIN:	CALL	CLEAR
	LD	A,(HW1)  
	AND	A  
	JR	Z,GBGIN  
	MOV	(DZOFF1),A  
	LD	(DZOFF2),A  
	DI	  
	CALL	DISKW  
	LD	A,#SC1/512+0x80 
	LD	(DZOFF1),A  
	LD	A,#SC2/512+0x80 
	LD	(DZOFF2),A  
	EI	  
	LD	A,#-1  
	OUT	(#TIMERA_4),A  
	OUT	(#TIMERA_5),A  
	OUT	(#TIMERA_1),A  
GBGIN:	MOV	(COL1),(COLTAB) 
	MOV	(COL2),(COLTAB+1)  
	CALL	DAZMOD  
	MOV	(PACEDZ),#30 ; Overcome OS craziness with shutting off Dazzler by resetting 2x/sec
	IN	A,(#0x18)  
	AND	#1  
	JP	NZ,NUMCIT  
	LD	HL,#BCITY  
	LD	BC,#70+6*256  
	MOV	(ONOFF),#C10  
	CALL	MESOUT  
	MOV	(ONOFF),#C01  
	LD	HL,#BCITY8  
	LD	BC,#70+94*256  
	CALL	MESOUT  
	LD	H,#0  
	LD	L,#8  
BCITY5:	LD	A,H 
	SHIFT	L,4  
	OR	L  
	LD	(BONUS),A  
	MOV	(ONOFF),#C01  
	LD	BC,#70+94*256  
	PUSH	HL  
	LD	A,H  
	AND	A  
	JR	NZ,BCITY1  
	LD	A,#10  
; PAGE 9 FOLLOWS

BCITY1:	CALL	PNUM
	POP	HL  
	PUSH	HL  
	PUT	L  
	POP	HL  
BCITY4:	IN	A,(#0x18) 
	AND	#1  
	JP	NZ,NUMCIT  
	PUSH	HL  
	LD	HL,#0x4000  
	CALL	DELAY  
	POP	HL  
	IN	A,(#0x1A)  
	AND	A  
	JP	M,BCITY3  
	ADD	A,#-64  
	JP	M,BCITY4  
	CALL	CLNUM  
	INC	L  
	CMP	L,#10  
	JR	NZ,BCITY5  
	LD	L,#0  
	INC	H  
	CMP	H,#10  
	JR	NZ,BCITY5  
	LD	H,#9  
	LD	L,#9  
	JR	BCITY5  
BCITY3:	NEG	 
	ADD	A,#-64  
	JP	M,BCITY4  
	CALL	CLNUM  
	DEC	L  
	JP	P,BCITY6  
	LD	L,#9  
	DEC	H  
	JR	BCITY5  
BCITY6:	JR	NZ,BCITY5
	LD	A,H  
	AND	A  
	JR	NZ,BCITY5  
	LD	L,#1  
	JR	BCITY5  
CLNUM:	LD	BC,#70+94*256 
	PUSH	HL  
	MOV	(ONOFF),#C00  
	LD	A,H  
	AND	A  
	JR	NZ,CLNUM1  
	LD	A,#10  
CLNUM1:	CALL	PNUM
	POP	HL  
	PUSH	HL  
	PUT	L  
	POP	HL  
	RET	  
NUMCIT:	IN	A,(#0x18) 
	AND	#2  
	JP	NZ,START1  
	CALL	CLEAR  
	LD	HL,#SC1  
NCIT1:	LD	(HL),#255 
	INC	HL  
	CMP	H,#(SC1+0x800)/256  
	JR	NZ,NCIT1  
	LD	BC,#70+5*256  
; PAGE 10 FOLLOWS
	LD	HL,#NCITY2  
	MOV	(ONOFF),#C00  
	CALL	MESOUT  
	MOV	(ONOFF),#C11  
	LD	H,#4  
	LD	BC,#70+102*256  
	PUSH	HL  
	PUT	H  
	POP	HL  
NCIT3:	MOV	(SCITY),H 
	IN	A,(#0x18)  
	AND	#2  
	JR	NZ,START1  
	LD	DE,#0  
NCIT4:	DEC	DE 
	LD	A,E  
	OR	D  
	JR	NZ,NCIT4  
	MOV	(ONOFF),#C01  
	LD	BC,#70+102*256  
	PUSH	HL  
	PUT	H  
	POP	HL  
	IN	A,(#0x1A)  
	AND	A  
	JP	M,NCIT2  
	ADD	A,#-64  
	JP	M,WRITN  
	INC	H  
	LD	A,H  
	ADD	A,#-7  
	JP	M,WRITN  
	LD	H,#6  
	JR	WRITN  
NCIT2:	NEG	 
	ADD	A,#-64  
	JP	M,WRITN  
	DEC	H  
	JR	NZ,WRITN  
	LD	H,#1  
WRITN:	MOV	(ONOFF),#C11 
	PUSH	HL  
	LD	BC,#70+102*256  
	PUT	H  
	POP	HL  
	JP	NCIT3  
NCITY2:	.db	24, 31, 23, 12, 15, 28, 10, 25, 16, 10, 13, 19, 30, 19, 15; NUMBER OF CITIES 
	.db	29, 255
START1:	CALL	CLEAR
	LD	HL,#0x100  
RSET:	CALL	RAND
	LD	(HL),A  
	INC	L  
	JR	NZ,RSET  
	MOV	(ONOFF),#C10  
	CALL	SCOR  
	JR	SCORA  
SCOR:	LD	BC,#6+6*256 
	LD	HL,#PLAY1+7  
	CALL	SCOR4  
	LD	BC,#6+44*256  
	LD	HL,#HIGHS+2  
	CALL	SCOR4  
	LD	A,(PLAY)  
	DEC	A  
	RET	Z  
; PAGE 11 FOLLOWS

	LD	BC,#6+87*256  
	LD	HL,#PLAY2+7  
	JR	SCOR4  
SCORA:	LD	HL,#HIGHS 
	MOV	(ONOFF),#C11  
	LD	D,#8  
	LD	BC,#16+35*256  
SCOR5:	LD	E,#3 
SCOR7:	PUSH	HL 
	PUSH	DE  
	PUT	(HL)  
	POP	DE  
	POP	HL  
	INC	HL  
	DEC	E  
	JR	NZ,SCOR7  
	LD	A,#6  
	ADD	A,B  
	LD	B,A  
	JR	SCOR6  
SCOR4:	LD	D,#6 
SCOR1:	DEC	D 
	INC	HL  
	JP	M,SCOR2  
	LD	A,(HL)  
	AND	A  
	JR	NZ,SCOR2  
	LD	A,#6  
	ADD	A,B  
	LD	B,A  
	JR	SCOR1  
SCOR2:	INC	D 
SCOR3:	PUSH	HL 
	PUSH	DE  
	PUT	(HL)  
	POP	DE  
	POP	HL  
	INC	HL  
	DEC	D  
	JP	P,SCOR3  
	RET	  
SCOR6:	PUSH	DE 
	DEC	HL  
	CALL	SCOR4  
	POP	DE  
	LD	A,#6  
	ADD	A,C  
	LD	C,A  
	LD	B,#35  
	DEC	D  
	JR	NZ,SCOR5  
SCOR8:	LD	BC,#70+6*256 
	LD	HL,#BCITY  
	MOV	(ONOFF),#C10  
	CALL	MESOUT  
	LD	A,#6  
	ADD	A,B  
	LD	B,A  
	MOV	(ONOFF),#C01  
	LD	A,(BONUS)  
	AND	#0x0F0  
	LD	A,#10  
	JR	Z,SCOR9  
	LD	A,(BONUS)  
	AND	#0x0F0  
	SHIFT	R,4  
; PAGE 12 FOLLOWS

SCOR9:	CALL	PNUM
	LD	A,(BONUS)  
	AND	#15  
	CALL	PNUM  
	PUT	#0  
	PUT	#0  
	PUT	#0  
	LD	A,#C01  
	LD	(ONOFF),A  
	CALL	FORE  
	MOV	(CITPU1),(SCITY)  
	LD	HL,#CITPOS  
CITPUT:	LD	A,#5 ; Draw cities
	ADD	(HL)  
	LD	B,A  
	INC	HL  
	LD	C,(HL)  
	PUSH	HL  
	PUSH	BC  
	MOV	(ONOFF),#C11  
	PUT	#39 ; City graphics are special characters
	PUT	#40  
	POP	BC  
	MOV	(ONOFF),#C10 ; Friendly color
	PUT	#41  
	PUT	#42  
	POP	HL  
	INC	HL  
	GET	CITPU1  
	DEC	A  
	LD	(CITPU1),A  
	JR	NZ,CITPUT  
	MOV	(ONOFF),#C10  
	CALL	MISPO  
	JR	PWIPE  
MISPO:	LD	HL,#MISPOS ; Display base missiles
	MOV	(MISPU1),#3  
MISPUT:	GET	MISPU1 
	DEC	A  
	LD	(MISPU1),A  
	RET	M  
	LD	DE,#MISDIS  
	LD	B,(HL)  
	INC	HL  
	LD	C,(HL)  
	INC	HL  
	MOV	(MISPU3),#10  
MISPU4:	GET	MISPU3 
	DEC	A  
	LD	(MISPU3),A  
	JP	M,MISPUT  
	LD	A,(DE)  
	INC	DE  
	ADD	A,B  
	LD	B,A  
	LD	A,(DE)  
	INC	DE  
	ADD	A,C  
	LD	C,A  
	CALL	LISSIM  
	JR	MISPU4  
MOVERZ:	PUSH	HL 
	EXX	  
	POP	HL  
	LD	B,#16  
MVERZ1:	RRD	 
; PAGE 13 FOLLOWS

	DEC	HL  
	DJNZ	MVERZ1  
	EXX	  
	RET	  
PWIPE:	LD	HL,#PLAY1 
	LD	DE,#PLAY1+1  
	LD	BC,#35  
	LD	(HL),#0  
	LDIR	  
	MOV	(PLAY),#1  
	LD	HL,#DFCTY  
	LD	BC,#25*256+96  
	MOV	(ONOFF),#C10  
	CALL	MESOUT  
DISPL:	MOV	(DISP),#0 
	LD	(BMESP),A  
DIS6:	PUSH	DE ; flash the arrows
	GET	ARFLSH  
	INC	A  
	CP	#16  
	JR	NZ,AR1  
	CALL	TAKEAR  
	XOR	A  
AR1:	LD	(ARFLSH),A 
	CP	#0  
	JR	NZ,AR2  
	CALL	PUTAR  
AR2:	POP	DE
	LD	HL,#0x0C00  
	CALL	DELAY  
;	FOOEY

	MOV	(DIS2A),#-1  
	LD	HL,#SC1+2047  
DIS3:	LD	B,#3 
DIS2:	GET	DIS2A 
	CALL	MOVERZ  
	LD	DE,#-512  
	ADD	HL,DE  
	CALL	MOVERZ  
	LD	DE,#496  
	ADD	HL,DE  
	DJNZ	DIS2  
	LD	HL,#SC2+2047  
	LD	A,(DIS2A)  
	INC	A  
	LD	(DIS2A),A  
	JR	Z,DIS3  
	GET	DISP  
	INC	A  
	LD	(DISP),A  
	CP	#3  
	JR	NZ,DIS6  
	MOV	(DISP),#0  
	LD	BC,#122*256+127  
	GET	BMESP  
	PUSH	AF  
	LD	E,A  
	LD	D,#0  
	LD	HL,#INMES  
	ADD	HL,DE  
	MOV	(ONOFF),#C00  
	PUT	(HL)  
	POP	AF  
	INC	A  
	CP	#BMESPL  
	JR	NZ,DIS4  
; PAGE 14 FOLLOWS

	XOR	A  
DIS4:	LD	(BMESP),A 
	IN	A,(#0x18)  
	AND	#4 ; Button from joystick
	JR	Z,ONE  
	IN	A,(#0x18)  
	AND	#8  
	JP	NZ,DIS6  
TWO:	MOV	(PLAY2+15),(BONUS) 
	LD	(PLAY2+16),A  
	MOV	(PLAY2),(SCITY)  
	LD	B,A  
	LD	HL,#PLAY2+2  
TWO1:	LD	(HL),#1 
	INC	HL  
	DJNZ	TWO1  
	LD	A,(PLAY)  
	INC	A  
	LD	(PLAY),A  
ONE:	MOV	(PLAY+15),(BONUS) 
	LD	(PLAY+16),A  
	MOV	(PLAY1),(SCITY)  
	LD	B,A  
	LD	HL,#PLAY1+2  
ONE1:	LD	(HL),#1 
	INC	HL  
	DJNZ	ONE1  
	LD	A,R  
	AND	A  
	JR	NZ,RSET1  
	LD	A,#0x5A  
RSET1:	LD	(RANTAB),A 
	MOV	(PLAYER),#2  
GLOOP:	LD	A,(PLAY1) 
	LD	B,A  
	LD	A,(PLAY2)  
	OR	B  
	JP	Z,HIGHSC  
	LD	A,(PLAYER)  
	XOR	#3  
	LD	(PLAYER),A  
	DEC	A  
	JR	Z,P1  
	LD	HL,#PLAY2  
	LD	A,(HL)  
	OR	A  
	JR	NZ,SWAP  
	LD	HL,#PLAY1  
	LD	A,#1  
P2:	LD	(PLAYER),A 
	JR	SWAP  
P1:	LD	HL,#PLAY1 
	LD	A,(HL)  
	OR	A  
	JR	NZ,SWAP  
	LD	HL,#PLAY2  
	LD	A,#2  
	JR	P2  
SWAP:	LD	DE,#PCB 
	LD	BC,#18  
	LDIR	  
	LD	A,#-1  
	OUT	(#TIMERA_5),A  
	MOV	(EXPLCT),#0  
	LD	(MISSCT),A  
	LD	(SMISCT),A  
; PAGE 15 FOLLOWS

	LD	HL,#EXPLTB+2  
	LD	DE,#3  
	LD	B,#NUMEXP  
	LD	A,#-1  
ECLR:	LD	(HL),A 
	ADD	HL,DE  
	DJNZ	ECLR  
	LD	A,(SET)  
	SRL	A  
CCALC:	LD	B,A 
	SUB	#10  
	JP	P,CCALC  
	MOV	(COLOR),B  
	LD	A,(SET)  
	INC	A  
	INC	A  
	CP	#12  
	JR	NC,NCOR2  
	AND	#14  
	RRCA	  
	JR	NCOR3  
NCOR2:	LD	A,#6 
NCOR3:	LD	(TIMES),A 
	ADD	A,#-6  
	JR	NC,PGEN9  
	MOV	(TIMES),#6  
PGEN9:	LD	HL,#POINTS 
	LD	DE,#POINTS+1  
	LD	BC,#34  
	LD	(HL),#0  
	LDIR	  
	LD	DE,#PBASE  
	LD	HL,#POINTS  
	LD	B,#5  
PGEN:	PUSH	BC 
	MOV	C,(TIMES)  
PGEN3:	PUSH	HL 
	PUSH	DE  
	LD	B,#7  
	OR	A  
PGEN1:	LD	A,(DE) 
	ADC	A,(HL)  
	CP	#10  
	CCF	  
	JR	NZ,PGEN2  
	SUB	#10  
	SCF	  
PGEN2:	LD	(HL),A 
	INC	DE  
	INC	HL  
	DJNZ	PGEN1  
	POP	DE  
	POP	HL  
	DEC	C  
	JR	NZ,PGEN3  
	LD	BC,#7  
	ADD	HL,BC  
	EX	DE,HL  
	ADD	HL,BC  
	EX	DE,HL  
	POP	BC  
	DJNZ	PGEN  
	LD	A,(COLOR)  
	LD	HL,#COLUSE  
READY2:	DEC	A 
	JP	M,READY3  
; PAGE 16 FOLLOWS

	INC	HL  
	INC	HL  
	INC	HL  
	INC	HL  
	JR	READY2  
READY3:	MOV	(READY7),#4 
	LD	DE,#FM1  
READY4:	LD	BC,#CUSETB 
	LD	A,(HL)  
	LD	(DE),A  
	INC	DE  
	INC	HL  
READY5:	DEC	A 
	JP	M,READY6  
	INC	BC  
	JR	READY5  
READY6:	MOV	(DE),(BC) 
	INC	DE  
	GET	READY7  
	DEC	A  
	LD	(READY7),A  
	JR	NZ,READY4  
	MOV	(CREADY),(COLOR)  
	LD	HL,#CBTAB  
DREADY:	GET	CREADY 
	DEC	A  
	LD	(CREADY),A  
	JP	M,EREADY  
	INC	HL  
	JR	DREADY  
EREADY:	MOV	(FREADY),(HL) 
	LD	HL,#COLTAB  
GREADY:	GET	FREADY 
	DEC	A  
	LD	(FREADY),A  
	JR	Z,HREADY  
	INC	HL  
	INC	HL  
	JR	GREADY  
HREADY:	MOV	(COL1),(HL) 
	INC	HL  
	MOV	(COL2),(HL)  
	MOV	(READY8),#-1  
	MOV	(READY9),A  
	MOV	B,(BG)  
	CMP	B,#C01  
	JR	Z,READYA  
	CMP	B,#C11  
	JR	Z,READYA  
	MOV	(READY8),#0  
READYA:	CMP	B,#C10 
	JR	Z,READYB  
	CMP	B,#C11  
	JR	Z,READYB  
	XOR	A  
	LD	(READY9),A  
READYB:	LD	HL,#SC1 
	LD	A,#SC2/256  
READYC:	LD	(HL),#0 
READY8	.equ	.-1 
	INC	HL  
	CP	H  
	JR	NZ,READYC  
	ADD	A,#8  
READYD:	LD	(HL),#0 
READY9	.equ	.-1 
; PAGE 17 FOLLOWS

	INC	HL  
	CP	H  
	JR	NZ,READYD  
	MOV	(ONOFF),(EM)  
	CALL	FORE  
	MOV	(ONOFF),(FM)  
	CALL	MISPO  
	LD	HL,#CITTAB  
	MOV	(READYE),#6  
	LD	DE,#CITPOS  
READYF:	GET	READYE 
	DEC	A  
	LD	(READYE),A  
	JP	M,READYG  
	LD	A,(DE)  
	INC	DE  
	ADD	A,#5  
	LD	B,A  
	MOV	C,(DE)  
	INC	DE  
	LD	A,(HL)  
	INC	HL  
	AND	A  
	JR	Z,READYF  
	PUSH	HL  
	PUSH	DE  
	PUSH	BC  
	MOV	(ONOFF),(EX)  
	PUT	#39  
	PUT	#40  
	POP	BC  
	MOV	(ONOFF),(FM)  
	PUT	#41  
	PUT	#42  
	POP	DE  
	POP	HL  
	JR	READYF  
READYG:	MOV	(ONOFF),(EM) 
	LD	BC,#40*256+67  
	PUT	(TIMES)  
	MOV	(ONOFF),(FM)  
	LD	HL,#BREADY  
	CALL	MESOUT  
	LD	BC,#2560+55  
	LD	HL,#AREADY  
	CALL	MESOUT  
	MOV	(ONOFF),(EM)  
	PUT	(PLAYER)  
	CALL	SCOR  
	MOV	(ONOFF),(FM)  
	CALL	SCORW  
	LD	C,#6  
ONE5:	LD	D,#0x7F 
ONE4:	LD	B,#15 
ONE3:	LD	A,#0x7F 
	SUB	D  
ONE2:	DEC	A 
	JR	NZ,ONE2  
	LD	A,(SOUND)  
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
	DJNZ	ONE3  
	DEC	D  
	CMP	D,#0x40  
	JR	NZ,ONE4  
; PAGE 18 FOLLOWS

	DEC	C  
	JR	NZ,ONE5  
	MOV	(ONOFF),(BG)  
	LD	C,#32  
RCL:	LD	B,#0 
RCL1:	DOT	 
	INC	B  
	JP	P,RCL1  
	INC	C  
	CMP	C,#96  
	JR	NZ,RCL  
	LD	HL,#BASES  
	LD	B,#3  
TGYYRU:	LD	(HL),#10 
	INC	HL  
	DJNZ	TGYYRU  
	LD	HL,#MISSTB+12  
	LD	DE,#13  
	LD	B,#19  
MCLEAR:	LD	(HL),#255 
	ADD	HL,DE  
	DJNZ	MCLEAR  
	MOV	(WAVEC),#0  
	LD	(SWAVEC),A  
	LD	(WWAVE),A  
	LD	A,(SET)  
	CP	#10  
	JR	C,NCOR  
	AND	#1  
	ADD	A,#10  
NCOR:	LD	L,A 
	LD	H,#0  
	ADD	HL,HL  
	ADD	HL,HL  
	LD	DE,#SETDT  
	ADD	HL,DE  
	LD	IX,#NMIS  
	LD	B,#4  
NCOR1:	MOV	(IX),(HL) 
	INC	IX  
	INC	HL  
	DJNZ	NCOR1  
	LD	A,(SET)  
	CP	#10  
	JR	C,NOAD  
	CALL	RAND  
	AND	#3  
	NEG	  
	LD	B,A  
	LD	A,(NMIS)  
	ADD	A,B  
	LD	(NMIS),A  
	CALL	RAND  
	AND	#1  
	NEG	  
	LD	B,A  
	LD	A,(NSHP)  
	ADD	A,B  
	LD	(NSHP),A  
	CALL	RAND  
	AND	#2  
	NEG	  
	LD	B,A  
	LD	A,(NSMS)  
	ADD	A,B  
	LD	(NSMS),A  
; PAGE 19 FOLLOWS

NOAD:	MOV	(OFFCRS),#0 
	LD	(NFIN),A  
	DEC	A  
	LD	(TRCT),A  
	LD	(TRCT+3),A  
	LD	(TRCT+6),A  
	LD	(TARCIT),A  
	LD	(TARCIT+2),A  
	LD	(TARCIT+4),A  
	LD	A,(NSHP)  
	OR	A  
	CALL	NZ,SLRBM1  
	MOV	(KILCIT),#3  
SETLOP:	LD	HL,#MISSCT 
	LD	B,#7  
	LD	A,#2  
	EX	AF,AF'  
	XOR	A  
SETLP1:	EX	AF,AF'
	CP	B  
	JR	Z,NSETLP  
	EX	AF,AF'  
	OR	(HL)  
	EX	AF,AF'  
NSETLP:	EX	AF,AF'
	INC	HL  
	DJNZ	SETLP1  
	AND	A  
	JR	NZ,STLP99  
	LD	A,(SPACE+3)  
	INC	A  
	JR	NZ,STLP99  
	GET	NFIN  
	INC	A  
	LD	(NFIN),A  
	CP	#30  
	JP	Z,EOS  
	JR	STLP98  
STLP99:	MOV	(NFIN),A 
STLP98:	LD	A,(KILCIT) 
	LD	B,#3  
	LD	HL,#BASES  
STLP96:	OR	(HL) 
	INC	HL  
	DJNZ	STLP96  
	JP	NZ,STLP97  
	LD	HL,#NMIS  
	LD	B,#3  
	XOR	A  
STLP95:	LD	(HL),A 
	INC	HL  
	DJNZ	STLP95  
STLP97:	GET	CRSUP 
	INC	A  
	LD	(CRSUP),A  
	AND	#1  
	JP	Z,STLP7  
	IN	A,(#0x18)  
	AND	#0x40  
	LD	B,A  
	LD	A,(CCT)  
	CP	B  
	JR	Z,STLP1  
	MOV	(CCT),B  
	AND	A  
	JR	Z,STLP2  
; PAGE 20 FOLLOWS

	MOV	(ONOFF),(EM)  
	LD	A,(LSTN)  
	JR	STLP3  
CPLACE:	LD	D,A 
	SHIFT	R,4  
	AND	#15  
	CP	#10  
	JR	C,CPLAC1  
	INC	A  
CPLAC1:	PUSH	DE 
	CALL	PNUM  
	POP	DE  
	LD	A,#15  
	AND	D  
	CP	#10  
	JR	C,CPLAC2  
	INC	A  
CPLAC2:	JP	PNUM
STLP2:	MOV	(ONOFF),(FM) 
	MOV	(LSTN),(SET)  
STLP3:	LD	BC,#30*256+127 
	CALL	CPLACE  
STLP1:	IN	A,(#0x18) 
	AND	#0x20  
	LD	B,A  
	LD	A,(CST)  
	CP	B  
	JR	Z,STLP4  
	MOV	(CST),B  
	AND	A  
	JR	Z,STLP5  
	MOV	(ONOFF),(EM)  
	LD	A,(LCTN)  
	JR	STLP6  
STLP5:	MOV	B,(CITYS) 
	MOV	(ONOFF),(FM)  
	LD	A,(CITYB)  
	ADD	A,B  
	LD	(LCTN),A  
STLP6:	LD	BC,#85*256+127 
	CALL	CPLACE  
STLP4:	LD	HL,#BASES 
	LD	B,#3  
	LD	A,(MISSCT)  
STLP8:	OR	(HL) 
	INC	HL  
	DJNZ	STLP8  
	JR	NZ,STLP8A  
	GET	OFFCRS  
	INC	A  
	JP	Z,STLP7  
	MOV	(OFFCRS),#-1  
	MOV	(ONOFF),(BG)  
	LD	BC,(SITEY)  
	CALL	SITED  
	MOV	(MSPD),#4  
	JP	STLP7  
STLP8A:	LD	HL,#SITEY 
	LD	(SITEOY),HL  
	IN	A,(0x1A)  
	CPL	  
	AND	A,#128  
	AND	#0x0FE  
	RRCA	  
	CP	#5  
	JR	NC,SITE1  
; PAGE 21 FOLLOWS

	LD	A,#5  
SITE1:	CP	#122 
	JR	C,SITE2  
	LD	A,#122  
SITE2:	LD	(SITEX),A 
	IN	A,(#0x19)  
	CPL	  
	ADD	A,#128  
	AND	#0x0FE  
	RRCA	  
	CP	#13  
	JR	NC,SITE3  
	LD	A,#13  
SITE3:	CP	#101 
	JR	C,SITE4  
	LD	A,#101  
SITE4:	LD	(SITEY),A 
	LD	A,(SITEY)  
	CP	C  
	JR	NZ,SITEOK  
	LD	A,(SITEX)  
	CP	B  
	JP	Z,STLP7  
SITEOK:	MOV	(ONOFF),(BG) 
	LD	BC,(SITEOY)  
	CALL	SITED  
STLP9:	MOV	(ONOFF),(FM) 
	LD	BC,(SITEY)  
	CALL	SITED  
STLP7:	CALL	LAUNCH
	MOV	(SMARTU),#0  
	LD	IX,#MISSTB  
	MOV	(LINCOL),(FM)  
	LD	A,(EX)  
	CALL	MOVE  
	MOV	(MISSCT),(COUNT)  
	GET	FHJ  
	INC	A  
	LD	D,A  
	LD	A,(MSPD)  
	CP	D  
	LD	A,D  
	JR	NC,QXA  
	MOV	(LINCOL),(EM)  
	LD	IX,#EMISTB  
	LD	A,#CTEST  
	CALL	MOVE  
	MOV	(EMISCT),(COUNT)  
	CALL	SMOVE  
	CALL	SMLR  
	CALL	KCITY  
	CALL	MCHECK  
	XOR	A  
QXA:	LD	(FHJ),A 
	GET	QQQ  
	INC	A  
	CP	#24  
	JR	NZ,QQ1  
	CALL	EXPLUD  
	XOR	A  
QQ1:	LD	(QQQ),A 
	GET	QQ4  
	INC	A  
	CP	#12  
	JR	NZ,QQ5  
	CALL	SPACER  
; PAGE 22 FOLLOWS

	XOR	A  
QQ5:	LD	(QQ4),A 
	JP	SETLOP  
TAKEAR:	XOR	A 
	JR	ARDRW3  
PUTAR:	LD	A,#1 
ARDRW3:	LD	(ARPUT2),A 
	LD	HL,#SC1+85*16  
	LD	IX,#Q3DAT1  
	LD	IY,#Q3DAT  
	CALL	ARDRW  
	LD	HL,#SC1+117*16  
ARDRW:	LD	B,#3 
ARDRW1:	LD	A,(IY) 
	INC	IY  
	ADD	A,L  
	LD	L,A  
	LD	DE,#-16  
	CALL	ARPUT  
	LD	DE,#16  
	DEC	HL  
	CALL	ARPUT  
	INC	HL  
	DJNZ	ARDRW1  
	RET	  
ARPUT:	LD	C,#3 
ARPUT1:	MOV	(HL),(IX) 
	GET	ARPUT2  
	AND	A  
	JR	NZ,ARPUT3  
	LD	(HL),#0  
ARPUT3:	INC	IX 
	DEC	C  
	RET	Z  
	ADD	HL,DE  
	JR	ARPUT1  
	.area _DATA
DFCTY:	.db	14, 15, 16, 15, 24, 14, 10, 13, 19, 30, 19, 15, 29, 255; DEFNED CITIES 
Q3DAT:	.db	5, 3, 4, 3, 4, 4
Q3DAT1:	AR1	 
	AR2	  
	AR3	  
	AR1	  
	AR1	  
	AR3	  
	.area _CODE
END:	LD	HL,#SC1 
	MOV	(COL1),(COLTAB)  
	MOV	(COL2),(COLTAB+1)  
	CALL	DAZMOD  
	LD	A,#(SC1+0x800)/256  
END1:	LD	(HL),#-1 
	INC	HL  
	CP	H  
	JR	NZ,END1  
	LD	A,#(SC2+0x800)/256  
END2:	LD	(HL),#0 
	INC	HL  
	CP	H  
	JR	NZ,END2  
	MOV	(INT2B),#1  
	OUT	(#TIMERA_2),A  
	MOV	(ONOFF),#C11  
	LD	BC,#64+64*256  
	DOT	  
	LD	D,#1  
END14:	CALL	END3
	INC	D  
	CMP	D,#64  
; PAGE 23 FOLLOWS

	JR	NZ,END14  
	MOV	(ONOFF),#C00  
	MOV	(END16),#6  
	LD	HL,#ENDXY  
	LD	(END19),HL  
	LD	HL,#ENDCH  
	LD	(END20),HL  
END17:	GET	END16 
	DEC	A  
	LD	(END16),A  
	JP	M,END18  
	LD	BC,(0)  
END19	.equ	.-2 
	LD	HL,(END19)  
	INC	HL  
	INC	HL  
	LD	(END19),HL  
	LD	HL,#0  
END20	.equ	.-2 
	LD	A,(HL)  
	INC	HL  
	LD	(END20),HL  
	LD	HL,#ENDST  
	LD	DE,#9  
END21:	DEC	A 
	JP	M,END22  
	ADD	HL,DE  
	JR	END21  
	.area _DATA
ENDCH:	.db	0, 1, 2, 2, 3, 4
ENDST:	.db	16, 16, 16, 16, 16, 16, 16, 16, 127
	.db	65, 65, 65, 65, 127, 65, 65, 65, 65
	.db	127, 64, 64, 64, 112, 64, 64, 64, 127
	.db	65, 65, 65, 67, 69, 73, 81, 97, 65
	.db	124, 34, 33, 33, 33, 33, 33, 34, 124
ENDXY:	.db	61, 50, 61, 74, 61, 98
	.db	94, 51, 94, 75, 94, 99
AREADY:	.db	17, 15, 30, 10, 28, 15, 11, 14, 35, 10, 26, 22, 11, 35, 15
	.db	28, 10, 255; GET READY PLAUER 
BREADY:	.db	34, 10, 12, 25, 24, 31, 29, 255
	.area _CODE
END22:	LD	D,#9 
END23:	LD	E,#7 
	MOV	(END25),(HL)  
	INC	HL  
	PUSH	BC  
END24:	GET	END25 
	RRCA	  
	LD	(END25),A  
	CALL	C,END26  
	DEC	B  
	DEC	B  
	DEC	B  
	DEC	E  
	JR	NZ,END24  
	POP	BC  
	DEC	C  
	DEC	C  
	DEC	C  
	DEC	D  
	JR	NZ,END23  
	LD	HL,#20000  
	CALL	DELAY  
	JP	END17  
END26:	PUSH	HL 
	PUSH	DE  
	PUT	#44  
	POP	DE  
; PAGE 24 FOLLOWS

	POP	HL  
	LD	A,#-6  
	ADD	A,B  
	LD	B,A  
	RET	  
END18:	MOV	(ONOFF),#C01 
	LD	D,#63  
END15:	CALL	END3
	DEC	D  
	JR	NZ,END15  
	JP	GBEGIN  
END3:	LD	BC,#64+64*256 
	LD	A,D  
	ADD	B  
	LD	B,A  
	LD	E,D  
END5:	DEC	E 
	JP	M,END6  
	DEC	C  
	DEC	B  
	DOT	  
	JR	END5  
END6:	LD	E,D 
END7:	DEC	E 
	JP	M,END8  
	INC	C  
	DEC	B  
	DOT	  
	JR	END7  
END8:	LD	E,D 
END9:	DEC	E 
	JP	M,END10  
	INC	C  
	INC	B  
	DOT	  
	JR	END9  
END10:	LD	E,D 
END11:	DEC	E 
	JP	M,END12  
	DEC	C  
	DEC	B  
	DOT	  
	JR	END11  
END12:	LD	HL,#1000 
	CALL	DELAY  
	RET	  
	.area _DATA
INMES:	.db	26, 28, 15, 29, 29, 10, 12, 31, 30, 30, 25, 24, 10, 30, 18, 28, 15, 15, 10, 16
; PRESS BUTTON THREE F
; CONSULT PAGE 23A 
	.db	25, 28, 10, 25, 24, 15, 10, 26, 22, 11, 35, 15, 28, 10, 29, 30, 11, 28
; OR ONE PLAYER STAR
	.db	30, 10, 25, 28, 10, 26, 28, 15, 29, 29, 10, 12, 31, 30, 30, 25, 24, 10, 16, 25, 31, 28, 10, 16, 25
; T OR PRESS BUTTON FOUR FO
	.db	28, 10, 30, 33, 25, 10, 26, 22, 11, 35, 15, 28, 10, 29, 30, 11, 28, 30
; R TWO PLAYER START
	.db	43, 10, 10, 30, 18, 19, 29, 10, 32, 15, 28, 29, 19, 25, 24, 10, 25
; . THIS VERSION O
	.db	16, 10, 23, 19, 29, 29, 19, 22, 15, 10, 13, 25, 23, 23, 11, 24, 14
; F MISSILE COMMAND
	.db	10, 33, 11, 29, 10, 33, 28, 19, 30, 30, 15, 24
; WAS WRITTEN
	.db	10, 12, 35, 10, 20, 15, 16, 16, 10, 21, 15, 29, 24, 15, 28
; BY JEFF KESNER
	.db	10, 11, 24, 14, 10, 23, 11, 30, 30, 18, 15, 33, 10, 16, 28
; AND MATTHEW FR
	.db	11, 24, 13, 15, 35, 43
; ANCEY.
; PAGE 25 FOLLOWS
	.db	10, 10, 20, 31, 24, 15, 10, 1, 6, 10, 10, 1, 9, 8, 2
; JUNE 16, 1982
	.db	10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
BMESPL	.equ	.-INMES 
BCITY:	.db	12, 25, 24, 31, 29, 10, 13, 19, 30, 35, 10, 16, 25, 28, 255; BONUS CITY FOR 
BCITY8:	.db	10, 8, 0, 0, 0, 25; 8000 
MBONP:	.db	12, 25, 24, 31, 29, 10, 26, 25, 19, 24, 30, 29, 255
CITBN:	.db	12, 25, 24, 31, 29, 10, 13, 19, 30, 35, 255
COLTAB:	.db	113, 126, 122, 125, 124, 123
CBTAB:	.db	1, 2, 3, 3, 1, 1, 2, 3, 3, 1
COLUSE:	.db	2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3
	.db	1, 2, 0, 3, 1, 0, 2, 3, 2, 0, 3, 1
	.db	1, 0, 2, 3, 1, 0, 2, 3, 1, 0, 3, 2, 0, 2, 1, 3
PBASE:	.db	5, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
	.db	5, 2, 1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0
	.db	0, 0, 1, 0, 0, 0, 0
PLAY:	.db	1
;CITPOS:	.db	41, 121, 71, 119, 27, 116, 86, 118, 14, 117, 101, 119 ; old PNUM version
CITPOS:	.db	40, 121, 70, 119, 26, 116, 85, 118, 13, 117, 100, 119	; new PNUM version
MISPOS:	.db	7, 109, 62, 109, 120, 109
LOWTAB:	.db	4, 59, 115
MISDIS:	.db	0, 1, -2, 3, 4, 0, -6, 3, 4, 0, 4, 0, -10, 3, 4, 0, 4, 0, 4, 0
CIRC2:	.db	0, 0, 1, 0, 0, -1, -1, 0, -1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0x80
CIRC3:	.db	2, 0, 0, -1, -1, -1, -1, 0, -1, 0, -1, 1, 0, 1, 0, 1, 1, 1
	.db	1, 0, 1, 0, 1, -1, 0x80
CIRC4:	.db	3, 0, 0, -1, -1, -1, -1, -1, -1, 0, -1, 0, -1, 1, -1, 1, 0, 1
	.db	0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, -1, 1, -1, 0x80
CIRC5:	.db	4, 0, 0, -1, 0, -1, -1, 0, 0, -1, -1, 0, 0, -1, -1, 0, -1, 0
	.db	-1, 0, -1, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0, 1, 0, 1, 0, 1, 0, 1
	.db	1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, -1, 1, 0, 0, -1
	.db	1, -1, 0, -1, 0x80
CIRC6:	.db	5, 0, 0, -1, 0, -1, -1, -1, 0, -1, -1, 0, -1, -1, -1, 0, -1, 0
	.db	-1, -0, -1, 0, -1, 1, -1, 0, 0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 0, 1
	.db	1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, -1, 1, 0, 0, -1
	.db	1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, -1, 1, 0, 0, -1
	.db	1, -1, 0, -1, 0x80
CIRC7:	.db	6, 0, 0, -1, 0, -1, -1, -1, 0, -1, -1, -1, -1, 0, -1, -1, -1, 0
	.db	-1, 0, -1, 0, -1, 0, -1, 1, -1, 0, -1, 1, 0, 1, -1, 1, 0, 1, 0, 1
	.db	0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0
	.db	1, -1, 1, 0, 1, -1, 0, -1, 1, -1, 0, -1, 0x80
CIRC8:	.db	7, 0, 0, -1, 0, -1, -1, -1, 0, -1, -1, -1, -1, -1, -1, 0
	.db	-1, -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 1, -1, 0, -1, 1, -1, 1
	.db	0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0
	.db	1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, -1, 1, 0, 1, -1, 1, -1, 0, -1
	.db	1, -1, 0, -1, 0x80
CIRC9:	.db	8, 0, 0, -1, 0, -1, -1, -1, 0, -1, -1, -1, -1, -1, -1, -1
	.db	-1, 0, -1, -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 1, -1, 0, -1, 1
	.db	-1, 1, -1, 1, 0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1
	.db	1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, -1, 1, 0
; PAGE 27 FOLLOWS

	.db	1, -1, 1, -1, 1, -1, 0, -1, 1, -1, 0, -1, 128
CIRCTB:	.dw	CIRC2, CIRC3, CIRC4, CIRC5, CIRC6, CIRC7
	.dw	CIRC8, CIRC9
; Set data/details
; +0 = Number of missiles
; +1 = Number of bombers
; +2 = Number of smart missiles
; +3 = Speed of missiles

SETDT:	.db	12, 0, 0, 28
	.db	16, 2, 0, 20
	.db	20, 3, 0, 13
	.db	16, 4, 0, 9
	.db	20, 4, 0, 8
	.db	16, 3, 1, 7
	.db	20, 4, 3, 7
	.db	12, 3, 2, 6
	.db	16, 4, 4, 6
	.db	20, 5, 5, 6
	.db	25, 5, 6, 5
	.db	23, 4, 6, 5
SCITY:	.db	4
CUSETB:	.db	C00, C01, C10, C11
BONUS:	.db	0x10
SOUND:	.db	0x7F
	.area	_CODE
_DAZMOD::	
DAZMOD::
	PUSH	AF 
	LD	A,#SC1/512+0x80 
	LD	(DZOFF1),A  
	LD	A,#SC2/512+0x80  
	LD	(DZOFF2),A  
	LD	A,(COL1)  
	OUT	(#DAZZ_COLOR),A  
	LD	A,(COL2)  
	OUT	(#DAZZ_COLOR),A  
	LD	A,#0x0D1  
	OUT	(#DAZZ_COLOR),A  
	LD	A,(DZOFF1)  
	OUT	(#DAZZ_ADDR),A  
	POP	AF  
	RET	  
INT1:	DI	 
	PUSH	AF  
	GET	PACEDZ  
	DEC	A  
	LD	(PACEDZ),A  
	JR	NZ,INT1C  
	CALL	DAZMOD  
	MOV	(PACEDZ),#30  
	JR	INT1C ; Use simulated page flipping in DAZMOD, Dec 2020
		  
	DI	  
	PUSH	AF  
INT1D:	IN	A,(#0x0E) 
	AND	#0x40  
	JP	NZ,INT1D  
	GET	INT1A  
	INC	A  
	LD	(INT1A),A  
	AND	#1  
	JP	Z,INT1B  
	GET	COL1  
	OUT	(#DAZZ_COLOR),A  
	LD	A,#SC1/512+0x80 
DZOFF1	.gblequ	.-1 
	OUT	(#DAZZ_ADDR),A  
	JP	INT1C  
INT1B:	GET	COL2 
	OUT	(#DAZZ_COLOR),A  
	LD	A,#SC2/512+0x80  
DZOFF2	.gblequ	.-1 
	OUT	(#DAZZ_ADDR),A  
INT1C:	LD	A,#248 
	OUT	(#TIMERA_1),A  
	POP	AF  
	EI	  
	RET	  
; Draw the land

FORE:	LD	IY,#CRATF 
	LD	BC,#127 ; x,y 0,127
	LD	HL,#FTAB  
	LD	DE,#3*256  
FORE1:	CALL	FORES; Get 4 bits from FTAB
	AND	A  
	JR	Z,FORE3 ; 0 means next is repeat count and then height
	CALL	REPT ; Draw a column to given height
FORE8:	XOR	A 
	ADD	B  
	JP	P,FORE1 ; B goes 0-127
	RET	  
FORE3:	CALL	FORES; Get 4 bits from FTAB
	LD	(FORE5),A  
	CALL	FORES  
FORE6:	CALL	REPT; Loop here for 4 bit quantity from FTAB times
	GET	FORE5 ; REPT draws a column
	DEC	A  
	LD	(FORE5),A  
	LD	A,E  
	JR	NZ,FORE6  
; PAGE 28 FOLLOWS

	JR	FORE8  
; Enters with height-5

REPT:	PUSH	DE 
	ADD	A,#5  
	MOV	E,A  
FORE4:	DOT	 
	DEC	C  
	DEC	E ; The height of this column of terrain
	JR	NZ,FORE4  
	INC	C  
	LD	(IY),C ; Save height of this column for cratering data (CRATF)
	INC	IY  
	INC	B ; Next X
	LD	C,#127 ; y = 127
	POP	DE  
	RET	  
FORES:	LD	A,E 
	RLD	  
	DEC	D  
	JR	NZ,FORE2 ; 3 rotates to fix memory around, so done with this FTAB entry
	INC	HL  
	RLD	  
	LD	D,#2  
FORE2:	LD	E,A 
	RET	  
; Foreground drawing data (and missile bases) in nybbles, either height or 0 for repeat followed by count and height
	.area	_DATA
FTAB:	.db	0x0ED, 07, 0x0CD, 0x0E9, 0x60, 0x0D5, 0x0D, 0x65, 0x40, 0x0B1, 0x23, 0x69, 0x0CE, 0x0D0, 0x7C, 0x0DE; 1982 Listing didn't have 0x0B1 
	.db	0x0C9, 0x60, 0x0C3, 0x45, 0x0D, 0x45, 0x54, 0x0C, 0x34, 0x69, 0x0CE, 0x0D0, 0x7C, 0x0DE
	.area	_CODE
INT2:	DI	 
	PUSH	AF  
	LD	A,(0x100)  
INT2A	.equ	.-2 
	OUT	(#0x19),A  
	LD	A,(INT2A)  
	INC	A  
	LD	(INT2A),A  
	JR	Z,INT2C  
	LD	A,#2  
INT2B	.equ	.-1 
	OUT	(#TIMERA_2),A  
INT2D:	POP	AF
	EI	  
	RET	  
INT2C:	LD	A,(INT2B) 
	INC	A  
	LD	(INT2B),A  
	CP	#22  
	JR	Z,INT2D  
	JP	INT2B-1  
NSTAT	.equ	7 
NDEL	.equ	12 
NUMEXP	.equ	20 
EXPLUD:	LD	A,(EXPLCT) 
	CP	#NDEL  
; THE FOLLOWING JUMP IS TO GET AROUND PAUSE

	JR	EXUD1  
	NEG	  
	ADD	A,#NDEL  
	LD	D,A  
	MOV	(ONOFF),#CTEST  
EXUD2:	LD	E,#20 
EXUD3:	DOT	 
	DEC	E  
	JR	NZ,EXUD3  
	DEC	D  
	JR	NZ,EXUD2  
EXUD1:	LD	D,#NUMEXP 
	MOV	(EXPLCT),#0  
; PAGE 29 FOLLOWS

	LD	HL,#EXPLTB  
XPLUD8:	LD	B,(HL) 
	INC	HL  
	LD	C,(HL)  
	INC	HL  
	LD	A,(HL)  
	INC	A  
	JR	Z,XPLD4A  
	LD	A,(EXPLCT)  
	INC	A  
	LD	(EXPLCT),A  
	MOV	(ONOFF),(EX)  
	MOV	(CRATP),#0  
	LD	A,(HL)  
	CP	#NSTAT  
	JR	C,XPLUD1  
	MOV	(ONOFF),(BG)  
	MOV	(CRATP),#1  
	LD	A,#2*NSTAT-1  
	SUB	(HL)  
XPLUD1:	ADD	A,A 
	PUSH	DE  
	PUSH	HL  
	LD	HL,#CIRCTB  
	LD	E,A  
	LD	D,#0  
	ADD	HL,DE  
	LD	E,(HL)  
	INC	HL  
	LD	D,(HL)  
XPLUD2:	LD	A,(DE) 
	INC	DE  
	CP	#128  
	JR	Z,XPLUD3  
	ADD	A,B  
	LD	B,A  
	LD	A,(DE)  
	INC	DE  
	ADD	A,C  
	LD	C,A  
	CP	#123  
	JR	NC,XPLUD2  
	CP	#6  
	JR	C,XPLUD2  
	GET	CRATP  
	AND	A  
	PUSH	HL  
	JR	Z,NCRAT  
	MOV	(ONOFF),(BG)  
	LD	H,#CRATF/256  
	LD	A,#0x7F  
	AND	B  
	LD	L,A  
	LD	A,(HL)  
	CP	C  
	JR	NC,NCRAT  
	MOV	(ONOFF),(EM)  
	JR	NCRAT1  
NCRAT	.equ	. 
NCRAT1:	POP	HL
	DOT	  
	JR	XPLUD2  
XPLUD3:	POP	HL
	INC	(HL)  
	LD	A,#-2*NSTAT  
	ADD	A,(HL)  
; PAGE 30 FOLLOWS

	JR	NZ,XPLUD4  
	LD	(HL),#-1  
	LD	A,(EXPLCT)  
	DEC	A  
	LD	(EXPLCT),A  
XPLUD4:	POP	DE
XPLD4A:	DEC	D 
	RET	Z  
	INC	HL  
	JP	XPLUD8  
SITED:	DEC	B 
	DEC	B  
	CALL	XYEX  
	INC	B  
	CALL	XYEX  
	INC	B  
	CALL	XYEX  
	INC	B  
	CALL	XYEX  
	INC	B  
	CALL	XYEX  
	DEC	C  
	DEC	C  
	DEC	B  
	DEC	B  
	CALL	XYEX  
	INC	C  
	CALL	XYEX  
	INC	C  
	INC	C  
	CALL	XYEX  
	INC	C  
XYEX:	MOV	E,(ONOFF) 
	MOV	(ONOFF),#CTEST  
	DOT	  
	LD	D,A  
	MOV	(ONOFF),E  
	LD	A,(EX1)  
	CP	D  
	RET	Z  
	EXX	  
	RES	3,H  
	JP	XYACMP  
TARGET:	LD	+11(IX),A 
	LD	+12(IX),H  
	LD	(IX),B  
	LD	+1(IX),C  
	LD	+7(IX),B  
	LD	+8(IX),C  
	LD	A,D  
	SUB	B  
	LD	+5(IX),#1  
	JP	P,D1  
	LD	+5(IX),#-1  
	NEG	  
D1:	LD	+2(IX),A 
	LD	A,E  
	SUB	C  
	LD	+6(IX),#1  
	JP	P,D2  
	LD	+6(IX),#-1  
	NEG	  
D2:	LD	+3(IX),A 
; PAGE 31 FOLLOWS

	SRL	A  
	LD	+4(IX),A  
	LD	+9(IX),D  
	LD	+10(IX),E  
	RET	  
MOVE:	LD	D,#8 
	LD	(TIPCOL),A  
	MOV	(COUNT),#0  
MOVENM	.equ	. 
INCR3:	LD	A,+12(IX) 
	INC	A  
	JR	Z,INCR4  
	BIT	7,+11(IX)  
	JR	Z,UPD  
	LD	A,+11(IX)  
	XOR	#1  
	LD	+11(IX),A  
	AND	#1  
	JR	NZ,INCR1  
UPD:	LD	E,#1 
	PUSH	DE  
	GET	LINCOL  
	LD	(ONOFF),A  
	CALL	LINE  
	JR	Z,EXP  
	POP	DE  
INCR1:	LD	A,(COUNT) 
	INC	A  
	LD	(COUNT),A  
INCR4:	DEC	D 
	RET	Z  
	LD	BC,#13  
	ADD	IX,BC  
	JR	INCR3  
EXP:	LD	A,+12(IX) 
	CP	#0x20  
	JR	NC,EXPER  
	SRL	A  
	CP	#6  
	JR	NC,EXPZZ  
	LD	HL,#CITTAB  
	LD	C,A  
	LD	B,#0  
	ADD	HL,BC  
	LD	A,(HL)  
	OR	A  
	JR	Z,EXPER  
	LD	A,(CITYS)  
	DEC	A  
	LD	(CITYS),A  
	LD	A,(KILCIT)  
	DEC	A  
	LD	(KILCIT),A  
EXPQW:	LD	(HL),#0 
	MOV	(EXPLV),#EXPLLL  
	JR	EXPER  
EXPZZ:	SUB	#5 
	LD	(BL),A  
	CALL	OUTM  
	LD	A,(BL)  
	DEC	A  
	LD	HL,#BASES  
	LD	C,A  
	LD	B,#0  
	ADD	HL,BC  
	LD	A,(HL)  
; PAGE 32 FOLLOWS

	OR	A  
	JR	NZ,EXPQW  
EXPER:	CALL	EXPSET
	POP	DE  
	JR	INCR4  
LINE:	LD	B,(IX) 
	LD	C,+1(IX)  
	DOT	  
	GET	TIPCOL  
	LD	(ONOFF),A  
LINE1:	LD	A,+9(IX) 
	CP	(IX)  
	JR	NZ,NOENDL  
	LD	A,+1(IX)  
	CP	+10(IX)  
	RET	Z  
NOENDL:	LD	A,+3(IX) 
	CP	+4(IX)  
	JR	C,NOX  
	LD	A,+1(IX)  
	ADD	A,+6(IX)  
	LD	+1(IX),A  
	LD	A,+4(IX)  
	ADD	A,+2(IX)  
	LD	+4(IX),A  
	CP	+3(IX)  
	JR	C,YTF  
NOX:	LD	A,(IX) 
	ADD	A,+5(IX)  
	LD	(IX),A  
	LD	A,+4(IX)  
	SUB	+3(IX)  
	LD	+4(IX),A  
YTF:	LD	B,(IX) 
	LD	C,+1(IX)  
	DOT	  
	DEC	E  
	JR	NZ,LINE1  
	OR	#1  
	RET	  
SEARCH:	LD	B,#8 
SERCHR:	LD	DE,#13 
SERCH1:	LD	A,+12(IX) 
	INC	A  
	RET	Z  
	ADD	IX,DE  
	DJNZ	SERCH1  
	RET	  
QCHECK:	MOV	(HFLAG),#0 
	MOV	(ONOFF),#CTEST  
	MOV	E,(EX1)  
QCHK1:	LD	A,(HL) 
	CP	#0x80  
	RET	Z  
	ADD	A,B  
	LD	B,A  
	INC	HL  
	LD	A,(HL)  
	INC	HL  
	ADD	A,C  
	LD	C,A  
	DOT	  
	CP	E  
	JR	NZ,QCHK1  
	GET	HFLAG  
	INC	A  
	LD	(HFLAG),A  
; PAGE 33 FOLLOWS

	JR	QCHK1  
	.area	_DATA	
SQUARE:	.db	1, 1, 0, -1, 0, -1, -1, 0, -1, 0, 0, 1, 0, 1, 1, 0, 128
	.area	_CODE
EXPFND:	LD	IY,#EXPLTB 
	LD	DE,#3  
	LD	B,#NUMEXP  
EXPF1:	LD	A,+2(IY) 
	INC	A  
	RET	Z  
	ADD	IY,DE  
	DJNZ	EXPF1  
	RET	  
EXPSET:	CALL	EXPFND
	JR	NZ,EXP2  
	MOV	(IY),(IX)  
	MOV	+1(IY),+1(IX)  
	MOV	+2(IY),#0  
EXP2:	CALL	KCITR
	LD	+12(IX),#-1  
	GET	SMARTU  
	OR	A  
	RET	NZ  
	MOV	+9(IX),(IX)  
	MOV	+10(IX),+1(IX)  
	MOV	(IX),+7(IX)  
	MOV	+1(IX),+8(IX)  
	LD	A,+3(IX)  
	SRL	A  
	LD	+4(IX),A  
	LD	E,#0  
	MOV	(TIPCOL),(BG)  
	LD	(ONOFF),A  
	JP	LINE  
MCHECK:	LD	IX,#EMISTB 
	LD	D,#0  
MCHK1:	LD	A,+12(IX) 
	INC	A  
	PUSH	DE  
	JP	Z,MCHKA2  
	LD	B,(IX)  
	LD	C,+1(IX)  
	LD	A,C  
	CP	#110  
	JR	NC,MCHKA  
	CP	#7  
	JR	C,MCHKA  
	MOV	(ONOFF),#CTEST  
	DOT	  
	LD	E,A  
	LD	A,(EX1)  
	CP	E  
	JR	NZ,MCHKA1  
	LD	E,#NUMEXP  
	LD	IY,#EXPLTB  
SKPE5:	LD	A,+2(IY) 
	INC	A  
	JR	Z,SKPE1  
	DEC	A  
	CP	#NSTAT+1  
	JR	C,SKPE2  
	NEG	  
	ADD	A,#2*NSTAT+1  
SKPE2:	INC	A 
	LD	D,A  
	LD	A,(IY)  
	SUB	B  
; PAGE 34 FOLLOWS

	JP	P,SKPE3  
	NEG	  
SKPE3:	CP	D 
	JR	NC,SKPE1  
	LD	A,+1(IY)  
	SUB	C  
	JP	P,SKPE4  
	NEG	  
SKPE4:	CP	D 
	JR	C,SKPE6  
SKPE1:	INC	IY 
	INC	IY  
	INC	IY  
	DEC	E  
	JR	NZ,SKPE5  
	JR	MCHKA1  
SKPE6:	PUSH	DE 
	CALL	EXPSET  
	XOR	A  
	CALL	SINC  
	MOV	(EXPLV),#EXPLLL  
	POP	DE  
MCHKA1:	MOV	(ONOFF),(EX) 
	EXX	  
	RES	3,H  
	CALL	XYACMP  
	JR	MCHKA2  
MCHKA:	MOV	(ONOFF),(EX) 
	DOT	  
MCHKA2:	LD	BC,#13 
	POP	DE  
	ADD	IX,BC  
	DEC	D  
	JP	NZ,MCHK1  
	RET	  
KCITY:	GET	WWAVE 
	OR	A  
	JR	Z,KCIT9  
	DEC	A  
	LD	(WWAVE),A  
	RET	  
KCIT9:	GET	WAVEC 
	INC	A  
	AND	#15  
	LD	(WAVEC),A  
	JP	Z,KCIT8  
	GET	SWAVEC  
	CP	#4  
	RET	NC  
KCIT7:	LD	A,(NMIS) 
	OR	A  
	RET	Z  
KCITYA:	CALL	RAND
	AND	#7  
	JR	Z,MIRV  
	LD	A,(SPACE+3)  
	INC	A  
	JP	Z,MIRV  
	CP	#1  
	JR	Z,SP1  
	LD	H,#0  
	LD	L,#4  
	JR	SP2  
SP1:	LD	H,#7 
	LD	L,#0  
SP2:	LD	A,(SPACE+2) 
; PAGE 35 FOLLOWS

	DEC	A  
	JR	Z,SP3  
	LD	A,H  
	NEG	  
	LD	H,A  
SP3:	LD	A,(SPACE) 
	CP	#15  
	JR	C,MIRV  
	CP	#112  
	JR	NC,MIRV  
	ADD	A,H  
	LD	B,A  
	LD	A,(SPACE+1)  
	ADD	A,L  
	LD	C,A  
	JR	KCIT1  
MIRV:	CALL	RAND
	AND	#3  
	JR	NZ,TOPS  
	LD	IX,#EMISTB  
	LD	D,#8  
	LD	BC,#13  
MIRV2:	LD	A,+12(IX) 
	INC	A  
	JR	Z,MIRV1  
	CALL	RAND  
	AND	#3  
	JR	NZ,MIRV1  
	LD	A,+1(IX)  
	CP	#10  
	JR	C,MIRV1  
	CP	#80  
	JR	NC,MIRV1  
	LD	C,A  
	LD	B,(IX)  
KCIT1:	CALL	RAND
	AND	#3  
	INC	A  
	LD	H,A  
	LD	A,#4  
	LD	(SWAVEC),A  
	JR	KCIT2  
MIRV1:	ADD	IX,BC 
	DEC	D  
	JR	NZ,MIRV2  
TOPS:	LD	H,#1 
	CALL	RAND  
	AND	#0x7F  
	LD	B,A  
	LD	C,#5  
	LD	A,(SWAVEC)  
	INC	A  
	LD	(SWAVEC),A  
KCIT2:	LD	A,(NMIS) 
	OR	A  
	RET	Z  
	EXX	  
SXCZ:	CALL	TCITY
	LD	L,A  
	PUSH	DE  
	LD	IX,#EMISTB  
	CALL	SEARCH  
	LD	A,L  
	EXX	  
	POP	DE  
	JR	NZ,KCIT5  
; PAGE 36 FOLLOWS

	PUSH	HL  
	LD	H,A  
	CALL	RAND  
	AND	#0x80  
KCIT10:	CALL	TARGET
	POP	HL  
	LD	A,(NMIS)  
	DEC	A  
	LD	(NMIS),A  
	DEC	H  
	JR	NZ,KCIT2  
	RET	  
KCIT5:	LD	A,#95 
	LD	(WWAVE),A  
	MOV	(WAVEC),#0  
	LD	(SWAVEC),A  
	RET	  
KCIT8:	MOV	(SWAVEC),#0 
	JP	KCIT7  
SMLR:	LD	A,(NSMS) 
	OR	A  
	RET	Z  
	LD	A,(WAVEC)  
	OR	A  
	RET	NZ  
	LD	A,(NMIS)  
	CP	#4  
	JR	C,SMLR1  
	CALL	RAND  
	AND	#63  
	RET	NZ  
SMLR1:	LD	A,#1 
	LD	(WAVEC),A  
	LD	A,(WWAVE)  
	CP	#6  
	JR	NC,SMLR2  
	LD	A,#6  
	LD	(WWAVE),A  
SMLR2:	LD	B,#3 
	LD	IX,#SMISTB  
	CALL	SERCHR  
	RET	NZ  
	CALL	TCITY  
	LD	H,A  
	CALL	RAND  
	AND	#0x7F  
	LD	B,A  
	LD	C,#6  
	CALL	RAND  
	AND	#0x80  
	CALL	TARGET  
	LD	A,(NSMS)  
	DEC	A  
	LD	(NSMS),A  
	RET	
	.area	_DATA
SMARTP:	.db	1, 0, -1, 1, -1, -1, 1, -1, 128
	.area	_CODE
LAUNCH:	IN	A,(0x18) 
	CPL	  
	AND	#7  
	LD	(BUTTON),A  
	LD	HL,#MISPOS  
	LD	DE,#BASES  
	LD	BC,#FBASE  
	MOV	(BL),A  
LANCH:	GET	BUTTON 
	SRL	A  
; PAGE 37 FOLLOWS

	LD	(BUTTON),A  
	JP	NC,LANCH1  
	LD	A,(BC)  
	OR	A  
	JP	NZ,LANCH2  
	PUSH	HL  
	PUSH	DE  
	PUSH	BC  
	LD	IX,#MISSTB  
	CALL	SEARCH  
	JP	NZ,BOINK  
	POP	BC  
	POP	DE  
	PUSH	DE  
	PUSH	BC  
	LD	A,(DE)  
	OR	A  
	JP	Z,BOINK  
	LD	B,(HL)  
	INC	HL  
	LD	C,(HL)  
	PUSH	DE  
	PUSH	BC  
	LD	D,A  
	LD	HL,#MISDIS  
MISO:	LD	A,(HL) 
	ADD	A,B  
	LD	B,A  
	INC	HL  
	LD	A,(HL)  
	ADD	A,C  
	LD	C,A  
	INC	HL  
	DEC	D  
	JR	NZ,MISO  
	MOV	(ONOFF),(EM)  
	CALL	LISSIM  
	POP	BC  
	POP	DE  
	LD	A,(DE)  
	DEC	A  
	LD	(DE),A  
	CALL	Z,OUTM  
	CP	#3  
	CALL	Z,LOWM  
	MOV	(WLEV),#8  
	MOV	(WLEN),#80  
	LD	A,#8  
	OUT	(#TIMERA_3),A  
	PUSH	BC  
	MOV	B,(SITEX)  
	MOV	C,(SITEY)  
	LD	E,C  
	LD	D,B  
	MOV	(ONOFF),(EM)  
	DOT	  
	INC	B  
	INC	C  
	DOT	  
	DEC	C  
	DEC	C  
	DOT	  
	DEC	B  
	DEC	B  
	DOT	  
	INC	C  
; PAGE 38 FOLLOWS

	INC	C  
	DOT	  
	POP	BC  
	GET	BL  
	CP	#2  
	LD	A,#0x80  
	JR	NZ,BL1  
	XOR	A  
BL1:	LD	A,#0x80 
	CALL	TARGET  
LANCH3:	POP	BC
	POP	DE  
	POP	HL  
	LD	A,#1  
	JR	LANCH2  
LANCH1:	XOR	A 
LANCH2:	LD	(BC),A 
	INC	BC  
	INC	DE  
	INC	HL  
	INC	HL  
	LD	A,(BL)  
	INC	A  
	CP	#4  
	RET	Z  
	LD	(BL),A  
	JP	LANCH  
BOINK:	MOV	(OMV),#8 
	MOV	(OML),#30  
	LD	A,#8  
	OUT	(#TIMERA_4),A  
	JR	LANCH3  
; Draw a single missile in it's base

LISSIM:	DOT	 
	INC	C  
	DOT	  
	INC	B  
	INC	C  
	DOT	  
	DEC	B  
	DEC	B  
	DOT	  
	INC	B  
	DEC	C  
	DEC	C  
	RET	  
OUTM:	PUSH	BC 
	MOV	(ONOFF),(EM)  
	CALL	MESPOS  
	LD	HL,#LOWMIS  
	PUSH	BC  
	CALL	MESOUT  
	POP	BC  
	LD	HL,#OUTMIS  
	MOV	(ONOFF),(BG)  
	CALL	MESOUT  
	POP	BC  
	XOR	A  
	RET	  
MESPOS:	EXX	 
	MOV	E,(BL)  
	LD	D,#0  
	LD	HL,#LOWTAB  
	DEC	E  
	ADD	HL,DE  
	LD	B,(HL)  
	LD	C,#127  
; PAGE 39 FOLLOWS

	PUSH	BC  
	EXX	  
	POP	BC  
	RET	  
LOWM:	PUSH	BC 
	MOV	(ONOFF),(BG)  
	CALL	MESPOS  
	LD	HL,#LOWMIS  
	CALL	MESOUT  
	MOV	(MLN),#5  
	MOV	(WSL),#1  
	MOV	(ML1),#255  
	LD	A,#8  
	OUT	(#TIMERA_5),A  
	POP	BC  
	RET	  
	.area	_DATA	
LOWMIS:	.db	22, 25, 33, 255
OUTMIS:	.db	25, 31, 30, 255
	.area	_CODE
EOS:	LD	A,(SET) 
	INC	A  
	LD	(SET),A  
	MOV	(SPACE+3),#-1  
	MOV	(ONOFF),(BG)  
	MOV	B,(SITEX)  
	MOV	C,(SITEY)  
	CALL	SITED  
	LD	BC,#28*256+45  
	LD	HL,#MBONP  
	MOV	(ONOFF),(FM)  
	CALL	MESOUT  
	LD	HL,#46*256+49  
	LD	(BMXYP),HL  
	CALL	TSCL  
	LD	DE,#MISPOS  
	MOV	(MMMMM),#3  
	LD	HL,#BASES  
MMMLP:	MOV	B,(DE) 
	INC	DE  
	MOV	C,(DE)  
	INC	DE  
	XOR	A  
	ADD	A,(HL)  
	JR	Z,MMM1  
	PUSH	DE  
	LD	DE,#MISDIS  
MMM2:	LD	A,(DE) 
	ADD	A,B  
	LD	B,A  
	INC	DE  
	LD	A,(DE)  
	ADD	A,C  
	LD	C,A  
	INC	DE  
	PUSH	DE  
	PUSH	HL  
	PUSH	BC  
	MOV	(ONOFF),(EM)  
	CALL	LISSIM  
	MOV	(ONOFF),(FM)  
	LD	BC,#0  
BMXYP	.equ	.-2 
	CALL	LISSIM  
	LD	HL,(BMXYP)  
	INC	HL  
	INC	HL  
	INC	HL  
; PAGE 40 FOLLOWS

	INC	H  
	LD	(BMXYP),HL  
	LD	A,#3  
	CALL	SINC  
	MOV	(ALTSP1),#56  
	LD	A,#3  
	CALL	BONSC  
	CALL	SNCK  
	POP	BC  
	POP	HL  
	POP	DE  
	DEC	(HL)  
	JR	NZ,MMM2  
	POP	DE  
MMM1:	GET	MMMMM 
	DEC	A  
	LD	(MMMMM),A  
	JR	Z,CSBM  
	INC	HL  
	LD	A,(BMXYP)  
	ADD	A,#4  
	LD	(BMXYP),A  
	MOV	(BMXYP+1),#46  
	JP	MMMLP  
CSBM:	LD	HL,#50*256+70 
	LD	(BCXYP),HL ; BONUS CITY CALC
	CALL	TSCL  
	LD	DE,#CITPOS  
	LD	HL,#CITTAB  
	MOV	(CCCCC),#7  
CCCLP:	MOV	B,(DE) 
	INC	DE  
	MOV	C,(DE)  
	INC	DE  
	GET	CCCCC  
	DEC	A  
	LD	(CCCCC),A  
	JR	Z,EOS1  
	LD	A,(HL)  
	AND	A  
	INC	HL  
	JR	Z,CCCLP  
	PUSH	DE  
	PUSH	HL  
	LD	A,#5  
	ADD	A,B  
	LD	B,A  
	PUSH	BC  
	MOV	(ONOFF),(BG)  
	PUT	#39  
	PUT	#40  
	POP	BC  
	PUT	#41  
	PUT	#42  
	LD	BC,#0  
BCXYP	.equ	.-2 
	PUSH	BC  
	MOV	(ONOFF),(EX)  
	PUT	#39  
	PUT	#40  
	POP	BC  
	MOV	(ONOFF),(EM)  
	PUT	#41  
	PUT	#42  
	INC	B  
	INC	B  
; PAGE 41 FOLLOWS

	LD	(BCXYP),BC  
	LD	A,#4  
	CALL	SINC ; ADD 40 POINTS
	MOV	(ALTSP1),#70  
	LD	A,#4  
	CALL	BONSC  
	CALL	SNCK ; CLICK SOUND
	POP	HL  
	POP	DE  
	JP	CCCLP  
EOS1:	LD	B,#4 
EOS3:	CALL	DELAY1
	DJNZ	EOS3  
	LD	A,(CITYB)  
	AND	A  
	JR	Z,EOS12  
	LD	HL,#CITTAB  
	LD	B,#6  
	MOV	(BFLAG),#0  
EOS13:	LD	A,(HL) 
	AND	A  
	JR	NZ,EOS14  
	LD	(HL),#1  
	LD	A,(CITYS)  
	INC	A  
	LD	(CITYS),A  
	LD	A,(CITYB)  
	DEC	A  
	LD	(CITYB),A  
	MOV	(BFLAG),#1  
	JR	Z,EOS15  
EOS14:	INC	HL 
	DJNZ	EOS13  
	GET	BFLAG  
	AND	A  
	JR	Z,EOS12  
EOS15:	LD	HL,#BCITYM 
	LD	BC,#34*256+90  
	MOV	(ONOFF),(FM)  
	CALL	MESOUT  
	CALL	NOYZ  
EOS12:	LD	DE,#PLAY1 
	LD	A,(PLAYER)  
	CP	#1  
	JR	Z,EOS4  
	LD	DE,#PLAY2  
EOS4:	LD	HL,#PCB 
	LD	BC,#18  
	LDIR	  
	LD	A,(CITYS)  
	AND	A  
	JP	NZ,EOS10  
	LD	BC,#42*256+20  
	MOV	(ONOFF),(FM)  
	LD	HL,#GOM  
	CALL	MESOUT  
	LD	BC,#46*256+26  
	LD	HL,#GOM2  
	MOV	(GOM1),(PLAYER)  
	CALL	MESOUT  
	CALL	DELAY1  
EOS10:	JP	GLOOP
	.area	_DATA	
GOM:	.db	17, 11, 23, 15, 10, 25, 32, 15, 28, 255; GAME OVER 
GOM2:	.db	26, 22, 11, 35, 15, 28, 10, 0, 255; PLAYER 0 
GOM1	.equ	.-2 
BCITYM:	.db	12, 25, 24, 31, 29, 10, 13, 19, 30, 35, 255
	.area	_CODE
; PAGE 42 FOLLOWS

SNCK:	PUSH	BC 
	LD	HL,#0x100  
	LD	B,#7  
SNCK1:	LD	A,(HL) 
	OUT	(#0x19),A  
	INC	L  
	JR	NZ,SNCK1  
	DJNZ	SNCK1  
	LD	HL,#0x400  
	CALL	DELAY  
	POP	BC  
	RET	  
BONSC:	PUSH	AF 
	MOV	(ALTSP),#1  
	LD	(BBCHK),A  
	LD	DE,#TSC  
	LD	HL,#SCORE  
	LD	BC,#7  
	LDIR	  
	LD	DE,#SCORE  
	LD	HL,#BCORE  
	LD	BC,#7  
	LDIR	  
	POP	AF  
	CALL	SINC  
	MOV	(ALTSP),#0  
	LD	(BBCHK),A  
	LD	DE,#BCORE  
	LD	HL,#SCORE  
	LD	BC,#7  
	LDIR	  
	LD	DE,#SCORE  
	LD	HL,#TSC  
	LD	BC,#7  
	LDIR	  
	RET	  
NOYZ:	LD	B,#10 
NOYZ1:	CALL	RAND
	AND	#15  
	INC	A  
	LD	E,A  
	LD	A,#5  
NOYZ2:	ADD	A,#7 
	DEC	E  
	JR	NZ,NOYZ2  
	LD	E,A  
	LD	HL,#0x2000  
NOYZ3:	LD	C,E 
NOYZ4:	DEC	HL 
	LD	A,H  
	OR	L  
	JR	Z,NOYZ5  
	DEC	C  
	JR	NZ,NOYZ4  
	LD	A,(SOUND)  
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
	OUT	(#0x1B),A  
	JR	NOYZ3  
NOYZ5:	DJNZ	NOYZ1
	RET	  
TSCL:	LD	HL,#BCORE 
	LD	B,#7  
TSCL1:	LD	(HL),#0 
	INC	HL  
; PAGE 43 FOLLOWS

	DJNZ	TSCL1  
	RET	  
WHSI:	DI	 
	PUSH	AF  
	GET	WLEN  
	DEC	A  
	LD	(WLEN),A  
	JR	NZ,WHSI1  
	MOV	(WLEN),#255  
	GET	WLEV  
	DEC	A  
	LD	(WLEV),A  
	JR	NZ,WHSI1  
	POP	AF  
	EI	  
	RET	  
WHSI1:	LD	A,(0x100) 
WPOS	.equ	.-2 
	OUT	(#0x1B),A  
	LD	A,(WPOS)  
	INC	A  
	LD	(WPOS),A  
	LD	A,(WLEV)  
	OUT	(#TIMERA_3),A  
	POP	AF  
	EI	  
	RET	  
OMI:	DI	 
	PUSH	AF  
	LD	A,(OMV)  
	AND	A  
	JR	Z,EXPLI  
	GET	OML  
	DEC	A  
	LD	(OML),A  
	JR	NZ,OMI1  
	MOV	(OML),#30  
	GET	OMV  
	DEC	A  
	LD	(OMV),A  
	CP	#1  
	JR	NZ,OMI1  
NINTO:	LD	A,#255 
	OUT	(#TIMERA_4),A  
	POP	AF  
	EI	  
	RET	  
OMI1:	LD	A,#0x7F 
OMS	.equ	.-1 
	CPL	  
	OUT	(#0x1B),A  
	LD	(OMS),A  
	LD	A,(OMV)  
	OUT	(#TIMERA_4),A  
	POP	AF  
	EI	  
	RET	  
EXPLI:	CMP	#EXPLLM,(EXPLV) 
	JR	Z,NINTO  
	GET	EXPLL  
	INC	A  
	CP	#12  
	JR	NZ,EXPLI1  
	LD	A,#EXPLLM  
EXPLV	.equ	.-1 
EXPLLL	.equ	30 
; PAGE 44 FOLLOWS

EXPLLM	.equ	64 
	INC	A  
	LD	(EXPLV),A  
	CP	#EXPLLM  
	JR	Z,NINTO  
	XOR	A  
EXPLI1:	LD	(EXPLL),A 
	LD	A,(0x100)  
EXPLP	.equ	.-2 
	OUT	(#0x1B),A  
	LD	A,(EXPLP)  
	INC	A  
	LD	(EXPLP),A  
	LD	A,(EXPLV)  
	OUT	(#TIMERA_4),A  
	POP	AF  
	EI	  
	RET	  
MLOW:	MOV	(MLN),#5 
	MOV	(WSL),#1  
	MOV	(ML1),#255  
	LD	A,#8  
	OUT	(#TIMERA_5),A  
	RET	  
MLOWI:	DI	 
	PUSH	AF  
	LD	A,(MLN)  
	AND	A  
	JP	Z,SHWH  
	LD	A,#0x30  
ML1	.equ	.-1 
	DEC	A  
	LD	(ML1),A  
	JR	NZ,ML2  
	GET	MLN  
	DEC	A  
	LD	(MLN),A  
	JR	NZ,ML3  
	JP	NINT  
ML3:	GET	WSL 
	XOR	#1  
	LD	(WSL),A  
	MOV	(ML1),#255  
ML2:	LD	A,(WSL) 
	AND	A  
	JR	Z,ML4  
	LD	A,#0x7F  
MLS	.equ	.-1 
	CPL	  
	LD	(MLS),A  
	OUT	(#0x19),A  
ML4:	LD	A,#8 
	OUT	(#TIMERA_5),A  
	POP	AF  
	EI	  
	RET	  
SHWH:	LD	A,(SMISCT) 
	AND	A  
	JR	Z,SHWHP  
	LD	A,#3  
SMARL	.equ	.-1 
	DEC	A  
	JR	NZ,MARL1  
	LD	A,#12  
MARL1:	LD	(SMARL),A 
	JR	NZ,MARL2  
; PAGE 45 FOLLOWS

	LD	A,#4  
SMAR1	.equ	.-1 
	DEC	A  
	CP	#3  
	JR	NZ,SMAR2  
	LD	A,#11  
SMAR2:	LD	(SMAR1),A 
MARL2:	LD	A,(SOUND) 
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
	LD	A,(SMAR1)  
	OUT	(#TIMERA_5),A  
	POP	AF  
	EI	  
	RET	  
SHWHP:	LD	A,(SPACE+3) 
	CP	#-1  
	JP	Z,NINT  
	LD	A,(SOUND)  
	CPL	  
	LD	(SOUND),A  
	OUT	(#0x19),A  
	LD	A,#5  
SHWHL	.equ	.-1 
SHWHFT	.equ	150 
SHWHFS	.equ	140 
	DEC	A  
	LD	(SHWHL),A  
	JR	NZ,SHWH1  
	MOV	(SHWHL),A  
	LD	A,#SHWHFT  
SHWHF	.equ	.-1 
	DEC	A  
	CP	#SHWHFS  
	JR	NZ,SHWH2  
	LD	A,#SHWHFT  
SHWH2:	LD	(SHWHF),A 
SHWH1:	LD	A,(SHWHF) 
	OUT	(#TIMERA_5),A  
	POP	AF  
	EI	  
	RET	  
NINT:	LD	A,#-1 
	OUT	(#TIMERA_5),A  
	POP	AF  
	EI	  
	RET	  
KEYI:	DI	 
	PUSH	AF  
	LD	A,#0x01  
	CP	#0x1B  
	JR	NZ,KEYIX  
	LD	SP,#0x0FF  
	MOV	(0),#0x0C3  
	LD	HL,#0  
KEYIP	.equ	.-2 
	LD	(1),HL  
	DI	  
	JP	0  
KEYIX:	POP	AF
	EI	  
	RET	  
KEYO:	DI	 
	PUSH	AF  
	POP	AF  
; PAGE 46 FOLLOWS

	EI	  
	RET	  
TCITY:	CALL	RAND
	AND	#3  
	JP	Z,TCITY1  
	LD	A,(KILCIT)  
	OR	A  
	JR	Z,TCITYZ  
	LD	HL,#TARCIT  
	LD	B,#3  
	LD	D,#0  
	LD	A,#-1  
TCITYA:	CP	(HL) 
	JR	Z,TCITYB  
	INC	D  
TCITYB:	INC	HL 
	INC	HL  
	DJNZ	TCITYA  
	LD	A,(KILCIT)  
	CP	D  
	JR	NC,TCITY9  
TCITYZ:	LD	A,(CITYS) 
	CP	#6  
	JP	Z,TCITY1  
TCITYC:	LD	D,#0 
	JR	TCITY2  
TCITY9:	LD	A,(CITYS) 
	OR	A  
	JR	Z,TCITYC  
	LD	D,#1  
TCITY2:	CALL	RAND
	AND	#7  
	CP	#6  
	JR	NC,TCITY2  
	PUSH	DE  
	LD	E,A  
	ADD	A,A  
	LD	C,A  
	LD	D,#0  
	LD	HL,#CITTAB  
	ADD	HL,DE  
	POP	DE  
	LD	A,(HL)  
	CP	D  
	JR	NZ,TCITY2  
	LD	A,D  
	OR	A  
	JR	Z,TCITY4  
	CALL	SCH  
	JR	Z,TCITY3  
	PUSH	BC  
	LD	C,#-1  
	CALL	SCH  
	POP	BC  
	JR	NZ,TCITY2  
	LD	(HL),C  
	INC	HL  
	LD	(HL),#1  
	JR	TCITY4  
TCITY3:	INC	HL 
	INC	(HL)  
TCITY4:	LD	HL,#CITPOS 
	LD	E,C  
	LD	D,#0  
	ADD	HL,DE  
	LD	D,(HL)  
; PAGE 47 FOLLOWS

	INC	HL  
	LD	E,(HL)  
	LD	A,C  
	CP	#12  
	JR	NC,TCITY5  
	LD	A,D  
	ADD	A,#6  
	LD	D,A  
	LD	A,C  
	RET	  
TCITY5:	LD	A,E 
	ADD	A,#7  
	LD	E,A  
	LD	A,C  
	RET	  
TCITY1:	CALL	RAND
	AND	#3  
	JR	Z,TCITY1  
	DEC	A  
	ADD	A,A  
	ADD	A,#12  
	LD	C,A  
	JR	TCITY4  
SCH:	LD	HL,#TARCIT 
	LD	B,#3  
	LD	A,C  
SCH1:	CP	(HL) 
	RET	Z  
	INC	HL  
	INC	HL  
	DJNZ	SCH1  
	RET	  
TARCIT:	.ds	6
KILCIT:	.ds	1
KCITR:	LD	C,+12(IX) 
	CALL	SCH  
	RET	NZ  
	INC	HL  
	DEC	(HL)  
	RET	NZ  
	DEC	HL  
	LD	(HL),#-1  
	RET	  
; Satellite draw instructions 81h jumps to next color 80h is end of data
	.area	_DATA
SDATR:	.db	0, 0, -1, -1, 3, 0, -1, 1, 0x81
	.db	1, 0, 1, -1, -3, 0, -1, -2, 0, 5, -1, -1, 0, -1, 0, -1, 0, -1, -1, -2, 0, 7
	.db	7, 0, 0, -7, 0x81
	.db	2, -1, -1, 1, -2, 1, 1, 1, 0, 1, 0, 1, 0, 1, -1, 1, 2, 1, 1, 1, -9, 0
	.db	1, -1, 0, -7, -1, -1, 0x81
	.db	-1, 0, 0, 9, 9, 0, 0, -9, 0x80
; Bomber draw instructions, skips FM, then draws EM and then BG

BDATR:	.db	0x81, 5, -2, -2, -2, -2, 1, -2, 1, -1, 1, -2, 1, 3, 1, 1, 1, 2, 1, 0x81
	.db	2, 0, -1, -1, -1, -1, 3, -1, 1, -1, 0, -1, -4, 0, 1, -1, 1, -1, 0x80
	.area	_CODE
SPACER:	LD	A,(SPACE+3) 
	INC	A  
	JP	Z,SLRBMF  
	MOV	B,(SPACE)  
	LD	A,(SPACE+2)  
	ADD	A,B  
	CP	#135  
	JR	Z,SPEND  
	CP	#248  
	JR	NZ,OKSPQ  
SPEND:	MOV	(SPACE+3),#-1 
	RET	  
OKSPQ:	LD	(SPACE),A 
	LD	B,A  
	MOV	C,(SPACE+1)  
; PAGE 48 FOLLOWS

	LD	A,(SPACE+3)  
	LD	HL,#BDATR  
	OR	A  
	JR	Z,OKSPQ1  
	LD	HL,#SDATR  
OKSPQ1:	MOV	(KFLAG),#0 
	LD	(COLL1),A  
	MOV	(COLL),(FM)  
	MOV	E,(EX1)  
	LD	IX,#FM  
KDRW:	LD	A,(HL) 
	INC	HL  
	CP	#0x80  
	JR	Z,OKSPQ2  
	CP	#0x81  
	JR	Z,NXTCOL ; NEXT COLOR
	LD	D,A  
	LD	A,(SPACE+2)  
	DEC	A  
	LD	A,D  
	JR	NZ,NONEG  
	NEG	  
NONEG:	ADD	A,B 
	LD	B,A  
	LD	A,C  
	ADD	A,(HL)  
	LD	C,A  
	INC	HL  
	LD	A,B  
	CP	#0x80  
	JR	NC,KDRW  
	MOV	(ONOFF),#CTEST  
	DOT	  
	CP	E  
	JR	NZ,OKDRW  
	GET	KFLAG  
	INC	A  
	LD	(KFLAG),A  
OKDRW:	GET	COLL 
	LD	(ONOFF),A  
	EXX	  
	RES	3,H  
	CALL	XYACMP  
	JR	KDRW  
NXTCOL:	LD	A,(COLL1) 
	INC	A  
	INC	A ; CYCLE THROUGH FM,EM,BG
	LD	(COLL1),A  
	LD	A,+0(IX)  
COLL1	.equ	.-1 
	LD	(COLL),A  
	JR	KDRW  
OKSPQ2:	LD	A,(SPACE+3) 
	ADD	A,A  
	ADD	A,A  
	ADD	A,#4  
	LD	B,A  
	LD	A,(KFLAG)  
	CP	B  
	RET	C  
	CALL	EXPFND  
	JR	NZ,KILQA  
	MOV	(IY),(SPACE)  
	MOV	+1(IY),(SPACE+1)  
	MOV	+2(IY),#0  
KILQA:	MOV	(SPACE+3),#-1 
; PAGE 49 FOLLOWS

	MOV	(EXPLV),#EXPLLL  
	LD	A,#1  
	JP	SINC  
SLRBMF:	LD	A,(NSHP) 
	OR	A  
	RET	Z  
	LD	A,(NMIS)  
	OR	A  
	RET	Z  
	CP	#8  
	JR	C,SLRBM1  
	LD	A,(WAVEC)  
	OR	A  
	RET	NZ  
	CALL	RAND  
	AND	#63  
	RET	NZ  
SLRBM1:	CALL	RAND; POSITION BOMBER
	AND	#1  
	LD	(SPACE+3),A  
	CALL	RAND  
	AND	#63  
	ADD	A,#15  
	LD	(SPACE+1),A  
	CALL	RAND  
	AND	#1  
	JR	Z,FGBH  
	MOV	(SPACE),#135  
	LD	A,#-1  
	JR	FGBH1  
FGBH:	MOV	(SPACE),#248 
	LD	A,#1  
FGBH1:	LD	(SPACE+2),A 
	LD	A,(NSHP)  
	DEC	A  
	LD	(NSHP),A  
	RET	  
SINC:	PUSH	AF ; INCREASE SCORE
	MOV	(ONOFF),(BG)  
	CALL	SCORW  
	POP	AF  
	LD	C,A  
	ADD	A,A  
	ADD	A,A  
	ADD	A,A  
	SUB	C  
	LD	E,A  
	LD	D,#0  
	LD	HL,#POINTS  
	ADD	HL,DE  
	EX	DE,HL  
	LD	HL,#SCORE+6  
	OR	A  
	LD	B,#7  
SINC2:	LD	A,(DE) 
	ADC	A,(HL)  
	CP	#10  
	CCF	  
	JR	NC,SINC1  
	SUB	#10  
	SCF	  
SINC1:	LD	(HL),A 
	DEC	HL  
	INC	DE  
	DJNZ	SINC2  
	GET	BBCHK  
; PAGE 50 FOLLOWS

	OR	A  
	JR	NZ,SINC9  
	LD	A,(SCORE+2)  
	SHIFT	R,4  
	LD	B,A  
	LD	A,(SCORE+3)  
	OR	B  
	LD	B,A  
	LD	A,(BCHECK)  
	CP	B  
	JR	NZ,SINC9  
	LD	B,A  
	LD	A,(CITYB)  
	INC	A  
	LD	(CITYB),A  
	LD	A,(BONIS)  
	ADD	A,B  
	DAA	  
	LD	(BCHECK),A  
SINC9:	MOV	(ONOFF),(FM) 
SCORW:	LD	A,(PLAYER) 
	DEC	A  
	LD	BC,#6+6*256  
	JR	Z,SCORW1  
	LD	BC,#6+87*256  
SCORW1:	GET	ALTSP 
	AND	A  
	JR	Z,SCRW1A  
	LD	B,#5  
	LD	C,#0  
ALTSP1	.equ	.-1 
SCRW1A:	LD	HL,#SCORE-1 
	JP	SCOR4  
	.area	_DATA
SSSSSS:	.db	1, 0, 0, -1, -1, 0, -1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0
	.db	0, -1, -1, 0, 128, 128
	.area	_CODE
SMOVE:	LD	IX,#SMISTB 
	MOV	(SMARTS),#3  
	LD	(SMARTU),A  
	MOV	(LINCOL),(BG)  
	MOV	(TIPCOL),(EX)  
	MOV	(COUNTS),#0  
SMOVE2:	LD	A,+12(IX) 
	INC	A  
	JP	Z,SMOVE3  
	LD	A,#105  
	CP	+1(IX)  
	JR	C,SMOVE4  
	LD	B,(IX)  
	LD	C,+1(IX)  
	LD	HL,#SSSSSS  
	CALL	QCHECK  
	LD	A,(HFLAG)  
	CP	#4  
	JR	C,SMOVE4  
	CALL	EXPSET  
	LD	A,#2  
	CALL	SINC  
	JP	SMOVE3  
SMOVE4:	MOV	(ONOFF),(BG) 
	CALL	SMART  
	LD	D,#1  
	CALL	MOVENM  
	MOV	(ONOFF),#CTEST  
	LD	HL,#0  
	LD	B,(IX)  
	LD	C,+1(IX)  
; PAGE 51 FOLLOWS

	LD	A,C  
	CP	#105  
	JP	NC,DODGE3  
	MOV	D,(EX1)  
	DEC	B  
	DEC	B  
	DEC	B  
	DEC	B  
	INC	C  
	INC	C  
	INC	C  
	INC	C  
	DOT	  
	CP	D  
	JR	NZ,DODGE1  
	LD	HL,#0x101  
DODGE1:	LD	A,B 
	ADD	A,#8  
	LD	B,A  
	DOT	  
	CP	D  
	JR	NZ,DODGE4  
	LD	HL,#0x0FF01  
DODGE4:	LD	A,B 
	ADD	A,#-4  
	LD	B,A  
	DOT	  
	CP	D  
	JR	NZ,DODGE5  
	LD	L,#-1  
DODGE5:	LD	A,H 
	OR	L  
	LD	B,(IX)  
	LD	C,+1(IX)  
	JR	Z,DODGE3  
	MOV	(ONOFF),(BG)  
	DOT	  
	LD	A,H  
	ADD	A,B  
	LD	B,A  
	LD	A,L  
	ADD	A,C  
	LD	C,A  
	LD	D,+9(IX)  
	LD	E,+10(IX)  
	LD	H,+12(IX)  
	LD	A,+11(IX)  
	CALL	TARGET  
	MOV	(ONOFF),(EX)  
	DOT	  
DODGE3:	MOV	(ONOFF),(EM) 
	CALL	SMART  
	GET	COUNTS  
	INC	A  
	LD	(COUNTS),A  
SMOVE3:	GET	SMARTS 
	DEC	A  
	LD	(SMARTS),A  
	JR	Z,SMOVE5  
	LD	DE,#13  
	ADD	IX,DE  
	JP	SMOVE2  
SMOVE5:	MOV	(SMISCT),(COUNTS) 
	RET	  
 ; DELAY 4 MICROSECONDS PER HL COUNT

DELAY1:	LD	HL,#0 
DELAY:	DEC	HL 
; PAGE 52 FOLLOWS

	LD	A,H  
	OR	L  
	JR	NZ,DELAY  
	RET	  
SMART:	LD	B,(IX) 
	LD	C,+1(IX)  
	LD	HL,#SMARTP  
KDRAW:	LD	A,(HL) 
	CP	#128  
	INC	HL  
	RET	Z  
	ADD	A,B  
	LD	B,A  
	LD	A,(HL)  
	ADD	A,C  
	LD	C,A  
	INC	HL  
	LD	A,(ONOFF)  
	EX	AF,AF'  
	MOV	(ONOFF),#CTEST  
	DOT	  
	LD	E,A  
	LD	A,(EX1)  
	CP	E  
	EX	AF,AF'  
	LD	(ONOFF),A  
	EX	AF,AF'  
	JR	Z,KDRAW  
	EXX	  
	RES	3,H  
	CALL	XYACMP  
	JR	KDRAW  
DISKST:	LD	DE,#HIGHS1 
	LD	C,#26  
	CALL	5  
	LD	HL,#MISFNM  
	CDOS	#134  
	RET	  
DISKW:	CALL	DISKST
	CDOS	#22  
	CDOS	#15  
	LD	DE,#HIGHS1  
	LD	HL,#HIGHS  
	LD	BC,#128  
	LDIR	  
	CDOS	#21  
	JP	EXDISK  
MISFNM:	.ascis	'MISSILEH.IGH'
	.db	0x1F
DISKR:	CALL	DISKST
	CDOS	#15  
	CP	#-1  
	JR	NZ,DISKR1  
	CALL	HIGHST  
	JP	DISKW  
DISKR1:	CDOS	#20 
	LD	DE,#HIGHS  
	LD	HL,#HIGHS1  
	LD	BC,#128  
	LDIR	  
EXDISK:	CDOS	#16 
	RET	 
	
	.area	_DATA	
FBASE:	.db	0, 0, 0, 0

; THERE ARE TO BE THE ONLY COMMENTS IN THIS PROGRAM
; 
;	EACH FRIENDLY, ENEMY AND SMART MISSILE'S ARE STORED IN THE
; PAGE 53 FOLLOWS
;	FOLLOWING FORMAT:
;	
;	 +0 --> CURRENT X-POSITION
;	 +1 -->    "    Y-   "
;	 +2 --> ALL THESE ARE
;	 +3 --> USED BY THE
;	 +4 --> LINE DRAWER
;	 +5 --> X-INC
;	 +6 --> Y-INC
;	 +7 --> X-START POSITION
;	 +8 --> Y-START POSITION
;	 +9 --> X-END POSITION
;	+10 --> Y  "     "
;	+11 --> SPEED OF MISSILE
;	+12 --> TARGET TYPE, -1 IS NO MISSILE
;				TARGET'S ARE CODED AS FOLLOWS
;				 ALL ARE MULTIPLES OF TWO ...
;				  0-10 --> A CITY
;				  12-16 --> A MISSILE BASE
;				  ANY OTHER IS MID-AIR DETONATION


MISSCT:	.ds	1
SMISCT:	.ds	1
EMISCT:	.ds	1
EXPLCT:	.ds	1
NMIS:	.ds	1
NSHP:	.ds	1
NSMS:	.ds	1
MSPD:	.ds	1
MISSTB:	.ds	13*8
EMISTB:	.ds	13*8
SMISTB:	.ds	13*3
EXPLTB:	.ds	NUMEXP*3
SITEOY:	.ds	1
SITEOX:	.ds	1
STRCOL:	.ds	1
COUNT:	.ds	1
FM1:	.ds	1
FM:	.ds	1
EM1:	.ds	1
EM:	.ds	1
BG1:	.ds	1
BG:	.ds	1
EX1:	.ds	1
EX:	.ds	1
SITEY:	.ds	1
SITEX:	.ds	1
T81:	.ds	1
SPACE:	.ds	4; BOMBER/SATELLITE CONTROL BLOCK X Y 
; PAGE 54 FOLLOWS

TSC:	.ds	7
BCORE:	.ds	7
POINTS:	.ds	35
PCB	.equ	. 
CITYS:	.ds	1
CITYB:	.ds	1
CITTAB:	.ds	6
SCORE:	.ds	7
BONIS:	.ds	1
BCHECK:	.ds	1
SET:	.ds	1
BASES:	.ds	3
TIMES:	.ds	1
COLOR:	.ds	1
MISFCB:	.ds	33
HIGHS:	.ds	128
HIGHS1:	.ds	128
PLAY1:	.ds	18
PLAY2:	.ds	18
PLAYER:	.ds	1
CCT:	.ds	1
CST:	.ds	1
LCTN:	.ds	1
LSTN:	.ds	1
TRCT:	.ds	9
MAXLOW	.equ	. 
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)