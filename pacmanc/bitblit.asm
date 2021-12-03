	.module bitblit
	
	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.area _CODE
	.globl	PNUM, ONOFF, DAZINIT, WHITE, RED, BLUE, BLACK, MKZERO3, NUMZER3
	.globl	CLS
	.globl  GETST, GETEND, PDEFEL, RESTIM
	.globl	SC1
	.include "dazzler.mac"
	.include "dazzler.abs"
	
	.area _DATA
_LONGTIMER::
	.ds	4
	.area _CODE
_SETINTS::
	LD	A,#0x0C3  
	LD	(8),A  
;	LD	(8),A  
;	LD	(0x18),A  
;	LD	(0x30),A  
;	LD	(0x38),A  
	LD	HL,#INTER1  
	LD	(9),HL  		; Timer 2
	ld	a,#0x02			; Timer 2 only
	OUT	(#TUARTA_MASK),A  	; Interrupt mask
	LD	A,#8  
	OUT	(#TUARTA_CMD),A  	; Command (interrupt enable)
	EI	  
	LD	A,#255			; 16.32 mS
	OUT	(TIMERA_2),A  		; Timer 2
	LD	HL,#0
	LD	(_SETTIMER),HL
	RET
	
_CLEARINTS::
	DI
	LD	A,#0			; No ints
	OUT	(#TUARTA_MASK),A  	; Interrupt mask
	LD	A,#0
	OUT	(TIMERA_2),A  		; Timer 2
	LD	A,#0xC9
	LD	(8),A
	RET

INTER1:	DI
	PUSH	AF
	LD	A,#2
INTER_HALF	.equ .-1
	DEC	A
	JR	Z,INTER_60
	LD	(INTER_HALF),A
	LD	A,#130		; 1/120 second
	OUT	(TIMERA_2),A
	POP	AF
	EI
	RET

INTER_60:
	PUSH	HL
	LD	A,#2
	LD	(INTER_HALF),A
	LD	HL,#0
_SETTIMER	.gblequ .-2
	INC	HL
	LD	(_SETTIMER),HL
	LD	HL,(_LONGTIMER)
	INC	HL
	LD	(_LONGTIMER),HL
	LD	A,H
	OR	L
	JR	NZ,1$
	LD	HL,(_LONGTIMER+2)
	INC	HL
	LD	(_LONGTIMER+2),HL
1$:	LD	A,#130
	OUT	(TIMERA_2),A
	POP	HL
	POP	AF
	EI
	RET
	
_dumpDazzler::
	RET

_DAZMOD3::
	LD	A,#(0x80 + SC1/512) ; Initialize the Dazzler
	OUT	(#0xe),A
	LD	A,#0x79
	OUT	(#0xf),A
	LD	A,#0x7a
	OUT	(#0xf),A
	LD	A,#0x7c
	OUT	(#0xf),A
	LD	A,#0xd0
	OUT	(#0xf),A
	RET

_DAZMODB::
	LD	A,#(0x80 + SC1/512) ; Initialize the Dazzler
	OUT	(#0xe),A
	LD	A,#0x79
	OUT	(#0xf),A
	LD	A,#0x7a
	OUT	(#0xf),A
	LD	A,#0x7f	; Make the blue screen white.
	OUT	(#0xf),A
	LD	A,#0xd0
	OUT	(#0xf),A
	RET

_PROFILE3::	
_PTEST3::
	PUSH	IX
	LD	SP,#SC1
	CALL	DAZINIT
	CALL	RESTIM  
	MOV	(ONOFF),#WHITE  
	PROFILE	MKZERO3
		 
	CALL	CLS  
	PROFILE	PNUMTS
	POP	IX
	RET
		  
PNUMTS::
	LD	BC,#6+6*256 
	LOOPB	CGRP,#6  
	LOOPB	CNUM,#NUMZER3
	PUSH	BC  
	ADD	A,#' '
	CALL	PNUM
PNUMFC	.equ	.-2 
	POP	BC  
	LD	A,#8  
	ADD	A,B  
	LD	B,A  
	CP	#128-8  
	JR	C,NEXTC  
	LD	B,#0  
	LD	A,#8  
	ADD	C  
	LD	C,A  
	CP	#128-8  
	JR	NC,DONE  
NEXTC:	ENDLPB	CNUM 
	ENDLPB	CGRP

DONE:	RET	 
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
