Заведём для каждого процесса свою отдельную структуру
В ней будем хранить

Адрес верхушки стека                                   2
Адрес корня стека ?                                    2
Адрес старта задачи                                    2
Адрес возврата в задачу                                2
Дефолтный приоритет задачи                             1
Буфер входящих сообщений                               1
Мьютекс буфера входящих сообщений + адрес отправителя  1
Буфер прерывания                                       1
мьютекс прерывания + id прерывания                     1
Выходной буфер                                         1
мьютекс выходного буфера и адрес получателя            1
Таймер задачи                                          4  Итого 19 байт


также выделим место для стека.
Стек задачи                                            33 байта
    
если выделять всего 64 байта на структуру, то зазор между стеком и буферами будет всего 12 байт
Нужно посчитать сколько стека жрут системные вызовы



Установка семафора со счётчиком 4 байта


; Для временного хранения регистров  при сохранении и загрузке контекста
tmpR16:   .byte 1 ; 1
tmpR17:   .byte 1 ; 1
tmpZL:    .byte 1 ; 1
tmpZH:    .byte 1 ; 1


; Alloc Interrupt buffers 20 байт буферы для хранения прерываний
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



; Итого 153 байта
; На каждый стек щедро  выделим 64 байта 
; На системный стек, начинающийся с RAMEND  выделим тоже 64 байта (но может быть он и не нужен вовсе

; Итого: для 8 задач
;    153+576 = 729 байт
;    Для 16 задач
;    153+1152=1305

;Сколько влезет в 2048? 29 задач
