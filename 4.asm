DATAS SEGMENT
    STRING DB 'or example, This is a number 3692.','$'
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    LEA SI,STRING
    MOV DX,SI
    MOV AH,9
    INT 21H
    MOV DL,0AH
    MOV AH,6H
    INT 21H
    
    MOV BX,0
	JMP LOP
LOP:
	MOV CX,'$'
	MOV DX,[SI];ȡ�����еĵ�һ���ֽ�����
	MOV DH,0
	CMP DX,CX;�Ƿ�ȡ��������־
	JE FIN;��ת��������
	CALL CAC;����CAC
	MOV DL,20H;����ո�
	MOV AH,6H
	INT 21H
	ADD SI,1;SI����һλ
	JMP LOP;����ѭ�����

CAC:
	MOV BX,0FH;��ӱ�־λ��ջ
	PUSH BX
	JMP CACU;����ASCIIֵ
CACU:
	MOV AX,DX
	MOV DX,0AH;����10ȡ��
	DIV DL
	MOV BL,AH
	PUSH BX;������ջ
	MOV DL,AL
	CMP AL,0;�Ƿ���Ϊ0
	JE PRI;������ASCIIֵ
	JMP CACU;��������ȡ��
	

PRI:
	POP BX;��������
	CMP BX,0FH;�Ƿ�Ϊ��־λ
	JE FIN1;��ת�ҽ�����
	MOV DL,BL
	ADD DL,30H;�����������ASCII���
	MOV AH,6H
	INT 21H
	JMP PRI;ѭ�����

FIN1:
	RET
FIN:
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START





