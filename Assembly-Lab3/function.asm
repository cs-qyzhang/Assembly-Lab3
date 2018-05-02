; ==========================================
; Assembly-Lab3.asm
; ������Գ������ʵ����
; Created by qiuyang.Zhang at 2018.4.15
; ==========================================
.386
.model	flat, stdcall
option  casemap:none

include    C:\masm32\include\windows.inc
include    C:\masm32\macros\macros.asm

;===========��������==================
strlen		proto C, lpszString:dword
;========Goods�ṹ����================
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
changeFlag1	byte GOODSNUM dup(1)	;1����ı���Ҫ����������
changeFlag2	byte GOODSNUM dup(1)

public	 	ptrShop1, ptrShop2
;=================================STACK==========================================================
.stack 4096
;=================================CODE===========================================================
.code
; -------------------------------------
; �������ƣ�FindGoods
; �������ܣ�������Ʒ���̵��е�λ��
; ��ڲ�����goodsName:dword, ��Ʒ���׵�ַ
; ���ڲ�����eax, ��Ʒ�±꣬��0��ʼ(��δ�ҵ��򷵻�-1)
;--------------------------------------
FindGoods	proc uses ebx ecx edx esi edi es, goodsName:DWORD
	mov	eax, ds
	mov	es, eax
	mov	ebx, 0			;��ʼ��λ����Ϣ
	mov	edx, GOODSNUM
	LOOPA:	mov	edi, goodsName	;����Ʒ�����׵�ַ��ֵ��edi
		lea	esi, shop1[ebx].goodsName	;��shop1��Ʒ���Ƶ��׵�ַ��ֵ��esi
		invoke	strlen, esi
		mov	ecx, eax	;����Ʒ���ַ������ȸ�ֵ��ecx�����Ƚ�ecx���ж��ַ��������Ƿ����
		repz	cmpsb
		jne	N1		;����ȣ�����N1����ѭ��
		jmp	N2		;�ַ�����ȣ�����N2����λ����Ϣeax������������

	N1:	inc	ebx		;λ����Ϣ��һ
		dec	edx
		jnz	LOOPA
		mov	ebx, -1
N2:	mov	eax, ebx
	ret
FindGoods	endp
; -------------------------------------
; �������ƣ�CalcuProfit
; �������ܣ�������Ʒ���̵��е�������
; ��ڲ�������
; ���ڲ�������
;--------------------------------------
CalcuProfit	proc uses ebx ecx edx esi edi
	mov	ebx, 0
	mov	ecx, GOODSNUM
	;����shop1����Ʒ��������
	loop1:	.if	changeFlag1[ebx] == 0
			jmp	N1
		.endif
		mov	eax, shop1[ebx].inPrice		;����Ʒ�Ľ����۸�ֵ��eax
		mov	edx, shop1[ebx].quantity	;����Ʒ�Ľ���������ֵ��edx
		mul	edx
		push	eax

		mov	eax, shop1[ebx].outPrice	;����Ʒ�����ۼ۸�ֵ��eax
		mov	edx, shop1[ebx].sold		;����Ʒ������������ֵ��edx
		mul	edx
		push	eax

		pop	eax				;ȡ�����ۼ۳�����������
		pop	edx				;ȡ�������۳��Խ�������
		sub	eax, edx			;���ۼ۳�����������-�����۳��Խ�������->eax
		idiv	edx
		mov	shop1[ebx].profitRate, eax

	N1:	inc	ebx
		dec	ecx
		jnz	loop1

	mov	ebx, 0
	;����shop2����Ʒ��������
	loop2:	.if	changeFlag1[ebx] == 0
			jmp	N2
		.endif
		mov	eax, shop2[ebx].inPrice		;����Ʒ�Ľ����۸�ֵ��eax
		mov	edx, shop2[ebx].quantity	;����Ʒ�Ľ���������ֵ��edx
		mul	edx
		push	eax

		mov	eax, shop2[ebx].outPrice	;����Ʒ�����ۼ۸�ֵ��eax
		mov	edx, shop2[ebx].sold		;����Ʒ������������ֵ��edx
		mul	edx
		push	eax

		pop	eax				;ȡ�����ۼ۳�����������
		pop	edx				;ȡ�������۳��Խ�������
		sub	eax, edx			;���ۼ۳�����������-�����۳��Խ�������->eax
		idiv	edx
		mov	shop2[ebx].profitRate, eax

	N2:	inc	ebx
		dec	ecx
		jnz	loop2
	

	ret
CalcuProfit	endp
end
; -------------------------------------
; �������ƣ�ChangeGoods
; �������ܣ��޸���Ʒ����Ϣ
; ��ڲ�����shop:dword, ����޸���һ���̵����Ʒ,pos:dword, ����޸��̵�ĵڼ�����Ʒ����0��ʼ��,goodsChange:dword, ����޸ĺ����Ʒ��Ϣ�ṹ��ָ��
; ���ڲ�������
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