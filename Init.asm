; ============ Code Segment
.DSEG ; Allocate RAM

; Выделяем байт для хранения номера выполняемой задачи
currentTaskNumber: .byte 1

; Allocate Memory for Tasks Stacks

.SET TaskSregShift            = 0
.SET TaskTimerShift           = 1
.SET TaskStackRootShift       = 5
.SET TaskRetAddrShift         = 7
.SET TaskRecvBufMutexShift    = 9
.SET TaskRecvBufShift         = 10
.SET TaskIntBufShift          = 11

; Регистр состояния задачи                               1 байт   (+0)
; Таймер задачи                                          4 байта  (+1)
; Адрес верхушки стека                                   2 байта  (+5)
; Адрес возврата в задачу                                2 байта  (+7)
; Мьютекс буфера входящих сообщений + адрес отправителя  1 байт   (+9)
; Буфер входящих сообщений                               1 байт   (+10)
; Буфер прерывания                                       1 байт   (+11)

; Data                                                   FRAMESIZE - 33 - 12 = 35 байт
; Stack                                                  33 byte

.SET FRAMESIZE = 80
TaskFrame:        
Task1_state: .byte FRAMESIZE
Task2_state: .byte FRAMESIZE
Task3_state: .byte FRAMESIZE
Task4_state: .byte FRAMESIZE
Task5_state: .byte FRAMESIZE
Task6_state: .byte FRAMESIZE
Task7_state: .byte FRAMESIZE
Task8_state: .byte FRAMESIZE ; == 640 bytes

; Alocate Memory for mutexes
;Mutex1: .byte 1
;Mutex2: .byte 1
;Mutex3: .byte 1
;Mutex4: .byte 1
;Mutex5: .byte 1
;Mutex6: .byte 1
;Mutex7: .byte 1
;Mutex8: .byte 1  ; == 8 byte

; Allocate Memory for Interrupt Buffers
.SET MAXINTNUM = 20
Int_1_Addr:  .byte 2
Int_2_Addr:  .byte 2
Int_3_Addr:  .byte 2
Int_4_Addr:  .byte 2
Int_5_Addr:  .byte 2
Int_6_Addr:  .byte 2
Int_7_Addr:  .byte 2
Int_8_Addr:  .byte 2
Int_9_Addr:  .byte 2
Int_10_Addr: .byte 2
Int_11_Addr: .byte 2
Int_12_Addr: .byte 2
Int_13_Addr: .byte 2
Int_14_Addr: .byte 2
Int_15_Addr: .byte 2
Int_16_Addr: .byte 2
Int_17_Addr: .byte 2
Int_18_Addr: .byte 2
Int_19_Addr: .byte 2
Int_20_Addr: .byte 2 ; == 40 byte

; Allocate Memory for Interrupt Request Pool
IntPoolCounter:               .byte 1
IntReturnedToPoolCounter:     .byte 1
IntPoolAddr:                  .byte 2*MAXPROCNUM 
IntPoolReturnAddr:            .byte 2*MAXPROCNUM ; == 34 bytes

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
Task1_Timer: .db 10
Task2_Timer: .db 10
Task3_Timer: .db 10
Task4_Timer: .db 10
Task5_Timer: .db 10
Task6_Timer: .db 10
Task7_Timer: .db 10
Task8_Timer: .db 10

Reset:
OUTI SPL , low(RAMEND)
OUTI SPH , high(RAMEND)

.EXIT	
