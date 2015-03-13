.MACRO Init_OS_timer
    LDI R17, 0
    OUT SREG, R17            ; Инициализация SREG 

     ; Init Timer 2
     ; Основной таймер для ядра РТОС

    .EQU MainClock     = 16000000            ; CPU Clock
    .EQU TimerDivider     = MainClock/64/1000     ; 1 mS


    ldi R17 , 0                ; Toggle output A and B 
    out TCCR1A,R17              ; - Установить режим и предделитель

    ldi R17,1<<CTC2|4<<CS20         ; Freq = CK/64 - Установить режим и предделитель
    out TCCR2,R17                ; Автосброс после достижения регистра сравнения

    clr R17                    ; Установить начальное значение счётчиков
    out TCNT2,R17                ;    
    
    ldi R17,low(TimerDivider)
    out OCR2,R17                ; Установить значение в регистр сравнения
    
     LDI R17 , 1<<TOIE0|1<<OCF2 ; Разрешаем прерывание по переполнению Т0
     OUT TIMSK, R17
.ENDM

.MACRO Init_default_values
;Устанавливаем стартовые значения переменных
; Таймеры задач
; Значения мьютексов входных буферов
; регистры состояния задач 
; R16 - номер текущей задачи

LDI R16, MAXPROCNUM-1 ; Сначала установим адрес последней задачи
LDI R17, FRAMESIZE
MUL R16, R17
LDI XL, low(TaskFrame)
LDI XH, high(TaskFrame)
ADD XL, R0
ADC XH, R1

LDI R16 , MAXPROCNUM+1
CLR R17                       

Init_task_next:
    DEC R16
    BRCS Init_task_end
    
    ST X+, R17 ; Очистили регистр состояния задачи

    LDI  ZL,  low(DefaultTimer*2) ; Загружаем дефолтное значение таймера 
    LDI  ZH, high(DefaultTimer*2)

    MOV  R18, R16 ; вычисляю смещение до адреса с дефолтным таймером текущей задачи
    LSL  R18

    CLC
    ADD  ZL, R18   ; смещаюсь на адрес с дефолтным таймером текущей задачи
    SBRC SREG, 0   
    INC  ZH

    LPM  R18, Z ; Загрузили дефолтное значение таймера 

    ST   X+, R18 ; младший байт, пишем дефолтное значение
    ST   X+, R17 ; очищаем три старших байта таймера и записываем дефолтное значение в младший
    ST   X+, R17
    ST   X,  R17 

    SUBI XL, low(-5) ; Смещаемся на входной буфер
    SBCI XH, high(-5)
    ST X, R16
    
    SUBI XL, low(9+FRAMESIZE) 
    SBCI XH, high(9+FRAMESIZE)
    RJMP Init_task_next
Init_task_end:
    NOP

.ENDM




.MACRO RAM_Flush
RAM_Flush:    
    LDI    ZL,Low(SRAM_START)
    LDI    ZH,High(SRAM_START)
    CLR    R16
Flush:
    ST     Z+,R16
    CPI    ZH,High(RAMEND)
    BRNE  Flush
    CPI    ZL,Low(RAMEND)
    BRNE    Flush
    CLR    ZL
    CLR    ZH
.ENDM

;.MACRO Init
; Dynamic memory segment
; Выделяем оперативку для структур
.DSEG 

; Номер выполняемой задачи
; ------------------------
currentTaskNumber:  .byte 1 

; Несколько байт для хранения временных результатов
; -------------------------------------------------
tmpR16:                  .byte 1 
tmpR17:                  .byte 1
tmpR18:                  .byte 1
tmpR19:                  .byte 1
tmp_RetAddr_L:           .byte 1
tmp_RetAddr_H:           .byte 1
tmp_taskBreakPoint_L:    .byte 1
tmp_taskBreakPoint_H:    .byte 1

; Структуры данных задач (стек, флаги и прочее)
; ---------------------------------------------
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
    RETI
.ORG    INT1addr            ;External Interrupt1 Vector Address
    RETI
.ORG    INT2addr           ;External Interrupt2 Vector Address
    RETI
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


RAM_Flush
Init_OS_timer
Init_default_values
; Запишем сюда адреса где начинаются программы
; Эти адреса нужны загрузчику задач
; --------------------------------------------

task1_start: NOP
task2_start: NOP
task3_start: NOP
task4_start: NOP
task5_start: NOP
task6_start: NOP
task7_start: NOP
task8_start: NOP


taskStartAddress:
.dw task1_start
.dw task2_start
.dw task3_start
.dw task4_start
.dw task5_start
.dw task6_start
.dw task7_start
.dw task8_start

; Приоритеты задач по умолчанию
; Используется загрузчиком задач
; В этой версии приоритеты низменны. 
; Можно было бы хранить приоритеты по умолчанию в оперативе и изменять их в процессе работы
; Но мне кажется это не нужно. Да и память экономится
; -----------------------------
DefaultTimer: 
Task1_Timer: .db 1
Task2_Timer: .db 1
Task3_Timer: .db 1
Task4_Timer: .db 1
Task5_Timer: .db 1
Task6_Timer: .db 1
Task7_Timer: .db 1
Task8_Timer: .db 1

; Начало выполнения кода
; Выключаем прерывания
; Настраиваем периферию 
; Настраиваем таймер перывания
; Настраиваем стек
; -----------------------------
;.ENDM    



