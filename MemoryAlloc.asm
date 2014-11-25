





currentTaskNumber:       .byte 1              ; 1
taskStackHeader:         .byte MAXPROCNUM*2   ; 16 
defaultStackAddress:     .byte MAXPROCNUM*2   ; 16
taskStateRegister:       .byte MAXPROCNUM*2   ; 16
taskStartAddress:        .byte MAXPROCNUM*2   ; 16
runStackAddress:         .byte MAXPROCNUM*2   ; 16
taskTimerDefault:        .byte MAXPROCNUM     ; 8
taskTimer:               .byte MAXPROCNUM*taskTimerSize ; 32


; Temp Swap
tmpR16:   .byte 1 ; 1
tmpR17:   .byte 1 ; 1
tmpZL:    .byte 1 ; 1
tmpZH:    .byte 1 ; 1


; Alloc Interrupt buffers
int1buf:  .byte 1
int2buf:  .byte 1
int3buf:  .byte 1
int4buf:  .byte 1
int5buf:  .byte 1
int6buf:  .byte 1
int7buf:  .byte 1
int8buf:  .byte 1
int9buf:  .byte 1
int10buf: .byte 1
int11buf: .byte 1
int12buf: .byte 1
int13buf: .byte 1
int14buf: .byte 1
int15buf: .byte 1
int16buf: .byte 1
int17buf: .byte 1
int18buf: .byte 1
int19buf: .byte 1
int20buf: .byte 1         

semaphores: .byte MAX_SEMAPHORES_NUM*2


; Итого 153 байта
; На каждый стек щедро  выделим 64 байта 
; На системный стек, начинающийся с RAMEND  выделим тоже 64 байта (но может быть он и не нужен вовсе

; Итого: для 8 задач
;    153+576 = 729 байт
;    Для 16 задач
;    153+1152=1305

;Сколько влезет в 2048? 29 задач
