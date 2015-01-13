.MACRO CALL_SemUp   
    CLI
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemUp
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

.MACRO IPC_SemUp			  ; semaphore with counter. semaphore address  in Z register  
    .DEF limit = R17
    .DEF value = R16
    CLI
    PUSH value
    PUSH limit
    LD   limit , Z+		      ; максимальное значение семафора
IPC_SemUpCheck:
    LD   value , Z	          ; текущее значение семафора   
    CP   value , limit
    BRNE IPC_SemInc      ; Если значение < макс. то увеличиваем счётчик семафора
    RJMP TaskBreak	     ; Если значение == макс. то переходим к ожиданию. отдаём управление в ядро
    RJMP IPC_SemUpCheck  ; После возврата из ядра идём опять в проверку семафора
IPC_SemInc:
    INC  value                ; Если семафор < макс. ( не вижу причин для его превышения) то инкрементим его и RETI
    ST   Z  , value           ; сохраняем значение семафора обратно в память
    POP  limit
    POP  value
    RETI
    .UNDEF limit
    .UNDEF value
.ENDM

.MACRO IPC_SemDown
    .DEF value = R16
    CLI
    PUSH value
    LD   value , Z+	 	 ; не используется при опускании семафора, но загрузить байт быстрее чем сдвинуть адрес
    LD   value , Z		 ; текущее значение семафора   
    CPI  value , 0
    BREQ IPC_SemDownRet   ; Если значение == 0 то просто выходим
    DEC  value            ; Уменьшаем счётчик семафора
    ST   Z  , value       ; сохраняем значение семафора обратно в память
IPC_SemDownRet:    
    POP  value
    RETI
    .UNDEF value
.ENDM



