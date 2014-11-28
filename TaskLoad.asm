.MACRO TaskLoad
.DEF taskNumber      = R16
.DEF taskState       = R17
.DEF taskFrameAddr_L = XL
.DEF taskFrameAddr_H = XH
.DEF taskFrameAddr   = X
TaskLoadStart:                         
        LDS  taskNumber      , currentTaskNumber
       
        MOV tmp             , taskNumber
        LDI tmp1            , FRAMESIZE
        MUL tmp             , tmp1
        LDS taskFrameAddr_L , low(TaskFrame) 
        LDS taskFrameAddr_H , high(TaskFrame)
        ADD taskFrameAddr_L , R1
        ADD taskFrameAddr_H , R0
 

NextTask:                                  ; Итерация цикла обработки задач
        DEC  taskNumber
        STS  currentTaskNumber, taskNumber ; перед запуском сохраним номер задачи в память
        BRCS RefreshTaskQueue
        
        LD   taskState , taskFrameAddr     ; Регистр состояния теперь лежит в R17
        
        SBRC taskState , taskWaitInt       ; если задача ждёт прерывания то и пускай ждёт, вызывать мы её не будем 
        RJMP NextTask

        SBRC taskState, taskTimerIsZero ; если таймер не 0 то берём следующую задачу
        RJMP LoadTask
        
        RJMP NextTask
;
; -----------------------------------------------------------------------------------------------------------------------
;
LoadTask:                          ; Восстанавливаем состояние задачи (она выполнялась, но управление было передано к OS)
        MOV  R20 , R16             ; копируем номер задачи для будущих вычислений смещений
        LSL  R20                   ; умножили на 2 предполагается что задач будет мало (меньше 128)
        
        SBRC taskState, taskRun    ; если задача не выполняется то скипаем след строку (запускаем задачу заново)
        RJMP TaskWake              ; если выполняется, то будим программу
        
                                   ; Первый запуск программы а не wake
        ORI  taskState     , 1<<taskRun      ; Взводим флаг taskRun и сохраним регистр состояния 
        ST   taskFrameAddr , taskState
        
        LDIX defaultStackAddress   ; установить голову стека задачи по дефолтному для задачи адресу
        ADD  XL  , R20
        ADC  XH  , 0                 
        OUT  SPL , XL
        OUT  SPH , XH               ; верхушка стека установлена по адресу по умолчанию текущей задачи

        PUSH  low(TaskFinished)
        PUSH high(TaskFinished) ; Записать в стек адрес TaskFinished: В конце программы надо сделать RETI
    
        LDIZ taskStartAddress       ; Записать в Z начала программы и вызвать её
        ADD  ZL , R20
        ADC  ZH , 0                 
        ICALL                       

TaskWake:
        LDIX runStackAddress        ; загрузили адрес по которому лежит адрес головы стека запущенного таска
                                    ; он кладётся туда при сохраненийй контекста
        ADD  XL , R20
        ADC  XH , 0
        OUT  SPL , XL
        OUT  SPH , XH
        LoadContext

TaskFinished:
        LDS taskNumber, currentTaskNumber
        LDIX taskStateRegister 
        ADD XL, R16
        ADC XH, 0
        LD R17, X                  ; Регистр состояния задачи теперь лежит в R17 (флаги флаги семафоры, а я маленький такой)

        ORI  R17 , 0<<taskRun      ; Снимаем флаг taskRun 
        ST   X   , R17
        
        LDIZ taskTimerDefault      ; Взяли дефолтный приоритет текущей задачи
        ADD ZL , R16
        ADC ZH , 0
        LD R17, Z

        LDIZ taskTimer             ; Загружаем в таймер задачи дефолтный приоритет
        ADD ZL , R16
        ADC ZH , 0
        LDI R16 , 0
        ST  Z+ , R16               
        ST  Z+ , R16               
        ST  Z+ , R16               
        ST  Z  , R17               

        RJMP interruptServiceStart ; Уходим в обработчик прерываний. А из него обратно в загрузчик задча

TaskBreak:                         ; если задача передала управление ядру по любой причине кроме exit то мы попадаем сюда ведь задача должна просто немного подождать
      SaveContext  
      RJMP NextTask



RefreshTaskQueue:
    LDIZ currentTaskNumber 
    LDI R16, MAXPROCNUM
    ST Z, R16 ; по идее в Z лежит адрес ячейки куда сохраняем номер текущей задачи
    RJMP TaskLoadStart

.ENDM

