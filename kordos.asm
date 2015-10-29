;.INCLUDE "C:\AVR\GitHub\kordos\m323def.inc"
.INCLUDE "C:\AVR\GitHub\kordos\constants.asm"
.INCLUDE "C:\AVR\GitHub\kordos\macros.asm"

; System Init and Start
; =====================
.INCLUDE "C:\AVR\GitHub\kordos\Init.asm"
;
; Исполняемый код
; ---------------
.ORG INT_VECTORS_SIZE

;
; System calls
; ============
.INCLUDE "C:\AVR\GitHub\kordos\save_context.asm"
;.INCLUDE "C:\AVR\GitHub\kordos\Sleep.asm"
;.INCLUDE "C:\AVR\GitHub\kordos\SemCounter.asm"
;.INCLUDE "C:\AVR\GitHub\kordos\SemMutex.asm"
;.INCLUDE "C:\AVR\GitHub\kordos\WaitForInt.asm"
;.INCLUDE "C:\AVR\GitHub\kordos\IPC.asm"

; Исполняемый код задач
; ---------------------
.INCLUDE "C:\AVR\GitHub\kordos\Tasks.asm"

; Начинаем исполнение кода
; ========================
Reset: 
;Начальная инициализация после reset
NOP
NOP
NOP  
	
	; Очищаем память перед запуском
	; -----------------------------
	MACRO_RAM_Flush


	
	; Включаем стек
	; -------------
	;LDI R16 , low(RAMEND)
	;OUT SPL , R16
	;LDI R16 , high(RAMEND)
	;OUT SPH , R16
	LDI R16, low(kernel_State+kernelStackLength-1)  ; При первом запуске устанваливаем корень стека в конец 
    OUT SPL, R16
	LDI R16, high(kernel_State+kernelStackLength-1) ; в конец структуры данных задачи
    OUT SPH, R16 
	NOP
	NOP	
	; Включаем главный таймер для создания прерываний
	; -----------------------------------------------
	;Init_OS_timer
	
	LDI R17, 0
    OUT SREG, R17            ; Инициализация SREG 
	          
	.EQU MainClock     = 16000000            ; CPU Clock
    .EQU TimerDivider  = 255 ; 1/( 16000000/64*250) = 0,00102  = > 980 [Hz] 
	;.EQU TimerDivider  = 10 ; 1/( 16000000/64*250) = 0,00102  = > 980 [Hz] 
	;.EQU TimerDivider  = 2     ; 1 mS
	
	LDI R17, 1<<CS22|1<<CTC2   ; чатота таймера = clk/64  от частоты процессора(CS22=1, CS21=0 CS20=0) 
	;LDI R17, 1<<CS21|1<<CTC2  ; чатота таймера = clk/8  от частоты процессора(CS22=0, CS21=1 CS20=0) 
	OUT TCCR2,  R17			   ; + включен автосброс при достижениии регистра стравнения (CTC2=1) см стр. 125 даташита Mega32L.pdf
		
    CLR R17                    ; Установить начальное значение счётчиков
    OUT TCNT2, R17             ;    
    
    LDI R17,low(TimerDivider)
    OUT OCR2,R17                ; Установить значение в регистр сравнения
    
    LDI R17 , 1<<OCIE2 ; Разрешаем прерывание по достижению Т2 значения  регистра стравнения
    OUT TIMSK, R17

	; Выделение памяти и установка начальных значений
	; -----------------------------------------------
	;Init_default_values
	.INCLUDE "C:\AVR\GitHub\kordos\InitDefaultValues.asm"

	NOP
	NOP
	NOP
	
	; Пустой цикл заглушка
	; --------------------
	SEI
	dummy_loop: 
	NOP
	NOP
	NOP
	RJMP dummy_loop 


	OutComp2Int:
;    SEI
;	CLI
;	SEI
;	CLI
    NOP
	NOP
	NOP
	.INCLUDE "C:\AVR\GitHub\kordos\TimerService.asm" ; Timer Service Start
    SEI

	;;.INCLUDE "C:\AVR\GitHub\kordos\IntService.asm" ; Process Interrupts
    NOP
	NOP
	NOP
	
	.INCLUDE "C:\AVR\GitHub\kordos\TaskLoad.asm"
	NOP
	NOP
	NOP
	RJMP dummy_loop 

	Impossible:
	NOP
	NOP
	RJMP Impossible

