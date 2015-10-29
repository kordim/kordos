
;������������� ��������� �������� ����������
; ������� �����
; �������� ��������� ������� �������
; �������� ��������� ����� 
; R16 - ����� ������� ������

LDI R16, MAXPROCNUM
STS currentTaskNumber , R16
LDI R16, MAXPROCNUM-1 ; ������� ��������� ����� ��������� ������
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
    
    ST X+, R17 ; �������� ������� ��������� ������

    LDI  ZL,  low(DefaultTimer*2) ; ��������� ��������� �������� ������� 
    LDI  ZH, high(DefaultTimer*2)

    MOV  R18, R16 ; �������� �������� �� ������ � ��������� �������� ������� ������
    LSL  R18

    
    ADD ZL, R18   ; �������� �� ����� � ��������� �������� ������� ������
    LDI R18, 0
    ADC ZH, R18
	NOP
	

    LPM  R18, Z ; ��������� ��������� �������� ������� 

    ST   X+, R18 ; ������� ����, ����� ��������� ��������
    ST   X+, R17 ; ������� ��� ������� ����� ������� � ���������� ��������� �������� � �������
    ST   X+, R17
    ST   X,  R17 

    SUBI XL, low(-5) ; ��������� �� ������� �����
    SBCI XH, high(-5)
    ST X, R16
    
    SUBI XL, low(9+FRAMESIZE) 
    SBCI XH, high(9+FRAMESIZE)
    RJMP Init_task_next
Init_task_end:
    NOP


