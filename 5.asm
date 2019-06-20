DATAS SEGMENT
    N      DB 2 DUP(?);保存玩家数量
    	   
   	M	   DB 2 DUP(?);保存每次鼓声响的次数
   		   
   	I	   DB 2 DUP(?);保存起始位置
   		   
   	LIST_CH DB 100 DUP(?);保存初始玩家列表
   	STRING1 DB 'PLEASE INPUT THE NUMBER OF CHILDREN(1-9):','$'
   	STRING2 DB 'PLEASE INPUT THE TIMES OF KNOCKING(1-9):','$'
   	STRING3 DB 'PLEASE INPUT THE START INDEX(1-9):','$'
   	STRING4 DB 'LEFT:','$'
   	STRING5 DB 'OUT:','$'
   	STRING6 DB '~ILLEGAL','$'
   	STRING7 DB 'INPUT:','$'
   	INDEX DB 2 DUP(?);保存上一次游戏后的本次起始位置
   	TODELE DB 2 DUP(?);保存本次要淘汰的玩家位置
   	REST DB 2 DUP(?);保存剩余玩家数量
   		     
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
   	 MOV AX,DATAS
   	 MOV DS,AX
   	 
   	 LEA DX,STRING1;输出提示信息1
   	 MOV AH,9H
   	 INT 21H
   	 LEA SI,N;获得N的地址
   	 CALL GET;输出玩家数量
 	 
 	 MOV DL,0AH
	 MOV AH,6H
	 INT 21H;输出回车
	 
 	 LEA DX,STRING2;输出提示信息2
   	 MOV AH,9H
   	 INT 21H
 	 LEA SI,M
   	 CALL GET;输入鼓声响的次数
 	 
 	 MOV DL,0AH
	 MOV AH,6H
	 INT 21H;输出回车
	 
	 LEA DX,STRING3
   	 MOV AH,9H
   	 INT 21H;输出提示信息
 	 LEA SI,I;获得起始位置
   	 CALL GET

 	 JMP INI;初始化玩家列表

;获得输入数字并保存
GET:
	MOV DL,0FFH
	MOV AH,07H
	INT 21H;用户输入一个数字
	MOV AH,0
	PUSH AX
	SUB AX,31H
	JNS BLO;ASCII不小于31H，则转跳下一次判断
	JMP ILL;输出非法信息
	
BLO:
	POP AX
	PUSH AX
	SUB AX,3AH
	JNS ILL;ASCII大于3A值则输出非法信息
	JMP SAVE;保存输入的数字
ILL:	
	POP AX;弹出保存的数字
	LEA DX,STRING6;输出非法信息
	MOV AH,09H
	INT 21H
	
	MOV DL,0AH
	MOV AH,06H;输出回车
	INT 21H
	
	LEA DX,STRING7
	MOV AH,09H;提示重新输入
	INT 21H
	JMP GET
SAVE:
	POP AX ;保存输入的数字
 	MOV [SI],AX
 	MOV DX,AX
 	MOV DH,0
 	MOV AH,6H
 	INT 21H
 	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;初始化
INI:
	LEA SI,I
	MOV AX,[SI]
	MOV AH,0
	SUB AX,30H
	LEA SI,INDEX;将输入的游戏起始位置放到串INDEX中
	MOV [SI],AX
	
	LEA SI,N
	MOV CX,[SI];获得游戏总人数
	INC CX
	PUSH CX;总人数入栈
	
	LEA SI,LIST_CH;获得玩家列表首地址
	MOV AX,31H
	LOP_IN:
		MOV [SI], AX;玩家编号存入串
		INC SI;地址加一
		INC AX;玩家编号加一
		POP CX;弹出玩家总人数
		PUSH CX;入栈玩家总人数
		SUB CX,AX;是否所有编号已入栈
		JNE LOP_IN;循环
		MOV AX,'$';标志位
		MOV [SI],AX  ;标志位放于串尾
		POP CX ;弹出玩家总人数
		JMP PLAYING;开始游戏
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;开始进行游戏
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
	JMP ROUND;开始游戏循环
	
ROUND:;循环
	LEA SI,REST;获得剩余玩家人数
	MOV AX,[SI]
	MOV AH,0
	CMP AX,1;是否只剩一名玩家
	JE PRI;输出结果
	LEA SI,INDEX
	MOV AX,[SI];GET INDEX
	MOV AH,0
	
	LEA SI,M
	MOV BX,[SI];GET M
	MOV BH,0
	SUB BX,30H
	DEC AX;M减一，方便根据取余方式确定鼓声结束后待删除位置
	ADD AX,BX  ;ADD INDEX AND M TO SUM(AX)
	
	LEA SI,REST
	MOV BX,[SI]
	PUSH BX;PUSH REST
	DIV BL;CACU MOD, SUM%REST=AX
	MOV AL,AH
	MOV AH,0

	CMP AX,0;标记取余结果
	
	JE ZER;为0 则跳转
	LEA SI,TODELE;SET THE TODELE
	MOV [SI],AX
	LEA SI,INDEX;SET INDEX
	MOV [SI],AX;SET REST
	POP AX;POP REST
	DEC AX
	LEA SI,REST
	MOV [SI],AX
	JMP DELE;根据TODELE删除淘汰指定玩家
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
		JMP DELE;根据TODELE淘汰指定玩家
	DELE:
		MOV CX,'$'
		LEA SI,TODELE
		MOV BX,[SI];GET DELE PLACE
		MOV BH,0
		
		LEA SI,LIST_CH
		ADD SI,BX;让SI指向待删除玩家位置的后一位
		;;;;;;;;;
		MOV AX,SI
		DEC AX
		MOV DX,[SI]
		MOV DH,0
		PUSH SI
		MOV SI,AX
		MOV [SI],DX;将玩家位置前移，
				   ;覆盖前一个玩家位置。第一个被覆盖的是被删除玩家
		
		POP SI
		CMP DX,CX
		JE ROUND;移动到标志位$，跳转继续下一轮游戏
		LOP_D:
			MOV AX,SI
			INC SI
			MOV DX,[SI]
			MOV DH,0;依次将玩家位置前移，
			PUSH SI ;覆盖前一个玩家位置。第一个被覆盖的是被删除玩家
			MOV SI,AX
			MOV [SI],DX
			POP SI
			CMP DX,CX
			JE ROUND;移动到标志位$，跳转继续下一轮游戏
			JMP LOP_D;继续移动
;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRI:;输出结果
	MOV DL,0AH
	MOV AH,6H
	INT 21H
	LEA DX,STRING4;输出提示信息
	MOV AH,9H
	INT 21H
	
	LEA SI,LIST_CH;获得最后游戏结束时的玩家列表
	MOV AX,[SI]
	;ADD AX,30H
	MOV AH,0
	PUSH AX;未淘汰编号入栈
	MOV DX,AX
	MOV AH,6H
	INT 21H
	
	MOV DL,0AH;回车
	INT 21H
	
	LEA DX,STRING5;输出淘汰信息
	MOV AH,9H
	INT 21H
	LEA SI,N
	MOV BX,[SI];初始总人数
	MOV BH,0
	MOV CX,0
	MOV DX,30H;输出淘汰的标号
	LOP_OUT:
		INC DL
		CMP DX,BX
		JA FIN;输出结束，跳转到结束段
		POP AX
		PUSH AX
		CMP AX,DX;比较当前输出的编号是否是赢家的编号
		JE LOP_OUT;是跳过该编号
		MOV AH,6H
		INT 21H;输出编号
		JMP LOP_OUT;循环继续输出

FIN:
	MOV AH,4CH
	INT 21H
CODES ENDS
    END START























