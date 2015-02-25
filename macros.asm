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

.MACRO LDI_W
    LDI  @1   , low(@0)
    LDI  @2   , high(@0)
.ENDM

.MACRO ADD_Z_R16 ; doc: MACRO: ADD_Z_R16  Add R16 to Z register with carry uses R16 register for
    CLC
    ADD  ZL   , R16 
    SBRC SREG , 0
    INC  ZH
.ENDM

.MACRO ADDW ; _POD_ ADDW Usage: ADDW R16 ZL ZH
    CLC
    ADD  @1   , @0
    SBRC SREG , 0
    INC  @2
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

.MACRO getTaskAddrZ ; _POD_ MACRO getTaskAddrZ: TaskNumber , Return_L , Return_H
                    ; _POD_ MACRO getTaskAddrZ: R0,R1,R15 is reserved. Don`t use it as args.
   .DEF taskNumber = @0
   .DEF tmp        = @1
   .DEF Return_L   = @2
   .DEF Return_H   = @3
   
   PUSH R0
   PUSH R1
   PUSH R15
   
   LDI Return_L   , low(TaskFrame)
   LDI Return_H   , high(TaskFrame)
   LDI R15        , FRAMESIZE
   MUL taskNumber , tmp
   ADD Return_L , R0
   ADC Return_H , R1
   
   POP R15
   POP R1
   POP R0
   
   .UNDEF taskNumber 
   .UNDEF tmp        
   .UNDEF Return_L   
   .UNDEF Return_H   

.ENDM
