.MACRO TimerService
; Таймерная служба. 
; Зло и тупо уменьшает таймеры каждой задачи.
; 1) Когда таймер дощёлкал до нуля то взводим флаг tasktimerIsZero, 
;    он нужен для упрощения проверки таймена на 0
;    проверять на 0 4 байта долго, а одит бит проверить быстро
; 2) Если задача ждёт прерывание ( взведён флаг taskWaitInt ), 
;    то щёлкать таймером не нужно, пусть себе ждёт спокойно
; 3) Если задача уже выполняется, (флаг taskRun), то тоже ничего не делаем


; Какие регистры используются и для чего:
; R9  = Task State Register
; R10 = taskNumber counter ( for cycle ) 
; X   = TaskFrameAddr
; R16 = tmp
; R11 = timer byte 1 (low)
; R12 = timer byte 2
; R13 = timer byte 3
; R14 = timer byte 4 (high)
TS_Start:
    
    CALL SUB_SaveContext_TS ; Сюда попадаем по прерыванию ( сохраняем состояние задачи)
                            ; 2DO: SUB_SaveContext_TS можем попасть сюда из любой части ОС не только из задачи
                            ; 2DO: а изслужбы прерываний итп. нужно предусмотреть защиту от сбоя стека 
                            ; 2DO: (самое простое запрещать прерывания во время выполнения контекста ОС)
                            ; 2DO: прерывания доступны только в контексте задач
                            ; 2DO: или можно добавить какой нибудь флаг и дрочить на него
                            ; 2DO:
    
    
    ; Load MAXPROCNUM for cycle         
    LDI    R16, MAXPROCNUM
    MOV    R16, R10
    
    
    ; Set address pointer to last task
    LDI_X  TaskFrame              
    LDI    R16, (MAXPROCNUM-1)*FRAMESIZE 
    ADD    XL, R16
    SBRC   SREG , 0
    INC    XH
    
TS_processTask:
    DEC    R10
    BRCS   TS_END ; Когда прощёлкали все таймеры выходим из таймерной службы
    
    LD     R9, X  ; Load TaskState register to R9
    
    SBRC   R9, taskWaitInt            ; task wait interrupt, goto process next task timer
    RJMP   TS_nextTask
    
    SBRC   R9, taskTimerIsZero              ; timer already is zero, goto process next task timer
    RJMP   TS_nextTask
    
    SUBI XL, low(-1*TaskTimerShift)
    SBCI XH, high(-1*TaskTimerShift) ; shift Address in X reg to TaskTimer ( 1 byte forward )
    

    
    LD R11, X+                                     ; Load Task timer bytes
    LD R12, X+
    LD R13, X+
    LD R14, X+
    
    CLC
    SUBI R11 , 1                                   ; Decrease timer 
    SBCI R12 , 0
    SBCI R13 , 0
    SUBI R14 , 0
    
    ST   -X , R14
    ST   -X , R13
    ST   -X , R12
    ST   -X , R11  

    SUBI XL   , low(TaskTimerShift)
    SBCI XH   , high(TaskTimerShift)
 
    MOV  R16 , R11                                ; Check Timer Value
    OR   R16 , R12
    OR   R16 , R13
    OR   R16 , R14
    
    CPI  R16 , 0                                  ; Timer == 0 ?
    BREQ TS_timer_eq_zero                         ; timer == 0 : Set bit register "taskTimerIsZero" for task     
    RJMP TS_timer_ne_zero                         ; timer != 0 : Clear bit register "taskTimerIsZero" for task

TS_timer_ne_zero:
    CBR  R9 , taskTimerIsZero
    RJMP TS_nextTask

TS_timer_eq_zero:
    SBR  R9 , taskTimerIsZero
    RJMP TS_nextTask

TS_nextTask:
    ST   X  , R9 
    SUBI XL , low(FRAMESIZE)
    SBCI XH , high(FRAMESIZE)
    RJMP TS_processTask

TS_END:
    NOP

.ENDM

