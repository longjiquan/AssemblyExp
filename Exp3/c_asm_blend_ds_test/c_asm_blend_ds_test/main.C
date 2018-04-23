#include<stdio.h>

int num = 20;

#ifdef __cplusplus
extern "C" {
#endif
int asm_avg(void);
#ifdef __cplusplus
}
#endif

int printv(int v)
{
	printf("avg = %d\n", v);
	return v;
}

int main(void)
{
	int addr = &num;
	_asm mov ebx, addr;
	
	asm_avg();
}
