; New sleep call
; Timer procedure takes timer value from stack
; How to call: 
; PUSH R16 ; low byte
; PUSH R17
; PUSH R18
; PUSH R19 ; high byte
; CALL SUB_Sleep
SUB_Sleep: 

BRID
RJMP sleep_interrupt_is_disabled
CLI
STS R16 , tR16
LDI R16, 1
STS R16 , globalInterruptStateOnCall
LDS R16 , tR16
RJMP sleep_start

sleep_interrupt_is_disabled:
	CLI
	STS R16 , tR16
	LDI R16, 0
	STS R16 , globalInterruptStateOnCall
	LDS R16 , tR16

sleep_start:
	STS ZL, tZL
	STS ZL, tZL
	STS R0, tR0
	STS R1, tR1
	STS R16, tR16
	IN R16, SREG
	STS R16, tSREG

	POP ZH
	POP ZL
	
	POP R0 ; high byte
	POP R1
	POP R16
	POP R17 ; low byte

	; Save return address to stack
	PUSH ZL
	PUSH ZH ; адрес возврата сохранен

	; Save registers from RAM to stack
	LDS tZL, ZL
	PUSH ZL
	
	LDS tZH, ZL
	PUSH ZL
	
	LDS tR0 ZL
	PUSH ZL
	
	LDS tR1, ZL
	PUSH ZL
	
	LDS tR16 ZL
	PUSH ZL
	
	LDS tR17, ZL
	PUSH ZL
	
	OUT ZL, tSREG
	PUSH ZL

	; Save timer value to stack
	PUSH R0	; high byte
	PUSH R1
	PUSH R16
	PUSH R17  ; low byte
	
	LDI ZL, low(TaskFrame)
	LDI ZH, high(TaskFrame)

	SUBI ZL, low(-1*TaskTimerShift)
	SUBI ZH, high(-1*TaskTimerShift)

	LDS R16, currentTaskNum
	LDI R17, FRAMESIZE
	MUL R16,R17
	ADD ZL, R0
	ADC ZH, R1

	POP R16
	ST Z+ , R16 ; low byte
	POP R16
	ST Z+ , R16
	POP R16
	ST Z+ , R16
	POP R16
	ST Z+ , R16

	; Take control to core
	
	CALL       SUB_SaveContextBySelf   ; Semaphore reach maximal value, wait until semaphore is down
	CLI
	RJMP       TaskBreak	              ; 
	

	;Restore Task Context	
	POP R16 
	IN SREG, R16
	POP R17	
	POP R16
	POP R1
	POP R0
	POP ZH

	LDS globalInterruptStateOnCall, ZL
	TST ZL
	BRNE sleep_return_and_restore_interrupts
	POP ZL
	RET

sleep_return_and_restore_interrupts:
	POP ZL
	RETI
	; #######################################################