.MACRO TaskLoad
TaskLoadStart:                    ; Запуск загрузчика задач
        LDS R16, currentTaskNumber

NextTask:                          ; Итерация цикла обработки задач
        DEC R16
        STS currentTaskNumber, R16 ; перед запуском сохраним номер задачи в память
        BRCS RefreshTaskQueue
        
        LDIX taskStateRegister 
        ADD XL, R16
        ADC XH, 0
        LD R17, X                  ; Регистр состояния теперь лежит в R17

        SBRC R17, taskWaitInt      ; если задача ждёт прерывания то и пускай ждёт, вызывать мы её не будем 
        RJMP NextTask

        SBRC R17, taskTimerIsZero ; если таймер не 0 то берём следующую задачу
        RJMP LoadTask
        RJMP NextTask
;
; -----------------------------------------------------------------------------------------------------------------------
;
LoadTask:                          ; Восстанавливаем состояние задачи (она выполнялась, но управление было передано к OS)
        MOV  R20 , R16             ; копируем номер задачи для будущих вычислений смещений
        LSL  R20                   ; умножили на 2 предполагается что задач будет мало (меньше 128)
        
        SBRC R17, taskRun          ; если задача не выполняется то скипаем след строку (запускаем задачу заново)
        RJMP TaskWake              ; если выполняется, то будим программу
        
TaskRun:                           ; То что мы делаем при первом запуске задачи
        ORI  R17 , 1<<taskRun      ; Взводим флаг taskRun и сохраним регистр состояния 
        ST   X   , R17
        
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
        LDS R16, currentTaskNumber
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

