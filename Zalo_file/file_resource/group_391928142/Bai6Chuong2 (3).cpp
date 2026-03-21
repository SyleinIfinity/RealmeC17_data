#include<stdio.h>
#include<time.h>
#include <stdlib.h>
//int i;
struct NUT
	{
		int dlieu;
		NUT *tiep;
	};
//HAm bo sung FIFO
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

int KiemTraTrungLap(NUT *Dau, int x) {
    NUT *tg = Dau;
    while (tg != NULL) {
        if (tg->dlieu == x) {
            return 1;
        }
        tg = tg->tiep;
    }
    return 0;
}

void NHAP_RANDOM(NUT **Dau, NUT *ptu) {
    	int i, spt;
    	printf("Nhap vao so luong: ");
    	scanf("%d", &spt);

    	ptu = NULL;
    	NUT *tg = NULL;

    	for (i = 1; i <= spt; i++) {
        	int so;
       	do
		{
            so = 1 + rand() % spt;
        	} while (KiemTraTrungLap(ptu, so) == 1);
       	NUT *NutMoi;
       	NutMoi = new NUT;
	  	NutMoi->dlieu = so;
        	NutMoi->tiep = NULL;
        	if (ptu == NULL) {
            ptu = NutMoi;
            tg = NutMoi;
        	} else {
            tg->tiep = NutMoi;
            tg = NutMoi;
        	}
    	}
    	*Dau = BOSUNG_RAN_FIFO(*Dau,ptu);
}

//In ra danh sach lien ket
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
//ham main
main()
{
	NUT *Head, *p;
	Head = NULL;
	srand(time(0));
    	NHAP_RANDOM(&Head, p);
	printf("Danh sach lien ket :\n");
    	IN_DSLK(Head);
}
