; ==========================================
; Assembly-Lab3.asm
; 汇编语言程序设计实验三
; Created by qiuyang.Zhang at 2018.4.15
; ==========================================
.386
.model	flat, stdcall
option  casemap:none

include    C:\masm32\include\windows.inc
include    C:\masm32\macros\macros.asm

;===========函数声明==================
strlen		proto C, lpszString:dword
;========Goods结构声明================
Goods	struct
        goodsName       byte  12 dup(0)
        inPrice         dword 0
        outPrice        dword 0
        quantity        dword 0
        sold            dword 0
        profitRate      dword 0
Goods   ends
;==================================DATA==========================================================
.data
GOODSNUM		equ 30
GOODSLENGTH	equ 32

caption		db "The first win32 program", NULL
shop1		Goods GOODSNUM dup (<>)
shop2		Goods GOODSNUM dup (<>)
ptrShop1 	dword shop1
ptrShop2		dword shop2
changeFlag1	byte GOODSNUM dup(1)	;1代表改变需要更新利润率
changeFlag2	byte GOODSNUM dup(1)

public	 	ptrShop1, ptrShop2
;=================================STACK==========================================================
.stack 4096
;=================================CODE===========================================================
.code
; -------------------------------------
; 函数名称：FindGoods
; 函数功能：查找商品在商店中的位置
; 入口参数：goodsName:dword, 商品名首地址
; 出口参数：eax, 商品下标，从0开始(如未找到则返回-1)
;--------------------------------------
FindGoods	proc uses ebx ecx edx esi edi es, goodsName:DWORD
	mov	eax, ds
	mov	es, eax
	mov	ebx, 0			;初始化位置信息
	mov	edx, GOODSNUM
	LOOPA:	mov	edi, goodsName	;将商品名的首地址赋值给edi
		lea	esi, shop1[ebx].goodsName	;将shop1商品名称的首地址赋值给esi
		invoke	strlen, esi
		mov	ecx, eax	;将商品名字符串长度赋值给ecx，即比较ecx次判断字符串长度是否相等
		repz	cmpsb
		jne	N1		;不相等，跳到N1继续循环
		jmp	N2		;字符串相等，跳到N2返回位置信息eax并返回主函数

	N1:	inc	ebx		;位置信息加一
		dec	edx
		jnz	LOOPA
		mov	ebx, -1
N2:	mov	eax, ebx
	ret
FindGoods	endp
; -------------------------------------
; 函数名称：CalcuProfit
; 函数功能：计算商品在商店中的利润率
; 入口参数：无
; 出口参数：无
;--------------------------------------
CalcuProfit	proc uses ebx ecx edx esi edi
	mov	ebx, 0
	mov	ecx, GOODSNUM
	;更新shop1中商品的利润率
	loop1:	.if	changeFlag1[ebx] == 0
			jmp	N1
		.endif
		mov	eax, shop1[ebx].inPrice		;将商品的进货价赋值给eax
		mov	edx, shop1[ebx].quantity	;将商品的进货总数赋值给edx
		mul	edx
		push	eax

		mov	eax, shop1[ebx].outPrice	;将商品的销售价赋值给eax
		mov	edx, shop1[ebx].sold		;将商品的已售数量赋值给edx
		mul	edx
		push	eax

		pop	eax				;取出销售价乘以已售数量
		pop	edx				;取出进货价乘以进货总数
		sub	eax, edx			;销售价乘以已售数量-进货价乘以进货总数->eax
		idiv	edx
		mov	shop1[ebx].profitRate, eax

	N1:	inc	ebx
		dec	ecx
		jnz	loop1

	mov	ebx, 0
	;更新shop2中商品的利润率
	loop2:	.if	changeFlag1[ebx] == 0
			jmp	N2
		.endif
		mov	eax, shop2[ebx].inPrice		;将商品的进货价赋值给eax
		mov	edx, shop2[ebx].quantity	;将商品的进货总数赋值给edx
		mul	edx
		push	eax

		mov	eax, shop2[ebx].outPrice	;将商品的销售价赋值给eax
		mov	edx, shop2[ebx].sold		;将商品的已售数量赋值给edx
		mul	edx
		push	eax

		pop	eax				;取出销售价乘以已售数量
		pop	edx				;取出进货价乘以进货总数
		sub	eax, edx			;销售价乘以已售数量-进货价乘以进货总数->eax
		idiv	edx
		mov	shop2[ebx].profitRate, eax

	N2:	inc	ebx
		dec	ecx
		jnz	loop2
	

	ret
CalcuProfit	endp
end
; -------------------------------------
; 函数名称：ChangeGoods
; 函数功能：修改商品的信息
; 入口参数：shop:dword, 存放修改哪一个商店的商品,pos:dword, 存放修改商店的第几个商品（从0开始）,goodsChange:dword, 存放修改后的商品信息结构的指针
; 出口参数：无
;--------------------------------------
ChangeGoods	proc uses ebx ecx edx esi edi, shop:dword, pos:dword, goodsChange:dword
	mov	ebx, shop
	mov	ecx, pos
	mov	edx, goodsChange
	.if	ebx == 1
		jmp	N1
	.elseif	ebx == 2
		jmp	N2
	.endif
	N1:	shop1[ecx].goodsName = [edx].goodsName
		shop1[ecx].inPrice = [edx].inPrice
		shop1[ecx].outPrice = [edx].outPrice
		shop1[ecx].quantity = [edx].quantity
		shop1[ecx].sold = [edx].sold
		shop1[ecx].profitRate = [edx].profitRate
		jmp	N3
	N2:	shop2[ecx].goodsName = [edx].goodsName
		shop2[ecx].inPrice = [edx].inPrice
		shop2[ecx].outPrice = [edx].outPrice
		shop2[ecx].quantity = [edx].quantity
		shop2[ecx].sold = [edx].sold
		shop2[ecx].profitRate = [edx].profitRate
N3:	ret
ChangeGoods	endp
	end