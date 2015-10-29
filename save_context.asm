;.MACRO	pushKernelRegisters
;	PUSH R0
;	PUSH R1
;	PUSH R16
;	PUSH R17
;	PUSH R18
;	PUSH R19
;	PUSH XL
;	PUSH XH
;	PUSH ZL
;	PUSH ZH	; 10 bytes. Save all registers used in Task loader. 
;	IN R16,SREG
;	PUSH R16
;.ENDM

;.MACRO	loadKernelRegisters
;	LDI R16, low(kernel_State+kernelStackLength-1)
;	OUT SPL , R16
;	LDI R16, high(kernel_State+kernelStackLength-1)
;	OUT SPH , R16
;	POP R16
;	OUT SREG, R16
;	POP ZH
;	POP ZL
;	POP XH
;	POP XL
;	POP R19
;	POP R18
;	POP R17
;	POP R16
;	POP R1
;	POP R0	
;	RETI
;.ENDM

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
	IN R16,SREG
	PUSH R16
.ENDM


.MACRO LoadContextMacro
	POP R16
	IN R16, SREG
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
	NOP
	NOP
	NOP
	RETI ; то есть в стеке есть еще 2 байта для возврата
.ENDM




.MACRO write_stack_header_to_task
	
	LDS  R18 , currentTaskNumber ; Загружаем номер текущей задачи  и вычисляем адрес ячейки для сохранения адреса верхушки стека
	LDI  R19 , FRAMESIZE
	MUL  R18 , R19
	
    LDI  ZL  , low(TaskFrame) 
	LDI  ZH  , high(TaskFrame)
	
	ADD  ZL  , R0
	ADC  ZH  , R1 ; прыгнули на начало области памяти где хранится состояние задачи (флаги, контекст итд)
	
	SUBI_Z   -1*TaskStackRootShift ; прыгнули на адрес для сохранения верхушки стека. два байта обозначают адрес с верхушкой стека
	
	IN   R16 , SPL		; Берем адрес где сейчас находится верхушка стека
	IN   R17 , SPH	
	ST   Z+  , R16		; И сохраняем этот адрес в области памяти с состоянием  задачи
	ST   Z   , R17

.ENDM



SUB_SaveContextBySelf: ; Процедура которую вызывают системные вызовы когда хотять отдать управления в ядро, и потом ждать когда наступит событие
	STS tmpR16 , R16    ; Расчищаем себе пару регистров для работы
	STS tmpR17 , R17
	
    POP R16 ;H             ; Кладём адрес возврата во временную ячейку
	STS tmp_taskBreakPoint_H , R16  ; в конце эти два байта будут записаны на верхушку стека как адрес возврата
	POP R17 ; L
	STS tmp_taskBreakPoint_L , R17
	
	LDS R16 , tmpR16    ; Восстанавливаем регистры R16 R17 и  сохраняем регистры в стек задачи
	LDS R17 , tmpR17
     
     push_registers      ; Пишем все регистры в стек задачи

     write_stack_header_to_task     ; Вычисляем куда писать адрес верхушки стека и сохраняем его
     
    LDS R16, tmp_taskBreakPoint_L  ;Возвращаемся в вызвавшую программу
	LDS R17, tmp_taskBreakPoint_H  ;
    PUSH R16                       ; L 
	PUSH R17                       ; H
	RET




; Save Context by Timer Service
SUB_SaveContext_TS:
	CLI

	STS tmpR16 , R16 ; Сохраняем регистры в RAM. 
	STS tmpR17 , R17 ; Нужно 4 регистра чтобы выполнить процедуры установки адреса для сохранения
	STS tmpR18 , R18 
	STS tmpR19 , R19
	
	POP R16         ; адрес откуда вызвана подпрограмма. CALL (Скорее всего из таймерной службы)
	POP R17         ; Туда же потоми вернемся и прощёлкаем таймерами
    STS tmp_RetAddr_L , R17        ; сохраним, потом по этому адресу вернёмся через RET
	STS tmp_RetAddr_H , R16        ; 
	
	POP R18         ; Адрес который выполнялся прямо перед тем как прилетело прерывание по таймеры
	POP R19         ; Проверим откуда мы сюда попали и сохраним стек правильно
	STS tmp_taskBreakPoint_L , R19 ; сохраним. потом этот адрес запихнём на верхушку стека 
	STS tmp_taskBreakPoint_H , R18 ; это нужно чтобы при восстановлении контекста было куда вернуться
	
	; Проверка в каком режиме работала ОС. сохраняем контекст ядра или задачи
	; ========================================================================
	LDS R16, contextType
	CPI R16, taskMode
	BREQ SaveTaskContext ;(R16 = contextType = taskMode = 0 ; save task Context
	
	CPI R16, kernelInitMode
	BRNE SaveKernelContext
		
		; kernel init mode 
		LDS R16 , tmp_taskBreakPoint_L
		PUSH R16
		LDS R16 , tmp_taskBreakPoint_H
		PUSH R16

		LDS  R16 , tmp_RetAddr_L       ; возвращаемся в TimerService 
		PUSH R16
		LDS  R16 , tmp_RetAddr_H       ;
		PUSH R16                       ;
		NOP
		NOP
		NOP
		RET       
			; Не сохраняем контекст ядра если это самый первый запуск, 
			; потому что ядро еще толком и не работало, 
			; нет состояния которое нужно сохранять
	
	; ----------------------
	; Сохраняем контект ядра Только если это не первый запуск
	; ======================
	SaveKernelContext:
	LDI R16, low(kernel_State+kernelStackLength-1)	; устанавливаем адрес корня стека
	OUT SPL, R16
	LDI R16, high(kernel_State+kernelStackLength-1)
	OUT SPH, R16
    	
	; Сначала кладём в стек адрес перехода, адрес куда нужно перейти после восстановления стека
	; Потом сохраняем в стек регистры
	; потом кладём в стек адрес возврата из процедуры
	; потом выходим из процедуры через RET
	
	; Адрес перехода 	
	LDS R16 , tmp_taskBreakPoint_L
	PUSH R16
	LDS R16 , tmp_taskBreakPoint_H
	PUSH R16

	; Восстанавливаем регистры которые были временно сохранены в пямяти
	LDS R16 , tmpR16    
	LDS R17 , tmpR17
	LDS R18 , tmpR18
	LDS R19 , tmpR19
	
	; Сохряняем регистры в стек
	PUSH R0
	PUSH R1
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH XL
	PUSH XH
	PUSH ZL
	PUSH ZH	; 10 bytes. Save all registers used in Task loader. 
	IN R16,SREG
	PUSH R16
	
	LDS  R16 , tmp_RetAddr_L       ; возвращаемся в TimerService 
	PUSH R16
	LDS  R16 , tmp_RetAddr_H       ;
	PUSH R16                       ;
	
	NOP
	NOP
	NOP
	RET                            ;

; -------------------------
; Сохраняем контекст задачи 
; =========================
SaveTaskContext:	
	; Сохраняем контекст задачи
	; До прерывания стек был установлен на область памяти с состоянием задачи. После прерывания указатель на стек не менялся
	; Поэтому можно смело пихать регистры в стек
    LDS R18, tmp_taskBreakPoint_L  ; Пишем tmp_taskBreakPoint_L tmp_taskBreakPoint_H в стек задачи
	PUSH R18
	LDS R18, tmp_taskBreakPoint_H
    PUSH R18
	
	LDS R16 , tmpR16    ; Восстанавливаем сохранёные регистры
	LDS R17 , tmpR17
	LDS R18 , tmpR18
	LDS R19 , tmpR19
	
     push_registers      ; Пишем все регистры в стек задачи
                            
     write_stack_header_to_task     ; Вычисляем куда писать адрес верхушки стека и сохраняем его

	LDS  R16 , tmp_RetAddr_L       ; возвращаемся в TimerService 
	PUSH R16                       ;
	LDS  R17 , tmp_RetAddr_H       ;
	PUSH R17                       ;
	NOP
	NOP
	NOP
	RET                            ;

