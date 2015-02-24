.MACRO OUTI	
	LDI R16  , @1
	OUT @0   , R16 
.ENDMACRO		
				
.MACRO LDI_Z
    LDI  ZL   , low(@0)
    LDI  ZH   , high(@0)
.ENDM

.MACRO LDI_X
    LDI  XL   , low(@0)
    LDI  XH   , high(@0)
.ENDM

.MACRO ADD_Z_R16 ; doc: MACRO: ADD_Z_R16  Add R16 to Z register with carry uses R16 register for
    CLC
    ADD  ZL   , R16 
    SBRC SREG , 0
    INC  ZH
.ENDM

.MACRO SUBI_X ; uses registers: R16, ZL, ZH
    SUBI XL   , low(@0)
    SBCI XH   , high(@0)
.ENDM

.MACRO SUBI_Z ; uses registers: R16, ZL, ZH
    SUBI ZL   , low(@0)
    SBCI ZH   , high(@0)
.ENDM

.MACRO EXIT
    JMP  TaskLoader_TaskExit
.ENDM
