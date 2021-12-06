;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (MINGW64)
;--------------------------------------------------------
	.module launch
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _dazinit
	.globl __exit
	.globl _DAZINIT
	.globl _DAZMOD
	.globl _PNUMTS
	.globl _STARTA
	.globl _getchar
	.globl _puts
	.globl _printf
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_done:
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
;missile/space/launch.c:11: void dazinit(void)
;	---------------------------------
; Function dazinit
; ---------------------------------
_dazinit::
;missile/space/launch.c:14: if (done)
	ld	a,(#_done + 0)
	or	a, a
;missile/space/launch.c:15: return;
	ret	NZ
;missile/space/launch.c:16: done = 1;
	ld	hl,#_done + 0
	ld	(hl), #0x01
;missile/space/launch.c:17: DAZMOD();
	call	_DAZMOD
;missile/space/launch.c:18: DAZINIT();
;missile/space/launch.c:19: }
	jp	_DAZINIT
;missile/space/launch.c:21: int main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;missile/space/launch.c:24: done = 0;
	ld	hl,#_done + 0
	ld	(hl), #0x00
;missile/space/launch.c:27: do
00106$:
;missile/space/launch.c:33: printf("0. Exit\n");
	ld	hl, #___str_16
	push	hl
	call	_puts
	pop	af
;missile/space/launch.c:34: choice = getchar();
	call	_getchar
	inc	sp
	inc	sp
	push	hl
;missile/space/launch.c:36: switch (choice)
	ld	a, -2 (ix)
	sub	a, #0x30
	or	a, -1 (ix)
	jr	Z,00103$
	ld	a, -2 (ix)
	sub	a, #0x31
	or	a, -1 (ix)
	jr	Z,00101$
	ld	a, -2 (ix)
	sub	a, #0x32
	or	a, -1 (ix)
	jr	Z,00102$
	jr	00104$
;missile/space/launch.c:38: case '1':
00101$:
;missile/space/launch.c:39: printf("%s", "Please wait, building character bitmaps.\n");
	ld	hl, #___str_9
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
;missile/space/launch.c:40: STARTA();
	call	_STARTA
;missile/space/launch.c:41: break;
	jr	00106$
;missile/space/launch.c:42: case '2':
00102$:
;missile/space/launch.c:43: dazinit();
	call	_dazinit
;missile/space/launch.c:44: PNUMTS();
	call	_PNUMTS
;missile/space/launch.c:45: break;
	jr	00106$
;missile/space/launch.c:46: case '0':
00103$:
;missile/space/launch.c:47: printf("Exiting\n");
	ld	hl, #___str_11
	push	hl
	call	_puts
;missile/space/launch.c:48: _exit(0);
	ld	hl, #0x0000
	ex	(sp),hl
	call	__exit
	pop	af
;missile/space/launch.c:50: default:
00104$:
;missile/space/launch.c:51: printf("Not implemented.  Try again:\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;missile/space/launch.c:55: } while (1);
;missile/space/launch.c:57: }
	jr	00106$
___str_8:
	.ascii "%s"
	.db 0x00
___str_9:
	.ascii "Please wait, building character bitmaps."
	.db 0x0a
	.db 0x00
___str_11:
	.ascii "Exiting"
	.db 0x00
___str_13:
	.ascii "Not implemented.  Try again:"
	.db 0x00
___str_16:
	.ascii "Choose Action:"
	.db 0x0a
	.db 0x0a
	.ascii "1. Start program"
	.db 0x0a
	.ascii "2. Run pnum test"
	.db 0x0a
	.ascii "0. Exit"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
