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
void IN_DS_C(int ds[], int spt)
{
	int i;
	for (i=1;i<=spt;i++)
		if(ds[i]%2==0)
			printf("%d ", ds[i]);
}
//Xay dung ham in cac so chan ra man hình

int TONGDS(int ds[], int spt)
{
	int i, S;
	S = 0;
	for (i=1;i<=spt;i++)
		S = S +ds[i];
	return S;		
}
void HOANVI(int &x, int &y )
{
	int tg;
	tg = x;
	x = y;
	y = tg;
}
//Sap xep day so theo thu tu tang dan
void SXEP(int ds[], int spt)
{
	int t, s;
	for (t=1; t<=spt-1; t++)
		for (s= t+1; s<=spt; s++)
			if (ds[t]>ds[s])
				HOANVI(ds[t], ds[s]);			
}
main()
{
	int a[100], n;
	printf("Nhap bao nhieu so: ");
	scanf("%d", &n);
	NHAPDS(a, n);
	IN_DS(a, n);
	SXEP(a, n);
	printf("\nDay so da sap xep: \n");
	IN_DS(a, n);
	
}
