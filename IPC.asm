; IPC: Send and Receive messages
;
; Sending:
; Get Recipient task Incoming buffer address
; Write Message byte to recipient buffer
; Write Sender task Number to recipient incoming mutex
; * Clear flag 'WaitForInt' in recipient status register
; Set Recipient task, timer = 0


.MACRO M_SUB_Send ; _POD_ SUB_Send 
SUB_Send:         ; _POD_ SUB_Send: Arguments:  R16=Recipient , R17=Data
                  ; _POD_ SUB_Send: Return: None
                  ; _POD_ SUB_Send: Reserved: ZL, ZH, R18, R0, R1 
                  ; 
                  ; R17 = DATA
PUSH ZL
PUSH ZH
PUSH R18 ; temp register
PUSH R0
PISH R1

LDI_Z TaskFrame
LDI R18 , FRAMESIZE
MUL R16 , R18            ; RecipientTaskNumber * FRAMESIZE
ADD ZL  , R0
ADC ZH  , R1

; Shift Address in Z register forward to rcpt mutex.
; And wait until recipient will be ready to receive data
SUBI_Z    -1*TaskRecvBufMutexShift  
;MOV       R16, R18                ; Copy R16 to R18. R16 is an argument for  IPC_MutexUp
LDS       R16 currentTaskNumber   ; Set up arguments for IPC_mutexUp
CALL      IPC_MutexUp             ; Write Sender id to recipient mutex (mutex address in Z, sender ID in R1
                                  ; When recipient is ready, write data to incoming buffer and clear WaitForInt flag 
;MOV       R18 , R16               ; Restore RecipientTaskNumber in R16

SUBI_Z   -1                       ; Shift Address in Z forward on 1 byte to Recipient Incoming Buffer Address
ST        Z   , R17               ; TADAAA!!! Store data to buffer!!!

SUBI_Z    TaskRecvBufMutexShift+1 ; Shift Address in Z back to Status Register of recipient task
LD        R18 , Z                 ; Clear WaitForInt recipient flag
CBR       R18 , taskWaitInt       ; CBR clear byte 
ST        Z+  , R18               ; Z+ is for Shift address forward to recipient task timer 

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
.ENDM



; Receive:
; Set Up WaitForInt status register flag
; Break task and take directions to kernel

; When task return from kernel.
; get sender id from mutex
; get byte from buffer


.MACRO M_SUB_Recv
SUB_Recv:
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


; Set Wait For Int flag
LD R18 , Z
SBR R18 , taskWaitInt
ST Z , R18

; Take control to kernel
CALL SUB_SaveContextBySelf
RJMP TaskBreak
; Return from kernel

; Read data from buffer
SUBI_Z -1*TaskRecvBufShift
LD Z+ , R16    ; mutex value
LD Z  , R17    ; data value

POP R1
POP R0
POP R19
POP R18
POP ZH
POP ZL

.ENDM
