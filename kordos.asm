;.DEVICE ATmega323
;.INCLUDE "C:\AVR\GitHub\kordos\m323def.inc"
.INCLUDE "C:\AVR\GitHub\kordos\constants.asm"
.INCLUDE "C:\AVR\GitHub\kordos\macros.asm"

Reset: 
OUTI SPL , low(RAMEND)
OUTI SPH , high(RAMEND)
SEI

;
; System Init and Start
; =====================

.INCLUDE "C:\AVR\GitHub\kordos\Init.asm"
dummy_Loop: ; В самом начале покрутимся здесь пока не получим Таймерное прерывание
NOP
NOP
NOP
RJMP dummy_loop ; 

.EXIT
;
; Core files
; ==========
.INCLUDE "C:\AVR\GitHub\kordos\save_context.asm"
.EXIT
.INCLUDE "C:\AVR\GitHub\kordos\TimerService.asm"
.INCLUDE "C:\AVR\GitHub\kordos\TaskLoad.asm"
.INCLUDE "C:\AVR\GitHub\kordos\IntService.asm"

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
.INCLUDE "C:\AVR\GitHub\kordos\Sleep.asm"
.INCLUDE "C:\AVR\GitHub\kordos\WaitForInt.asm"
.INCLUDE "C:\AVR\GitHub\kordos\IPC.asm"
.INCLUDE "C:\AVR\GitHub\kordos\SemCounter.asm"
.INCLUDE "C:\AVR\GitHub\kordos\SemMutex.asm"
.INCLUDE "C:\AVR\GitHub\kordos\Tasks.asm"







