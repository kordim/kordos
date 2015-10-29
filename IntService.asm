;.MACRO InterruptManager
.DEF taskNum            = R18
.DEF intNum             = R19
.DEF intFlag            = R20
.DEF intBuf             = R21

IntServiceStart:
LDI R16 , 0
MOV R10 , R16                     ; Clear R10 = ReturnPoolCounter

IntServiceNext:
CLI
SUB_SemGetValue IntPoolCounter    ; Load Interrupt Request Queue Length to R16
								  ; загрузили длину очереди, желающих получить прерывания
CPI       R16 , 0                 ; Queue is empty ?
BREQ      ClearInterruptFlags     ; Queue is empty, goto Clearing
                    
; Загружаем элемент из пула
; =========================
LDI_Z     IntPoolAddr             ; Вычисляем адрес конца очереди  IntPoolAddr+2*IntPoolCounter  
                                  ; IntPoolCounter (IntPoolCounter лежит в R16)

MOV R18 , R16                     ; Смещаемся в хвост области памяти с очередью запросов.
LSL R18							  ; Чтобы вычислить смещение используем длину очереди и адрес начала этой области
ADD ZL, R18                       ; Каждый элемент содержит 2 байта, поэтому длину очереди умножаем на 2
CLR R18		                      
ADC ZH , R18                      

; Загрузили номер задачи и номер ожидаемого прерыания
LD R18 , Z+				; R18 = task Number.      Номер задачи
LD R19 , Z              ; R19 = Interrupt Number. Номер прерывания

; Check Interrupt flag
; Если он 0, прерываний не было, возвращаем запрос в пул
;=======================================================
LDI_X     Int_1_Addr               ; Вычисляем смещение до буфера и флага прерываний
MOV       R16 , R19                ; Copy Interrupt Number to tmp register 
LSL       R16                      ; Уможили на 2

ADD XL , R16
CLR R16
ADC XH, R16						   ; Смещение получено


LD        R21 , X+                 ; R21 = Interrupt Buffer Value. Загружаем значение из буфера
LD        R20 , X                  ; R20 = Interrupt State Flag.   Загружаем флаг прерывания

; Состояние регистров
; R18 = task Number
; R19 = Interrupt Number
; R20 = Interrupt State Flag
; R21 = Interrupt Buffer Value

CPI       R20 , 0                 
BREQ      ReturnToPool            ; Если заказаное прерывание не произошло, то возвращаем запрос обратно в пул запросов.
								  ; Используем  для этого временный пул из которого потом перенесем в основной

; Copy Interrupt Buffer to Task Buffer
; Если Флаг состония прерывания > 0 , то
; нужно записать буфер прерывания в буфер задачи 
; =========================================================
CopyInterruptValueToTask:
LDI_Z     TaskFrame                ; Get task frame address
LDI       R16 , FRAMESIZE          ; Add Shift Address to TASK number "R16"
MUL       R16 , R18                ; TaskNumber * FRAMESIZE 
ADD       ZL  , R0                  
ADC       ZH  , R1                 ; Address in Z point to "Task Interrupt Incoming Buffer"

SUBI_Z    -1*TaskIntBufShift
ST        Z  , R21                 ; Store Interrupt Buffer value to Task Buffer

SUBI_Z    TaskIntBufShift		

; Вот тут надо очищать флаг taskWaitInt

; Mark Interrupt for Clearing
; ===========================
LDI       R16 , 2                  ; 0: no interrupnts ; 1: Interrupt appear ; 2 Interrupt processed and must be cleared
ST        X   , R16


; Get next Pool Request
; =====================
NextPoolRequest:
SUB_SemDown   IntPoolCounter      ; Уменьшаем длину очереди на 1 
RJMP IntServiceNext


; Return To Pool
; ==============
ReturnToPool:
; SaveRequestToPool -> Increase ReturnPoolCounter -> NextPoolRequest
LDI_Z     IntPoolReturnAddr   ; Get Address to Save 
MOV       R10 , R16
LSR       R16
ADD ZL, R16
CLR R16
ADC ZH, R16


ST        Z+  , R18           ; Save Task Number 
ST        Z   , R19           ; Save Interrupt  Number

INC R10                       ; Increase ReturnPoolCounter
RJMP NextPoolRequest          ; Decrease Pool Couner and take next request

; Clearing processed Interrupt Flags 
; And Copy From Returned Pool to Main Pool

; Clear Interrupt State Flags and Incoming Buffers
; =================================================
;
ClearInterruptFlags:
LDI       R17 , MAXINTNUM
MOV       R11 , R17
LDI       R17 , 0
LDI_Z     Int_1_Addr

ClearNextInterrupt:
CLC
DEC       R11
BRBS 2,   EndOfClear          
LD        R18 , Z
CPI       R18 , 2             ; InteffuptFlag == 2. Need to Clear ?
BREQ      ClearInterrupt
SUBI_Z    -2             ;Shift Interrupt Buffer Addredd on 2 bytes forward to next interrupt
RJMP      ClearNextInterrupt

ClearInterrupt:
CLI
ST        Z+ , R17            ; Clear Interrupt state flag
ST        Z  , R17            ; Clear Interrupt incoming buffer
SEI
RJMP      ClearNextInterrupt
    
EndOfClear:

; Move request from "Return" Pool to Main Pool
; ============================================
;
MoveReturnToMain:
LDI_Z     IntPoolReturnAddr       ; Get Interrupr Returned Requests Pool Address
LDI_X     IntPoolAddr             ; Get Main Interrupt Requests Pool  Address
MOV       R10, R16

MoveNextRequest:
CLC
DEC       R10                      ; Decrease Counter of returned requests
BRBS 2,   MoveReturnEnd            ; Interrupt Returned Requests Pool is empty

LD        R18 , Z+
LD        R19 , Z
ST        X+  , R18                ; Store Task Number
ST        X   , R19                ; Store Interrupt number
RJMP      MoveNextRequest

MoveReturnEnd:
SUB_SemSetValue IntPoolCounter ; IntPoolCounter = R16 =  R10 = "Number of returned requests"
SEI

;.ENDM
