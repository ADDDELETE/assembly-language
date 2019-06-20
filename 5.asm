DATAS SEGMENT
    N      DB 2 DUP(?);�����������
    	   
   	M	   DB 2 DUP(?);����ÿ�ι�����Ĵ���
   		   
   	I	   DB 2 DUP(?);������ʼλ��
   		   
   	LIST_CH DB 100 DUP(?);�����ʼ����б�
   	STRING1 DB 'PLEASE INPUT THE NUMBER OF CHILDREN(1-9):','$'
   	STRING2 DB 'PLEASE INPUT THE TIMES OF KNOCKING(1-9):','$'
   	STRING3 DB 'PLEASE INPUT THE START INDEX(1-9):','$'
   	STRING4 DB 'LEFT:','$'
   	STRING5 DB 'OUT:','$'
   	STRING6 DB '~ILLEGAL','$'
   	STRING7 DB 'INPUT:','$'
   	INDEX DB 2 DUP(?);������һ����Ϸ��ı�����ʼλ��
   	TODELE DB 2 DUP(?);���汾��Ҫ��̭�����λ��
   	REST DB 2 DUP(?);����ʣ���������
   		     
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
   	 MOV AX,DATAS
   	 MOV DS,AX
   	 
   	 LEA DX,STRING1;�����ʾ��Ϣ1
   	 MOV AH,9H
   	 INT 21H
   	 LEA SI,N;���N�ĵ�ַ
   	 CALL GET;����������
 	 
 	 MOV DL,0AH
	 MOV AH,6H
	 INT 21H;����س�
	 
 	 LEA DX,STRING2;�����ʾ��Ϣ2
   	 MOV AH,9H
   	 INT 21H
 	 LEA SI,M
   	 CALL GET;���������Ĵ���
 	 
 	 MOV DL,0AH
	 MOV AH,6H
	 INT 21H;����س�
	 
	 LEA DX,STRING3
   	 MOV AH,9H
   	 INT 21H;�����ʾ��Ϣ
 	 LEA SI,I;�����ʼλ��
   	 CALL GET

 	 JMP INI;��ʼ������б�

;����������ֲ�����
GET:
	MOV DL,0FFH
	MOV AH,07H
	INT 21H;�û�����һ������
	MOV AH,0
	PUSH AX
	SUB AX,31H
	JNS BLO;ASCII��С��31H����ת����һ���ж�
	JMP ILL;����Ƿ���Ϣ
	
BLO:
	POP AX
	PUSH AX
	SUB AX,3AH
	JNS ILL;ASCII����3Aֵ������Ƿ���Ϣ
	JMP SAVE;�������������
ILL:	
	POP AX;�������������
	LEA DX,STRING6;����Ƿ���Ϣ
	MOV AH,09H
	INT 21H
	
	MOV DL,0AH
	MOV AH,06H;����س�
	INT 21H
	
	LEA DX,STRING7
	MOV AH,09H;��ʾ��������
	INT 21H
	JMP GET
SAVE:
	POP AX ;�������������
 	MOV [SI],AX
 	MOV DX,AX
 	MOV DH,0
 	MOV AH,6H
 	INT 21H
 	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;��ʼ��
INI:
	LEA SI,I
	MOV AX,[SI]
	MOV AH,0
	SUB AX,30H
	LEA SI,INDEX;���������Ϸ��ʼλ�÷ŵ���INDEX��
	MOV [SI],AX
	
	LEA SI,N
	MOV CX,[SI];�����Ϸ������
	INC CX
	PUSH CX;��������ջ
	
	LEA SI,LIST_CH;�������б��׵�ַ
	MOV AX,31H
	LOP_IN:
		MOV [SI], AX;��ұ�Ŵ��봮
		INC SI;��ַ��һ
		INC AX;��ұ�ż�һ
		POP CX;�������������
		PUSH CX;��ջ���������
		SUB CX,AX;�Ƿ����б������ջ
		JNE LOP_IN;ѭ��
		MOV AX,'$';��־λ
		MOV [SI],AX  ;��־λ���ڴ�β
		POP CX ;�������������
		JMP PLAYING;��ʼ��Ϸ
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;��ʼ������Ϸ
PLAYING:
	LEA SI,N
	MOV AX,[SI];GIVE N TO REST 
	MOV AH,0
	SUB AX,30H
	LEA SI,REST
	MOV [SI],AX
	
	LEA SI,I
	MOV AX,[SI];GIVE I TO INDEX
	MOV AH,0
	SUB AX,30H
	LEA SI,INDEX
	MOV [SI],AX
	JMP ROUND;��ʼ��Ϸѭ��
	
ROUND:;ѭ��
	LEA SI,REST;���ʣ���������
	MOV AX,[SI]
	MOV AH,0
	CMP AX,1;�Ƿ�ֻʣһ�����
	JE PRI;������
	LEA SI,INDEX
	MOV AX,[SI];GET INDEX
	MOV AH,0
	
	LEA SI,M
	MOV BX,[SI];GET M
	MOV BH,0
	SUB BX,30H
	DEC AX;M��һ���������ȡ�෽ʽȷ�������������ɾ��λ��
	ADD AX,BX  ;ADD INDEX AND M TO SUM(AX)
	
	LEA SI,REST
	MOV BX,[SI]
	PUSH BX;PUSH REST
	DIV BL;CACU MOD, SUM%REST=AX
	MOV AL,AH
	MOV AH,0

	CMP AX,0;���ȡ����
	
	JE ZER;Ϊ0 ����ת
	LEA SI,TODELE;SET THE TODELE
	MOV [SI],AX
	LEA SI,INDEX;SET INDEX
	MOV [SI],AX;SET REST
	POP AX;POP REST
	DEC AX
	LEA SI,REST
	MOV [SI],AX
	JMP DELE;����TODELEɾ����ָ̭�����
	ZER:
		MOV AX,1
		LEA SI,INDEX;SET THE INDEX 1
		MOV [SI],AX
		POP AX
		LEA SI,TODELE;SET THE TODELE 'REST'
		MOV [SI],AX
		LEA SI,REST;SET REST
		DEC AX
		MOV [SI],AX
		JMP DELE;����TODELE��ָ̭�����
	DELE:
		MOV CX,'$'
		LEA SI,TODELE
		MOV BX,[SI];GET DELE PLACE
		MOV BH,0
		
		LEA SI,LIST_CH
		ADD SI,BX;��SIָ���ɾ�����λ�õĺ�һλ
		;;;;;;;;;
		MOV AX,SI
		DEC AX
		MOV DX,[SI]
		MOV DH,0
		PUSH SI
		MOV SI,AX
		MOV [SI],DX;�����λ��ǰ�ƣ�
				   ;����ǰһ�����λ�á���һ�������ǵ��Ǳ�ɾ�����
		
		POP SI
		CMP DX,CX
		JE ROUND;�ƶ�����־λ$����ת������һ����Ϸ
		LOP_D:
			MOV AX,SI
			INC SI
			MOV DX,[SI]
			MOV DH,0;���ν����λ��ǰ�ƣ�
			PUSH SI ;����ǰһ�����λ�á���һ�������ǵ��Ǳ�ɾ�����
			MOV SI,AX
			MOV [SI],DX
			POP SI
			CMP DX,CX
			JE ROUND;�ƶ�����־λ$����ת������һ����Ϸ
			JMP LOP_D;�����ƶ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRI:;������
	MOV DL,0AH
	MOV AH,6H
	INT 21H
	LEA DX,STRING4;�����ʾ��Ϣ
	MOV AH,9H
	INT 21H
	
	LEA SI,LIST_CH;��������Ϸ����ʱ������б�
	MOV AX,[SI]
	;ADD AX,30H
	MOV AH,0
	PUSH AX;δ��̭�����ջ
	MOV DX,AX
	MOV AH,6H
	INT 21H
	
	MOV DL,0AH;�س�
	INT 21H
	
	LEA DX,STRING5;�����̭��Ϣ
	MOV AH,9H
	INT 21H
	LEA SI,N
	MOV BX,[SI];��ʼ������
	MOV BH,0
	MOV CX,0
	MOV DX,30H;�����̭�ı��
	LOP_OUT:
		INC DL
		CMP DX,BX
		JA FIN;�����������ת��������
		POP AX
		PUSH AX
		CMP AX,DX;�Ƚϵ�ǰ����ı���Ƿ���Ӯ�ҵı��
		JE LOP_OUT;�������ñ��
		MOV AH,6H
		INT 21H;������
		JMP LOP_OUT;ѭ���������

FIN:
	MOV AH,4CH
	INT 21H
CODES ENDS
    END START























