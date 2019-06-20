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
;除法
FIR:;将待转换的数入栈
	PUSH 0;停止标志
	PUSH 369
	PUSH 10000
	PUSH 4095
	PUSH 32767
	PUSH 8000
	JMP OUTER2
OUTER2:
	POP BX;弹出一个待转换的数
	CMP BX,0;比较是否为0
	JNE GOC;非0则调到GOC
	MOV DL,0AH;输出回车
	MOV AH,6H
	INT 21H
	;JMP FIN_END
	JMP SEC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GOC:
	CALL LP2;调用LP2
	MOV DL,20H;输出空格
	MOV AH,6
	INT 21H
	JMP OUTER2
LP2:
	MOV AX,BX
	SHR BX,1;逻辑右移
	CMP BX,0;是否为0
	JE FI2;为0则转跳FI2，输出最后一位
	PUSH AX
	MOV AX,BX
	SHL AX,1;逻辑左移
	MOV CX,AX
	POP AX
	SUB AX,CX;两次做差，差入栈
	PUSH AX
	JMP LP2
FI2:
	PUSH 1
	LEA SI,TEMP_STRING
	JMP PRI2
PRI2:
	POP DX;出栈，并依次输出之前入栈的结果
	CMP DX,2;判断是否是
	JNB FI3
	
	MOV DH,0
	MOV [SI],DX;保存到字符串
	INC SI
	
	ADD DL,30H;输出一位
	MOV AH,6
	INT 21H
	JMP PRI2

FI3:
	PUSH AX
	MOV AX,'$'
	MOV [SI],AX;添加结束标志
	POP AX
	
	PUSH DX
	JMP OUT_HX;跳到十六进制输出



OUT_HX:;输出十六进制结果
	LEA SI,TEMP_STRING
	MOV BP,SI
	JMP INDEX_LEN
INDEX_LEN:;将SI指针指到$的前一位
	MOV AL,[SI]
	MOV AH,0
	INC SI
	CMP AL,'$'
	JNE INDEX_LEN;为到标志位，继续循环
	
	DEC SI
	MOV AL,0
	MOV [SI],AL
	DEC SI
	
	MOV DX,'$';作为标志入栈
	JMP HX
HX: 
	PUSH DX;计算结果或者标志入栈
	MOV DX,0;清零
	MOV CX,4;设置循环次数，四个二进制转换成一个十六进制
	LOP_HX:
		DEC CX
		CALL MUL_N;计算累加
		CMP SI,BP;是否全部转换完毕
		JE PRE_PRI;输出十六进制结果
		DEC SI;指针后退一位
		CMP CX,0;四位是否转换完毕
		JE HX
		JMP LOP_HX
MUL_N:;累加计算
	PUSH AX
	MOV AL,[SI];去除二进制串中的一位
	
	PUSH DX
	MOV DX,0
	MOV [SI],DL;二进制串中该位清零
	POP DX
	
	MOV AH,0
	
	PUSH BX
	MOV BX,3H
	SUB BL,CL;确定需要左移位数
	PUSH CX
	MOV CL,BL
	SHL AX,CL;左移CL位
	POP CX
	POP BX
	
	ADD DX,AX;左移结果保存到DX中
	POP AX
	RET
PRE_PRI:
	PUSH DX;保存最后得到的一个十六进制数
	MOV DL,20H;输出空格
	MOV AH,6H
	INT 21H
	JMP PRI_HX
	
PRI_HX:;输出十六进制数
	POP AX
	MOV AH,0
	CMP AX,'$';是否是标志位

	JE FIN
	CMP AX,0AH
	JB OUT_NUM;输出数字
	JMP OUT_ALF;输出字母
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
;降幂法


SEC:;待转换数与标志位0入栈
	PUSH 0
	PUSH 369
	PUSH 10000
	PUSH 4095
	PUSH 32767
	PUSH 8000
	JMP OUTER
OUTER:;循环取出待转换的数
	POP AX
	CMP AX,0;是否是标志位0
	JE FIN_END
	MOV BX,1
	CALL LOP_INI;初始化，找到最大的比待转换数小的2^N
	SHR BX,1
	MOV CX,AX
	
	LEA SI,TEMP_STRING
	CALL CACU;计算二进制

	CALL OUT_HX1;根据二进制串输出十六进制
	MOV DL,20H;输出空格
	MOV AH,6
	INT 21H
	
	JMP OUTER;循环
LOP_INI:;初始化减数
	SHL BX,1;左移一位
	PUSH AX
	SUB AX,BX
	POP AX
	JNS LOP_INI;比较是否大于被减数
	RET
CACU:;计算二进制结果
	MOV AX,CX
	SUB AX,BX
	JE ZER;相减结果为0
	JS SML;相减结果未负
	JNS GRA;相减结果为正
ZER:;结果未0
	MOV DX,BX
	SHR DX,1
	CMP DX,0
	JNE ST_P;是否已到为后一位
	
	MOV DL,31H;输出最后一位
	MOV AH,6
	INT 21H
	
	PUSH DX;为后一位保存到二进制串
	MOV DX,1H
	MOV [SI],DL
	INC SI
	POP DX
	
	PUSH AX
	MOV AX,'$';添加标志位到二进制串
	MOV [SI],AL
	POP AX
	
	RET
ST_P:;结果为0但不是最后一位，则需要先输出一个1，之后全是零
	MOV DL,31H;输出1
	MOV AH,6H
	INT 21H
	
	PUSH DX;添加到二进制串
	MOV DX,1H
	MOV [SI],DL
	INC SI
	POP DX
	
	JMP ST_P1
ST_P1:
	MOV DX,BX
	SHR DX,1
	CMP DX,0
	JNZ PRI0;输出0
	
	PUSH AX
	MOV AX,'$';添加标志位到二进制串
	MOV [SI],AL
	POP AX
	
	RET
PRI0:;输出剩下的0
	MOV DL,30H
	MOV AH,6;输出0
	INT 21H
	
	PUSH DX
	MOV DX,0H;0保存到二进制串
	MOV [SI],DL
	INC SI
	POP DX
	
	SHR BX,1
	JMP ST_P1
SML:;结果负，则输出0
	SHR BX,1
	MOV DL,0
	CALL PRI;输出
	JMP CACU
GRA:;结果为正，则输出1
	SHR BX,1
	MOV CX,AX
	MOV DL,1H
	CALL PRI;输出
	JMP CACU

PRI:
	MOV [SI],DL;待输出数保存到二进制串
	INC SI
	
	ADD DL,30H
	MOV AH,6
	INT 21H
	RET
	
;;;;;;;;;;;;;;;;;;;;;
;以下部分代码用以输出十六进制数，代码与上文基本一致。
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





















