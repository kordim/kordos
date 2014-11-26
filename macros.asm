
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