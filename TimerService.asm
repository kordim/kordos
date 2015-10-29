;.MACR TimerService
; Таймерная служба. 
; Зло и тупо уменьшает таймеры каждой задачи.
; 1) Когда таймер дощёлкал до нуля то взводим флаг tasktimerIsZero, 
;    он нужен для упрощения проверки таймена на 0
;    проверять на 0 4 байта долго, а одит бит проверить быстро
; 2) Если задача ждёт прерывание ( взведён флаг taskWaitInt ), 
;    то щёлкать таймером не нужно, пусть себе ждёт спокойно
; 3) Если задача уже выполняется, (флаг taskRun), то тоже ничего не делаем


; Какие регистры используются и для чего:
; R20  = Task State Register
; R10 = taskNumber counter ( for cycle ) 
; X   = TaskFrameAddr
; R16 = tmp 
; R17 = tmp
; R18 = tmp
; R19 = tmp

; R11 = timer byte 1 (low)
; R12 = timer byte 2
; R13 = timer byte 3
; R14 = timer byte 4 (high)
TS_Start:
    
    NOP
	NOP
	NOP
	CALL SUB_SaveContext_TS ; Сюда попадаем по прерыванию таймера. сохраняем состояние задачи или состояние ядра
							; Сохранение стека производится подпрограмме SUB_SaveContext_TS
                            ; 2DO: SUB_SaveContext_TS можем попасть сюда из любой части ОС не только из задачи
                            ; Что именно нужно сохранять узнаём из флага contextType
    
    ;RET
    ; Load MAXPROCNUM for cycle         
    LDI    R16, MAXPROCNUM
    MOV    R10, R16
    
    ; Set address pointer to last task
    LDI_X  TaskFrame              
    LDI    R16, MAXPROCNUM-1 
    LDI    R17, FRAMESIZE
    MUL    R16, R17
    ADD    XL, R0
    ADC    XH, R1
    
TS_processTask:
    DEC R10
    BRBS 2, TS_END ; Когда прощёлкали все таймеры выходим из таймерной службы
    
    LD R20, X  ; Load TaskState register to R20
    
    SBRC R20, taskWaitInt  ; В регистре состояния задачи взведен бит taskWaitInt
	RJMP TS_nextTask      ;поэтому не обрабатываем таймеры этой задачи а сразу переходим к следующей
							
    SBRC R20, taskTimerIsZero ; В регистре состояния задачи взведен бит taskTimerIsZero (таймер уже дотикал до нуля)
    RJMP TS_nextTask		 ; поэтому переходим к следующей задаче
    
    SUBI XL, low(-1*TaskTimerShift)
    SBCI XH, high(-1*TaskTimerShift) ; shift Address in X reg to TaskTimer ( 1 byte forward )
    
	LD R16, X+  ; low byte  ; Load Task timer bytes
    LD R17, X+
    LD R18, X+
    LD R19, X+ ; high byte
    
    CLC
    SUBI R16 , 1  ;low byte ; Decrease timer 
    SBCI R17 , 0
    SBCI R18 , 0
    SUBI R19 , 0
    
    ST   -X , R19  
	ST   -X , R18
	ST   -X , R17
	ST   -X , R16
	; ====================================================================
		

	; ====================================================================

    SUBI XL   , low(TaskTimerShift); shift Address in X reg to TaskStateRegister ( 1 byte backward )
    SBCI XH   , high(TaskTimerShift)
 
    OR   R16 , R17                                ; Check Timer Value
    OR   R16 , R18
    OR   R16 , R19
    
    CPI  R16 , 0                                  ; Timer == 0 ?
    BREQ TS_timer_eq_zero                         ; timer == 0 : Set bit register "taskTimerIsZero" for task     
    RJMP TS_timer_ne_zero                         ; timer != 0 : Clear bit register "taskTimerIsZero" for task

TS_timer_ne_zero:
	CBR  R20 , 1<<taskTimerIsZero
    RJMP TS_nextTask

TS_timer_eq_zero:
	SBR  R20 , 1<<taskTimerIsZero
    RJMP TS_nextTask

TS_nextTask:
    ST   X  , R20 
    SUBI XL , low(FRAMESIZE)
    SBCI XH , high(FRAMESIZE)
    RJMP TS_processTask

TS_END:
    NOP

;.ENDM

; Set current task timer.
; сделать это как вызываемую процедуру? жалко памяти под стек
; сделать как макрос? ну можно чо. займет больше места в памяти прорамм но оперативу сэкономнлю
; реализовывать каждый раз на месте? мало памяти и мало места, но геморно

