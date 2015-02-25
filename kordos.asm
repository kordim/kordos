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

; Define task context offsets
.SET TaskSregShift            = 0
.SET TaskTimerShift           = 1
.SET TaskStackRootShift       = 5
.SET TaskRetAddrShift         = 7
.SET TaskRecvBufMutexShift    = 9
.SET TaskRecvBufShift         = 10
.SET TaskIntBufShift          = 11
; Регистр состояния задачи                               1 байт   (+0)
; Таймер задачи                                          4 байта  (+1)
; Адрес верхушки стека                                   2 байта  (+5)
; Адрес возврата в задачу                                2 байта  (+7)
; Мьютекс буфера входящих сообщений + адрес отправителя  1 байт   (+9)
; Буфер входящих сообщений                               1 байт   (+10)
; Буфер прерывания                                       1 байт   (+11)
; Data                                                   FRAMESIZE - 33 - 12 = 35 байт
; Stack                                                  33 byte

.SET FRAMESIZE = 80 ; Length of task context
.SET MAXINTNUM = 20 ; Define Maximun number of used interrupts


; Includes
.NOLIST
.INCLUDE m323def.inc
.LIST

;
; Macros
; ======
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
