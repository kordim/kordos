.MACRO OUTI	
	LDI 	R16,@1
	OUT 	@0,R16 
.ENDMACRO		
				
.MACRO LDI_Z
    LDI ZL, low(@0)
    LDI ZH, high(@0)
.ENDM

.MACRO LDI_X
    LDI XL, low(@0)
    LDI XH, high(@0)
.ENDM

.MACRO add_Z_R16 ; uses R16 register for
    CLC
    ADD  ZL   , R16        ; Прибавляем длину очереди в байтах, к адресу начала очереди
    SBRC SREG , 0
    INC  ZH
.ENDM

.MACRO SUBI_X ; uses registers: R16, ZL, ZH
	SUBI XL   , low(@0)
	SBCI XH   , high(@0)
.ENDM

.MACRO EXIT
    JMP TaskLoader_TaskExit
.ENDM
