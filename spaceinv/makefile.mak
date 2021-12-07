SDCCBIN=/cygdrive/a/Progra~1/SDCC/bin

spaceinv.com: spaceinv.ihx
	/cygdrive/p/525Archive/z80pack/windows/hex2bin.exe -e com spaceinv.ihx 

spaceinv.ihx: space.rel dazzler.rel graphics.rel sdcc_stdio.rel launch.rel crt0.rel
	$(SDCCBIN)/sdldz80 -u -s -m  -b _CODE=0x10f -i spaceinv crt0 launch space graphics dazzler sdcc_stdio -l "A:\Program Files\SDCC\lib\z80\z80.lib"
	
sdcc_stdio.rel: sdcc_stdio.c
	$(SDCCBIN)/sdcc -c -mz80 sdcc_stdio.c

launch.rel: space/space/launch.c
	$(SDCCBIN)/sdcc -c -mz80 space/space/launch.c

space.rel:	space.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
graphics.rel:	graphics.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<

profile.rel:	profile.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
dazzler.rel:	dazzler.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<

crt0.rel:	crt0.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<


