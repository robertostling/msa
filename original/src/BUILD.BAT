@echo off

rem     This is the makefile for MSA assembler (Build 12)

bcc -Z -C -1 -O -mt -Id:\lang\bc\include -Ld:\lang\bc\lib msa.c
rem     Change the above directories to the location of your C compiler. 

rem bcc -Z -C -O -mt -Id:\lang\bc\include -Ld:\lang\bc\lib msa.c
rem     Use this line for 8086 output

exe2bin msa.exe msa.com
del msa.exe
