; System call Sleep
; =================
;
; SUB_Sleep call example:
; LDS R16 , currentTaskNum
; LDI R17 , 100
; LDI R18 , 0
; LDI R19 , 0
; LDI R20 , 0
; CALL SUB_Sleep
SUB_Sleep: 
    ; _POD_  SUB_Sleep: Arguments: taskNumber=R16, timerByte1(Low)=R17, timerByte2=R18, timerByte3=R19, timerByte4(Low)=R20 
    ; _POD_  SUB_Sleep: Reserved: ZL, ZH , R0 , R1 (Stack 4 bytes )
    
    PUSH ZL
    PUSH ZH
    PUSH R0
    PUSH R1

    LDI ZL  , low(TaskFrame)  ; Вычисляем адрес таймера текущей задачи и смещаемся на него
    LDI ZH  , high(TaskFrame)
    MOV R15 , R16
    LDI R16 , FRAMESIZE
    MUL R15 , R16
    ADD ZL , R0
    ADC ZH , R1
    SUBI ZL, low(-1*TaskTimerShift)
    SUBI ZH, high(-1*TaskTimerShift)
    
    ST Z+ , R17
    ST Z+ , R18
    ST Z+ , R19
    ST Z+ , R20

    ; Take control to core
    CALL       SUB_SaveContextBySelf   ; Semaphore reach maximal value, wait until semaphore is down
    RJMP       TaskBreak	              ; 

    ; Return From Core and continue.

    POP R1
    POP R0
    POP ZH
    POP ZL
    RET

