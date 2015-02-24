; IPC: Send and Receive messages
;
; Sending:
; Get Recipient task Incoming buffer address
; Write Message byte to recipient buffer
; Write Sender task Number to recipient incoming mutex
; * Clear flag 'WaitForInt' in recipient status register
; Set Recipient task, timer = 0


; Receive:
; Set Up WaitForInt status register flag
; Break task and take directions to kernel

; When task return from kernel.
; get sender id from mutex
; get byte from buffer

.MACRO SUB_Send ; _POD_ SUB_Send 
                ; 
                ; R16 = RECIPIENT 
                ; R17 = DATA
PUSH ZL
PUSH ZH
PUSH R18 ; temp register

LDI_Z TaskFrame
LDI R18 , FRAMESIZE
MUL R16 , R18            ; RecipientTaskNumber * FRAMESIZE
ADD ZL  , R0
ADC ZH  , R1

; Shift Address in Z register forward to rcpt mutex.
; And wait until recipient will be ready to receive data
SUBI_Z    -TaskRecvBufMutexShift  
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

POP R18
POP ZH
POP ZL
.ENDM


