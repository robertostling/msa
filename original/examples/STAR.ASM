
;
;                                    Star
;
;                       Copyright(C) 2001 Robert ™stling
;
;
;       This is a sample program to the MSA assembler, just a simple
;       starfield. NASM and MSA assemble it both.
;

                ORG     0X0100

                MOV     AX,0X13
                INT     0X10
                MOV     AX,0XA000
                MOV     ES,AX

MAIN_LOOP:
                CALL    SLUMPA
                MOV     DI,320*200-1
L0:             MOV     AL,BYTE[ES:DI]
                MOV     BL,AL
                OR      AL,AL
                JZ      L1
                MOV     BYTE[ES:DI],0
                PUSH    AX
                MOV     AX,DI
                XOR     DX,DX
                MOV     CX,320
                DIV     CX
                POP     AX
                XOR     AH,AH
                SUB     AL,0X17
                ;SHR     AX,2
                ;INC     AX
                MOV     CX,AX
                ADD     CX,DX
                CMP     CX,320
                JNB     L1
                PUSH    DI
                ADD     DI,AX
                MOV     BYTE[ES:DI],BL
                POP     DI
L1:             DEC     DI
                CMP     DI,0XFFFF
                JNZ     L0
                MOV     AH,1
                INT     0X16
                JZ      MAIN_LOOP

                MOV     AH,0
                INT     0X16
                MOV     AX,3
                INT     0X10
                INT     0X20


SLUMPA:         XOR     DI,DI
SLUMPA1:        MOV     DX,500
                CALL    RANDOM
                CMP     AL,3
                JNZ     SLUMPA0
                MOV     DX,8
                CALL    RANDOM
                ADD     AL,0X18
                STOSB
                DEC     DI
SLUMPA0:        ADD     DI,320
                CMP     DI,64000
                JB      SLUMPA1
                RET

RANDOM:         MOV     AH,BYTE[RSEED+1]
                IN      AL,0X40
                XOR     AH,AL
                ROR     AH,1
                XOR     AL,AH
                MOV     BYTE[RSEED],AL
                IN      AL,0X40
                ROR     AX,4
                XOR     AL,AH
                MOV     BYTE[RSEED+1],AL
                MOV     AX,WORD[RSEED]
                PUSH    CX
                MOV     CX,DX
                XOR     DX,DX
                DIV     CX
                MOV     AX,DX
                POP     CX
                RET

RSEED           DW      0X5B8A
