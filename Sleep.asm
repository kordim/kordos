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

.MACRO sys_sleep
SUB_Sleep: 
    ; _POD_  SUB_Sleep: Arguments: taskNumber=R16, timerByte1(Low)=R17, timerByte2=R18, timerByte3=R19, timerByte4(Low)=R20 
    ; _POD_  SUB_Sleep: Reserved: ZL, ZH
    
    PUSH ZL
    PUSH ZH

    CALL SUB_getTaskAddr   ; Call SUB_getTaskAddr , argument in R16 , results in ZL:ZH
    SUBI_Z -1*TaskTimerShift ; shift address to high byte of timer
    ST Z+ , R17
    ST Z+ , R18
    ST Z+ , R19
    ST Z+ , R20

    ; Take control to core
    CALL       SUB_SaveContextBySelf        ; Semaphore reach maximal value, wait until semaphore is down
    RJMP       TaskBreak	               ; 

    ; Return From Core and continue.

    POP ZH
    POP ZL
    RET
.ENDM

; Get Task Frame Address to Z register
; ====================================
;
; Usage example:
;
; PUSH R16
; LDI R16 , 5  
; CALL SUB_getTaskAddr

.MACRO getTaskAddr
SUB_getTaskAddr: 
    ; _POD_ SUB_getTaskAddr: Argument: taskNumber = R16.
    ; _POD_ SUB_getTaskAddr: Return:   Address    = ZL:ZH
    ; _POD_ SUB_getTaskAddr: Reserved: R0, R1, R17

   PUSH R0
   PUSH R1
   PUSH R17
   
   LDI ZL  , low(TaskFrame)
   LDI ZH  , high(TaskFrame)
   LDI R17 , FRAMESIZE
   MUL R16 , R15
   ADD ZL  , R0
   ADC ZH  , R1
   
   POP R17
   POP R1
   POP R0
   RET

.ENDM























