; Definitions and Sets
.DEVICE ATmega323
.SET MAXPROCNUM = 8 ; Summary 8 Tasks: 0,1,2,3,4,5,6,7
.SET MAX_SEMAPHORES_NUM   = 8

; task StateRegister bit definition
; какие биты регистра состояния задачи за что отвечают

.SET taskRun             = 7
.SET taskWaitInt         = 6
.SET taskTimerIsZero     = 5

; Timer Size in bytes. MaxTimerValue = 2^(taskTimerSize*8) 
.SET taskTimerSize       = 4  ; 4 byte for each time

; Define address of Task Stacks root
; Где храним стеки задач (64 байта отдаём для стек операционки)
.SET taskStackRoot = RAMEND-64

; Includes
.NOLIST
.INCLUDE m323def.inc
.LIST

.INCLUDE macros.asm
.INCLUDE Init.asm
.INCLUDE IntService.asm
.INCLUDE IntWaitSet.asm
.INCLUDE ipc.asm
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
