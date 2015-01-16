; =========================================
;
; MACRO for saving task context from kernel 
;
; =========================================
.MACRO SaveContextIntMacro
	SaveContextByInterrupt:
	STS tmpR16 , R16 ; Расчищаем себе пару регистров для работы
	STS tmpR17 , R17
	
	STS tmpR18 , R18 ; Расчищаем себе пару регистров для работы
	STS tmpR19 , R19
	
	POP R18
	POP R19
	STS tmpReturnCall1 , R18
	STS tmpReturnCall2 , R19
	
	POP R16             ; Кладём адрес возврата во временную ячейку
	POP R17
	STS tmpReturnToTask1 , R16  
	STS tmpReturnToTask2 , R17
	
	PUSH R17            ; Пихаем адрес возврата обратно в стек
	PUSH R16
	
	LDS R16 , tmpR16    ; Восстанавливаем регистры R16 R17 и  сохраняем регистры в стек задачи
	LDS R17 , tmpR17
	LDS R18 , tmpR18
	LDS R19 , tmpR19
	
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	PUSH R21
	PUSH R22
	PUSH R23
	PUSH R24
	PUSH R25
	PUSH R26
	PUSH R27
	PUSH R28
	PUSH R29
	PUSH R30
	PUSH R31
	MOV SREG, R16
	PUSH R16
	
	; Загружаем номер текущей задачи  и вычисляем адрес ячейки для сохранения адреса верхушки стека
	LDS R18 , currentTaskNumber
	LDI R19 , FRAMESIZE
	LDS ZL  , low(TaskFrame) 
	LDS ZH  , high(TaskFrame)
	MUL R18 , R19
	
	ADD ZL  , R0
	ADC ZH  , R1 ; прыгнули на начало контекста задачи
	
	SUBI ZL , low(-5)
	SBCI ZH , high(-5) ; прыгнули на адрес для сохранения верхушки стека
	
	IN R16 , SPL        ; Сохраняем адрес верхушки стека во временную ячейку
	IN R17 , SPH
	ST Z+ , R16
	ST Z  , R17
	
	
	; Вычисляем смещение
	LDI XL ,  low( taskStackHeader )
	LDI XH , high( taskStackHeader )
	ADD XL, R16
	LDI R16, 0
	ADC XH, R16   ;  Теперь Z содержит адрес куда можно складывать верхушку стека
	
	
	; Сохраняем адрес верхушки стека
	IN R16, SPL
	IN R17, SPH
	ST X+, R16 ; сохраяняем L,H загружать надо будет HL
	ST X, R17
	
	LDS R18, tmpReturnCall1   
	LDS R19, tmpReturnCall2 
	
	PUSH R19
	PUSH R18
	RETI
.ENDM

; =========================================
;
; MACRO for saving context from task level
;
; =========================================


.MACRO SaveContextBySelf
	SaveContextBySelf:
	STS tmpR16 , R16 ; Расчищаем себе пару регистров для работы
	STS tmpR17 , R17
	
	POP R16             ; Кладём адрес возврата во временную ячейку
	POP R17
	STS tmpReturnToTask1 , R16  
	STS tmpReturnToTask2 , R17
	
	PUSH R17            ; Пихаем адрес возврата обратно в стек
	PUSH R16
	
	LDS R16 , tmpR16    ; Восстанавливаем регистры R16 R17 и  сохраняем регистры в стек задачи
	LDS R17 , tmpR17
	LDS R18 , tmpR18
	LDS R19 , tmpR19
	
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	PUSH R21
	PUSH R22
	PUSH R23
	PUSH R24
	PUSH R25
	PUSH R26
	PUSH R27
	PUSH R28
	PUSH R29
	PUSH R30
	PUSH R31
	MOV SREG, R16
	PUSH R16
	
	; Загружаем номер текущей задачи  и вычисляем адрес ячейки для сохранения адреса верхушки стека
	LDS R18 , currentTaskNumber
	LDI R19 , FRAMESIZE
	LDS ZL  , low(TaskFrame) 
	LDS ZH  , high(TaskFrame)
	MUL R18 , R19
	
	ADD ZL  , R0
	ADC ZH  , R1 ; прыгнули на начало контекста задачи
	
	SUBI ZL , low(-5)
	SBCI ZH , high(-5) ; прыгнули на адрес для сохранения верхушки стека
	
	IN R16 , SPL        ; Сохраняем адрес верхушки стека во временную ячейку
	IN R17 , SPH
	ST Z+ , R16
	ST Z  , R17
	
	
	; Вычисляем смещение
	LDI XL ,  low( taskStackHeader )
	LDI XH , high( taskStackHeader )
	ADD XL, R16
	LDI R16, 0
	ADC XH, R16   ;  Теперь Z содержит адрес куда можно складывать верхушку стека
	
	
	; Сохраняем адрес верхушки стека
	IN R16, SPL
	IN R17, SPH
	ST X+, R16 ; сохраяняем L,H загружать надо будет HL
	ST X, R17
	
	LDS R16, tmpReturnToTask1
	LDS R17, tmpReturnToTask2
	
	PUSH R17
	PUSH R16
	RETI
.ENDM

.MACRO LoadContextMacro
	CLI
	POP R16
	MOV SREG, R16
	POP R31
	POP R30
	POP R29
	POP R28
	POP R27
	POP R26
	POP R25
	POP R24
	POP R23
	POP R22
	POP R21
	POP R20
	POP R19
	POP R18
	POP R17
	POP R16
	POP R15
	POP R14
	POP R13
	POP R12
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R3
	POP R1
	POP R0
	RETI
.ENDM


