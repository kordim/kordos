.SET FRAMESIZE = 80
.MACRO allocateTaskFrame
     ; Регистр состояния задачи                               1 байт  
     ; Таймер задачи                                          4 байта
	; Дефолтный приоритет (таймер)  задачи                   1 байт
	
     ; Адрес верхушки стека                                   2 байта
	; Адрес корня стека ?                                    2 байта
	
     ; Адрес старта задачи                                    2 байта
	; Адрес возврата в задачу                                2 байта
     ;
	; Буфер входящих сообщений                               1 байт
	; Мьютекс буфера входящих сообщений + адрес отправителя  1 байт
	; Буфер прерывания                                       1 байт
	; мьютекс прерывания + id прерывания                     1 байт
	; Выходной буфер                                         1 байт
	; мьютекс выходного буфера и адрес получателя            1 байт
	; Data                                                   28 bytes
	; Stack                                                  33 byte
	
	.byte FRAMESIZE
.ENDM


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


