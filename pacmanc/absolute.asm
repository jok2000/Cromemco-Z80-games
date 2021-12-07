        .area _DATAA (ABS)
	 .ORG	((.-1)/256+1)   * 256
DAZTAB:	.db	1, 4, 2, 8, 0x10, 0x40, 0x20, 0x80

	 .ORG ((.-1)/256+1)   * 256
DAZTB1:	.db	1, 1<<1, 1<<4, 1<<5, 1<<2, 1<<3, 1<<6, 1<<7	; Official Dazzler memory layout (x+y*4) 
        
	.ORG	(./2048+1)*2048
SC1     .ds	2048
SC2     .ds	2048        