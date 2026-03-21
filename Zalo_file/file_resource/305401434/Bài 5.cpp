#include<stdio.h>
main()
{
	int i, j, m, n, S;
	m=0;
	n=0;
	i=1;
	while(i<=3)
	{
		j=5;
		while(j>=1)
		{
			m=S;
			S=S+i+j;
			printf("i=%d , j=%d -> %d + %d + %d = %d\n",i,j,m,i,j,S);
			j=j-2;
		}
		i++;
	}
}
