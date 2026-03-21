#include<stdio.h>
main()
{
    int n, i, Tong;
    printf("Nhap so nguyen duong n: ");
    scanf("%d", &n);
    Tong=0;
    i=0;
    while(i<=n)
    {
    	if(i%2==0)
    		Tong=Tong+i;
    	i++;
	}
    printf("Tong cac so chan tu 1 den %d la: %d\n", n, Tong);
}

