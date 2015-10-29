
;Устанавливаем стартовые значения переменных
; Таймеры задач
; Значения мьютексов входных буферов
; регистры состояния задач 
; R16 - номер текущей задачи

LDI R16, MAXPROCNUM
STS currentTaskNumber , R16
LDI R16, MAXPROCNUM-1 ; Сначала установим адрес последней задачи
LDI R17, FRAMESIZE
MUL R16, R17
LDI XL, low(TaskFrame)
LDI XH, high(TaskFrame)
ADD XL, R0
ADC XH, R1

LDI R16 , MAXPROCNUM+1
CLR R17                       

Init_task_next:
    DEC R16
    BRCS Init_task_end
    
    ST X+, R17 ; Очистили регистр состояния задачи

    LDI  ZL,  low(DefaultTimer*2) ; Загружаем дефолтное значение таймера 
    LDI  ZH, high(DefaultTimer*2)

    MOV  R18, R16 ; вычисляю смещение до адреса с дефолтным таймером текущей задачи
    LSL  R18

    
    ADD ZL, R18   ; смещаюсь на адрес с дефолтным таймером текущей задачи
    LDI R18, 0
    ADC ZH, R18
	NOP
	

    LPM  R18, Z ; Загрузили дефолтное значение таймера 

    ST   X+, R18 ; младший байт, пишем дефолтное значение
    ST   X+, R17 ; очищаем три старших байта таймера и записываем дефолтное значение в младший
    ST   X+, R17
    ST   X,  R17 

    SUBI XL, low(-5) ; Смещаемся на входной буфер
    SBCI XH, high(-5)
    ST X, R16
    
    SUBI XL, low(9+FRAMESIZE) 
    SBCI XH, high(9+FRAMESIZE)
    RJMP Init_task_next
Init_task_end:
    NOP


