
;                                   Snow
;
;                       Copyright(C) 2001 Robert �stling
;
;       I wrote this program as a VGA 'snow' demo, but then I added
;       fireworks, and now I think this is a nice little program.
;       Just run SNOW.COM and enjoy! (Press any key to exit). Can be
;       assembled by NASM and MSA. NASM makes it 33 bytes smaller )-:
;
;       I'm sorry, but the (few) comments are in Swedish.
;


SMALT_FARG      EQU     16
RAKET_INT       EQU     25
MAX_FART        EQU     8
MIN_FART        EQU     3
MAXSTORL        EQU     25
MINSTORL        EQU     15
SVALNA          EQU     2
HOJD            EQU     55
FART            EQU     0X08
SPLITTER        EQU     0X1
MINSKNING       EQU     0X08
RAKETFARG       EQU     0XFD
FARGER          EQU     3

                ORG     0X0100

                CALL    INIT8

                MOV     AX,0X13
                INT     0X10                    ; VIDEO MODE 320X200 256C
                MOV     AX,0XA000
                MOV     ES,AX                   ; ES=VIDEO SEG 0XA0000

                CALL    _SETPAL

                MOV     SI,MESSAGE
                MOV     CX,90
                MOV     DX,50
                CALL    PUTSTRING

                MOV     AX,80
                CALL    DELAY

MAIN_LOOP:
                CMP     BYTE[RAKET],0           ; �R EN RAKET P� V�G UPP
                JNZ     J11                     ; NEJ, G� TILL J5
                JMP     J5
J11:            MOV     AX,WORD[RAKETFART]
                SUB     WORD[RAKETY],AX         ; FLYTTA RAKETEN UPP�T
                INC     WORD[RAKETFART]
                MOV     AX,HOJD
                SHL     AX,MINSKNING
                CMP     WORD[RAKETY],AX         ; DENONATIONSH�JD?
                JNA     J18                     ; NEJ G� TILL J6
                JMP     J6
J18:            MOV     BYTE[RAKET],0           ; RAKETEN UPPH�R ATT EXISTERA
                MOV     DI,WORD[RAKETY]
                SHR     DI,MINSKNING
                MOV     AX,320
                MUL     DI
                XCHG    AX,DI                   ; DI = OFFSET EXPLOSIONS-
                ADD     DI,WORD[RAKETX]         ; PLATSEN

                SUB     DI,5
                MOV     AL,RAKETFARG ;BYTE[RAKETFARG]      ; EXPLOSIONSF�RG
                MOV     DX,WORD[RAKETSTORL]     ; STORLEK I Y-LED F�R EXP.
L0:
                MOV     CX,WORD[RAKETSTORL]     ; STORLEK I X-LED F�R EXP.
                SHR     CX,1
L2:             PUSH    DX
                ADD     DX,CX
                CALL    RANDOM
                POP     DX
                DEC     BX
                CMP     AL,SPLITTER
                JA      J9
                MOV     AL,RAKETFARG ;BYTE[RAKETFARG]
                MOV     BYTE[ES:BX+DI],AL
                MOV     SI,BX
                XOR     BX,BX
                SUB     BX,SI
                MOV     BYTE[ES:BX+DI],AL
J9:             LOOP    L2
                SUB     DI,320                  ; G� TILL N�STA
                DEC     DX
                JNZ     L0                      ; RITAT KLART? G� TILL L0

                CMP     BYTE[RAKETER],2
                JB      L16
                MOV     DX,5
                CALL    RANDOM
                CMP     AL,1
                JA      L16

                MOV     DX,WORD[RAKETY]
                SUB     DX,10
                SHR     DX,MINSKNING
                MOV     CX,WORD[RAKETX]
                SUB     CX,21
                MOV     SI,MESSAGE3
                CMP     AL,1
                JZ      L17
                MOV     SI,MESSAGE4
L17:
                MOV     BYTE[TEXTCOLOR],0XFE
                CALL    PUTSTRING
                MOV     WORD[TIMER],30
L16:
                JMP     J7
J6:
                MOV     DI,WORD[RAKETY]
                SHR     DI,MINSKNING
                MOV     AX,320
                MUL     DI
                XCHG    AX,DI                   ; DI = OFFSET TILL RAKETH�JD
                ADD     DI,WORD[RAKETX]
                DEC     DI
                DEC     DI
                ;MOV     AL,BYTE[RAKETFARG]      ; RITA RAKETEN

                MOV     DX,0X30
                CALL    RANDOM
                ADD     AL,0X90
                STOSB
                MOV     DX,0X30
                CALL    RANDOM
                ADD     AL,0X90
                STOSB
                SUB     DI,322
                MOV     DX,0X30
                CALL    RANDOM
                ADD     AL,0X90
                STOSB
                MOV     DX,0X30
                CALL    RANDOM
                ADD     AL,0X90
                STOSB
                JMP     SHORT J7

J5:             CMP     BYTE[RESTER],1
                JZ      J7
                MOV     DX,1000                 ; SKA EN NY RAKET SKICKAS UPP?
                CALL    RANDOM
                CMP     AX,RAKET_INT
                JA      J7                      ; NEJ, G� TILL J7
                INC     BYTE[RAKETER]
                MOV     DX,FARGER
                CALL    RANDOM
                MOV     BYTE[NEWPAL],AL
                CALL    SETPAL
                MOV     DX,MAX_FART-MIN_FART
                CALL    RANDOM                  ; SLUMPA RAKETFART
                ADD     AX,MIN_FART
                SHL     AX,MINSKNING-1
                MOV     WORD[RAKETFART],AX      ; LAGRA RAKETFART
                MOV     DX,140
                CALL    RANDOM
                ADD     AX,90                   ; SLUMPA RAKETPOS. X
                MOV     WORD[RAKETX],AX         ; LAGRA POS. X
                MOV     WORD[RAKETY],190        ; LAGRA POS.
                SHL     WORD[RAKETY],MINSKNING
                MOV     DX,MAXSTORL-MINSTORL
                CALL    RANDOM
                ADD     AX,MINSTORL             ; STORLEK P� EXP.
                MOV     WORD[RAKETSTORL],AX     ; LAGRA EXP.STORLEK
                MOV     BYTE[RAKET],1           ; RAKET EXISTERAR
J7:
                CALL    TACKE                   ; HUR DJUPT �R SN�T�CKET?
                CMP     BYTE[SMALT],1           ; H�LLER SN�N P� ATT SM�LTA
                JNZ     J3                      ; NEJ, G� TILL J3
                CMP     WORD[SNODJUP],0X4       ; �R SN�DJUPET �VER 4
                JA      J1                      ; JA, G� TILL J1
                MOV     BYTE[SMALT],0           ; SN�NIV� L�G. SLUTA SM�LTA.
                MOV     WORD[SNOW],1            ; B�RJA SN�A
                JMP     SHORT J1

J3:             CMP     WORD[SNODJUP],0X8       ; �R SN�T�CKET UNDER 8
                JB      J1                      ; JA, G� TILL J1
                MOV     BYTE[SMALT],1           ; SN�NIV� H�G, B�RJA SM�LTA.

J1:             CALL    SLUMPAUPPE              ; RITA UT NYA FLINGOR
                DEC     BYTE[COUNTER]           ; �R DET DAGS ATT �KA SN�ANDET?
                JNZ     J0                      ; NEJ, G� TILL J0
                MOV     BYTE[COUNTER],FART
                CMP     WORD[SNOW],0X080        ; �R SN�ANDET REDAN P� MAX?
                JA      J0                      ; JA, G� TILL J0
                INC     WORD[SNOW]              ; �KA SN�ANDET
J0:             CALL    FALL                    ; G�R S� ATT SN�N ETC. FALLER

                MOV     AH,1
                INT     0X16
                JNZ     QUIT
                JMP     MAIN_LOOP

QUIT:
                MOV     AH,0
                INT     0X16
                MOV     AX,0X3
                INT     0X10

                CALL    EXIT8

                INT     0X20

FALL:           MOV     DI,320*199
                MOV     CX,319
                MOV     BYTE[RESTER],0
FALL14:         MOV     AL,BYTE[ES:DI]
                CMP     AL,0X80
                JB      FALL13
                SUB     AL,SVALNA
                MOV     BYTE[ES:DI],AL
                CMP     AL,0X80
                JA      FALL13
                MOV     BYTE[ES:DI],0
FALL13:         INC     DI
                LOOP    FALL14
                MOV     DI,200                  ; BEHANDLA ALLT UTOM D�R
                SUB     DI,WORD[SNODJUP]        ; SN�N LIGGER.
                MOV     AX,320
                MUL     DI
                XCHG    AX,DI                   ; F�R ALLA PXLAR:
FALL0:          MOV     AL,BYTE[ES:DI]          ; LADDA PIXELN TILL AL
                CMP     AL,0XFE
                JNZ     FALL18
                CMP     WORD[TIMER],0
                JZ      FALL18
                JMP     FALL1
FALL18:         CMP     AL,0X80
                JNA     FALL12
                CMP     AL,0XC0
                JNA     FALL15
                MOV     BYTE[RESTER],1
FALL15:         SUB     AL,SVALNA
                CMP     AL,0X80
                JA      FALL12
                MOV     AL,0
FALL12:
                MOV     BYTE[ES:DI],AL
                OR      AL,AL                   ; OM N�GOT �R D�R,
                JNZ     FALL10                  ; BEHANDLA DATA, ANNARS
                JMP     FALL1                   ; G� TILL FALL1 (N�STA PIXEL)
FALL10:         PUSH    AX
                MOV     DX,WORD[MAINWIND]       ; SLUMPA R�RELSERIKTNING
                CALL    RANDOM
                ADD     AX,WORD[MAINWIND2] 
                MOV     WORD[WIND],AX           ; LAGRA R�RELSERIKTNING
                POP     AX
                PUSH    DI
                ADD     DI,320
                ADD     DI,WORD[WIND]           ; LADDA NY POSITION
                CMP     AL,0X1C                 ; OM PIXELN _INTE_ VAR EN
                JB      FALL5                   ; FLINGA, G� TILL FALL5
                CMP     AL,0X20                 ; ...
                JA      FALL5                   ; ...
                MOV     BL,AL
                SUB     BL,0X1C
                MOV     BH,0                    ; M�RKARE FLINGOR FALLER
                SHR     BX,1                    ; �T ENA H�LLET, LJUSARE
                SUB     BX,1                    ; �T ANDRA.
                ADD     DI,BX
FALL5:          MOV     AH,BYTE[ES:DI]          ; SE VAD SOM FINNS P� GAMLA
                CMP     AL,SMALT_FARG           ; POSITIONEN. OM SM�LT-
                JNZ     FALL3                   ; DROPPE, G� TILL FALL3
                CMP     AH,0                    ; OM NYA POSITIONEN �R TOM
                JZ      FALL4                   ; G� TILL FALL4
                MOV     BYTE[ES:DI],0           ; T�M NYA POS.
                POP     DI
                MOV     BYTE[ES:DI],0           ; T�M GAMLA POS.
                JMP     SHORT FALL1             ; G� TILL FALL1
FALL4:          MOV     BYTE[ES:DI],SMALT_FARG  ; SM�LTDROPPE TILL NYA POS.
                POP     DI
                MOV     BYTE[ES:DI],0           ; T�M GAMLA POS.
                JMP     SHORT FALL1             ; G� TILL FALL1
FALL3:
FALL9:          CMP     AH,0                    ; �R NYA POS. TOM?
                JNZ     FALL2                   ; NEJ, G� TILL FALL2
                OR      BYTE[ES:DI],AL          ; FLYTTA FLINGAN
FALL6:
                POP     DI
                MOV     BYTE[ES:DI],0           ; T�M GAMLA POS.
                JMP     SHORT FALL1             ; G� TILL FALL1
FALL2:          POP     DI
FALL1:          DEC     DI
                CMP     DI,0XFFFF
                JZ      FALL8
                JMP     FALL0                   ; BEHANDLA N�STA PIXEL
FALL8:          RET

TACKE:          MOV     DI,320*200-1            ; B�RJA I SLUTET
                MOV     CX,DI
TACKE0:         MOV     AL,BYTE[ES:DI]          ; LADDA PIXEL
                DEC     DI
                OR      AL,AL                   ; INGET D�R? D� KAN JU INTE
                JZ      TACKE1                  ; RADEN VARA HELT T�CKT.
                                                ; HOPPA TILL TACKE1
                LOOP    TACKE0                  ; KOLLA N�STA PIXEL
                MOV     WORD[SNODJUP],200       ; HELA SK�RMEN �R FYLLD...
                RET
TACKE1:         MOV     AX,DI
                XOR     DX,DX
                MOV     CX,320
                DIV     CX
                MOV     WORD[SNODJUP],200
                SUB     WORD[SNODJUP],AX        ; LAGRA SN�DJUPET
                RET

SLUMPAUPPE:     XOR     DI,DI
                MOV     CX,320
SLUMP0:         CMP     WORD[SNOW],0
                JZ      SLUMP1
                MOV     DX,0X8000
                CALL    RANDOM
                CMP     AX,WORD[SNOW]
                JNB     SLUMP1
                CMP     BYTE[SMALT],1
                JNZ     SLUMP2
                MOV     AL,SMALT_FARG
                JMP     SHORT SLUMP3
SLUMP2:         MOV     DX,4
                CALL    RANDOM
                ADD     AL,0X1C
SLUMP3:         MOV     BYTE[ES:DI],AL
SLUMP1:         INC     DI
                LOOP    SLUMP0
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

SETPAL:
                MOV     AL,BYTE[OLDPAL]
                CMP     AL,BYTE[NEWPAL]
                JNZ     _SETPAL

                RET
_SETPAL:
                MOV     CX,0X40
SETPAL0:        MOV     DX,0X03C8
                MOV     AL,CL
                ADD     AL,0X80
                OUT     DX,AL
                INC     DX
                MOV     AL,CL
                OUT     DX,AL
                XOR     AL,AL
                OUT     DX,AL
                OUT     DX,AL

                LOOP    SETPAL0

                MOV     CX,0X40
SETPAL1:        MOV     DX,0X03C8
                MOV     AL,CL
                ADD     AL,0XBF
                OUT     DX,AL
                INC     DX
                MOV     AL,CL

                CMP     BYTE[NEWPAL],0
                JNZ     SETPAL_NOT0

                PUSH    AX
                MOV     AL,0X3F
                OUT     DX,AL
                POP     AX
                OUT     DX,AL
                XOR     AL,AL
                OUT     DX,AL
                JMP     SHORT SETPAL_DONE
SETPAL_NOT0:
                CMP     BYTE[NEWPAL],1
                JNZ     SETPAL_NOT1

                XOR     AL,0X3F
                OUT     DX,AL
                PUSH    AX
                XOR     AL,AL
                OUT     DX,AL
                POP     AX
                XOR     AL,0X3F
                OUT     DX,AL
                JMP     SHORT SETPAL_DONE
SETPAL_NOT1:
                XOR     AL,0X3F
                OUT     DX,AL
                XOR     AL,0X3F
                OUT     DX,AL
                XOR     AL,AL
                OUT     DX,AL

SETPAL_DONE:

                LOOP    SETPAL1
                MOV     AL,BYTE[NEWPAL]
                MOV     BYTE[OLDPAL],AL
                RET


PUTSTRING2:     PUSHA
                CALL    PUTCHAR
                POPA
                ADD     CX,6
PUTSTRING:      LODSB
                MOV     AH,AL
                CMP     AL,0
                JZ      PUTSTRING0
                CMP     AL,0XD
                JZ      PUTSTRING1
                CMP     CX,310
                JA      PUTSTRING3
                JMP     PUTSTRING2
PUTSTRING1:     ADD     DX,6
                XOR     CX,CX
                JMP     PUTSTRING
PUTSTRING3:     ADD     DX,6
                XOR     CX,CX
                JMP     PUTSTRING2
PUTSTRING0:     RET

PUTCHAR:        CALL    LOADCHAR
                PUSH    DS
                PUSH    CS
                POP     DS
                ADD     SI,CHARSET
                MOV     DI,5
                MOV     BX,DI
                CALL    PUTIMG
                POP     DS
                RET

LOADCHAR:       MOV     SI,CHARSETSTR
LOADCHAR2:      MOV     AL,BYTE[CS:SI]
                CMP     AL,0
                JZ      LOADCHAR0
                CMP     AL,AH
                JZ      LOADCHAR1
                INC     SI
                JMP     LOADCHAR2
LOADCHAR0:      XOR     SI,SI
                RET
LOADCHAR1:      SUB     SI,CHARSETSTR
                MOV     AX,25
                PUSH    DX
                MUL     SI
                POP     DX
                MOV     SI,AX
                RET

PUTIMG:         PUSH    CS
                POP     DS
                PUSH    DI
                PUSH    CX
PUTIMG0:        PUSH    DI
                PUSH    CX
                PUSH    DX
                PUSH    BX
                LODSB
                CMP     AL,5
                JZ      PUTIMG1
                CMP     AL,0
                JNZ     PUTIMG2
                MOV     AL,BYTE[CS:TEXTCOLOR]
PUTIMG2:        MOV     BL,AL
                CALL    PSET
PUTIMG1:        POP     BX
                POP     DX
                POP     CX
                POP     DI
                INC     CX
                DEC     DI
                JNZ     PUTIMG0
                POP     CX
                POP     DI
                INC     DX
                DEC     BX
                JNZ     PUTIMG
                RET

FILLED:         PUSHA
                CALL    XLINE
                POPA
                INC     DX
                DEC     DI
                JNZ     FILLED
                RET

RECTANGLE:      PUSHA
                MOV     SI,DI
                CALL    YLINE
                POPA
                PUSHA
                ADD     CX,SI
                DEC     CX
                MOV     SI,DI
                CALL    YLINE
                POPA
                PUSHA
                CALL    XLINE
                POPA
                ADD     DX,DI
                CALL    XLINE
                RET

YLINE:          MOV     AX,[CS:MAXX]
                MUL     DX
                ADD     AX,CX
                MOV     DI,AX
                MOV     CX,SI
                MOV     DX,ES
                MOV     AX,0XA000
                MOV     ES,AX
                MOV     AL,BL
YLINE0:         MOV     BYTE[ES:DI],AL
                ADD     DI,[CS:MAXX]
                LOOP    YLINE0
                MOV     ES,DX
                RET

XLINE:          MOV     AX,[CS:MAXX]
                MUL     DX
                ADD     AX,CX
                MOV     DI,AX
                MOV     CX,SI
                MOV     DX,ES
                MOV     AX,0XA000
                MOV     ES,AX
                MOV     AL,BL
                REP     STOSB
                MOV     ES,DX
                RET

PSET:           MOV     AX,[CS:MAXX]
                MUL     DX
                ADD     AX,CX
                MOV     DI,AX
                MOV     DX,ES
                MOV     AX,0XA000
                MOV     ES,AX
                MOV     AL,BL
                STOSB
                MOV     ES,DX
                RET

INIT8:          PUSH    DS
                XOR     AX,AX
                MOV     DS,AX
                MOV     DI,OLD8
                MOV     SI,8*4
                MOVSW
                MOVSW
                MOV     WORD[8*4],NEW8
                MOV     WORD[8*4+2],CS
                POP     DS
                RET

EXIT8:          PUSH    ES
                XOR     AX,AX
                MOV     ES,AX
                MOV     DI,8*4
                MOV     SI,OLD8
                MOVSW
                MOVSW
                POP     ES
                RET

NEW8:           CMP     WORD[CS:TIMER],0
                JZ      JUMP8
                DEC     WORD[CS:TIMER]
JUMP8:          DB      0XEA
OLD8            DD      0

DELAY:          MOV     WORD[TIMER],AX
DELAY0:         CMP     WORD[TIMER],0
                JNZ     DELAY0
                RET

CHARSETSTR      DB      " ABCDEFGHIJKLMNOPQRSTUVWXYZ���0123456789.",0
CHARSET         DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,5,5,5,5

                DB      5,5,0,5,5
                DB      5,0,5,0,5
                DB      0,5,5,5,0
                DB      0,0,0,0,0
                DB      0,5,5,5,0

                DB      0,0,0,5,5
                DB      0,5,5,0,5
                DB      0,0,0,5,5
                DB      0,5,5,0,5
                DB      0,0,0,5,5

                DB      5,5,0,0,0
                DB      5,0,5,5,5
                DB      5,0,5,5,5
                DB      5,0,5,5,5
                DB      5,5,0,0,0

                DB      0,0,0,5,5
                DB      0,5,5,0,5
                DB      0,5,5,0,5
                DB      0,5,5,0,5
                DB      0,0,0,5,5

                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,0,0,5

                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,5,5,5

                DB      5,0,0,0,5
                DB      0,5,5,5,5
                DB      0,5,0,0,0
                DB      0,5,5,0,5
                DB      5,0,0,5,5

                DB      5,0,5,5,0
                DB      5,0,5,5,0
                DB      5,0,0,0,0
                DB      5,0,5,5,0
                DB      5,0,5,5,0

                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5

                DB      5,5,5,0,5
                DB      5,5,5,0,5
                DB      5,5,5,0,5
                DB      5,0,5,0,5
                DB      5,5,0,5,5

                DB      5,0,5,5,0
                DB      5,0,5,0,5
                DB      5,0,0,5,5
                DB      5,0,5,0,5
                DB      5,0,5,5,0

                DB      5,0,5,5,5
                DB      5,0,5,5,5
                DB      5,0,5,5,5
                DB      5,0,5,5,5
                DB      5,0,0,0,5

                DB      0,5,5,5,0
                DB      0,0,5,0,0
                DB      0,5,0,5,0
                DB      0,5,5,5,0
                DB      0,5,5,5,0

                DB      0,5,5,5,0
                DB      0,0,5,5,0
                DB      0,5,0,5,0
                DB      0,5,5,0,0
                DB      0,5,5,5,0

                DB      5,5,0,0,5
                DB      5,0,5,5,0
                DB      5,0,5,5,0
                DB      5,0,5,5,0
                DB      5,5,0,0,5

                DB      5,0,0,0,5
                DB      5,0,5,5,0
                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,5,5,5

                DB      5,5,0,0,5
                DB      5,0,5,5,0
                DB      5,0,5,5,0
                DB      5,0,5,0,0
                DB      5,5,0,0,0

                DB      0,0,0,5,5
                DB      0,5,5,0,5
                DB      0,0,0,5,5
                DB      0,5,5,0,5
                DB      0,5,5,0,5

                DB      5,0,0,0,0
                DB      0,5,5,5,5
                DB      5,0,0,0,5
                DB      5,5,5,5,0
                DB      0,0,0,0,5

                DB      0,0,0,0,0
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5

                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      5,0,0,0,5

                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      5,0,5,0,5
                DB      5,0,5,0,5
                DB      5,5,0,5,5

                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      0,5,0,5,0
                DB      0,5,0,5,0
                DB      5,0,5,0,5

                DB      0,5,5,5,0
                DB      5,0,5,0,5
                DB      5,5,0,5,5
                DB      5,0,5,0,5
                DB      0,5,5,5,0

                DB      5,0,5,0,5
                DB      5,0,5,0,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5

                DB      0,0,0,0,0
                DB      5,5,5,0,5
                DB      5,5,0,5,5
                DB      5,0,5,5,5
                DB      0,0,0,0,0

                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,0,5,0,5
                DB      5,0,0,0,5
                DB      5,0,5,0,5

                DB      5,0,5,0,5
                DB      5,5,0,5,5
                DB      5,0,5,0,5
                DB      5,0,0,0,5
                DB      5,0,5,0,5

                DB      0,5,5,5,0
                DB      5,0,0,0,5
                DB      0,5,5,5,0
                DB      0,5,5,5,0
                DB      5,0,0,0,5

                DB      5,0,0,0,5
                DB      0,5,5,5,0
                DB      0,5,0,5,0
                DB      0,5,5,5,0
                DB      5,0,0,0,5

                DB      5,5,0,0,5
                DB      5,0,5,0,5
                DB      5,5,5,0,5
                DB      5,5,5,0,5
                DB      5,5,5,0,5

                DB      5,5,0,0,5
                DB      5,0,5,5,0
                DB      5,5,5,0,5
                DB      5,5,0,5,5
                DB      5,0,0,0,0

                DB      5,0,0,5,5
                DB      5,5,5,0,5
                DB      5,5,0,5,5
                DB      5,5,5,0,5
                DB      5,0,0,5,5

                DB      5,0,5,0,5
                DB      5,0,5,0,5
                DB      5,0,0,0,5
                DB      5,5,5,0,5
                DB      5,5,5,0,5

                DB      5,0,0,0,5
                DB      5,0,5,5,5
                DB      5,0,0,5,5
                DB      5,5,5,0,5
                DB      5,0,0,5,5

                DB      5,5,0,0,0
                DB      5,0,5,5,5
                DB      5,0,0,0,5
                DB      5,0,5,5,0
                DB      5,5,0,0,5

                DB      5,0,0,0,5
                DB      5,5,5,0,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5
                DB      5,5,0,5,5

                DB      5,0,0,0,5
                DB      0,5,5,5,0
                DB      5,0,0,0,5
                DB      0,5,5,5,0
                DB      5,0,0,0,5

                DB      5,5,0,0,5
                DB      5,0,5,5,0
                DB      5,5,0,0,0
                DB      5,5,5,5,0
                DB      5,0,0,0,5

                DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,5,5,5,5
                DB      5,0,0,5,5


MESSAGE         DB      "HAPPY NEW YEAR 2001",0
MESSAGE3        DB      "ROBERT",0
MESSAGE4        DB      " 2001 ",0
MAXX            DW      320
MAXY            DW      200
TEXTCOLOR       DB      0XDF
RSEED           DW      0X6B95
SNOW            DW      1
WIND            DW      1
COUNTER         DB      FART
SNODJUP         DW      0
SMALT           DB      0
MAINWIND        DW      3
MAINWIND2       DW      -1
RAKETX          DW      0
RAKETY          DW      0
RAKET           DB      0
RAKETFART       DW      1
RAKETSTORL      DW      10
NEWPAL          DB      0
OLDPAL          DB      0
RESTER          DB      0
RAKETER         DB      0
TIMER           DW      0
