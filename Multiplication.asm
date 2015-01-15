
.MACRO MUL2x2
.DEF dataL  = R4  ; multiplicand low byte
.DEF dataH  = R5  ; multiplicand high byte
.DEF KoeffL = R2  ; multiplier   low byte
.DEF KoeffH = R3  ; multiplier   high byte
.DEF temp   = R16 ; result byte 0 (LSD)
.DEF temp1  = R17 ; result byte 1
.DEF temp2  = R18 ; result byte 2 (MSD)

Mul1616:
CLR temp2
MUL dataL , KoeffL
MOV temp  , R0
MOV temp1 , R1

MUL dataH, KoeffL
ADD temp1, R0
ADC temp2, R1

MUL dataL, KoeffH
ADD temp1, R0
ADC temp2, R1

MUL dataH, KoeffH
ADD temp2, R0
ADC temp3, R1

RET
.ENDM

.MACRO MUL1x2
.DEF dataL  = R4  ; multiplicand low byte
.DEF KoeffL = R2  ; multiplier   low byte
.DEF KoeffH = R3  ; multiplier   high byte
.DEF temp   = R16 ; result byte 0 (LSD)
.DEF temp1  = R17 ; result byte 1
.DEF temp2  = R18 ; result byte 2 (MSD)

Mul816:
CLR temp2
MUL dataL , KoeffL
MOV temp  , R0
MOV temp1 , R1

MUL dataL, KoeffH
ADD temp1, R0
ADC temp2, R1


RET
.ENDM


.MACRO MUL1x1
.DEF dataL  = R4  ; multiplicand low byte
.DEF KoeffL = R2  ; multiplier   low byte
.DEF KoeffH = R3  ; multiplier   high byte
.DEF temp   = R16 ; result byte 0 (LSD)
.DEF temp1  = R17 ; result byte 1

Mul88:
CLR temp2
MUL dataL , KoeffL
MOV temp  , R0
MOV temp1 , R1

RET
.ENDM



