.286
DATA    SEGMENT 
	TEMP_STRING DB 20 DUP(?)
DATA    ENDS  
STACK SEGMENT

STACK ENDS

CODE   SEGMENT    
ASSUME  CS:CODE, DS:DATA,SS:STACK
BEGIN:
	MOV AX,DATA
	MOV DS,AX
	JMP FIR
	;JMP SEC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;����
FIR:;����ת��������ջ
	PUSH 0;ֹͣ��־
	PUSH 369
	PUSH 10000
	PUSH 4095
	PUSH 32767
	PUSH 8000
	JMP OUTER2
OUTER2:
	POP BX;����һ����ת������
	CMP BX,0;�Ƚ��Ƿ�Ϊ0
	JNE GOC;��0�����GOC
	MOV DL,0AH;����س�
	MOV AH,6H
	INT 21H
	;JMP FIN_END
	JMP SEC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GOC:
	CALL LP2;����LP2
	MOV DL,20H;����ո�
	MOV AH,6
	INT 21H
	JMP OUTER2
LP2:
	MOV AX,BX
	SHR BX,1;�߼�����
	CMP BX,0;�Ƿ�Ϊ0
	JE FI2;Ϊ0��ת��FI2��������һλ
	PUSH AX
	MOV AX,BX
	SHL AX,1;�߼�����
	MOV CX,AX
	POP AX
	SUB AX,CX;�����������ջ
	PUSH AX
	JMP LP2
FI2:
	PUSH 1
	LEA SI,TEMP_STRING
	JMP PRI2
PRI2:
	POP DX;��ջ�����������֮ǰ��ջ�Ľ��
	CMP DX,2;�ж��Ƿ���
	JNB FI3
	
	MOV DH,0
	MOV [SI],DX;���浽�ַ���
	INC SI
	
	ADD DL,30H;���һλ
	MOV AH,6
	INT 21H
	JMP PRI2

FI3:
	PUSH AX
	MOV AX,'$'
	MOV [SI],AX;��ӽ�����־
	POP AX
	
	PUSH DX
	JMP OUT_HX;����ʮ���������



OUT_HX:;���ʮ�����ƽ��
	LEA SI,TEMP_STRING
	MOV BP,SI
	JMP INDEX_LEN
INDEX_LEN:;��SIָ��ָ��$��ǰһλ
	MOV AL,[SI]
	MOV AH,0
	INC SI
	CMP AL,'$'
	JNE INDEX_LEN;Ϊ����־λ������ѭ��
	
	DEC SI
	MOV AL,0
	MOV [SI],AL
	DEC SI
	
	MOV DX,'$';��Ϊ��־��ջ
	JMP HX
HX: 
	PUSH DX;���������߱�־��ջ
	MOV DX,0;����
	MOV CX,4;����ѭ���������ĸ�������ת����һ��ʮ������
	LOP_HX:
		DEC CX
		CALL MUL_N;�����ۼ�
		CMP SI,BP;�Ƿ�ȫ��ת�����
		JE PRE_PRI;���ʮ�����ƽ��
		DEC SI;ָ�����һλ
		CMP CX,0;��λ�Ƿ�ת�����
		JE HX
		JMP LOP_HX
MUL_N:;�ۼӼ���
	PUSH AX
	MOV AL,[SI];ȥ�������ƴ��е�һλ
	
	PUSH DX
	MOV DX,0
	MOV [SI],DL;�����ƴ��и�λ����
	POP DX
	
	MOV AH,0
	
	PUSH BX
	MOV BX,3H
	SUB BL,CL;ȷ����Ҫ����λ��
	PUSH CX
	MOV CL,BL
	SHL AX,CL;����CLλ
	POP CX
	POP BX
	
	ADD DX,AX;���ƽ�����浽DX��
	POP AX
	RET
PRE_PRI:
	PUSH DX;�������õ���һ��ʮ��������
	MOV DL,20H;����ո�
	MOV AH,6H
	INT 21H
	JMP PRI_HX
	
PRI_HX:;���ʮ��������
	POP AX
	MOV AH,0
	CMP AX,'$';�Ƿ��Ǳ�־λ

	JE FIN
	CMP AX,0AH
	JB OUT_NUM;�������
	JMP OUT_ALF;�����ĸ
OUT_NUM:
	MOV DL,AL
	ADD DL,30H
	MOV AH,06H
	INT 21H
	JMP PRI_HX
OUT_ALF:
	MOV DL,AL
	ADD DL,37H
	MOV AH,06H
	INT 21H
	JMP PRI_HX
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���ݷ�


SEC:;��ת�������־λ0��ջ
	PUSH 0
	PUSH 369
	PUSH 10000
	PUSH 4095
	PUSH 32767
	PUSH 8000
	JMP OUTER
OUTER:;ѭ��ȡ����ת������
	POP AX
	CMP AX,0;�Ƿ��Ǳ�־λ0
	JE FIN_END
	MOV BX,1
	CALL LOP_INI;��ʼ�����ҵ����ıȴ�ת����С��2^N
	SHR BX,1
	MOV CX,AX
	
	LEA SI,TEMP_STRING
	CALL CACU;���������

	CALL OUT_HX1;���ݶ����ƴ����ʮ������
	MOV DL,20H;����ո�
	MOV AH,6
	INT 21H
	
	JMP OUTER;ѭ��
LOP_INI:;��ʼ������
	SHL BX,1;����һλ
	PUSH AX
	SUB AX,BX
	POP AX
	JNS LOP_INI;�Ƚ��Ƿ���ڱ�����
	RET
CACU:;��������ƽ��
	MOV AX,CX
	SUB AX,BX
	JE ZER;������Ϊ0
	JS SML;������δ��
	JNS GRA;������Ϊ��
ZER:;���δ0
	MOV DX,BX
	SHR DX,1
	CMP DX,0
	JNE ST_P;�Ƿ��ѵ�Ϊ��һλ
	
	MOV DL,31H;������һλ
	MOV AH,6
	INT 21H
	
	PUSH DX;Ϊ��һλ���浽�����ƴ�
	MOV DX,1H
	MOV [SI],DL
	INC SI
	POP DX
	
	PUSH AX
	MOV AX,'$';��ӱ�־λ�������ƴ�
	MOV [SI],AL
	POP AX
	
	RET
ST_P:;���Ϊ0���������һλ������Ҫ�����һ��1��֮��ȫ����
	MOV DL,31H;���1
	MOV AH,6H
	INT 21H
	
	PUSH DX;��ӵ������ƴ�
	MOV DX,1H
	MOV [SI],DL
	INC SI
	POP DX
	
	JMP ST_P1
ST_P1:
	MOV DX,BX
	SHR DX,1
	CMP DX,0
	JNZ PRI0;���0
	
	PUSH AX
	MOV AX,'$';��ӱ�־λ�������ƴ�
	MOV [SI],AL
	POP AX
	
	RET
PRI0:;���ʣ�µ�0
	MOV DL,30H
	MOV AH,6;���0
	INT 21H
	
	PUSH DX
	MOV DX,0H;0���浽�����ƴ�
	MOV [SI],DL
	INC SI
	POP DX
	
	SHR BX,1
	JMP ST_P1
SML:;������������0
	SHR BX,1
	MOV DL,0
	CALL PRI;���
	JMP CACU
GRA:;���Ϊ���������1
	SHR BX,1
	MOV CX,AX
	MOV DL,1H
	CALL PRI;���
	JMP CACU

PRI:
	MOV [SI],DL;����������浽�����ƴ�
	INC SI
	
	ADD DL,30H
	MOV AH,6
	INT 21H
	RET
	
;;;;;;;;;;;;;;;;;;;;;
;���²��ִ����������ʮ�������������������Ļ���һ�¡�
OUT_HX1:
	LEA SI,TEMP_STRING
	MOV BP,SI
	JMP INDEX_LEN1
INDEX_LEN1:
	MOV AL,[SI]
	MOV AH,0
	INC SI
	CMP AL,'$'
	JNE INDEX_LEN1
	
	DEC SI
	MOV AL,0
	MOV [SI],AL
	DEC SI
	
	MOV DX,'$'
	JMP HX1
HX1: 
	PUSH DX
	MOV DX,0
	MOV CX,4
	LOP_HX1:
		DEC CX
		CALL MUL_N1
		CMP SI,BP
		JE PRE_PRI1
		DEC SI
		CMP CX,0
		JE HX1
		JMP LOP_HX1
MUL_N1:
	PUSH AX
	MOV AL,[SI]
	
	PUSH DX
	MOV DX,0
	MOV [SI],DL
	POP DX
	
	MOV AH,0
	
	PUSH BX
	MOV BX,3H
	SUB BL,CL
	PUSH CX
	MOV CL,BL
	SHL AX,CL
	POP CX
	POP BX
	
	ADD DX,AX
	POP AX
	RET
PRE_PRI1:
	PUSH DX
	MOV DL,20H
	MOV AH,6H
	INT 21H
	JMP PRI_HX1
	
PRI_HX1:
	POP AX
	MOV AH,0
	CMP AX,'$'
	JE FIN
	CMP AX,0AH
	JB OUT_NUM1
	JMP OUT_ALF1
OUT_NUM1:
	MOV DL,AL
	ADD DL,30H
	MOV AH,06H
	INT 21H
	JMP PRI_HX1
OUT_ALF1:
	MOV DL,AL
	ADD DL,37H
	MOV AH,06H
	INT 21H
	JMP PRI_HX1	
	
	
	

FIN:
	RET
FIN_END:
	MOV AH,4CH
	INT 21H
	RET
CODE   ENDS    
    END BEGIN





















