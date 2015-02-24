
.MACRO WaitForInterrupt
PUSH ZL
PUSH ZH
PUSH R16  ; tmp 
PUSH R17  ; currentTaskNum
RUSH R18  ; Number of Interrupt
;===========
    LDI R18 , @0 ; Load interrupt number (code) to R16
    LDS R17 , currentTaskNumber
    CALL SUB_WainForInt
;===========
POP R18
POP R17
POP R16
POP ZH
POP ZL
.ENDM


SUB_WainForInt:
; Get Task State Register Address
; Set "WaitForInt" flag in "Task State Register"
LDI_Z     TaskFrame
LDI R16 , FRAMESIZE
MUL R17 , R16 ; TaskNum * FRAMESIZE
ADD ZL  , R0    
ADC ZH  , R1

LD  R16 , Z              ; Load Task State reister
SBR R16 , taskWaitInt    ; Set "WainForInt" flag
;ORI R16 , 1<<taskWaitInt ; Set "WainForInt" flag
ST  Z   , R16            ; Save Task register

; Add Task request to queue
; Get Semaphore value
; Get queue tail address
; store Task Number
; store interrupt number
; increase semaphore number

SUB_GetSemValue IntPoolCounter
LDI_Z IntPoolAddr
LSL R16
ADD_Z_R16
LSR R16
ST  Z+ , R17
ST  Z  , R18
SUB_SemUp IntPoolCounter
RETI
