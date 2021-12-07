	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	
	.module dazzler
	.optsdcc -mz80
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE

	.include /dazzler.mac/
	.include /dazzler.abs/

	
DAZTABS:	.db	1, 4, 2, 8, 0x10, 0x40, 0x20, 0x80
DAZTB1S:	.db	1, 1<<1, 1<<4, 1<<5, 1<<2, 1<<3, 1<<6, 1<<7	; Official Dazzler memory layout (x+y*4) 

_DAZINIT::
DAZINIT::
	PUSH	IX
	.if 0			; This program needs space, not XY speed.
	LD	HL,#DAZTABS
	LD	DE,#DAZTAB
	LD	BC,#8
	LDIR
	.endif

	; Usually used for sound efffects.   Not present in this game
	.if 0
	LD	HL,#PRE_RANTAB
RSET:	CALL	RAND
	LD	(HL),A  
	INC	L  
	JR	NZ,RSET  
	.endif

	CALL	MKZERO3
	CALL	CLS
	POP	IX
	RET
	
	.area _DATA
_RANTAB:: .ds	4
	.area _CODE
RAND::	PUSH	HL 
	PUSH	BC  
	LD	HL,#_RANTAB  
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

; RGB XY
; Input BC = x,y
; Uses HL', DE', AF
; Preserves HL, BC, DE
XY::	PUSH	BC 
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
	RRCA	  
	RRCA	  
	LD	L,A  
	LD	A,#0x3E  
	AND	C  
	RLCA	  
	RLCA	  
	ADD	A,A  
	RL	H  
	OR	L  
	LD	L,A  
	LD	A,#3  
	AND	B  
	RRC	C  
	RLA	  
	EX	DE,HL
	LD	C,A  
	LD	B,#0
	LD	HL,#DAZTABS
	ADD	HL,BC
	LD	A,(HL) 
	EX	DE,HL

	LD	C,#0  
ONOFF	.gblequ	.-1 
_ONOFF  .gblequ .-1
	BIT	7,C  
	JR	NZ,TESTXY  
	RRC	C  
	LD	B,A  
	JR	NC,XYD1  
	OR	(HL)  
	JP	XYD2  
XYD1:	CPL	 
	AND	(HL)  
XYD2:	LD	(HL),A 
	LD	A,#8  
	ADD	A,H  
	LD	H,A  
	LD	A,B  
	RRC	C  
	JR	NC,XYD3  
	OR	(HL)  
	JP	XYD4  
XYD3:	CPL	 
	AND	(HL)  
XYD4:	LD	(HL),A 
	LD	A,#8  
	ADD	A,H  
	LD	H,A  
	LD	A,B  
	RRC	C  
	JR	NC,XYD5  
	OR	(HL)  
	LD	(HL),A  
	EXX	  
	RET	  
XYD5:	CPL	 
	AND	(HL)  
	LD	(HL),A  
	EXX	  
	RET	  
TESTXY::
	LD	B,A 
	LD	A,#16  
	ADD	A,H  
	LD	H,A  
	XOR	A  
	LD	C,A  
	LD	A,(HL)  
	AND	B  
	ADD	A,#-1  
	RL	C  
	LD	A,#-8  
	ADD	A,H  
	LD	H,A  
	LD	A,(HL)  
	AND	B  
	ADD	A,#-1  
	RL	C  
	LD	A,#-8  
	ADD	A,H  
	LD	H,A  
	LD	A,(HL)  
	AND	B  
	ADD	A,#-1  
	RL	C  
	LD	A,C  
	EXX	  
	RET	
	
; This version of XY only plots in first quadrant in one color

XY16:	LD	HL,#SC1
	LD	A,#0x1E		; This limits us to y=[0,31] but the characters are only 7 pixels high.
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
	JR	Z,1$
	ADD	A,#4
1$:	PUSH	HL		; Could be faster using a 256 byte even offset table, but this is just init, and we are short on space.
	LD	HL,#DAZTB1S
	LD	E,A
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	OR	(HL)
	LD	(HL),A
	RET

_CLS::	
CLS::	LD	HL,#SC1
	LD	DE,#SC1+1
	LD	BC,#2048*3-1
	LD	(HL),#0
	LDIR
	RET
	
; Clear first character on screen plus bit blit dimensions

CLSZ:	LD	DE,#16
	LD	B,#5
	LD	IX,#SC1
CLSZ1:	LD	(IX),#0
	LD	+1(IX),#0
	LD	+2(IX),#0
	ADD	IX,DE
	DJNZ 	CLSZ1
	RET
	
; XX.
; XX.
; ...
; ...
; Scan 3x4 area to see if this is actually 2x2
MKZ_GETSIZE:
	ld	hl,#SC1+16*3
	ld	a,(hl)
	and	a
	jp	nz,SIZE3x4
	ld	bc,#3
	xor	a
	cpir
	jr	nz,SIZE3x4
	ld	hl,#SC1+16*2
	ld	c,#3
	cpir
	jr	nz,SIZE3x4
	ld	a,(SC1+2)
	and	a
	jr	nz,SIZE3x4
	ld	a,(SC1+16+2)
	and	a
	jr	nz,SIZE3x4
	ld	a,#2
	ret
SIZE3x4:
	ld	a,#4
	ret

MESOUT::
	PUSH	IX
1$:	LD	A,(HL) 
	INC	HL  
	CP	#-1  
	JR	Z, 2$  
	CP	#WHITE+1  
	JR	NC,3$  
	LD	(ONOFF),A  
	JR	1$  
3$:	AND	#0x7F 
	PUSH	HL
	CALL	PNUM  
	POP	HL
	JR	1$ 
2$:	POP	IX
	RET

_CROSS::
	COLOR	WHITE
	LD	BC,#63
	LD	D,#128
	CALL	LINEH
	LD	BC,#63*256
	LD	D,#128
	JP	LINEV

LINEH::	PUSH	IX
	LINEH
	POP	IX
	RET
	
LINEV::	PUSH	IX
	LINEV
	POP	IX
	RET
	
; Make ZEROB table (bit blit table)
; Hand compiled from the C version
; C version does gymnastics so it can print pretty comments

YBIT:	.ds	1

; RGB bit blit PNUM
; Preserves x,y in BC
; Does not use EXX	
; Will accept clipping of 4 x positions on left and right of screen.
PNUM::
PNUM3::	LD	HL,#CLIPPED
	LD	(HL),#0
	SUB	#ZERO_BASE		; Remove table base character ASCII value
	JP	Z,PNOCHAR
	BIT	7,B
	JR	Z,1$
	LD	(HL),#-4
	LD	L,A
	LD	A,#4
	ADD	A,B
	JP	M,PNOCHAR	; Errorneous call
	LD	B,A
	JR 	2$
1$:	LD	L,A
2$:	LD	H,#0
	ADD	HL,HL
	ADD	HL,HL		; C' * 4
	LD	DE,#ZEROP	; Table of pointers (BltX, addr)
	ADD	HL,DE
	MOV	(PCLEN),(HL)	; Save the BltX value
	INC	HL
	MOV	(CWIDTH),(HL)	; Save the character width
	INC	HL
	MOV	E,(HL)
	INC	HL
	MOV	D,(HL)
	PUSH	DE
	POP	IX		; IX Points to beginning of character BitBlit data table
	
	; PCLEN has 2/4 line indicator
	; IX has pointer to data

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
	ADD	HL,DE		; + x portion
	LD	DE,#SC1
	ADD	HL,DE		; Offset of byte on screen
	MOV	(SCRBIT),#1
SCLOOP:	PUSH	HL
	PUSH	BC
	LD 	IY,#ONOFF
	LD	A,(CWIDTH)
	CP	#6
	JR	Z,SCRBa
	LD	A,#0
PCLEN	.equ	.-1		; Switch bltX value
	CP	#2
	JP	Z,B2x2
	CP	#3
	JP	Z,B2x3
SCRBa:	LD	A,#0
SCRBIT	.equ	.-1	

B3x4:	AND	(IY)
	JP 	Z,B3x4a
	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLTORMEM
	BLT	ORMEM 		; Generates 256 bytes of instructions
	JP	NXTSC3
SkipBLTORMEM:
	BLTSKIP	ORMEM
	JP 	NXTSC3
B3x4a:	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLTANDMEM
	BLT	ANDMEM
	JP	NXTSC3
SkipBLTANDMEM:
	BLTSKIP	ANDMEM
	JP 	NXTSC3
	
B2x2:	LD 	A,(SCRBIT)	; Note macros take care of quadrant for HL
	AND	(IY)
	JP 	Z,B2x2a
	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLT2ORMEM
	BLT2	ORMEM 		
	JP	NXTSC3
SkipBLT2ORMEM:
	BLT2SKIP ORMEM
	JP 	NXTSC3
B2x2a:	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLT2ANDMEM
	BLT2	ANDMEM
	JP	NXTSC3
SkipBLT2ANDMEM:
	BLT2SKIP ANDMEM
	JP 	NXTSC3
	
B2x3:	LD 	A,(SCRBIT)	
	AND	(IY)
	JP 	Z,B2x3a
	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLT3ORMEM
	BLT3	ORMEM 		
	JP	NXTSC3
SkipBLT3ORMEM:
	BLT3SKIP ORMEM
	JP 	NXTSC3
B2x3a:	LD	A,(CLIPPED)
	AND	A
	JP	NZ,SkipBLT3ANDMEM
	BLT3	ANDMEM
	JP 	NXTSC3
SkipBLT3ANDMEM:
	BLT3SKIP ANDMEM
NXTSC3:	POP	BC		; Because C is randomized on edge detect, BLT size
	POP	HL
	LD	A,#2048/256
	ADD	A,H
	LD	H,A
	CP	#(SC3+2048)/256
	JR	NC,$1
	LD	A,(SCRBIT)
	RLCA
	LD	(SCRBIT),A
	JP	SCLOOP
PNOCHAR:
	MOV	(CWIDTH),#2	
$1:	LD	A,#0
CWIDTH	.EQU	.-1		; Automatically update position (for MESOUT)
	ADD	A,B
	ADD	A,#0
CLIPPED .EQU .-1
	LD	B,A
	INC	B
	RET
PNUMLEN .gblequ .-PNUM
	
CHAR_WIDTH	.equ	7
; RGB version of MKZERO (bit blit data generator) for characters and monocolor sprites	
MKZERO3::
	LD	IY,#ZEROB
	LD	IX,#ZEROP	; ZEROP table BltX, Char Width, Pointer to Bit Blit data
	LOOPB	ZCHAR3,#NUMZER3
	PUSH	IY
	POP	BC
	LD	2(IX),C		; IX.blitData
	LD	3(IX),B		; Size (2/4) and then pointer to bit blit data
	LD	BC,#4
	ADD	IX,BC
	
	LOOPB	ZYOFF3,#2	; yofs
	LOOPB	ZXOFF3,#4	; xofs
MKZRX13:
	PUSH	IX
	CALL	CLSZ; Uses IX
	POP	IX
	LD	A,(ZCHAR3)   	; IX.width
	LD	L,A
	LD	H,#0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL   	; c * 8
	LD	DE,#ZERO3
	ADD	HL,DE
	LD	A,(HL)		; zero3[c][0]
	LD	-3(IX),A	; Width byte 
	LD	B,#CHAR_WIDTH-1	; B is x
	LD	DE,#CHAR_WIDTH		; starting at zero[c][6] working down to zero[c][1]
	ADD	HL,DE
3$:	LD	C,#CHAR_WIDTH-1		; C is y
	MOV	(YBIT),#1 ;#1<<(CHAR_WIDTH-1)

2$:	PUSH	HL
	LD	A,(YBIT)
	AND	A,(HL)
	JR 	Z,1$
	PUSH	BC
	LD	A,#CHAR_WIDTH	; xy(6-y + xOff, 6-x + yOff, color);
	SUB	C   		; 6 - y
	LD	HL,#ZXOFF3
	ADD	A,(HL)   	; + xOff
	LD	E,A
	LD	A,B	; WAS 6-B
	LD	HL,#ZYOFF3
	ADD	A,(HL)   	; + yOff
	LD	C,A   		; xy Y parm = 6-x+yOff
	LD	B,E   		; xy X parm = 6-y + xOff
	CALL 	XY16
	POP 	BC
1$:	DEC	C   		; 2 closing braces in C
	LD	HL,#YBIT
	SLA	(HL)
	POP	HL
	JP 	P,2$		; All the bits (SRL)
	DEC	HL
	DEC	B		; B in range(6,1)
	JP 	P,3$

	PUSH	BC
; Dump the bytes from the screen after the XY plot of the character is done
	LD	C,#0   ; for (int y = 0; y < 4; y++)
MKDUY3:	LD	B,#0   ; for (int x = 0; x < 3; x++)
	LD	H,#SC1/256
1$:	LD	A,C  		 ; screenByte[x + (y << 4)]
	SHIFT	L,4
	ADD	A,B
	LD	L,A
	LD	A,(HL)
	LD	(IY),A
	INC	IY
	INC	B
	LD	A,#3
	CP	B
	JR	NZ,1$	;	x<3
	INC	C
	LD	A,#4
	CP	C
	JR 	NZ,MKDUY3   	; 2 closing braces in C
	
	POP 	BC   		; Retrieve x, y
	ENDLPB	ZXOFF3
	ENDLPB	ZYOFF3
	LD	A,-3(IX)	; Get width
	LD	-4(IX),#3	; 3 = 2x3
	CP	#5
	JR	C,2$
	CALL	MKZ_GETSIZE	; Is this a 2x2 byte blit, 2x3 or a 3x4 byte blit?
	LD	-4(IX),A
2$:
	ENDLPB	ZCHAR3
	RET
	
	.area _DATA
ZERO_BASE .equ 0x20	
ZERO3:	.db	2,0,0,0,0,0,0,0, 1,1,1,0,1,0,0,0,  2,5,5,0,0,0,0,0 		; b bang double quote Base is 20H
	.db	5,0xa,0x1f,0xa,0x1f,0xa,0,0, 6,4,14,2,14,8,14,4  		; # $
	.db	5,0x11,8,4,2,0x11,0,0, 6,6,6,6,0x15,9,0x16,0			;  % &
	.db	3,2,2,0,0,0,0,0, 6,4,2,1,1,1,2,4, 6,1,2,4,4,4,2,1		; ' ( )
	.db	3,5,2,7,2,5,0,0, 3,0,2,7,2,0,0,0, 1,0,0,2,2,1,0,0	    	; * + , Base is 2AH
	.db	3,0,0,7,0,0,0,0, 1,0,0,0,0,1,0,0, 3,4,4,2,1,1,0,0           	; - . /
; len = 3
; 210
; .XX
; .X.
; .X.
; .X.
; XXX
	.db	3,7,5,5,5,7,0,0, 3,3,2,2,2,7,0,0, 3,7,4,7,1,7,0,0	    ; 0 1 2
	.db	3,7,4,7,4,7,0,0, 3,1,5,7,4,4,0,0, 3,7,1,7,4,7,0,0	    ; 3 4 5
	.db	3,7,1,7,5,7,0,0, 3,7,5,4,4,4,0,0, 3,7,5,7,5,7,0,0	    ; 6 7 8
	.db	3,7,5,7,4,4,0,0, 1,0,1,0,1,0,0,0, 2,2,0,2,2,1,0,0           ; 9 : ;
	.db	3,4,2,1,2,4,0,0, 3,0,7,0,7,0,0,0, 3,1,2,4,2,1,0,0           ; < = >
	.db	3,2,5,4,2,2,0,0, 2,0,0,2,0,0,0,0, 3,2,5,7,5,5,0,0           ; ? . A
	.db	3,7,5,3,5,7,0,0, 3,6,1,1,1,6,0,0, 3,3,5,5,5,3,0,0           ; B C D
	.db	3,7,1,3,1,7,0,0, 3,7,1,3,1,1,0,0, 4,14,1,13,9,14,0,0        ; E F G
	.db	3,5,5,7,5,5,0,0, 3,7,2,2,2,7,0,0, 3,4,4,4,5,7,0,0           ; H I J
	.db	3,5,5,3,5,5,0,0, 3,1,1,1,1,7,0,0, 5,27,21,21,17,17,0,0      ; K L M
	.db	4,9,11,13,9,9,0,0, 3,2,5,5,5,2,0,0, 3,7,5,7,1,1,0,0         ; N O P
	.db	4,6,9,9,13,14,0,0, 3,7,5,3,5,5,0,0, 3,6,1,2,4,3,0,0         ; Q R S
	.db	3,7,2,2,2,2,0,0, 4,5,5,5,5,7,0,0, 4,5,5,5,2,2,0,0           ; T U V
	.db	5,17,17,21,21,10,0,0, 3,5,5,2,5,5,0,0, 3,5,5,2,2,2,0,0      ; W X Y
	.db	3,7,4,2,1,7,0,0, 1,1,1,1,0,1,0,0, 6,6,15,3,15,6,0,0        ; Z ! <mini-pacman> ([ \)
; 0123456
;   XXX
;  XXXXX
; XXXXXXX
; XXXXXXX
; XXXXXXX
; XXXXXXX
; X X X X
	.db	7, 0x01C, 0x03E, 0x7F, 0x7F, 0x7F, 0x7F, 0x55; Ghost coat ] 
; XX XX
; XX XX
	.db	5, 0x1B, 0x1B, 0, 0, 0, 0, 0; Eyes ^ Note Blit2x2 calculated by MKZERO3 
; 0123456
; X  X
	.db	3, 9, 0, 0, 0, 0, 0, 0; Pupils _ 
;   ...							; Will plot one row higher in production
;  .....
; .......
; ..O.O..						; Blue/Magenta
; .......						; White/Red
; .O.O.O.
; O O O O
	.db	7, 0x14, 0, 0x2a, 0x55, 0, 0, 0; Scared look #'`' 
		  
; 0123456	
; ..XXX
; .XXXXX
; XXXXXXX
; XXXXXXX
; XXXXXXX
; .XXXXX
; . XXX
	.db	7, 0x1C, 0x3E, 0x7F, 0x7F, 0x7F, 0x3E, 0x1C; Pacman right state 0 #'a' 
	.db	7, 0x14, 0x36, 0x77, 0x77, 0x7F, 0x3E, 0x1C; Pacman up state 1 #'b' 

; We interrupt this program for lower case c / copyright
	.db	7, 0x1e, 0x21, 0x2d,0x25,0X2d, 0x21,0x1e

	.db	7, 0, 0x22,  0x77, 0x77, 0x77, 0x3E, 0x1C; Pacman up state 3 #'d' 
; ..XXX
;  XXXXX
; XXXXXXX
; XXX
; XXXXXXX
;  XXXXX
;   XXX	
	.db	7, 0x1C, 0x3E, 0x7F, 7, 0x7F, 0x3E, 0x1C; Pacman right state 1 #'e' 
		  
; ..XXX
; .XXXXX	
; XXXXX
; XX
; XXXXX
;  XXXXX
;   XXX
	.db	7, 0x1C, 0x3E, 0x1F, 3, 0x1F, 0x3E, 0x1C; Pacman right state 2 #'f' 
		 
; ..XXX
;  XXXXX
; XXXX
; XX
; XXXX
;  XXXXX
;   XXX
	.db	7, 0x1C, 0x3E, 0x0F, 0x03, 0x0F, 0x3E, 0x1C; Pacman right state 3 #'g' 
		 
	.db	7, 0x1C, 0x3E, 0x7F, 0x70, 0x7F, 0x3E, 0x1C; Pacman left state 1 #'h' 
	.db	7, 0x1C, 0x3E, 0x7C, 0x60, 0x7C, 0x3E, 0x1C; Pacman left state 2 #'i' 
	.db	7, 0x1C, 0x3E, 0x78, 0x60, 0x78, 0x3E, 0x1C; Pacman left state 3 #'j' 
		  
	  
	.db	7, 0x1C, 0x3E, 0x7F, 0x77, 0x77, 0x36, 0x14; Pacman down state 1 #'k' 
	.db	7, 0x1C, 0x3E, 0x77, 0x77, 0x77, 0x22, 0; Pacman down state 2 #'l' 
	.db	7, 0x1C, 0x3E, 0x77, 0x77, 0x63, 0x22, 0; Pacman down state 3 #'m' 
; 01234
;  XXX
; XXXXX
; XXXXX   Power Up 'n'
; XXXXX
;  XXX
	.db	5, 14, 0x1f, 0x1f, 0x1f, 14, 0, 0
; 0123456
;   XXX
;  XXXXX
; XXXXXXX
; XXXXXXX
; XXXXXXX
; XXXXXXX
;  X X X
	.db	7, 0x01C, 0x03E, 0x7F, 0x7F, 0x7F, 0x7F, 0x2A; Ghost coat type 2 'o' 
	
; 0123456
	.db	7, 0x49, 0x22, 0x0, 0x63, 0x0, 0x22, 0x49 ; Splat 'p'
	.db	7, 0,0,0, 0x77, 0x7f, 0x3e, 0x24 ; death state 2 'q' (death state 1 = 'b')
	.db	7, 0,0,4,0x1c, 0x3e, 0x7f, 0x36 ; death state 3 'r'
	.db	7, 0,0,4,0x1c, 0x1c, 0x3e, 0x14 ; death state 4 's', death state 4 is splat, 'p'
	.db	3, 6,6,4,0,2,0,0		; Slanted ! 't'
	.db	7, 0, 0x22, 0x77, 0x77, 0x77, 0x3E, 0x1C; Pacman up state 2 #'u' 
	.db	7, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f ; 7x7 Block for erasing 'v'
;	.db	7,0x7f,0,0,0,0,0,0,0 		; Horizontal bar 'w'
;	.db	1,1,1,1,1,1,1,1			; Vertical bar 'x'

NUMZER3	.gblequ (.-ZERO3)   / 8

_inTable:
	.dw	INTABLE
_SC1P::	.dw	SC1

; Note 2x2 char store in same array (wastes (n=3x4x8) - 2x2x8 or n-2x3x8 bytes, but the indexing calculation is simplified for now.  Most chars waste 48 bytes
_ZEROP::
ZEROP:	.ds	4*NUMZER3
BEGIN_FREE  .gblequ    ZEROB+4*3*8*NUMZER3

; Check BEGIN_FREE against s__HEAP in the bitblit.map file.   Not much allocation going on in this program though.
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
