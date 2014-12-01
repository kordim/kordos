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
        LDI taskNumber , MAXPROCNUM
        STS currentTaskNumber , taskNumber    ; 8 in currentTaskNumber 

TaskLoader_Start:
        LDS  taskNumber , currentTaskNumber ; загрузили номер текущей задачи 
       
TaskLoader_Next:                                  ; Итерация цикла обработки задач
        DEC  taskNumber        ; R16=7 (8-1)
        BRCS TaskLoader_Init
        STS  currentTaskNumber , taskNumber ; перед запуском сохраним номер задачи в память
        
        MOV tmp             , taskNumber         ; считаем смещение чтобы утановить стековый кадр
        LDI tmp1            , FRAMESIZE
        MUL tmp             , tmp1
        LDS taskFrameAddr_L , low(TaskFrame) 
        LDS taskFrameAddr_H , high(TaskFrame)
        ADD taskFrameAddr_L , R1
        ADC taskFrameAddr_H , R0
        
        LD   taskState , taskFrameAddr     ; Регистр состояния теперь лежит в R17
        
        SBRC taskState , taskWaitInt       ; если задача ждёт прерывания то и пускай ждёт, вызывать мы её не будем 
        RJMP TaskLoader_Next

        SBRC taskState, taskTimerIsZero ; если таймер не 0 проверяем таймер следующей задачи.
        RJMP TaskLoader_Load            ; если таймер == 0 то запускаем программу. либо сначала, либо с того места где она прервалась
        
        RJMP TaskLoader_Next

TaskLoader_Load:                   
        SBRC taskState, taskRun     ; если задача не выполняется то скипаем след строку (запускаем задачу заново)
        RJMP TaskLoader_WakeUp      ; если выполняется, то будим программу
        ORI  taskState , 1<<taskRun ; Не выполняется. Взводим флаг taskRun и сохраним регистр состояния 
        ST   taskFrameAddr , taskState
        
        SUBI taskFrameAddr_L , low(-FRAMESIZE) ; установить голову стека задачи ( это конец стекового кадра )
        SBCI taskFrameAddr_H , high(-FRAMESIZE)
        OUT  SPL , taskFrameAddr_L
        OUT  SPH , taskFrameAddr_H               

        
        MOV  taskFrame_taskStart_L, taskNumber ; загружаем адрес старта задачи
        LSL  taskFrame_taskStart_L
        CLR  taskFrame_taskStart_H
        SUBI taskFrame_taskStart_L , low(2*taskStartAddress) 
        SBCI taskFrame_taskStart_H , high(2*taskStartAddress)
        LPM  tmp  , Z+ ; High byte of address
        LPM  tmp1 , Z  ; Low  byte of address
        PUSH tmp1                      ; пихаем  Z в стек и прыгаем в задачу
        PUSH tmp
        RETI

TaskLoader_WakeUp:
        SUBI taskFrameAddr_L , low(-8)  ; установить голову стека задачи ( это конец стекового кадра )
        SBCI taskFrameAddr_H , high(-8) ; загрузили адрес по которому лежит адрес головы стека запущенного таска
        OUT  SPL , taskFrameAddr_L
        OUT  SPH , taskFrameAddr_L
        LoadContext

TaskLoader_TaskExit:
        STS currentTaskNumber , taskNumber ; перед запуском сохраним номер задачи в память
        MOV tmp               , taskNumber         ; считаем смещение чтобы утановить стековый кадр
        LDI tmp1              , FRAMESIZE
        MUL tmp               , tmp1
        LDS taskFrameAddr_L   , low(TaskFrame) 
        LDS taskFrameAddr_H   , high(TaskFrame)
        ADD taskFrameAddr_L   , R1
        ADC taskFrameAddr_H   , R0
        LD  taskState         , taskFrameAddr     ; Регистр состояния теперь лежит в R17
        ORI taskState         , 0<<taskRun      ; Снимаем флаг taskRun 
        ST  taskFrameAddr     , taskState
        
        
        SUBI taskFrameAddr_L  , low(-5)
        SUBI taskFrameAddr_H  , high(-5)
        LD   tmp, taskFrameAddr
        CLR  tmp1
        SUBI taskFrameAddr_L  , low(4)
        SUBI taskFrameAddr_H  , high(4)
        
        ST  Z+ , tmp1
        ST  Z+ , tmp1
        ST  Z+ , tmp1
        ST  Z  , tmp

        RJMP interruptServiceStart ; Уходим в обработчик прерываний. А из него обратно в загрузчик задча

TaskBreak:                         ; если задача передала управление ядру по любой причине кроме exit то мы попадаем сюда ведь задача должна просто немного подождать
      SaveContext
      RJMP TaskLoader_Next




.ENDM

