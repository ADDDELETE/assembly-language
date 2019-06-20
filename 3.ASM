.286
DATAS SEGMENT
   SUM DW 1H,'#','$',1000 DUP(?)
   ;SUM DW 24H,8F9H,0E40BH,0FA6H,346CH,7FDBH,8082H,0F81AH,0BEE3H,6DA6H,0B2BDH,8919H,3EE0H,66CDH,45AAH,0EF58H,5833H,0EA40H,0H,0H, 0H,0H,'$','$',10 DUP(?)
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
	CBW;字节转换为字
	MOV AX,1D
	JMP CACU;开始计算

CACU:
	PUSH AX;N入栈
	LEA SI,SUM
	MOV BP,SI
	LOP_INDEX:
		MOV AX,[SI]
		ADD SI,2
		CMP AX,'#'
		JNE LOP_INDEX
		MOV AX,[SI]
		ADD SI,2
		CMP AX,'$'
		JNE LOP_INDEX
	SUB SI,4;SI回退到'$'
	POP BX;弹出N
	MOV CX,0;初始设0
	ADD CX,0;进位设零
	MOV AX,'$';#入栈，作为标志2
	PUSH AX
	MOV AX,'#'
	PUSH AX;$入栈，作为标志1
	LOP_MUL:
		SUB SI,2
		MOV AX,[SI]
		
		MUL BX
		ADD AX,CX;前一个低位加上本次高位
		PUSH AX;和进栈
		ADC DX,0;进位加到高位
		MOV CX,DX
		CMP BP,SI
		JNE LOP_MUL;相乘循环
		LEA SI,SUM;保存结果到SUM串
		CMP CX,0
		JE SAVE
		PUSH CX;保存进位
		JMP SAVE
	SAVE:;保存结果到串
		POP AX
		MOV [SI],AX
		ADD SI,2
		CMP AX,'#';是否为标志位1
		JNE SAVE;循环弹出保存
		MOV [SI],AX
		POP AX
		MOV [SI],AX
		ADD SI,2
		CMP AX,'$';是否为标志位2
		JNE SAVE;循环弹出保存
		MOV [SI],AX

	MOV AX,BX;
	INC AX
	CMP AX,1001D;是否到1000
	JNE CACU;继续相乘
	JMP SHOW;输出结果
	
	
;输出结果，以十六进制数出
SHOW:
	LEA SI,SUM;获得串的地址
	MOV DX,0
	MOV BX,10H
	MOV CX,'$'
	PUSH CX;标志入栈
	MOV AX,[SI]
	ADD SI,2
	JMP LOP_TRAN1;循环将串中的内容取出，以字为单位，
	LOP_TRAN1:
		MOV DX,0
		DIV BX;将取出来的一个字的内容，并取余
		PUSH DX;余数入栈
		CMP AX,0;是否商为0
		JNE LOP_TRAN1;不为零则继续取余并入栈
		JMP POP_OUT;跳出，准备弹出入栈内容
		
	POP_OUT:
		POP AX;余数出栈
		MOV AH,0
		CMP AX,'$';是否弹出了标志位
		JE LOP_SHOW;跳到下一个字的计算输出
		CMP AX,0AH;弹出内容是数字还是字母
		JB OUT_NUM;调到数字输出
		JMP OUT_ALF;调到字母输出
		
	LOP_SHOW:
		MOV DL,20H;输出空格
		MOV AH,06H
		INT 21H
		MOV CX,'$';标志入栈
		PUSH CX
		MOV AX,[SI];获取一个字的内容
		ADD SI,2;SI地址后移两个字节
		MOV CX,4;计数
		CMP AX,'#';是否到了字符串的倒数第二个字
		JNE LOP_TRAN2;继续取余循环
		
		MOV AX,[SI];获取一个字的内容
		ADD SI,2;SI地址后移两个字节
		MOV CX,4;计数
		CMP AX,'$';是否到了字符串的最后一个字
		JNE LOP_TRAN2;继续取余循环
		
		JMP FIN;结束
	LOP_TRAN2:;计算取余
		DEC CX;计数减一
		MOV DX,0
		MOV BX,10H
		DIV BX;除10H取余
		PUSH DX;余数入栈
		CMP CX,0;四位是否取余转换完毕
		JNE LOP_TRAN2;循环取余
		JMP POP_OUT;跳到输出
		
	OUT_NUM:;输出数字
		MOV DL,AL
		ADD DL,30H
		MOV AH,06H
		INT 21H
		JMP POP_OUT;调回循环输出
	OUT_ALF:;输出字幕
		MOV DL,AL
		ADD DL,37H
		MOV AH,06H
		INT 21H
		JMP POP_OUT;调回循环输出
FIN:
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START








































