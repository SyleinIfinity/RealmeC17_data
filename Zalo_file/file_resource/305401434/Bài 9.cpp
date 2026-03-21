#include<stdio.h>
main()
{
    int i, x, y;
    float Tong;
    printf("Nhap x va y: ");
    scanf("%d%d", &x,&y);
    Tong=0;
    for (i=x; i<=y; i++)
	{
		Tong=Tong + i*i;
    }
    printf("Tong S=%f", Tong);
}
