#include<stdio.h>
#include<time.h>
#include <stdlib.h>

struct NUT
	{
		int dlieu;
		NUT *tiep;
	};

NUT* TAONUT(int n)
{
	NUT *NutMoi= new NUT;
	NutMoi->dlieu = n;
	NutMoi->tiep = NULL;
	return NutMoi;
} 
NUT *BOSUNG_RAN_FIFO(NUT *Dau,NUT *ptu)
{
	NUT *tg;
	if(Dau == NULL)
		Dau = ptu;
	else
	{
		tg = Dau;
		while(tg->tiep != NULL)
			tg = tg->tiep;
		tg->tiep = ptu;
	}
	return Dau;
}

int KiemTraTrungLap(NUT *Dau, int x) 
{
    NUT *tg = Dau;
    while (tg != NULL) {
        if (tg->dlieu == x) 
		{
            return 1;
        }
        tg = tg->tiep;
    }
    return 0;
}

void NHAP_RANDOM(NUT *&Dau, NUT *&ptu) 
{
    int i, spt;
    printf("Nhap vao so luong: ");
    scanf("%d", &spt);

    NUT *Dau2 = NULL;
    NUT *tg = NULL;

    for (i = 1; i <= spt; i++) 
	{
        int so;
        do 
		{
            so = 1 + rand() % spt;
        } 
		while (KiemTraTrungLap(Dau2, so));
	NUT *NutMoi = TAONUT(so); 
	Dau = BOSUNG_RAN_FIFO(Dau, NutMoi);
    }
}
void IN_DSLK(NUT *Dau)
{
	NUT *tg;
	tg=Dau;
	while(tg != NULL)
	{
		printf("%d ", tg->dlieu);
		tg = tg->tiep;
	}
}
main()
{
	NUT *Head, *p;
	Head = NULL;
	srand(time(0));
    	NHAP_RANDOM(Head, p);
	printf("Danh sach lien ket :\n");
    	IN_DSLK(Head);
}
