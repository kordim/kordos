; ============ Code Segment
.DSEG ; Allocate RAM

; Allocate Memory for Tasks Stacks
.SET FRAMESIZE = 80
TaskFrame:        
Task1: .byte FRAMESIZE
Task2: .byte FRAMESIZE
Task3: .byte FRAMESIZE
Task4: .byte FRAMESIZE
Task5: .byte FRAMESIZE
Task6: .byte FRAMESIZE
Task7: .byte FRAMESIZE
Task8: .byte FRAMESIZE

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
TaskDefaultBegin:
    .dw Task1_Begin
    .dw Task2_Begin
    .dw Task3_Begin
    .dw Task4_Begin
    .dw Task5_Begin
    .dw Task6_Begin
    .dw Task7_Begin
    .dw Task8_Begin

Reset:
     OUTI 	SPL,low(RAMEND)
	OUTI 	SPH,high(RAMEND)

	
