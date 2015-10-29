.MACRO OUTI	
	LDI R16  , @1
	OUT @0   , R16 
.ENDM	
				
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

.MACRO SUBI_X ; uses registers: R16, ZL, ZH
    SUBI XL   , low(@0)
    SBCI XH   , high(@0)
.ENDM

.MACRO SUBI_Z ; uses registers: R16, ZL, ZH
    SUBI ZL   , low(@0)
    SBCI ZH   , high(@0)
.ENDM

.MACRO TASK_EXIT
    JMP  TaskLoader_TaskExit
	NOP
.ENDM

.MACRO getTaskAddrZ 
; _POD_ MACRO getTaskAddrZ: TaskNumber , Return_L , Return_H
; _POD_ MACRO getTaskAddrZ: R0,R1,R16 is reserved. Don`t use it as args.
   .DEF taskNumber = @0
   .DEF tmp        = @1
   .DEF Return_L   = @2
   .DEF Return_H   = @3
   
   PUSH R0
   PUSH R1
   PUSH R16
   
   LDI Return_L   , low(TaskFrame)
   LDI Return_H   , high(TaskFrame)
   LDI R16        , FRAMESIZE
   MUL taskNumber , tmp
   ADD Return_L , R0
   ADC Return_H , R1
   
   POP R16
   POP R1
   POP R0
   
   .UNDEF taskNumber 
   .UNDEF tmp        
   .UNDEF Return_L   
   .UNDEF Return_H   

.ENDM



.MACRO MACRO_RAM_Flush
RAM_Flush:    
    LDI    ZL,Low(SRAM_START)
    LDI    ZH,High(SRAM_START)
    CLR    R16
Flush:
    ST     Z+,R16
    CPI    ZH,High(RAMEND)
    BRNE  Flush
    CPI    ZL,Low(RAMEND)
    BRNE    Flush
    CLR    ZL
    CLR    ZH

.ENDM