; System call Sleep
; =================
;
; SUB_Sleep call example:
; LDI R11 , 100
; LDI R12 , 0
; LDI R13 , 0
; LDI R14 , 0
; LDS R16 , currentTaskNum
; CALL SUB_Sleep

.MACRO sys_sleep
SUB_Sleep: 
    ; _POD_  SUB_Sleep: Arguments: taskNumber=R16, timerByte1(Low)=R11, timerByte2=R12, timerByte3=R13, timerByte4(Low)=R14 
    ; _POD_  SUB_Sleep: Reserved: ZL, ZH
    
    PUSH ZL
    PUSH ZH

    CALL SUB_getTaskAddr   ; Call SUB_getTaskAddr , argument in R16 , results in ZL:ZH
    SUBI_Z -1*TaskTimerShift ; shift address to high byte of timer
    ST Z+ , R11
    ST Z+ , R12
    ST Z+ , R13
    ST Z+ , R14


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
    ; _POD_ SUB_getTaskAddr: Reserved: R0, R1, R15

   PUSH R0
   PUSH R1
   PUSH R15
   
   LDI ZL  , low(TaskFrame)
   LDI ZH  , high(TaskFrame)
   LDI R15 , FRAMESIZE
   MUL R16 , R15
   ADD ZL  , R0
   ADC ZH  , R1
   
   POP R15
   POP R1
   POP R0
   RET

.ENDM























