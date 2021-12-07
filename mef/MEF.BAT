cpm cc mef -r 14 -e b100
cpm cc stty -r 14 -e b100
cpm cc info -r 14 -e b100
cpm cc ic -r 14 -e b100
cpm cc util -r 14 -e b100
cpm ld mef -o mef stty info ic util -r 1000 -s
del mef.cpm
ren mef.com mef.cpm
