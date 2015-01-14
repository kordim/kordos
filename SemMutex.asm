; Мьютексы могу принимать любое значение. 0 - значит он опущен, >0 поднят
.MACRO CALL_MutexUp   
    PUSH ZL
    PUSH ZH
    PUSH R16
    
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    
    LDI  R16, @1
    CALL IPC_MutexUp
    
    POP R16
    POP  ZH
    POP  ZL
.ENDM

.MACRO CALL_MutexDown
    PUSH ZL
    PUSH ZH
    PUSH R16
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    LDI  R16, @1
    CALL IPC_MutexDown
    POP R16
    POP  ZH
    POP  ZL
.ENDM

; Preconditions:
; Mutex address in Z register
; Mutex value to set in register R16

.MACRO IPC_MutexUp
    .DEF  temp  = R17
    .DEF  value = R16
    PUSH  temp
    LD    temp , Z           ; Загрузили значение семафора

IPC_MutexCheckUp:
    CPI   temp , 0           ; Проверили опущен ли флаг
    
    BREQ  IPC_MutexSet       ; Если семафор опущен то взводим его
    RJMP  TaskBreak          ; Если семафор поднят то ждём когда он опустится, отдаём управление ядру
    RJMP  IPC_MutexCheckUp   ; После возврата из ядра идём опять в проверку семафора

IPC_MutexSet:
    ST    Z  , value
    POP   temp
    RET
    .UNDEF temp
    .UNDEF value
.ENDM


.MACRO IPC_MutexDown
    .DEF  temp = R17
    PUSH temp

IPC_MutexCheckDown:
    LD    temp , Z          ; Загрузили значение семафора
    CPI   temp , 0          ; Проверили взведен ли флаг
    
    BRNE  IPC_MutexClear       ; Если семафор поднят то опускаем флаг
    RJMP  IPC_MutexDown_Ret    ; Если семафор опущен то возврат

IPC_MutexClear:
    LDI   temp , 0
    ST    Z  , temp

IPC_MutexDown_Ret:
    POP   temp
    RET
    .UNDEF temp
.ENDM



                
