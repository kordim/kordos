.MACRO CALL_MutexUp   
    CLI
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_MutexUp
    POP  ZH
    POP  ZL
    SEI
.ENDM

.MACRO CALL_MutexDown
    CLI
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_MutexDown
    POP  ZH
    POP  ZL
    SEI
.ENDM

; Preconditions:
; Mutex address in Z register
; Mutex value to set in register R16

.MACRO IPC_MutexUp
    .DEF  temp = R17
    CLI
    PUSH  temp
    LD    temp , Z           ; Загрузили значение семафора

IPC_MutexCheckUp:
    CPI   temp , 0           ; Проверили опущен ли флаг
    
    BREQ  IPC_MutexSet       ; Если семафор опущен то взводим его
    RJMP  TaskBreak          ; Если семафор поднят то ждём когда он опустится, отдаём управление ядру
    RJMP  IPC_MutexCheckUp   ; После возврата из ядра идём опять в проверку семафора

IPC_MutexSet:
    LDI   temp , 1
    ST    Z  , temp
    POP   temp
    RETI
    .UNDEF temp
.ENDM


.MACRO IPC_MutexDown
    .DEF  temp = R17
    CLI
    PUSH temp

IPC_MutexCheckDown:
    LD    temp , Z          ; Загрузили значение семафора
    CPI   temp , 1          ; Проверили взведен ли флаг
    
    BREQ  IPC_MutexClear       ; Если семафор поднят то опускаем флаг
    RJMP  IPC_MutexDown_Ret    ; Если семафор опущен то возврат

IPC_MutexClear:
    LDI   temp , 0
    ST    Z  , temp

IPC_MutexDown_Ret:
    POP   temp
    RETI
    .UNDEF temp
.ENDM



                
