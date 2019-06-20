DATAS SEGMENT
    STRING DB 'or example, This is a number 3692.','$'
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
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
	MOV DX,[SI];取出串中的第一个字节内容
	MOV DH,0
	CMP DX,CX;是否取到结束标志
	JE FIN;跳转到结束段
	CALL CAC;调用CAC
	MOV DL,20H;输出空格
	MOV AH,6H
	INT 21H
	ADD SI,1;SI后退一位
	JMP LOP;继续循环输出

CAC:
	MOV BX,0FH;添加标志位入栈
	PUSH BX
	JMP CACU;计算ASCII值
CACU:
	MOV AX,DX
	MOV DX,0AH;除以10取余
	DIV DL
	MOV BL,AH
	PUSH BX;余数入栈
	MOV DL,AL
	CMP AL,0;是否商为0
	JE PRI;输出结果ASCII值
	JMP CACU;继续计算取余
	

PRI:
	POP BX;弹出余数
	CMP BX,0FH;是否为标志位
	JE FIN1;跳转找结束段
	MOV DL,BL
	ADD DL,30H;输出余数，以ASCII输出
	MOV AH,6H
	INT 21H
	JMP PRI;循环输出

FIN1:
	RET
FIN:
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START





