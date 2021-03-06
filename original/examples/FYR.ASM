                ORG     0X0100

                MOV     AX,0X13
                INT     0X10
                MOV     AX,0XA000
                MOV     ES,AX

                MOV     CX,0X40
SETPAL0:        MOV     DX,0X03C8
                MOV     AL,CL
                DEC     AX
                OUT     DX,AL
                INC     DX
                OUT     DX,AL
                XOR     AL,AL
                OUT     DX,AL
                OUT     DX,AL
                LOOP    SETPAL0

MAIN_LOOP:
                MOV     DI,320*199
                MOV     CX,319
L0:             MOV     DX,0X3F
                CALL    RANDOM
                STOSB
                LOOP    L0

                MOV     DI,320*199-1
L1:
                MOV     AL,BYTE[ES:DI+320]
                MOV     AH,0
                SHL     AX,2
L2:
                ADD     AL,BYTE[ES:DI+321]
                ADC     AH,0
                ADD     AL,BYTE[ES:DI+319]
                ADC     AH,0
                ADD     AL,BYTE[ES:DI-319]
                ADC     AH,0
                ADD     AL,BYTE[ES:DI-321]
                ADC     AH,0
                INC     AX
                SHR     AX,3
                MOV     BYTE[ES:DI],AL
                OR      AL,AL
                JNZ     J3
                INC     CX
                CMP     CX,320
                JA      J1
                JMP     SHORT J4

J3:
                XOR     CX,CX
J4:

                DEC     DI
                CMP     DI,0XFFFF
                JNZ     L1

J1:             MOV     AH,1
                INT     0X16
                JZ      MAIN_LOOP

                MOV     AH,0
                INT     0X16
                MOV     AX,3
                INT     0X10
                INT     0X20

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

RSEED           DW      0X5A8B
