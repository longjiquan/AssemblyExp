.386
.model flat, c
.code
public isGoods

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;int isGoods(int firstAddr,int goodsNameAddr);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isGoods proc firstAddr:dword,goodsNameAddr:dword
	push ecx;计数器
	push esi
	push ebx
	push edi
	push edx
	mov ebx,firstAddr
	mov edi,goodsNameAddr
	mov eax,0;偏移数
isGoodsCycle:
	mov ecx,10
	mov esi,0
isGoodsCmp:
	mov dl,byte ptr [ebx+esi]
	cmp dl,byte ptr [edi+esi]
	jne next_goods
	inc esi
	dec ecx
	jnz isGoodsCmp
	jmp isGoodsRet;成功找到
next_goods:
	add eax,20
	cmp eax,600
	jne isGoodsCycle
isGoodsRet:
	pop edx
	pop edi
	pop ebx
	pop esi
	pop ecx
	ret;返回值为eax
isGoods endp

end
