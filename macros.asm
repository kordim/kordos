.MACRO OUTI	
	LDI 	R16,@1
	OUT 	@0,R16 
.ENDMACRO		
				
.MACRO LDIZ
    LDI ZL, low(@0)
    LDI ZH, high(@0)
.ENDM

.MACRO LDIX
    LDI XL, low(@0)
    LDI XH, high(@0)
.ENDM

.MACRO Shift_Z ; uses registers: R16, ZL, ZH
	.DEF temp , R16
	
	LDI  temp , @0
	ADD  ZL   , temp
	LDI  temp , 0
	ADC  ZH   , temp
	
	.UNDEF temp
.ENDM

.MACRO SUBI_X ; uses registers: R16, ZL, ZH
	
	SUBI XL   , low(@0)
	SBCI XH   , high(@0)
	
.ENDM

