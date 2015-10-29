; Mutexes: Mutex can be in two states. mutex == 0 : down ; mutex != 0 : up
; there is two call types for mutexes
; 1. Set constant to mutex.
; 2. Set mutex value from R16 register
; ========================================================================

.MACRO SUB_MutexUp_Const       ; Set Constant value to mutex 
    PUSH  ZL
    PUSH  ZH
    PUSH  R16
    
    LDI_Z       @0
    LDI   R16 , @1
    CALL  IPC_MutexUp
    
    POP   R16
    POP   ZH
    POP   ZL
.ENDM

.MACRO SUB_MutexUp       ; Set R16 value to mutex 
    PUSH ZL
    PUSH ZH
    
    LDI_Z @0
    CALL IPC_MutexUp
    
    POP  ZH
    POP  ZL
.ENDM

IPC_MutexUp:          ; _POD_ IPC_MutexUp SetUp Mutex Value. Value to set taken from R16
    PUSH  R17
    LD    R17 , Z           ; Загрузили значение семафора

IPC_MutexCheckUp:
    CPI   R17 , 0           ; Проверили опущен ли флаг

    BREQ  IPC_MutexSet       ; Если семафор опущен то взводим его
    CALL  SUB_SaveContextBySelf
    RJMP  TaskBreak          ; Если семафор поднят то ждём когда он опустится, отдаём управление ядру
    RJMP  IPC_MutexCheckUp   ; После возврата из ядра идём опять в проверку семафора

IPC_MutexSet:
    ST    Z  , R16
    POP   R17
    RET


; Dowm Mutex
; ==========
;
.MACRO SUB_MutexDown
    PUSH  ZL
    PUSH  ZH
    PUSH  R16

    LDI_Z @0
    LDI   R16 , @1
    CALL  IPC_MutexDown

    POP   R16
    POP   ZH
    POP   ZL
.ENDM

.MACRO IPC_MutexDown
    PUSH R17

    LDI   R17 , 0
    ST    Z   , R17

    POP   R17
    RET
.ENDM
        
