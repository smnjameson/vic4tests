@echo off

set WRITE="C:\C64\Tools\vice\bin\c1541.exe" -attach "./bin/DISK.D81" 8 -write
set FORMAT="C:\C64\Tools\vice\bin\c1541.exe" -format "disk,0" d81 "./bin/DISK.D81"
set KICKASM=java -cp Z:\Projects\Mega65\_build_utils\kickass.jar kickass.KickAssembler65CE02  -vicesymbols -showmem 
set DEPLOY="C:\C64\Tools\m65_connect\M65Connect Resources\m65.exe" -l COM6 -F -r 
set SPLIT=node "Z:\Projects\Meg65\_build_utils\split64.js"
set ASP65 ="node ../_build_utils/aseparse65/asp65 parse -i "

rem ASSETS

                               
echo ASSEMBLING SOURCES...
rem PRG BOOT  - Initial file should be this
%KICKASM%  vic4tests.s -odir ./bin

echo DEPLOYING...
%DEPLOY% "./bin/vic4tests.prg"
"C:\Program Files\xemu\xmega65.exe" -besure -prg "./bin/vic4tests.prg"





