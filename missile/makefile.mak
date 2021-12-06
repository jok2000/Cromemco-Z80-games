SDCCBIN=/cygdrive/a/Progra~1/SDCC/bin

bitblit.com: bitblit.ihx
	/cygdrive/p/525Archive/z80pack/windows/hex2bin.exe -p 0 -e com bitblit.ihx 

bitblit.ihx: bitblit.rel dazzler.rel sdcc_stdio.rel ghost.rel ztest.rel crt0.rel
	$(SDCCBIN)/sdldz80 -u -s -m  -b _CODE=0x10f -i bitblit crt0 bitblit profile ztest ghost dazzler sdcc_stdio -l "A:\Program Files\SDCC\lib\z80\z80.lib"
	
sdcc_stdio.rel: sdcc_stdio.c
	$(SDCCBIN)/sdcc -c -mz80 sdcc_stdio.c

ztest.rel: bitblit/ztest/ztest/ztest.c
	$(SDCCBIN)/sdcc -c -mz80 bitblit/ztest/ztest/ztest.c

ghost.rel: bitblit/ztest/ztest/ghost.c
	$(SDCCBIN)/sdcc -c -mz80 bitblit/ztest/ztest/ghost.c

missile.rel:	missile.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<

missileStrip.rel:	missileStrip.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
profile.rel:	profile.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
dazzler.rel:	dazzler.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
dazzlerStrip.rel:	dazzlerStrip.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<	

crt0.rel:	crt0.asm makefile.mak
	$(SDCCBIN)/sdasz80 -l -o $@ $<
