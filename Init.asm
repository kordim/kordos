; ============ Code Segment
.DSEG ; Allocate RAM
currentTaskNumber:       .byte 1 ; Выделяем байт для хранения номера выполняемой задачи

tmpR16:                  .byte 1
tmpR17:                  .byte 1
tmpR18:                  .byte 1
tmpR19:                  .byte 1
tmp_RetAddr_L:           .byte 1
tmp_RetAddr_L:           .byte 1
tmp_taskBreakPoint_L:    .byte 1
tmp_taskBreakPoint_H:    .byte 1

TaskFrame:        ; Allocate Memory for Tasks Stacks
Task1_state: .byte FRAMESIZE
Task2_state: .byte FRAMESIZE
Task3_state: .byte FRAMESIZE
Task4_state: .byte FRAMESIZE
Task5_state: .byte FRAMESIZE
Task6_state: .byte FRAMESIZE
Task7_state: .byte FRAMESIZE
Task8_state: .byte FRAMESIZE ; == 640 bytes

; Allocate Memory for Interrupt Buffers
int_1_Addr:  .byte 2
int_2_Addr:  .byte 2
int_3_Addr:  .byte 2
int_4_Addr:  .byte 2
int_5_Addr:  .byte 2
int_6_Addr:  .byte 2
int_7_Addr:  .byte 2
int_8_Addr:  .byte 2
int_9_Addr:  .byte 2
int_10_Addr: .byte 2
int_11_Addr: .byte 2
int_12_Addr: .byte 2
int_13_Addr: .byte 2
int_14_Addr: .byte 2
int_15_Addr: .byte 2
int_16_Addr: .byte 2
int_17_Addr: .byte 2
int_18_Addr: .byte 2
int_19_Addr: .byte 2
int_20_Addr: .byte 2 ; == 40 byte

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
.dw task1_start
.dw task2_start
.dw task3_start
.dw task4_start
.dw task5_start
.dw task6_start
.dw task7_start
.dw task8_start

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
