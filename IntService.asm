.DEF taskNum            = R18
.DEF intNum             = R19
.DEF intFlag            = R20
.DEF intBuf             = R21


IntServiceStart:
CLR R10                            ; R10 = ReturnPoolCounter
IntServiceNext:

CLI

CALL_SemGetValue IntPoolCounter    ; Загружаем длину очереди в R16
CPI        R16 , 0                 ; Сравниваем длину очереди с нулём чтобы понять пуста ли она 
BREQ       ClearInterruptFlags     ; Если очередь пуста, никто не ждёт прерываний. выходим и чистим флаги
                    
; Загружаем элемент из пула
; =========================
LDI_Z      IntPoolAddr             ; Вычисляем адрес конца очереди  IntPoolAddr + (2 * IntPoolCounter) + IntPoolState 
                                   ; IntPoolCounter лежит в R16
LSL        R16                     ; Умножаем IntPoolCounter на 2
ADD_Z_R16                          ; Прибавляем 2*IntPoolCounter к смещению
LSR        R16                     ; Делим обратно IntPoolCounter на 2 ( еще приголдится )
;LDS        R16 , IntPoolState      ; Ну и наконец прибавляем к смещению "большое" смещение, состояние пула.
;ADD_Z_R16                          ; прибавили =)
                                   ; Адрес загружен

LD         R18 , Z+                ; R18 = task Number.      Номер задачи
LD         R19 , Z                 ; R19 = Interrupt Number. Номер прерывания

; Check Interrupt flag
; Если он 0, прерываний не было, возвращаем запрос в пул
;=======================================================
LDI_X     Int_1_Addr               ; Вычисляем смещение до буфера и флага прерываний
MOV       R19 , R16                ; Copy Interrupt Number to tmp register 
LSL       R16                      ; Уможили на 2
ADD_X_R16                          ; Смещение получено

LD        R21 , X+                 ; R21 = Interrupt Buffer Value. Загружаем значение из буфера
LD        R20 , X                  ; R20 = Interrupt State Flag.   Загружаем флаг прерывания

CPI       R19 , 0                  ; Interrupt Flag == 0 ?
BREQ      ReturnToPool             ; Interrupf Flag == 0 : Return request back to Pool

; Copy Interrupt Buffer to Task Buffer
; Флаг срабатывания прерывания > 0
; Нужно записать значение буфера прерывания в буфер задачи 
; =========================================================
LDI_Z     TaskFrame
LDI       R16 , TaskIntBufShift
ADD_Z_R16 
LDI       R16 , FRAMESIZE

MUL       R16, R18                 ; TaskNumber * FRAMESIZE (FRAMESIZE is a length of Task context)
                                   ; R0 and R1 contain low anf High bytes of multiplicaton  results.
CLC
ADD       ZL , R0                  
ADC       ZH , R1                  ; Z point to Task Interrupt Buffer

ST        Z  , R21                 ; Store Interrupt Buffer value to Task Buffer

; Mark Interrupt for Clearing
; ===========================
LDI       R16 , 2                  ; 0: no interrupnts ; 1: Interrupt appear ; 2 Interrupt processed and must be cleared
ST        X   , R16


; Get next Pool Request
; =====================
NextPoolRequest:
CALL_SemDown     IntPoolCounter   ; Уменьшаем длину очереди на 1 
RJMP IntServiceNext:

; Return not  processed request back To Pool
; ==========================================
ReturnToPool:
; SaveRequestToPool -> Increase ReturnPoolCounter -> NextPoolRequest
; Get Address to Save 

LDI_Z IntReturnedPoolAddr                  ; Вычисляем адрес для сохранения возврящённых значений
MOV       R10 , R16                ; Copy R10=ReturnPoolCounter to R16=tmp 
LSR       R16                      ; R16 *= 2
ADD_Z_R16 

ST        Z+  , R18                ; Save Task Number 
ST        Z   , R19                ; Save Interrupt  Number

INC R10                            ; Increase ReturnPoolCounter
RJMP NextPoolRequest

; Clearing processed Interrupt Flags 
; And Copy From Returned Pool to Main Pool

