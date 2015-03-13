.MACRO write_stack_header_to_task
	; Загружаем номер текущей задачи  и вычисляем адрес ячейки для сохранения адреса верхушки стека
	LDS  R18 , currentTaskNumber
	LDI  R19 , FRAMESIZE
	MUL  R18 , R19
	
     LDI  ZL  , low(TaskFrame) 
	LDI  ZH  , high(TaskFrame)
	
	ADD  ZL  , R0
	ADC  ZH  , R1 ; прыгнули на начало контекста задачи
	
	SUBI_Z   -1*TaskStackRootShift ; прыгнули на адрес для сохранения верхушки стека. два байта обозначают адрес с верхушкой стека
	
	IN   R16 , SPL        ; Сохраняем адрес верхушки стека задачи во временную ячейку
	IN   R17 , SPH
	ST   Z+  , R16
	ST   Z   , R17

.ENDM

.MACRO push_registers
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
     LDS R18, tmp_taskBreakPoint_L  ; Пишем tmp_taskBreakPoint_L tmp_taskBreakPoint_H в стек задачи
	LDS R19, tmp_taskBreakPoint_H
     PUSH R19
     PUSH R18
.ENDM

.MACRO M_SaveContextBySelf
SUB_SaveContextBySelf:
	STS tmpR16 , R16    ; Расчищаем себе пару регистров для работы
	STS tmpR17 , R17
	
     POP R16             ; Кладём адрес возврата во временную ячейку
	POP R17
	
     STS tmp_taskBreakPoint_L , R16  ; в конце эти два байта будут записаны на верхушку стека как адрес возврата
	STS tmp_taskBreakPoint_H , R17
	
	LDS R16 , tmpR16    ; Восстанавливаем регистры R16 R17 и  сохраняем регистры в стек задачи
	LDS R17 , tmpR17
     
     push_registers      ; Пишем все регистры в стек задачи

     write_stack_header_to_task     ; Вычисляем куда писать адрес верхушки стека и сохраняем его
     
     LDS R16, tmp_taskBreakPoint_L  ;Возвращаемся в вызвавшую программу
	LDS R17, tmp_taskBreakPoint_H  ;
     PUSH R17                       ;
	PUSH R16                       ;
	RET
.ENDM


.MACRO M_SaveContext_TS ; Save Context by Timer Service
SUB_SaveContext_TS:
	STS tmpR16 , R16 ; Сохраняем регистры в RAM. 
	STS tmpR17 , R17 ; Нужно 4 регистра 
	STS tmpR18 , R18 
	STS tmpR19 , R19
	
	POP R16         ; младший байт адреса откуда вызвана подпрограмма. попал в стек после CALL
	POP R17         ; старший байт  
     POP R18         ; младший байт адреса задачи откуда ее прервали по таймеру. попал в стек по прерыванию
	POP R19         ; старший байт 
	
     STS tmp_RetAddr_L , R16        ; сохраним, потом по этому адресу вернёмся через RET
	STS tmp_RetAddr_H , R17        ; 
	
     STS tmp_taskBreakPoint_L , R18 ; сохраним. потом этот адрес запихнём на верхушку стека 
	STS tmp_taskBreakPoint_H , R19 ; это нужно чтобы при восстановлении контекста было куда вернуться
	
	LDS R16 , tmpR16    ; Восстанавливаем сохранёные регистры
	LDS R17 , tmpR17
	LDS R18 , tmpR18
	LDS R19 , tmpR19
	
     push_registers      ; Пишем все регистры в стек задачи
                            
     write_stack_header_to_task     ; Вычисляем куда писать адрес верхушки стека и сохраняем его

	LDS  R16 , tmp_RetAddr_L       ; возвращаемся в TimerService 
	LDS  R17 , tmp_RetAddr_H       ;
	PUSH R17                       ;
	PUSH R16                       ;
	RET                            ;
.ENDM









.MACRO LoadContextMacro
	CLI
	POP R16
	MOV R16, SREG
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
	RETI ; то есть в стеке есть еще 2 байта для возврата
.ENDM


