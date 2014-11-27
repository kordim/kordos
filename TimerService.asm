; Переделать с учётом кольцевой структуры данных задачи
.MACRO TimerService

TimerService_Start:
    LDI R16, MAXPROCNUM
    LDS XL,  low(TaskFrame)
    LDS XH, high(TaskFrame)
    ; Смещаемся на начало Фрейма последней задачи 
    LDI R17 , MAXPROCNUM-1
    LDI R18 , FRAMESIZE
    MUL R18,R17
    ADD XL,R1
    ADD XH,R0

TimerService_NextTask:
    DEC R16
    BRCS TimerService_END ; Когда прощёлкали все таймеры выходим из таймерной службы
    
    
    LD  R17 , X
    
    
    LDI XL,  low( taskStateRegister )
    LDI XH, high( taskStateRegister )
    ADD XL, R16
    ADC XH, 0
    LD R17, X ; Регистр состояния теперь лежит в R17

    SBRC R17, taskWaitInt
    JMP TimerService_NextTask
    
    SBRC R17, taskTimerIsZero
    RJMP TimerService_NextTask

    MOV R18, R16
    MUL R18, taskTimerSize ; умножаем на 4
    
    LDI ZL,  low( taskTimer )
    LDI ZH, high( taskTimer )
    
    ADD ZL, R1
    ADC ZH, R0 ; в Z лежит адрес начала области с таймерами задачи

    ; загрузили таймер в регистры 4 байт должно хватить на ~50 дней
    LD R19, Z+
    LD R20, Z+
    LD R21, Z+
    LD R22, Z
    
    ; Уменьшаем таймер
    SUBI R22,1
    SBCI R21,0
    SBCI R20,0
    SBCI R19,0

    ; Проверяем на 0
    MOV R23, R19
    OR  R23, R20
    OR  R23, R21
    OR  R23, R22
    
    CPI R23,0
    BREQ TimerServiceSetZero   ; Если таймер == 0, то выставляем флаг в регистре состояния и сохраняем его 
    RJMP TimerService_NextTask ; А если > 0 то просто переходим к следующей задаче

TimerServiceSetZero:
    ORI R17, 1<<taskTimerIsZero
    ST X, R17
    RJMP TimerService_NextTask

TimerService_END:
    NOP

.ENDM

