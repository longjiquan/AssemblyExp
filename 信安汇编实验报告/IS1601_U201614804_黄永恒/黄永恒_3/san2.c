#include <stdio.h>
#include <stdlib.h>

int strcmp1(char *s, char *t)
{
    int i=0;
    while((s[i]==t[i])&&s[i]!='\0')
                i++;
    if (s[i]=='\0')
        return 1;
    else
        return 0;
}
int main()
{
    char s[]={'a','b','c','d'},t[10];
    int h;
    printf("Please input characters:\n");
    scanf("%s",t);
    h=strcmp1(s,t);
    printf("%d",h);
    return 0;
}

