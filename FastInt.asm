int_1_proc:
    CLI
    PUSH ZL
    PUSH ZH 
    PUSH R16
    LDI_Z int_1_Addr;
    ST R16, Z+      ; Store new value
    LDI R16 , 1
    ST R16 , Z      ; store new status flag
    POP R16
    POP ZH
    POP ZL
    RETI

int_2_proc:
    CLI
    PUSH ZL
    PUSH ZH 
    PUSH R16
    PUSH R17
        
    LDI_Z int_1_Addr;
    LD Z , R17
    ADD R16, R17
    ST R16, Z+
    LDI R16 , 1
    ST R16 , Z
    
    POP R17
    POP R16
    POP ZH
    POP ZL
    RETI



