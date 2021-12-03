	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	.module profile
	.optsdcc -mz80
	
	.area _CODE		 
; Library
; BINHEX        Convert A to ASCII hex
; CONOUT        HL, B
; ELTODEC        Convert elapsed time to decimal and store in ELBUF
;   Should clear buffer to spaces or zeros as desired. B is length of buffer
; ELTO10        Leading zeros. Convert DEHL to decimal and store in (IX) to (IX+8), right justified.
; ELTO10S       No leading zeros. Convert DEHL to decimal and store in (IX) to (IX+8), right justified.
; GETST         Get start time in nanoseconds (in STRTIME)
; GETEND        Get end time in nanoseconds (in ENDTIME)
; HEXSTR        Convert binary data to ASCII hex string B = size, IX = pointer to data HL pointer to output location
; PDEFEL        Print default elapsed time message
; DUMPTIM       Dump out the Start, elapsed and delta time values in hex

	.include "dazzler.mac"
	.include "dazzler.abs"
	
DEFALT:	.ascii	'Default'
DEFLEN	.equ	.-DEFALT 
ELMSG:	.ascii	' elapsed time: '
ELSBUF:	.ds	1
	.db	'.'  
ELBUF:	.ds	9
	.ascii	'uS'
	.db	13,10  
ELMLEN	.equ	.-ELMSG 
		 
CONOUT::
	MOV	C,#TUARTA+TDATA 
	OTIR	  
	RET	  
PDEFEL::
	CALL	GETDEL
	LD	HL,#ELBUF  
	CALL	ELTODEC  
	LD	A,(DELTIME+4)  
	ADD	A,#'0'  
	LD	(ELSBUF),A  
	LD	HL,#DEFALT  
	LD	B,#DEFLEN+ELMLEN  
	CALL	CONOUT  
	CALL	DUMPTIM  
	RET	  
RESTIM::
	LD	A,#0
	OUT	(#TMPORT),A
	RET	  
GETEND::
	LD	HL,#ENDTIME 
	JR	GETTIME  
GETST::	LD	HL,#STRTIME 
GETTIME::
	LD	C,#TMPORT 
	LD	B,#TIMSIZ  
	INIR	  
	RET	  
BILLION:
	.db	00, 0x0CA, 0x9A, 0x3B
GETDEL::
	LD	HL,#ENDTIME 
	LD	IX,#STRTIME  
	LD	DE,#DELTIME  
	LD	B,#4  
	XOR	A  
GDEL1:	LD	A,(HL) 
	SBC	A,(IX)  
	LD	(DE),A  
	INC	DE  
	INC	IX  
	INC	HL  
	DJNZ	GDEL1  
	JR	NC,GDEL5  
	XOR	A  
	LD	HL,#BILLION  
	LD	DE,#DELTIME  
	LD	B,#4  
GDEL2:	LD	A,(DE) 
	ADC	A,(HL)  
	LD	(DE),A  
	INC	DE  
	INC	HL  
	DJNZ	GDEL2  
	SCF	  
GDEL5:	LD	HL,#ENDTIME+4 
	LD	IX,#STRTIME+4  
	LD	DE,#DELTIME+4  
	LD	B,#8  
GDEL3:	LD	A,(HL) 
	SBC	A,(IX)  
	LD	(DE),A  
	INC	DE  
	INC	IX  
	INC	HL  
	DJNZ	GDEL3  
	RET	  
		  
WRTDEL:	LD	B,#8 
	LD	IX,#DELTIME  
	CALL	HEXSTR  
	MOV	(HL),#'.'  
	INC	HL  
	LD	B,#4  
	CALL	HEXSTR
	LD	A,#' '
	OUT	(#TUARTA+TDATA),A
	CALL	ELTODEC  
	LD	HL,#ELBUF  
	LD	B,#9  
	CALL	CONOUT  
	RET	  
CRLF:	.db	13, 10
OUTBUF:	.ds	24
		 
; Dump the time values in hex

DUMPTIM::
	LD	IX,#STRTIME 
	LD	B,#12  
	LD	HL,#OUTBUF  
	CALL	HEXSTR  
	LD	HL,#OUTBUF  
	LD	B,#8  
	CALL	CONOUT  
	LD	A,#'-'
	OUT	(#TUARTA+TDATA),A  
	LD	B,#16  
	CALL	CONOUT  
	LD	HL,#CRLF  
	LD	B,#2  
	CALL	CONOUT  
	LD	IX,#ENDTIME  
	LD	B,#12  
	LD	HL,#OUTBUF  
	CALL	HEXSTR  
	LD	HL,#OUTBUF  
	LD	B,#8  
	CALL	CONOUT  
	LD	A,#'-'
	OUT	(#TUARTA+TDATA),A  
	LD	B,#16  
	CALL	CONOUT  
	LD	HL,#CRLF  
	LD	B,#2  
	CALL	CONOUT  
	LD	IX,#DELTIME  
	LD	B,#12  
	LD	HL,#OUTBUF  
	CALL	HEXSTR  
	LD	HL,#OUTBUF  
	LD	B,#8  
	CALL	CONOUT  
	LD	A,#'-'
	OUT	(#TUARTA+TDATA),A  
	LD	B,#16  
	CALL	CONOUT  
	LD	HL,#CRLF  
	LD	B,#2  
	CALL	CONOUT  
	RET	  
		  
; HEXSTR        Convert binary data to ASCII hex string B = size, IX = pointer to data HL pointer to text out        

HEXSTR:	CALL	HEXWRT
	INC	IX  
	DJNZ	HEXSTR  
	RET	  
HEXWRT:	LD	A,(IX) 
	LD	D,A  
	SHIFT	R,4  
	AND	#15  
	CALL	BINHEX  
	LD	(HL),A  
	INC	HL  
	LD	A,#15  
	AND	D  
	CALL	BINHEX  
	LD	(HL),A  
	INC	HL  
	RET	  
BINHEX::
	ADD	A,#'0' 
	CP	#'9'+1  
	RET	C  
	ADD	A,#7  
	RET	  
INTRO:	.ascii	'BitBlit test routine. save bitblit.com '
SSIZE:	.db	''
	.db	13, 10
INTLEN	.equ	.-INTRO 
ELTODEC:
	LD	HL,#ELBUF 
	LD	DE,#ELBUF+1 
	LD	A,#' '
	LD	(HL),A
	LD	BC,#8  
	LDIR	  
	LD	IX,#ELBUF+8  
	LD	HL,(DELTIME)  
	LD	DE,(DELTIME+2)  
	LD	B,#9  
ELTO10::
	PUSH	BC 
	CALL	Div10  
	ADD	A,#'0'  
	LD	(IX),A  
	DEC	IX  
	POP	BC  
	DJNZ	ELTO10  
	RET	  
ELTO10S::
	PUSH	BC 
	CALL	Div10  
	ADD	A,#'0'  
	LD	(IX),A  
	DEC	IX  
	POP	BC  
	LD	A,H  
	OR	L  
	OR	D  
	OR	E  
	RET	Z  
	DJNZ	ELTO10S  
	RET	  
		  
; Math lib
;Inputs:
;     DEHL
;Outputs:
;     DEHL is the quotient
;     A is the remainder
;     BC is 10

		 
Div10:	ld	bc,#0xD0A 
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
	
TIMSIZ  .equ     12
STRTIME: .ds      TIMSIZ
ENDTIME: .ds     TIMSIZ
DELTIME: .ds     TIMSIZ    	
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)