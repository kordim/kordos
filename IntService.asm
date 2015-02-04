.MACRO IntService

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

IntServiceInit:
    LDI taskNumber      , MAXPROCNUM


IntService_nextTask:
    DEC taskNumber
    LDS taskFrameAddr_L , low(TaskFrame) ; Смещаемся на начало Фрейма задачи
    LDS taskFrameAddr_H , high(TaskFrame)
    MOV tmp             , taskNumber
    LDI tmp1            , FRAMESIZE
    MUL tmp , tmp1
    ADD taskFrameAddr_L , R0
    ADC taskFrameAddr_H , R1

    BRCS IntService_END ; Когда прощёлкали все таймеры выходим из таймерной службы

    LD  taskState , X ; загрузили состояние задачи
    
    SBRS taskState , taskWaitInt   ; если задача не ждёт прерывания то ей и не надо впихивать их, переходим к следующей задаче
    RJMP IntService_nextTask
    
    ; ОК задача ждёт прерывание сейчас надо взять мьютекс задачи, и определить номер прерывания которое ждёт задача 
    SUBI taskFrameAddr_L , low(-TaskIntMutexShift)
    SBCI taskFrameAddr_H , high(-TaskIntMutexShift)

    LD tmp , X  ; OK в X теперь  лежит содержимое мьютекса. Значение равно номеру поерывания которое нужно получить.
                ; Проверяем флаг прерывания
                ; Если прерывание сработало, 
                ;    обнуляем мьютекс задачи, ( надо-ли? )
                ; Загружаем данные из буфера прерывания в буфер задачи
                ; Опускаем флаг задачи taskWaitInt
                ; переходим к следующей задаче

    


  

IntService_END:
CLI
; очистить все флаги прерываний? или только те которые были проверены?
SEI

.ENDM
