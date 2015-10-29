; Dynamic memory segment
; Выделяем оперативку для структур
.DSEG 

; Номер выполняемой задачи
; ------------------------
currentTaskNumber:  .byte 1 

; режим в котором работала ОС в момент прерывания по таймеру
; В режиме ядра или выполняла задачу. от этого зависит как следует сохранять контекст
contextType:		.byte 1

; Несколько байт для хранения временных результатов
; -------------------------------------------------
tmpR16:                  .byte 1 
tmpR17:                  .byte 1
tmpR18:                  .byte 1
tmpR19:                  .byte 1
tmp_RetAddr_H:           .byte 1
tmp_RetAddr_L:           .byte 1
tmp_taskBreakPoint_H:    .byte 1
tmp_taskBreakPoint_L:    .byte 1


; Структуры данных задач (стек, флаги и прочее)
; ---------------------------------------------
;kernelSPL: .byte 1
;kernelSPH: .byte 1
kernel_State: .byte kernelStackLength ; (15 bytes)
;kernelStackRoot:


TaskFrame:        
Task1_state: .byte FRAMESIZE
Task2_state: .byte FRAMESIZE
Task3_state: .byte FRAMESIZE
Task4_state: .byte FRAMESIZE
Task5_state: .byte FRAMESIZE
Task6_state: .byte FRAMESIZE
Task7_state: .byte FRAMESIZE
Task8_state: .byte FRAMESIZE ; == 640 bytes



; Буферы для хранения приходящих прерываний
; -----------------------------------------
int_1_Addr:  .byte 2 ; struct format: Value (1 byte) , State Flag (1 byte)
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
; Память для менеджера прерывания
IntPoolCounter:               .byte 1   ; счетчик количества запросов на прерывание
IntReturnedToPoolCounter:     .byte 1   ; счетчик запросов требующих повторной обработки
IntPoolAddr:                  .byte 2*MAXPROCNUM  ; Пул запросов на прерывание
IntPoolReturnAddr:            .byte 2*MAXPROCNUM  ; Временный пул необработанных запросов 

;
; Исполняемый код
; ---------------
.CSEG 

; Первым делом заполним вектора прерываний 
.ORG    0x0000                
    RJMP     Reset                
.ORG    INT0addr            ;External Interrupt0 Vector Address
   RJMP Impossible
.ORG    INT1addr            ;External Interrupt1 Vector Address
    RJMP Impossible
.ORG    INT2addr           ;External Interrupt2 Vector Address
    RJMP Impossible
.ORG    OC2addr            ;Output Compare2 Interrupt Vector Address
    RJMP OutComp2Int
.ORG    OVF2addr            ;Overflow2 Interrupt Vector Address
    RJMP Impossible
.ORG    ICP1addr            ;Input Capture1 Interrupt Vector Address
    RJMP Impossible
.ORG    OC1Aaddr            ;Output Compare1A Interrupt Vector Address
    RJMP Impossible
.ORG    OC1Baddr            ;Output Compare1B Interrupt Vector Address
    RJMP Impossible
.ORG    OVF1addr            ;Overflow1 Interrupt Vector Address
    RJMP Impossible
.ORG    OC0addr            ;Output Compare0 Interrupt Vector Address
    RJMP Impossible
.ORG    OVF0addr            ;Overflow0 Interrupt Vector Address
    RJMP Impossible
.ORG    SPIaddr             ;SPI Interrupt Vector Address
    RJMP Impossible
.ORG    URXCaddr            ;UART Receive Complete Interrupt Vector Address
    RJMP Impossible
.ORG    UDREaddr            ;UART Data Register Empty Interrupt Vector Address
    RJMP Impossible
.ORG    UTXCaddr            ;UART Transmit Complete Interrupt Vector Address
    RJMP Impossible
.ORG    ADCCaddr            ;ADC Interrupt Vector Address
    RJMP Impossible
.ORG    ERDYaddr            ;EEPROM Interrupt Vector Address
    RJMP Impossible
.ORG    ACIaddr             ;Analog Comparator Interrupt Vector Address
    RJMP Impossible
.ORG    TWIaddr            ;Irq. vector address for Two-Wire Interface
    RJMP Impossible
.ORG    SPMRaddr           ;Store Program Memory Ready Interrupt Vector Address
    RJMP Impossible

	





