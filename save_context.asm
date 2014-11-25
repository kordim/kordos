.MACRO SaveContext
CLI
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10
PUSH R11
PUSH R12
PUSH R13
PUSH R14
PUSH R15
PUSH R16
PUSH R17
PUSH R18
PUSH R19
PUSH R20
PUSH R21
PUSH R22
PUSH R23
PUSH R24
PUSH R25
PUSH R26
PUSH R27
PUSH R28
PUSH R29
PUSH R30
PUSH R31
MOV SREG, R16
PUSH R16

; Загружаем номер текущей задачи  и вычисляем адрес ячейки для сохранения адреса верхушки стека
LDI XL,  low( currentTaskNumber )
LDI XH, high( currentTastNumber )
LD  R16, X  ; в R16 лежит номер текущей задачи 

; Вычисляем смещение
LDI XL ,  low( taskStackHeader )
LDI XH , high( taskStackHeader )
ADD XL, R16
LDI R16, 0
ADC XH, R16   ;  Теперь Z содержит адрес куда можно складывать верхушку стека


; Сохраняем адрес верхушки стека
MOV R16, SPL
MOV R17, SPH

ST X+, R16
ST X, R17
SEI
.ENDM

.MACRO LoadContext

POP R16
MOV SREG, R16
POP R31
POP R30
POP R29
POP R28
POP R27
POP R26
POP R25
POP R24
POP R23
POP R22
POP R21
POP R20
POP R19
POP R18
POP R17
POP R16
POP R15
POP R14
POP R13
POP R12
POP R11
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4
POP R3
POP R3
POP R1
POP R0
RETI
.ENDM


