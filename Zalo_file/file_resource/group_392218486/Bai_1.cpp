#include <stdio.h>
#include <stdlib.h>
#include <time.h>
main()
{
	int a[10][10], m, n, h, c;
	srand((int)time(0)); 
	printf("Nhap so hang va so cot: ");
	scanf("%d%d", &m, &n);
	for (h=1; h<=m; h++)
		for (c=1;c<=n;c++)
		{
			//printf("a[%d %d] = ",h, c);
			//scanf("%d", &a[h][c]);
			a[h][c] = rand()%20+1; 
		}
	//In 
	for (h=1; h<=m; h++)
	{
		for (c=1;c<=n;c++)
			printf("%4d ", a[h][c]);
		printf("\n");	
	}		
	
}
