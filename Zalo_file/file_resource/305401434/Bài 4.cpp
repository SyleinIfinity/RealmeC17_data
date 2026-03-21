#include<stdio.h>
main()
{
	int i, n, S;
	printf("Nhap n:");
	scanf("%d", &n);
	S=1;
	if(n>0)
	{
		i=1;
		while(i<=n)
		{
			S=S*i;
			i++;
		}
		printf("S=%d", S);
	}
	else
		printf("Nhap lai");
}
