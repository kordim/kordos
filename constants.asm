.EQU MAXPROCNUM = 8 ; Summary 8 Tasks: 0,1,2,3,4,5,6,7

; 10 для регистров 
; + 2 для адреса возврата к выполняемой строке 
; + 2 для адреса возврата из функции 
; + 1 для регистрасостояния
; какие биты регистра состояния задачи за что отвечают
.EQU kernelStackLength = 10+2+2+1 

.EQU taskRun             = 7 ; 128 ; 0b10000000 - 7 байт
.EQU taskWaitInt         = 6 ; 64 ; 0b01000000 - 6 байт ; нигде не очищается
.EQU taskTimerIsZero     = 5 ; 32 ; 0b00100000 - 5 байт

; режимы из которых можно поймать прерывание, 
; в соответствии с этим нужно правильно восстанавливать и сохранять конекст или задачи или ядра
.EQU taskMode = 0
.EQU kernelMode = 1
.EQU kernelInitMode = 2

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

; Структура контекста задачи. какие байты за что отвечают

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

