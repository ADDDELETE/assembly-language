.286
DATAS SEGMENT
    ;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,0D
    MOV DX,0
    MOV CX,0
    JMP LOP
LOP:;循环累加
	ADD AX,CX;实现带进位的双精度加法
	ADC DX,0;保存进位
	
	PUSH AX
	PUSH DX
	CALL OUT1;输出每次累加的结果
	MOV DL,20H;输出空格
	MOV AH,6H
	INT 21H
	POP DX
	POP AX
	INC CX
    CMP CX,1001D;判断是否加到1000,
    JNE LOP;继续循环
    JE FIN;退出
    
OUT1:;输出累加结果
	MOV BP,0AH
	PUSH BP;标志位入栈
	MOV BP,0
	JMP MOD1
MOD1:;结果由十六进制，求余数转成十进制数。
	MOV BX,10D
	DIV BX
	PUSH DX;余数入栈
	MOV DX,0
	CMP AX,0
	JE PRD;求余结束，输出
	JMP MOD1;循环

PRD:;输出入栈结果
	POP BX
	CMP BX,0AH;是否为标志位
	JE FIN;弹出标志位，输出结束
	MOV DL,BL;输出弹出的数字
	ADD DL,30H
	MOV AH,6H
	INT 21H
	JMP PRD
	
FIN:
	RET
	
CODES ENDS
    END START








