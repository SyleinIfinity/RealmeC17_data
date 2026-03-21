#include<stdio.h>
main()
{
    int i, j, n;
    float Tong;
    printf("Nhap so nguyen duong n: ");
    scanf("%d", &n);
    j=1;
    Tong=0;
    for (i=1; i<=n; i++)
	{
		j=j*i;
        Tong=Tong +1.0/j;
    }
    printf("Tong S = 1 + 1/2! + 1/3! + ... + 1/%d! la: %.4f\n", n, Tong);
}
