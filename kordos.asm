;.DEVICE ATmega323
.INCLUDE "m323def.inc"
.INCLUDE "constants.asm"
.INCLUDE "macros.asm"

Reset: 
OUTI SPL , low(RAMEND)
OUTI SPH , high(RAMEND)
SEI

;
; System Init and Start
; =====================

.INCLUDE "Init.asm"
dummy_Loop: ; В самом начале покрутимся здесь пока не получим Таймерное прерывание
NOP
NOP
NOP
RJMP dummy_loop ; 

.EXIT
;
; Core files
; ==========
.INCLUDE "save_context.asm"
.EXIT
.INCLUDE "TimerService.asm"
.INCLUDE "TaskLoad.asm"
.INCLUDE "IntService.asm"

OutComp2Int:
    CLI
    TimerService ; Timer Service Start
    InterruptManager ; Process Interrupts
    TaskLoader
    RJMP dummy_loop ; если вдруг мы попали сюда, TaskLoader выпустил нас из своих мохнатых объятий, 
                    ; то от греха подальше постоим в сторонке пока нас таймер не позовёт



;
; System calls
; ============
.INCLUDE "Sleep.asm"
.INCLUDE "WaitForInt.asm"
.INCLUDE "IPC.asm"
.INCLUDE "SemCounter.asm"
.INCLUDE "SemMutex.asm"
.INCLUDE "Tasks.asm"







