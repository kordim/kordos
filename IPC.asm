; IPC: Send and Receive messages
;
; Sending:
; Get Recipient task Incoming buffer address
; Write Message byte to recipient buffer
; Write Sender task Number to recipient incoming mutex
; * Clear flag 'WaitForInt' in recipient status register
; Set Recipient task, timer = 0


;.MACRO M_SUB_Send ; _POD_ SUB_Send 
SUB_Send:         ; _POD_ SUB_Send: Arguments:  R16=Recipient , R17=Data
                  ; _POD_ SUB_Send: Return: None
                  ; _POD_ SUB_Send: Reserved: ZL, ZH, R18, R0, R1 
                  ; 
                  ; R17 = DATA
PUSH ZL
PUSH ZH
PUSH R18 ; temp register
PUSH R0
PUSH R1

LDI ZL , low(TaskFrame)
LDI ZH , high(TaskFrame)
LDI R18 , FRAMESIZE
MUL R16 , R18            ; RecipientTaskNumber * FRAMESIZE
ADD ZL , R0
ADC ZH , R1

; Shift Address in Z register forward to rcpt mutex.
; And wait until recipient will be ready to receive data

SUBI ZL, low(-1*TaskRecvBufMutexShift)
SBCI ZH, high(-1*TaskRecvBufMutexShift)
LDS R16, currentTaskNumber   ; Set up arguments for IPC_mutexUp
CALL IPC_MutexUp             ; Write Sender id to recipient mutex (mutex address in Z, sender ID in R1
                             ; When recipient is ready, write data to incoming buffer and clear WaitForInt flag 

SUBI ZL, -1
SBCI ZH, 0                       ; Shift Address in Z forward on 1 byte to Recipient Incoming Buffer Address
ST Z, R17               ; TADAAA!!! Store data to buffer!!!

SUBI ZL, low(TaskRecvBufMutexShift+1) ; Shift Address in Z back to Status Register of recipient task
SBCI ZH, high(TaskRecvBufMutexShift+1)
LD R18, Z                 ; Clear WaitForInt recipient flag
CBR R18, taskWaitInt       ; CBR clear byte 
ST Z+, R18               ; Z+ is for Shift address forward to recipient task timer 

; Clear Recipient Timer
LDI       R18 , 0                 ; Clear 4 bytes of recipient timer 
ST        Z+  , R18                
ST        Z+  , R18
ST        Z+  , R18
ST        Z   , R18

POP R1
POP R0
POP R18
POP ZH
POP ZL
;.ENDM



;.MACRO M_SUB_Send

PUSH ZL
PUSH ZH
PUSH R18
PUSH R19
PUSH R0
PUSH R1
; R16 contain data to send
; R17 must contain number of recipient task
; Shift Address in Z register = TaskFrameAddress + (RecipientTaskNum * FRAMESIZE) + TaskRecvBufMutexShift

LDI ZL, low(TaskFrame)
LDI ZH, high(TaskFrame)
LDI R18 , FRAMESIZE
MUL R18, R17 
ADD ZL , R0
ADC ZH , R1

LDI R18 , TaskRecvBufMutexShift 
ADD ZL , R18
CLR R18
ADC ZH, R18


_Send_Load_Mutex:
LD R18, Z  ; Load recipient mutex. for sure if recipient ready to receive data
CP R18 , R17 ; if recipient mutex == recipient , task ready to receive, otherwise, sending is not allowed
BRNE _Send_Wait

ST  Z+, R16 ; Store data and sender task id 
LDS R18 , currentTaskNumber
ST  Z, R18

; Reset recipient task timer for immediate call recipient.
SUBI ZL, TaskRecvBufMutexShift+1 ; shift to recipient task state register address
SBCI ZH, 0

SUBI ZL, low(TaskTimerShift) ; Shift to recipient task timer address
SBCI ZH, high(TaskTimerShift)

LDI R18, 0     ; Clear timer
ST Z+, R18
ST Z+, R18
ST Z+, R18
ST Z+, R18

POP R1
POP R0
POP R19
POP R18
POP ZH
POP ZL
RET

_Send_Wait:
CALL  SUB_SaveContextBySelf
RJMP  TaskBreak              
RJMP  _Send_Load_Mutex  
;.ENDM





; ====================
;   RECEIVE
; ==================== 

SUB_Recv:
; Receive:
; Set Up WaitForInt status register flag
; Break task and take directions to kernel
; When task return from kernel:
;	get sender id from mutex
;	get byte from buffer

; _POD_ SUB_Recv: Arguments: None
; _POD_ SUB_Recv: Return: R16=Sender R17=data
; _POD_ SUB_Recv: Reserved: ZL , ZH , R18 , R19 , R0 , R1
PUSH ZL
PUSH ZH
PUSH R18
PUSH R19
PUSH R0
PUSH R1

; Get task context address
LDI_Z TaskFrame
LDI R18 , FRAMESIZE
LDS R19 , currentTaskNumber
MUL R18, R19
ADD ZL , R0
ADC ZH , R1

; Set TaskRecvBufMutex = 0xFF (MAX) to signal other tasks about ready to read
; Set Wait For Int flag
LD R18 , Z
SBR R18 , taskWaitInt
ST Z , R18

; Take control to kernel
CALL SUB_SaveContextBySelf
RJMP TaskBreak
; Return from kernel by clear Wait4Int flag (unsecure) 

; Read data from buffer
SUBI_Z -1*TaskRecvBufShift
LD R16, Z+   ; mutex value
LD R17, Z   ; data value

POP R1
POP R0
POP R19
POP R18
POP ZH
POP ZL
RET
;.ENDM
