.MACRO TimerService
; R9  = Task State Register
; R10 = taskNumber counter ( for cycle ) 
; X   = TaskFrameAddr
; R16 = tmp
; R11 = timer byte 1 (low)
; R12 = timer byte 2
; R13 = timer byte 3
; R14 = timer byte 4 (high)
TS_Start:
    
    CALL SUB_SaveContext_TS 
    
    LDI    R16, MAXPROCNUM
    MOV    R16, R10                         ; Load MAXPROCNUM for cycle         
    
    LDI_X  TaskFrame              
    
    LDI    R16, (MAXPROCNUM-1)*FRAMESIZE 
    ADDW   R16, XL , XH                     ; shift to last task frame

TS_processTask:
    DEC    R10
    BRCS   TS_END                            ; Когда прощёлкали все таймеры выходим из таймерной службы
    
    LD     R9, X                      ; Load TaskState register to R9
    
    SBRC   R9, taskWaitInt            ; task wait interrupt, goto process next task timer
    RJMP   TS_nextTask
    
    SBRC   R9       , taskTimerIsZero              ; timer already is zero, goto process next task timer
    RJMP   TS_nextTask
    
    SUBI_X  -1*TaskTimerShift                        ; shift Address in X reg to TaskTimer ( 1 byte forward )

    
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

    SUBI_X TaskTimerShift
    
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
    SUBI_X  FRAMESIZE;
    RJMP TS_processTask

TS_END:
    NOP

.ENDM

