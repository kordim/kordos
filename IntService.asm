.DEF taskNum            = R18
.DEF intNum             = R19
.DEF intFlag            = R20
.DEF intBuf             = R21


IntServiceStart:
CLR       R10                            ; R10 = ReturnPoolCounter
IntServiceNext:

CLI

SUB_SemGetValue IntPoolCounter    ; Load Interrupt Request Queue Length to R16
CPI       R16 , 0                 ; Queue is empty ?
BREQ      ClearInterruptFlags     ; Queue is empty, goto Clearing
                    
; Загружаем элемент из пула
; =========================
LDI_Z     IntPoolAddr             ; Вычисляем адрес конца очереди  IntPoolAddr + (2 * IntPoolCounter)  
                                   ; IntPoolCounter лежит в R16
LSL       R16                     ; Умножаем IntPoolCounter на 2 (запрос из 2х байт)
ADD_Z_R16                          ; Прибавляем 2*IntPoolCounter к смещению
LSR       R16                     ; Делим обратно IntPoolCounter на 2 ( еще приголдится )
                                   ; Адрес загружен

LD        R18 , Z+                ; R18 = task Number.      Номер задачи
LD        R19 , Z                 ; R19 = Interrupt Number. Номер прерывания

; Check Interrupt flag
; Если он 0, прерываний не было, возвращаем запрос в пул
;=======================================================
LDI_X     Int_1_Addr               ; Вычисляем смещение до буфера и флага прерываний
MOV       R19 , R16                ; Copy Interrupt Number to tmp register 
LSL       R16                      ; Уможили на 2
ADD_X_R16                          ; Смещение получено

LD        R21 , X+                 ; R21 = Interrupt Buffer Value. Загружаем значение из буфера
LD        R20 , X                  ; R20 = Interrupt State Flag.   Загружаем флаг прерывания

CPI       R20 , 0                  ; Interrupt State Flag == 0 ?
BREQ      ReturnToPool             ; Interrupf State Flag == 0 : Return request back to Pool

; Copy Interrupt Buffer to Task Buffer
; Если Флаг состония прерывания > 0 , то
; нужно записать буфер прерывания в буфер задачи 
; =========================================================
CopyInterruptValueToTask:
LDI_Z     TaskFrame

LDI       R16 , TaskIntBufShift    ; Add shift to "Task Interrupt Incoming Buffer"
ADD_Z_R16 

CLC
LDI       R16 , FRAMESIZE          ; Add Shift Address to TASK number "R16"
MUL       R16 , R18                ; TaskNumber * FRAMESIZE 
ADD       ZL  , R0                  
ADC       ZH  , R1                 ; Address in Z point to "Task Interrupt Incoming Buffer"
ST        Z  , R21                 ; Store Interrupt Buffer value to Task Buffer

; Mark Interrupt for Clearing
; ===========================
LDI       R16 , 2                  ; 0: no interrupnts ; 1: Interrupt appear ; 2 Interrupt processed and must be cleared
ST        X   , R16


; Get next Pool Request
; =====================
NextPoolRequest:
SUB_SemDown   IntPoolCounter      ; Уменьшаем длину очереди на 1 
RJMP           IntServiceNext:


; Return To Pool
; ==============
ReturnToPool:
; SaveRequestToPool -> Increase ReturnPoolCounter -> NextPoolRequest
LDI_Z     IntPoolReturnAddr   ; Get Address to Save 
MOV       R10 , R16
LSR       R16
ADD_Z_R16

ST        Z+  , R18           ; Save Task Number 
ST        Z   , R19           ; Save Interrupt  Number

INC R10                       ; Increase ReturnPoolCounter
RJMP NextPoolRequest          ; Decrease Pool Couner and take next request

; Clearing processed Interrupt Flags 
; And Copy From Returned Pool to Main Pool

; Clear Interrupt State Flags and Incoming Buffers
; =================================================
;
LDI       R11 , MAXINTNUM
LDI       R17 , 0
LDI_Z     Int_1_Addr

ClearNextInterrupt:
CLC
DEC       R11
BRCS      EndOfClear          
LD        R18 , Z
CPI       R18 , 2             ; InteffuptFlag == 2. Need to Clear ?
BREQ      ClearInterrupt
SUBI      ZL  ,  low(-2)
SBCI      ZH  , high(-2)      ;Shift Interrupt Buffer Addredd on 2 bytes ahead 
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
BRCS      MoveReturnEnd            ; Interrupt Returned Requests Pool is empty

LD        R18 , Z+
LD        R19 , Z
ST        X+  , R18                ; Store Task Number
ST        X   , R19                ; Store Interrupt number
RJMP      MoveNextRequest:

MoveReturnEnd:
SUB_SemSetValue IntPoolCounter ; IntPoolCounter = R16 =  R10 = "Number of returned requests"
SEI


.EXIT
