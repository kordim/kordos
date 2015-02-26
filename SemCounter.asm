; Increase semaphore by 1 
; =======================
;
.MACRO SUB_SemUp   
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemUp
    POP  ZH
    POP  ZL
.ENDM

.MACRO IPC_SemUp        ; _POD_ IPC_SemUp: Increase Semaphore value by 1
                        ; _POD_ IPC_SemUp: Semaphore address must be in Z before call
    PUSH       R16      
    PUSH       R17

    LD         R17 , Z+	; R17 = Limit
IPC_SemUpCheck:
    LD         R16 , Z	; R16 = Value   
    CP         R16 , R17                ; Semaphore == maximum value ???
    BRNE       IPC_SemInc               ; Increase Semaphore value 
    
    CALL       SUB_SaveContextBySelf        ; Semaphore reach maximal value, wait until semaphore is down
    RJMP       TaskBreak	               ; 
    
    RJMP       IPC_SemUpCheck           ; Return from core. Check semaphore again
IPC_SemInc:
    INC        R16                     
    ST         Z , R16                
    
    POP        R17
    POP        R16
    RET
.ENDM

; Decrease semaphore by 1
; =======================
;
.MACRO SUB_SemDown
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    CALL IPC_SemDown
    POP  ZH
    POP  ZL
.ENDM
.MACRO IPC_SemDown
    PUSH R16              
    LD   R16 , Z+	 	 ; Load semaphore limit to R16
    LD   R16 , Z		 ; Load semaphore value to R16  
    CPI  R16 , 0
    BREQ IPC_SemDownRet   ; Если значение == 0 то просто выходим
    DEC  R16              ; Уменьшаем счётчик семафора
    ST   Z  , R16         ; сохраняем значение семафора обратно в память
    IPC_SemDownRet:    
    POP  R16
    RET
.ENDM

; Direct set semaphore value from R16 
; ===================================
;
.MACRO SUB_SemSetValue ;  _POD_ SUB_SemSetValue parameters: Address , Value
    PUSH       ZL
    PUSH       ZH
    LDI_Z      @0+1     ; Get semaphore address , and skip 1 byte (limit) 
    ST         Z  , R16 ; Set value
    POP        ZH
    POP        ZL
.ENDM

; Get semaphore current value
; ===========================
;
.MACRO SUB_SemGetValue  ; _POD_ Result stored in R16
    PUSH ZL
    PUSH ZH
    LDI  ZL  , low(@0)
    LDI  ZH  , high(@0)
    LD   R16 , Z+
    LD   R16 , Z
    POP  ZH
    POP  ZL
.ENDM

; Get semaphore maximum allowed value
; ===================================
; 
.MACRO SUB_SemGetMax    ; _POD_ SUB_SemGetMax: Result stored in R16
    PUSH ZL
    PUSH ZH
    LDI  ZL , low(@0)
    LDI  ZH , high(@0)
    LD   R16 , Z
    POP  ZH
    POP  ZL
.ENDM

