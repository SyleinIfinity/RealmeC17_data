#include <stdio.h>
//Xay dung ham nhap day so
//Vao: day so (chua co gia tri), so phan tu (co gia tri)
//Ra: day so (co gia tri)
void NHAPDS(int ds[], int spt)
{
	int i;
	for (i=1;i<=spt;i++)
	{
		printf("Nhap so thu %d: ", i);
		scanf("%d", &ds[i]);
	}
}
//In day so
//Vao: day so, so phan tu
//Ra: hien thi
void IN_DS(int ds[], int spt)
{
	int i;
	for (i=1;i<=spt;i++)
		printf("%d ", ds[i]);
}
int TONGDS(int ds[], int spt)
{
	int i, S;
	S = 0;
	for (i=1;i<=spt;i++)
		S = S +ds[i];
	return S;		
}
main()
{
	int a[100], n;
	printf("Nhap bao nhieu so: ");
	scanf("%d", &n);
	NHAPDS(a, n);
	IN_DS(a, n);
	printf("\nTong la %d",TONGDS(a, n ));		
}
