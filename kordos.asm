; Definitions and Sets
.DEVICE ATmega323
.SET MAXPROCNUM = 8 ; Summary 8 Tasks: 0,1,2,3,4,5,6,7

; task StateRegister bit definition
; какие биты регистра состояния задачи за что отвечают
.SET taskRun             = 7
.SET taskWaitInt         = 6
.SET taskTimerIsZero     = 5

; Timer Size in bytes. MaxTimerValue = 2^(taskTimerSize*8) 
.SET taskTimerSize       = 4  ; 4 byte for each time

; Includes
.NOLIST
.INCLUDE m323def.inc
.LIST

.INCLUDE macros.asm
.INCLUDE Init.asm
.INCLUDE IntService.asm
.INCLUDE WaitForInt.asm
.INCLUDE IPC.asm
.INCLUDE save_context.asm
.INCLUDE SemCounter.asm
.INCLUDE SemMutex.asm
.INCLUDE TaskLoad.asm
.INCLUDE TimerService.asm

.INCLUDE Tasks.asm

