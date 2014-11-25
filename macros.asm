
.MACRO LDIZ
    LDI ZL, low(@0)
    LDI ZH, high(@0)
.ENDM

.MACRO LDIX
    LDI XL, low(@0)
    LDI XH, high(@0)
.ENDM
