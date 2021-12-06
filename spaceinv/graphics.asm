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

	.globl BLACK, LINEH, XY, WHITE, BLUE, RED, ONOFF
; draw the player (base)       

	.area _CODE
LB::	ld	a,(ONOFF)
	cp	#WHITE
	jr	nz, $1
brkpt:	nop
$1:	PUSH	BC 
	LD	D,#7  
	CALL	LINEH  
	POP	BC  
	DEC	C  
	PUSH	BC  
	LD	D,#7  
	CALL	LINEH  
	POP	BC  
	DEC	C  
	PUSH	BC  
	LD	D,#7  
	CALL	LINEH  
	POP	BC  
	DEC	C  
	INC	B  
	INC	B  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	B  
	CALL	XY  
	DEC	B  
	DEC	C  
	CALL	XY  
	RET	  
 
; Draw a fort

FORT::	PUSH	BC 
; 0189

	COLOR	#BLUE  
	LD	E,#12  
FORT1:	LD	H,B 
	LD	D,#12  
	CALL	LINEH  
	LD	B,H  
	DEC	C  
	DEC	E  
	JP	NZ,FORT1  
	POP	BC  
	INC	B  
	INC	B  
	INC	B  
	INC	B  
	COLOR	#BLACK  
	LD	E,#4  
	LD	H,B  
FORT2:	LD	D,#4 
	CALL	LINEH  
	LD	B,H  
	DEC	C  
	DEC	E  
	JR	NZ,FORT2  
	INC	B  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	B  
	INC	B  
	INC	B  
	LD	A,#-7  
	ADD	A,C  
	LD	C,A  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	C  
	CALL	XY  
	DEC	B  
	CALL	XY  
	INC	C  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	C  
	CALL	XY ; LOST CODE RECOVERED shape of fort recovered visually
	INC	C ; LOST CODE RECOVERED shape of fort
	CALL	XY  
	LD	A,#-11  
	ADD	A,B  
	LD	B,A  
	CALL	XY  
	DEC	C  
	CALL	XY  
	DEC	C  
	CALL	XY  
	INC	B  
	CALL	XY  
	DEC	C  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	C  
	CALL	XY  
	INC	B  
	CALL	XY  
	INC	B  
	CALL	XY  
	RET	  
	
; Draw saucer        
SDRAWR::	INC	B 
	CALL	XY  
	INC	B  
	INC	B  
	INC	B  
	INC	B  
	CALL	XY  
	INC	B  
	INC	B  
	INC	B  
	INC	B  
	CALL	XY  
	INC	B  
	DEC	C  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
; 1121        

	DEC	C  
	INC	B  
	LD	D,#9  
	CALL	LINEH  
	LD	A,#-8  
	ADD	A,B  
	LD	B,A  
	LD	D,#7  
	DEC	C  
	CALL	LINEH  
	DEC	B  
	DEC	B  
	CALL	XY  
	DEC	B  
	DEC	B  
	DEC	B  
	DEC	B  
	CALL	XY  
	RET	  

XPLDR1::
	DEC	B 
	CALL	XY  
	INC	B  
; 2280        

	INC	B  
	INC	B  
	CALL	XY  
	DEC	C  
	DEC	B  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	C  
	CALL	XY  
	INC	B  
	CALL	XY  
	DEC	C  
	CALL	XY  
	DEC	B  
	CALL	XY  
	DEC	B  
	DEC	C  
	CALL	XY  
	INC	B  
	INC	B  
	INC	B  
	CALL	XY  
	RET	  

	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
