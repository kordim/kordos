.DEVICE ATmega323
.INCLUDE m323def.inc
.INCLUDE constants.asm
.INCLUDE macros.asm
;
; Core files
; ==========
.INCLUDE save_context.asm
.INCLUDE TimerService.asm
.INCLUDE TaskLoad.asm
.INCLUDE IntService.asm

;
; System calls
; ============
.INCLUDE Sleep.asm
.INCLUDE WaitForInt.asm
.INCLUDE IPC.asm
.INCLUDE SemCounter.asm
.INCLUDE SemMutex.asm
.INCLUDE Tasks.asm

;
; System Init and Start
; =====================
.INCLUDE Init.asm

OutComp2Int:
    TimerService ; Timer Service Start
    InterruptManager ; Process Interrupts
    TaskLoader
    RJMP dummy_loop ; если вдруг мы попали сюда, TaskLoader выпустил нас из своих мохнатых объятий, 
                    ; то от греха подальше постоим в сторонке пока нас таймер не позовёт

.ORG INT_VECTORS_SIZE 
RAM_Flush
Init_OS_timer
Init
Init_default_values

Reset: 
OUTI SPL , low(RAMEND)
OUTI SPH , high(RAMEND)
SEI

dummy_Loop: ; В самом начале покрутимся здесь пока не получим Таймерное прерывание
NOP
NOP
NOP
RJMP dummy_loop ; 


