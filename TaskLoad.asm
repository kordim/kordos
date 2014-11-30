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
		STS currentTaskNumber , taskNumber	; 8 in currentTaskNumber 

TaskLoader_Start:                         
        LDS  taskNumber , currentTaskNumber ; загрузили номер текущей задачи 
       
TaskLoader_Next:                                  ; Итерация цикла обработки задач
		DEC  taskNumber		; R16=7 (8-1)
		BRCS TaskLoader_Init
		STS  currentTaskNumber , taskNumber ; перед запуском сохраним номер задачи в память
		
		MOV tmp             , taskNumber		 ; считаем смещение чтобы утановить стековый кадр
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
        RJMP TaskLoader_Load			; если таймер == 0 то запускаем программу. либо сначала, либо с того места где она прервалась
        
        RJMP TaskLoader_Next

;  Task Load section 

TaskLoader_Load:                   ; Восстанавливаем состояние задачи (она выполнялась, но управление было передано к OS)
        ; Проверить статус выполнения задачи
		; Установить корень стека задачи ( стека taskFrameAddr + FRAMESIZE )
		; Запихнуть в стек адрес старта программмы
		; RETI
		
		SBRC taskState, taskRun    ; если задача не выполняется то скипаем след строку (запускаем задачу заново)
        RJMP TaskLoader_WakeUp     ; если выполняется, то будим программу
        
        ;
		; Запуск задачи
		;
        ORI  taskState     , 1<<taskRun      ; Взводим флаг taskRun и сохраним регистр состояния 
        ST   taskFrameAddr , taskState
        
        LDIX defaultStackAddress   ; установить голову стека задачи ( это конец стекового кадра )
        SUBI  taskFrameAddr_L  ,  low(-FRAMESIZE) 
		SBCI  taskFrameAddr_H  , high(-FRAMESIZE)
        OUT  SPL , taskFrameAddr_L
        OUT  SPH , taskFrameAddr_H               ; верхушка стека установлена по адресу по умолчанию текущей задачи

		; загружаем программу:
		; ====================
		; загружаем в Z адрес начала хранилища с адресами старта программ
		; смещаемся до нужной нам программы используя taskNumber
		; загружаем значение в Z 
		; пихаем  Z в стек
		; RETI
		
        LDIZ taskFrame_taskStart       	
        ADD  taskFrame_taskStart_L , taskNumber
		LDI  tmp , 0
        ADC  taskFrame_taskStart_H , tmp    
		
		LPM tmp, 
        
		PUSH taskFrameAddr_L
		PUSH taskFrameAddr_H
		RETI

TaskLoader_WakeUp:
        LDIX runStackAddress        ; загрузили адрес по которому лежит адрес головы стека запущенного таска
                                    ; он кладётся туда при сохраненийй контекста
        ADD  XL , R20
        ADC  XH , 0
        OUT  SPL , XL
        OUT  SPH , XH
        LoadContext

TaskLoader_TaskExit:
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
      RJMP TaskLoader_Next




.ENDM

