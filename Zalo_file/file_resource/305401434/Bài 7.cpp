#include<stdio.h>

int main() 
{
    int i, n;
    float Tong;
    printf("Nhap so nguyen duong n: ");
    scanf("%d", &n);
    Tong=0;
    for (i=1; i <= n; i++)
	{
        Tong = Tong + 1.0/i;
    }
    printf("Tong S = 1 + 1/2 + 1/3 + ... + 1/%d la: %.2f\n", n, Tong);
}
