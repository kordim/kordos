; Definitions and Sets
.DEVICE ATmega323
.SET MAXPROCNUM = 7 ; Tasks 0 - 7

; Includes
.NOLIST
.INCLUDE m323def.inc
.LIST

.INCLUDE macros.asm
.INCLUDE Init.asm
.INCLUDE IntService.asm
.INCLUDE IntWaitSet.asm
.INCLUDE ipc.asm
.INCLUDE kerneldef.asm
.INCLUDE kordos.asm
.INCLUDE save_context.asm
.INCLUDE SemCounter.asm
.INCLUDE SemMutex.asm
.INCLUDE TaskLoad.asm
.INCLUDE Tasks.asm
.INCLUDE TimerService.asm
.INCLUDE TimerSet.asm

Init
TimerService
IntService     
TaskLoad

; Timer set system call

; waitForInt system call
