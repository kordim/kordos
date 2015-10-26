.CSEG 

.ORG    0x0000                
    RJMP     Reset                
.ORG    INT0addr            ;External Interrupt0 Vector Address
   RETI
.ORG    INT1addr            ;External Interrupt1 Vector Address
    RETI
.ORG    INT2addr           ;External Interrupt2 Vector Address
    RJMP int_loop
.ORG    OC2addr            ;Output Compare2 Interrupt Vector Address
    RETI 
.ORG    OVF2addr            ;Overflow2 Interrupt Vector Address
    RETI
.ORG    ICP1addr            ;Input Capture1 Interrupt Vector Address
    RETI
.ORG    OC1Aaddr            ;Output Compare1A Interrupt Vector Address
    RETI
.ORG    OC1Baddr            ;Output Compare1B Interrupt Vector Address
    RETI
.ORG    OVF1addr            ;Overflow1 Interrupt Vector Address
    RETI
.ORG    OC0addr            ;Output Compare0 Interrupt Vector Address
    RETI
.ORG    OVF0addr            ;Overflow0 Interrupt Vector Address
    RETI
.ORG    SPIaddr             ;SPI Interrupt Vector Address
    RETI
.ORG    URXCaddr            ;UART Receive Complete Interrupt Vector Address
    RETI
.ORG    UDREaddr            ;UART Data Register Empty Interrupt Vector Address
    RETI
.ORG    UTXCaddr            ;UART Transmit Complete Interrupt Vector Address
    RETI
.ORG    ADCCaddr            ;ADC Interrupt Vector Address
    RETI
.ORG    ERDYaddr            ;EEPROM Interrupt Vector Address
    RETI
.ORG    ACIaddr             ;Analog Comparator Interrupt Vector Address
    RETI
.ORG    TWIaddr            ;Irq. vector address for Two-Wire Interface
    RETI
.ORG    SPMRaddr           ;Store Program Memory Ready Interrupt Vector Address
    RETI


.ORG INT_VECTORS_SIZE


Reset: 

LDI R16 , low(RAMEND)
OUT SPL , R16
LDI R16 , high(RAMEND)
OUT SPL , R16
	
SEI
	

dummy_Loop: ; 
NOP
NOP
NOP
NOP
RJMP dummy_loop 

int_loop: ; 
NOP
NOP
NOP
NOP
RETI 
	
