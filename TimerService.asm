; Переделать с учётом кольцевой структуры данных задачи
.MACRO TimerService
.DEF taskFrameAddr_L = XL
.DEF taskFrameAddr_H = XH
.DEF taskFrameAddr   = X
.DEF taskNumber      = R16
.DEF taskState       = R17
.DEF timer1          = R19
.DEF timer2          = R20
.DEF timer3          = R21
.DEF timer4          = R22
.DEF tmp             = R23
.DEF tmp2            = R24

TimerService_Start:
    CALL SaveContextByInterrupt
    LDI taskNumber      , MAXPROCNUM
    LDS taskFrameAddr_L , low(TaskFrame) ; Смещаемся на начало Фрейма последней задачи 
    LDS taskFrameAddr_H , high(TaskFrame)
    LDI tmp             , (MAXPROCNUM-1)*FRAMESIZE
    ADD taskFrameAddr_L , tmp
    SBRC SREG , 0
    INC taskFrameAddr_H
    CLC 

TimerService_processTask:
    DEC  taskNumber
    BRCS TimerService_END ; Когда прощёлкали все таймеры выходим из таймерной службы

    LD  taskState , X ; загрузили состояние задачи
    
    SBRC taskState , taskWaitInt   ; если задача ждёт прерывания то тикать не надо берём следующую задачу
    RJMP TimerService_nextTask
    
    SBRC taskState , taskTimerIsZero ; если таймер уже 0 то тикать не надо берём следующую задачу
    RJMP TimerService_nextTask

    SUBI taskFrameAddr_L , low(-1)  ; сместились на 1 байт вперёд в стековом кадре, чтобы читать таймерые (см MemoryAlloc.asm )
    SBCI taskFrameAddr_H , high(-1)

    ; загрузили таймер в регистры 4 байт должно хватить на ~50 дней
    LD timer1, X+
    LD timer2, X+
    LD timer3, X+
    LD timer4, X
    
    ; Уменьшаем таймер
    SUBI timer4 , 1
    SBCI timer3 , 0
    SBCI timer2 , 0
    SBCI timer1 , 0
    
    ST   timer4 , X-
    ST   timer3 , X-
    ST   timer2 , X-
    ST   timer1 , X- ; после 4 декремента адреса он должен указывать на регистр состояния задачи
    
    ; Проверяем на 0
    MOV  tmp , timer1
    OR   tmp , timer2
    OR   tmp , timer3
    OR   tmp , timer4
    
    CPI  tmp , 0
    BREQ TimerService_taskIsZero      ; Если таймер  > 0 то сохраняем таймер и выставляем бит taskTimeIsZero = 0  потоме переходим к следующей задаче
    RJMP TimerService_taskNotZero

TimerService_taskNotZero:
    ORI  taskState , 0<<taskTimerIsZero ; Если таймер > 0, то выставляем флаг = 1 
    RJMP TimerService_nextTask

TimerService_taskIsZero:
    ORI  taskState , 1<<taskTimerIsZero ; Если таймер == 0, то выставляем флаг в регистре состояния и сохраняем его 
    RJMP TimerService_nextTask

TimerService_nextTask:
    ST   taskState , X
    SUBI taskFrameAddr_L , low(FRAMESIZE);
    SBCI taskFrameAddr_H , high(FRAMESIZE);
    RJMP TimerService_processTask

TimerService_END:
    NOP

.UNDEF taskFrameAddr_L
.UNDEF taskFrameAddr_H
.UNDEF taskFrameAddr  
.UNDEF taskNumber     
.UNDEF taskState      
.UNDEF timer1         
.UNDEF timer2         
.UNDEF timer3         
.UNDEF timer4         
.UNDEF tmp            
.UNDEF tmp2           

.ENDM

