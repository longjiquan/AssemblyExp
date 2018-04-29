#include<stdio.h>


#ifdef __cplusplus
extern "C" {
#endif
int asm_avg(int num1,int num2,int num3);
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
	int a = 80;
	int b = 90;
	int c = 100;
	
	asm_avg(a, b, c);
}
