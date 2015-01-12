.MACRO SemCounter_Up_byAddr
    ; Not finished yet
    PUSH ZL
    PUSH ZH


    POP ZH
    POP ZL
.ENDM

.MACRO IPC_semCounter_Up			  ; semaphore with counter. semaphore address  in Z register  
    .DEF sem_limit = R17
    .DEF sem_value = R16
    CLI
    PUSH sem_value
    PUSH sem_limit
    LD   sem_limit , Z+		      ; максимальное значение семафора

IPC_semup_load_and_test:
    LD   sem_value , Z	          ; текущее значение семафора   
    CP   sem_value , sem_limit
    
    BRNE IPC_semup_set            ; Если значение < макс. то увеличиваем счётчик семафора
    RJMP TaskBreak				  ; Если значение == макс. то переходим к ожиданию. отдаём управление в ядро
    RJMP IPC_semup_load_and_test  ; После возврата из ядра идём опять в проверку семафора

    IPC_semup_set:
    INC  sem_value                ; Если семафор < макс. ( не вижу причин для его превышения) то инкрементим его и RETI
    ST   Z  , sem_value           ; сохраняем значение семафора обратно в память
    
IPC_SemUpReti:    
    POP  sem_limit
    POP  sem_value
    RETI
    .UNDEF sem_limit
    .UNDEF sem_value
.ENDM

.MACRO IPC_semCounter_Down
    .DEF sem_value = R16
    
    CLI
    PUSH sem_value
    LD   sem_value , Z+			; не используется при опускании семафора, но загрузить байт быстрее чем сдвинуть адрес
    LD   sem_value , Z			 ; текущее значение семафора   
    CPI  sem_value , 0
    BREQ IPC_semDown_reti    ; Если значение == 0 то просто выходим
    DEC  sem_value                 ; Уменьшаем счётчик семафора
    ST   Z  , sem_value            ; сохраняем значение семафора обратно в память
    
IPC_semDown_reti:    
    POP  sem_value
    RETI
    
    .UNDEF sem_value
.ENDM



