
.MACRO CALL_SemUp   
    CLI
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemByte_Up
    POP  ZH
    POP  ZL
    SEI
.ENDM

.MACRO CALL_SemDown
    CLI
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemDown
    POP  ZH
    POP  ZL
    SEI
.ENDM


.MACRO IPC_semByte_Up
.DEF temp = R16
IPC_semByte_Up:                    
    CLI
    PUSH temp

IPC_semByte_Up_check:
    LD    temp , Z                 ; Загрузили значение семафора
    CPI   temp , 0                 ; Проверили значение семафора 0 - опущен 1- взведён
    BREQ  IPC_semByte_Up_set       ; Если семафор опущен то взводим его
    RJMP  TaskBreak                ; Если семафор поднят то ждём когда он опустится, отдаём управление ядру
    RJMP  IPC_semByte_Up_check     ; После возврата из ядра идём опять в проверку семафора

IPC_semByte_Up_set:
    SBR   temp                      
    ST    Z  , temp
    
    POP temp
    RETI
.UNDEF temp
.ENDM


.MACRO IPC_semByte_Down
.DEF temp = R16
IPC_semByte_Down:                    
    CLI
    PUSH temp

IPC_semByte_Down_check:
    LD    temp , Z                  ; Загрузили значение семафора
    CPI   temp , 0                  ; Проверили значение семафора 0 - опущен 1- взведён
    BRNE  IPC_semByte_Down_set      ; Если семафор поднят то опускаем его
    RJMP  IPC_semByte_Down_return   ; Если семафор уже опущен, то возврат

IPC_semByte_Down_set:
    CLR   temp                      
    ST    Z  , temp
    
IPC_semByte_Down_return:
    POP temp
    RETI
.UNDEF temp
.ENDM


