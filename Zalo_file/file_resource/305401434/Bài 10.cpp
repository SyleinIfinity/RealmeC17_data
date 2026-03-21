#include<stdio.h>
int main()
{
    int i, n, Tong;
    printf("Nhap so nguyen duong n: ");
    scanf("%d", &n);
    Tong=0;
    for (i=1; i<=n/2; i++)
	{
        if (n%i==0)
		{
            Tong = Tong + i;
        }
    }
    if (Tong==n)
        printf("%d la so hoan hao.\n", n);
	else
        printf("%d khong phai la so hoan hao.\n", n);
}

