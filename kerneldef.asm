.equ MAXPROCNUM           = 8
.equ MAX_SEMAPHORES_NUM   = 8

; task StateRegister bit definition
.equ taskRun             = 7
.equ taskWaitInt         = 6
.equ taskTimerIsZero     = 5

; Timer Size in bytes. MaxTimerValue = 2^(taskTimerSize*8) 
.equ taskTimerSize       = 4  ; 4 byte for each time

; Define address of Task Stacks root
.equ taskStackRoot = RAMEND-64




