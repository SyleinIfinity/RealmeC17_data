#include <stdio.h>
#include <stdlib.h>
#include <time.h>
void NHAP_MT(int mt[][10],int m1, int n1 )
{
	int h, c;
	for (h=1; h<=m1; h++)
		for (c=1;c<=n1;c++)
		{
			//printf("a[%d %d] = ",h, c);
			//scanf("%d", &mt[h][c]);
			mt[h][c] = rand()%11+10; 
		}	
}
void IN_MT(int mt[][10], int m1, int n1)
{
	int h, c;
	for (h=1; h<=m1; h++)
	{
		for (c=1;c<=n1;c++)
			printf("%4d ", mt[h][c]);
		printf("\n");	
	}			
}
main()
{
	int a[10][10], m, n, h, c;
	srand((int)time(0)); 
	printf("Nhap so hang va so cot: ");
	scanf("%d%d", &m, &n);
	NHAP_MT(a,m, n );
	//In 
	IN_MT(a, m, n);		
	
}
