.MACRO TaskLoad
.DEF taskNumber      = R16
.DEF taskState       = R17
.DEF taskFrameAddr_L = XL
.DEF taskFrameAddr_H = XH
.DEF taskFrameAddr   = X

.DEF taskFrame_taskStart_L = ZL
.DEF taskFrame_taskStart_H = ZH
.DEF taskFrame_taskStart   = Z

.DEF tmp             = R18
.DeF tmp1            = R19

TaskLoader_Init:
        CLI
        LDI taskNumber        , MAXPROCNUM
        STS currentTaskNumber , taskNumber

;TaskLoader_Start:
;        LDS  taskNumber , currentTaskNumber ; загрузили номер текущей задачи 
       
TaskLoader_Next:                                  ; Итерация цикла обработки задач
        DEC  taskNumber        ; R16=7 (8-1)
        BRCS TaskLoader_Init
        STS currentTaskNumber , taskNumber ; перед запуском сохраним номер задачи в память
        MOV tmp             , taskNumber         ; считаем смещение чтобы утановить стековый кадр
        LDI tmp1            , FRAMESIZE
        LDI taskFrameAddr_L , low(TaskFrame) 
        LDI taskFrameAddr_H , high(TaskFrame)
        MUL tmp             , tmp1
        ADD taskFrameAddr_L , R0
        ADC taskFrameAddr_H , R1 ; посчитали адрес смещения до  контекста задачи
        LD   taskState , taskFrameAddr     ; Регистр состояния теперь лежит в R17
        SBRC taskState , taskWaitInt       ; если задача ждёт прерывания то и пускай ждёт, вызывать мы её не будем 
        RJMP TaskLoader_Next
        SBRC taskState, taskTimerIsZero ; если таймер не 0 проверяем таймер следующей задачи.
        RJMP TaskLoader_Load            ; если таймер == 0 то запускаем программу. либо сначала, либо с того места где она прервалась
        RJMP TaskLoader_Next

TaskLoader_Load:                   
        SBRC taskState, taskRun     ; если задача не выполняется то скипаем след строку (запускаем задачу заново)
        RJMP TaskLoader_WakeUp      ; если выполняется, то будим программу
        
        SBR  taskState      , taskRun ; Не выполняется. Взводим флаг taskRun и сохраним регистр состояния 
       ;ORI  taskState      , 1<<taskRun ; Не выполняется. Взводим флаг taskRun и сохраним регистр состояния 
        ST   taskFrameAddr  , taskState
        
        SUBI taskFrameAddr_L , low(-FRAMESIZE) ; установить голову стека задачи ( это конец стекового кадра )
        SBCI taskFrameAddr_H , high(-FRAMESIZE)
        OUT  SPL , taskFrameAddr_L
        OUT  SPH , taskFrameAddr_H               
        
        ; Пихаю адрес TaskLoader_TaskExit в стек задачи чтобы сделав конце RET она сразу перешла

        ; загружаем адрес старта задачи чтобы вызвать задачу
        LDI ZL                ,  low(taskStartAddress*2)
        LDI ZH                , high(taskStartAddress*2)
        MOV tmp               , taskNumber
        
        LSL tmp             ; умножаем номер таска на 2 чтобы учесть двухбайтовую природу адресации
        CLC
        ADD ZL , tmp
        SBRC SREG , 0 ; skip if C flag is clear
        INC ZH
        CLC

        ; ICALL ; минус вызова ICALL в том что нужно держать 2 байта в стеке для возврата сюда
                ; Сделаю по другомуЖ запихну в стек адрес старта программы и сделаю RETI
                ; Прыгну в задачу. В конце каждой задачи должно стоять EXIT ( это просто макрос для RJMP TaskLoader_TaskExit)
                ; В этом случае я экономлю 2 байта на каждой задаче и гарантированно возвращаюсь куда нужно
        
        LPM tmp               , Z+ ; MSD
        LPM tmp1              , Z  ; LSD
        PUSH tmp1             ; пихаем  Z в стек и прыгаем в задачу
        PUSH tmp              
        RETI                  
        ; Вот тут я возвращаюсь из задачи
        ; RJMP TaskLoader_TaskExit ; Этот RJMP не нужен, потому что в конце каждой задачи должно стоять EXIT

TaskLoader_WakeUp:
        SUBI taskFrameAddr_L ,  low(-5) ; установить голову стека задачи ( это конец стекового кадра )
        SBCI taskFrameAddr_H , high(-5) ; загрузили адрес по которому лежит адрес головы стека запущенного таска
        
        LD Z+, R17                      ; High byte of address
        LD Z,  R16                      ; Low byte of address

        OUT  SPH , R17
        OUT  SPL , R16
        LoadContextMacro

TaskLoader_TaskExit:
        ; Что делается когда задача завершилась?
        ; Снимаем флаг выпонения!!! 
        LDS  taskNumber        , currentTaskNumber ; загрузили номер текущей задачи, после выполнения задачи
        
        MOV  tmp               , taskNumber        ; считаем смещение чтобы утановить стековый кадр
        LDI  tmp1              , FRAMESIZE
        MUL  tmp               , tmp1
        LDI  taskFrameAddr_L   , low(TaskFrame) 
        LDI  taskFrameAddr_H   , high(TaskFrame)
        ADD  taskFrameAddr_L   , R0
        ADC  taskFrameAddr_H   , R1
        LD   taskState         , X     ; Регистр состояния теперь лежит в R17
        CBR  taskState         , taskRun
       ;ORI  taskState         , 0<<taskRun      ; Снимаем флаг taskRun 
        ST   X+                , taskState ; Сохранили регистр состояния задачи и сместили указатель на таймер задачи
        
        ; Тут надо загрузить дефолтное значение приоритета из таблицы в памяти программ
        LDI  ZL                ,  low(DefaultTimer*2)
        LDI  ZH                , high(DefaultTimer*2)
        
        MOV  tmp               , taskNumber ; прибавляю смещение: удвоенное значение номера задачи
        LSL  tmp               
        CLC
        ADD  ZL                , tmp
        SBRC SREG              , 0 ; skip if C flag is clear 
        INC  ZH
        CLC
        LPM  tmp               , Z ; Дефолтное значение таймера лежит в tmp
        
        CLR  tmp1
        ST   X+                , tmp1
        ST   X+                , tmp1
        ST   X+                , tmp1
        ST   X                 , tmp ; Записываем дефолтное значение таймера в самый младший байт таймера
        
        RJMP interruptServiceStart ; Уходим в обработчик прерываний. А из него обратно в загрузчик задча

TaskBreak:                         ; если задача передала управление ядру по любой причине кроме exit то мы попадаем сюда ведь задача должна просто немного подождать
        RJMP TaskLoader_Next




.ENDM

