SDCCBIN=/cygdrive/a/Progra~1/SDCC/bin

bitblit.com: bitblit.ihx
	/cygdrive/p/525Archive/z80pack/windows/hex2bin.exe -e com bitblit.ihx 

bitblit.ihx: bitblit.rel profile.rel dazzler.rel asmhooks.rel ztest.rel ghost.rel sdcc_stdio.rel pacmanc.rel paclib.rel crt0.rel 
	$(SDCCBIN)/sdldz80 -u -s -m -b _CODE=0x10f -i bitblit crt0 bitblit asmhooks profile ztest paclib pacmanc ghost dazzler sdcc_stdio -l "A:\Program Files\SDCC\lib\z80\z80.lib"

bitblit.rel: bitblit.asm dazzler.mac dazzler.abs
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
profile.rel: profile.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
dazzler.rel: dazzler.asm dazzler.mac dazzler.abs
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
paclib.rel: paclib.asm dazzler.mac dazzler.abs
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
crt0.rel: crt0.asm
	$(SDCCBIN)/sdasz80 -l -o $@ $<
	
sdcc_stdio.rel: sdcc_stdio.c
	$(SDCCBIN)/sdcc -c -mz80 sdcc_stdio.c
	
ztest.rel: ztest/ztest/ztest.c
	$(SDCCBIN)/sdcc -c -mz80 ztest/ztest/ztest.c
	
pacmanc.rel: ztest/ztest/pacmanc.c ztest/ztest/pacman.h ztest/ztest/ghost.h ztest/ztest/data.h
	$(SDCCBIN)/sdcc -c -mz80 ztest/ztest/pacmanc.c
	
ghost.rel: ztest/ztest/ghost.c ztest/ztest/pacman.h ztest/ztest/ghost.h ztest/ztest/data.h
	$(SDCCBIN)/sdcc -c -mz80 ztest/ztest/ghost.c
	
asmhooks.rel: asmhooks.c
	$(SDCCBIN)/sdcc -c -mz80 asmhooks.c
