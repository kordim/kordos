.EQU MAXPROCNUM = 8 ; Summary 8 Tasks: 0,1,2,3,4,5,6,7

; какие биты регистра состояния задачи за что отвечают
.EQU taskRun             = 7
.EQU taskWaitInt         = 6
.EQU taskTimerIsZero     = 5

; Timer Size in bytes. MaxTimerValue = 2^(taskTimerSize*8) 
.EQU taskTimerSize       = 4  ; 4 byte = 2^32 ticks

; Define task context offsets
.EQU TaskSregShift            = 0
.EQU TaskTimerShift           = 1
.EQU TaskStackRootShift       = 5
.EQU TaskRetAddrShift         = 7
.EQU TaskRecvBufMutexShift    = 9
.EQU TaskRecvBufShift         = 10
.EQU TaskIntBufShift          = 11
; Регистр состояния задачи                               1 байт   (+0)
; Таймер задачи                                          4 байта  (+1)
; Адрес верхушки стека                                   2 байта  (+5)
; Адрес возврата в задачу                                2 байта  (+7)
; Мьютекс буфера входящих сообщений + адрес отправителя  1 байт   (+9)
; Буфер входящих сообщений                               1 байт   (+10)
; Буфер прерывания                                       1 байт   (+11)
; Data                                                   FRAMESIZE - 33 - 12 = 35 байт
; Stack                                                  33 byte

.EQU FRAMESIZE = 80 ; Length of task context
.EQU MAXINTNUM = 20 ; Define Maximun number of used interrupts
