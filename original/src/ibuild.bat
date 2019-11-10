@echo off
bcc -Z -C -O -Id:\lang\bc\include -Ld:\lang\bc\lib -mt install.c
exe2bin install.exe install.com
del install.exe
