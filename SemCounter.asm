.MACRO CALL_SemUp   
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemUp
    POP  ZH
    POP  ZL
.ENDM

.MACRO CALL_SemDown
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemDown
    POP  ZH
    POP  ZL
.ENDM

.MACRO IPC_SemUp			     ; semaphore with counter. semaphore address  in Z register  
    .DEF limit = R17
    .DEF value = R16
    PUSH value                     ; сохранили регистры R16 и R17
    PUSH limit

    LD   limit , Z+		          ; pfuhepbkb максимальное значение семафора
IPC_SemUpCheck:
    LD   value , Z	               ; текущее значение семафора   
    CP   value , limit             ; Сравнивает текужее значение и максимальное
    BRNE IPC_SemInc                ; Если значение < макс. то увеличиваем счётчик семафора
    CALL SaveContextBySelf
    RJMP TaskBreak	               ; Если значение == макс. то переходим к ожиданию. отдаём управление в ядро
    RJMP IPC_SemUpCheck            ; После возврата из ядра идём опять в проверку семафора
IPC_SemInc:
    INC  value                     ; Если семафор < макс. ( не вижу причин для его превышения) то инкрементим его и RETI
    ST   Z  , value                ; сохраняем значение семафора обратно в память
    POP  limit
    POP  value
    RET
    .UNDEF limit
    .UNDEF value
.ENDM

.MACRO IPC_SemDown
    .DEF value = R16
    PUSH value            ; сохраняем R16
    LD   value , Z+	 	 ; не используется при опускании семафора, но загрузить байт быстрее чем сдвинуть адрес
    LD   value , Z		 ; текущее значение семафора   
    CPI  value , 0
    BREQ IPC_SemDownRet   ; Если значение == 0 то просто выходим
    DEC  value            ; Уменьшаем счётчик семафора
    ST   Z  , value       ; сохраняем значение семафора обратно в память
IPC_SemDownRet:    
    POP  value
    RET
    .UNDEF value
.ENDM

; ============================

.MACRO CALL_SemGetValue  ; _POD_ Result stored in R16
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemGetValue
    POP  ZH
    POP  ZL
.ENDM

.MACRO IPC_SemGetValue   ; _POD_ Return Semaphore current value
    .DEF value = R16
    LD   value , Z+	 	 ; не используется при опускании семафора, но загрузить байт быстрее чем сдвинуть адрес
    LD   value , Z		 ; текущее значение семафора   
    RET
    .UNDEF value
.ENDM

; ============================
.MACRO CALL_SemGetMax    ; _POD_ Result stored in R16
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemGetMax
    POP  ZH
    POP  ZL
.ENDM

.MACRO IPC_SemGetMax      ; _POD_ Return semaphore limit value
    .DEF value = R16
    LD   value , Z+	 	 ; не используется при опускании семафора, но загрузить байт быстрее чем сдвинуть адрес
    RET
    .UNDEF value
.ENDM
.

