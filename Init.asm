; ============ Code Segment
.DSEG ; Allocate RAM

; Allocate Memory for Tasks Stacks
.SET FRAMESIZE = 80
; Регистр состояния задачи                               1 байт  
; Таймер задачи                                          4 байта
; Адрес верхушки стека                                   2 байта
; Адрес возврата в задачу                                2 байта
; Буфер входящих сообщений                               1 байт
; Мьютекс буфера входящих сообщений + адрес отправителя  1 байт
; Буфер прерывания                                       1 байт
; мьютекс прерывания + id прерывания                     1 байт  	
; Data                                                   FRAMESIZE - 33 - 13 = 34 байта
; Stack                                                  33 byte
TaskFrame:        
Task1_state: .byte FRAMESIZE
Task2_state: .byte FRAMESIZE
Task3_state: .byte FRAMESIZE
Task4_state: .byte FRAMESIZE
Task5_state: .byte FRAMESIZE
Task6_state: .byte FRAMESIZE
Task7_state: .byte FRAMESIZE
Task8_state: .byte FRAMESIZE

; Alocate Memory for mutexes
Mutex1: .byte 1
Mutex2: .byte 1
Mutex3: .byte 1
Mutex4: .byte 1
Mutex5: .byte 1
Mutex6: .byte 1
Mutex7: .byte 1
Mutex8: .byte 1

; Allocate Memory for Interrupt Buffers
int1buf:  .byte 1
int2buf:  .byte 1
int3buf:  .byte 1
int4buf:  .byte 1
int5buf:  .byte 1
int6buf:  .byte 1
int7buf:  .byte 1
int8buf:  .byte 1
int9buf:  .byte 1
int10buf: .byte 1
int11buf: .byte 1
int12buf: .byte 1
int13buf: .byte 1
int14buf: .byte 1
int15buf: .byte 1
int16buf: .byte 1
int17buf: .byte 1
int18buf: .byte 1
int19buf: .byte 1
int20buf: .byte 1         


;=========== Interrupt Vectors 
.CSEG 
.ORG	0x0000				
	RJMP 	Reset				
.ORG	INT0addr			;External Interrupt0 Vector Address
	RETI
.ORG	INT1addr			;External Interrupt1 Vector Address
	RETI
.ORG	OC2addr			;Output Compare2 Interrupt Vector Address
	RETI
.ORG	OVF2addr			;Overflow2 Interrupt Vector Address
	RETI
.ORG	ICP1addr			;Input Capture1 Interrupt Vector Address
	RETI
.ORG	OC1Aaddr			;Output Compare1A Interrupt Vector Address
	RETI
.ORG	OC1Baddr			;Output Compare1B Interrupt Vector Address
	RETI
.ORG	OVF1addr			;Overflow1 Interrupt Vector Address
	RETI
.ORG	OVF0addr			;Overflow0 Interrupt Vector Address
	RETI
.ORG	SPIaddr 			;SPI Interrupt Vector Address
	RETI
.ORG	URXCaddr			;UART Receive Complete Interrupt Vector Address
	RETI
.ORG	UDREaddr			;UART Data Register Empty Interrupt Vector Address
	RETI
.ORG	UTXCaddr			;UART Transmit Complete Interrupt Vector Address
	RETI
.ORG	ADCCaddr			;ADC Interrupt Vector Address
	RETI
.ORG	ERDYaddr			;EEPROM Interrupt Vector Address
	RETI
.ORG	ACIaddr 			;Analog Comparator Interrupt Vector Address
	RETI
.ORG	TWIaddr    		;Irq. vector address for Two-Wire Interface
	RETI
.ORG	INT2addr   		;External Interrupt2 Vector Address
	RETI
.ORG	OC0addr    		;Output Compare0 Interrupt Vector Address
	RETI
.ORG	SPMRaddr   		;Store Program Memory Ready Interrupt Vector Address
	RETI

; Put start addreses of tasks in Code segment 
taskStartAddress:
    .dw Task1_Start
    .dw Task2_Start
    .dw Task3_Start
    .dw Task4_Start
    .dw Task5_Start
    .dw Task6_Start
    .dw Task7_Start
    .dw Task8_Start

DefaultTimer:
    .db Task1_Timer
    .db Task2_Timer
    .db Task3_Timer
    .db Task4_Timer
    .db Task5_Timer
    .db Task6_Timer
    .db Task7_Timer
    .db Task8_Timer

Reset:
     OUTI 	SPL,low(RAMEND)
	OUTI 	SPH,high(RAMEND)

	
