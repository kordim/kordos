; Запишем сюда адреса где начинаются программы
; Эти адреса нужны загрузчику задач
; --------------------------------------------

task1_start: 
NOP
NOP
NOP
TASK_EXIT

task2_start: 
NOP
NOP
NOP
TASK_EXIT

task3_start:
NOP
NOP
NOP
TASK_EXIT

task4_start:
NOP
NOP
NOP
TASK_EXIT

task5_start:
NOP
NOP
NOP
TASK_EXIT

task6_start:
NOP
NOP
NOP
TASK_EXIT

task7_start:
NOP
NOP
NOP
TASK_EXIT

task8_start: 
NOP
NOP
NOP
TASK_EXIT

taskStartAddress:
.dw task1_start
.dw task2_start
.dw task3_start
.dw task4_start
.dw task5_start
.dw task6_start
.dw task7_start
.dw task8_start

; Приоритеты задач по умолчанию
; Используется загрузчиком задач
; -----------------------------
.EQU DTV = 5
DefaultTimer: 
Task1_Timer: .dw DTV
Task2_Timer: .dw DTV+1
Task3_Timer: .dw DTV+2
Task4_Timer: .dw DTV+3
Task5_Timer: .dw DTV+4
Task6_Timer: .dw DTV+5
Task7_Timer: .dw DTV+6
Task8_Timer: .dw DTV+7


