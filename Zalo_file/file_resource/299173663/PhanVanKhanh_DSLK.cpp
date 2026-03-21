#include<stdio.h>
struct NUT
	{
		int dlieu;
		NUT *tiep;
	};
	
//HAm bo sung FIFO
NUT *TAONUT(int ptu)
{
	NUT *NutMoi ;
	NutMoi = new NUT;
	NutMoi->dlieu = ptu;
	NutMoi->tiep = NULL;
	return NutMoi;
}

NUT *BOSUNG_S(NUT *Dau,NUT *ptu)
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

//HAm bo sung LIFO
NUT *BOSUNG_D(NUT *Dau,NUT *ptu)
{
	if(Dau == NULL)
		Dau = ptu;
	else
	{
		ptu->tiep = Dau;
		Dau = ptu;
	}
	return Dau;
}

//Nhap kieu FIFO
void NHAP_DSLK_FIFO(NUT *&Dau, NUT *&ptu) {
    Dau = NULL;
    printf("Nhap vao ki tu so(nhap ki tu khac so de ket thuc): ");
    do {
        	ptu = new NUT;
        	if(scanf("%d", &ptu->dlieu) != 1)
        		break;
        	else
        	{
        		ptu->tiep = NULL;
     		Dau = BOSUNG_S(Dau, ptu);
		}
    }while (true);
}

//Nhap kieu LIFO
void NHAP_DSLK_LIFO(NUT *&Dau, NUT *&ptu) {
    Dau = NULL;
    printf("Nhap vao ki tu so(nhap ki tu khac so de ket thuc): ");
    do {
        	ptu = new NUT;
        	if(scanf("%d", &ptu->dlieu) != 1)
        		break;
        	else
        	{
	        	ptu->tiep = NULL;
	     	Dau = BOSUNG_D(Dau, ptu);
		}
    } while (true);
}
//In ra danh sach lien ket 
void IN_DSLK(NUT *Dau)
{
	NUT *tg;
	tg=Dau;
	while(tg != NULL)
	{
		printf("%d  ", tg->dlieu);
		tg = tg->tiep;
	}
	
}
NUT *CHEN_PTU(NUT *Dau,NUT *ptu, int x)
{   
    NUT *tg = Dau ;
    NUT *truoc;
    if(tg->dlieu > x)
        Dau= BOSUNG_D(Dau, ptu);
    else
    {
        while(tg != NULL && tg->dlieu < x)
        {
           truoc = tg;
           tg = tg->tiep;
        }
        ptu = TAONUT(x);
        ptu->tiep = truoc->tiep;
        truoc->tiep= ptu;
    }
    return Dau;
}

NUT *SapXep_Tang(NUT *Dau, NUT*ptu)
{
    NUT *tang = NULL;
    NUT *tg ;
    while(Dau!=NULL)
    {   
        tg=Dau;
        Dau = tg->tiep;
        tg->tiep=NULL;
        if(tang == NULL)
            tang = tg;
        else
        {
            tang=CHEN_PTU(tang, ptu, tg->dlieu);
        }
            
    }
    return tang;
}

NUT *TimKiem(NUT *DAU, int x)
{
	NUT *tg;
	tg = DAU;
	while(tg != NULL)
	{
		if(tg->dlieu == x)
			return tg;
		tg= tg->tiep;
	}
	return NULL;
}

NUT *XOA(NUT *Dau,int x)
{
    	NUT *truoc;
    	NUT *tg;
	do
	{
		tg = TimKiem(Dau, x);
		if(tg!= NULL)
			if(tg==Dau)
			{
				Dau = tg->tiep;
				tg->tiep = NULL;
			}
			else
			{
				truoc = Dau;
				while(truoc->tiep != tg)
					truoc = truoc->tiep;
				truoc->tiep = tg->tiep;
				tg->tiep = NULL;
			}
	}
	while(tg != NULL);
    return Dau;
}

NUT *GHEP(NUT *Dau1, NUT *Dau2)
{
	NUT *tg = Dau1;
	while(tg->tiep != NULL)
		tg = tg->tiep;
	tg->tiep = Dau2;
	Dau2=NULL;
	return Dau1;
}

main()
{
	NUT *Head, *Head2, *ptu, *tg;
	int so;
	Head = NULL;
	nhan:
	printf("--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--");
	printf("\n");
	printf("|(0)Ket thuc chuong trinh						\n");
	printf("|(1)Tao day so luu trong DSLK dang LIFO			\n");
	printf("|(2)Tao day so luu trong DSLK dang FIFO			\n");
	printf("|(3)Chen 1 so thich hop vao trong day so tang dan	\n");
	printf("|(4)Xoa 1 so trong day so						\n");
	printf("|(5)Sap xep day so tang dan					\n");
	printf("|(6)Kiem tra 1 so co trong day so khong?			\n");
	printf("|(7)Co hai day so, ghep hai day so thanh 1 day tang dan\n");
	printf("\n");
	printf("--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--");
	printf("\n");
	int n;
	printf("Nhap vao lua chon: ");
     scanf(" %d", &n);
	switch(n)
	{
		case 0:
			printf("Ket thuc chuong trinh");
			break;
		case 1:
			NHAP_DSLK_LIFO(Head, ptu);
			printf("\nDanh sach LIFO: \n");
			IN_DSLK(Head);
			break;
		case 2:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach FIFO: \n");
			IN_DSLK(Head);
			break;
		case 3:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach FIFO: \n");
			IN_DSLK(Head);
			fflush(stdin);
			printf("\nNhap vao so de chen: ");
			scanf("%d", &so);
			CHEN_PTU(Head, ptu, so);
			printf("\nDanh sach sau khi chen: \n");
			IN_DSLK(Head);
			break;
		case 4:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach FIFO: \n");
			IN_DSLK(Head);
			fflush(stdin);
			printf("\nNhap vao so de xoa: ");
			scanf("%d", &so);
			Head = XOA(Head, so);
			printf("\nDanh sach sau khi xoa: \n");
			IN_DSLK(Head);
			break;
		case 5:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach FIFO: \n");
			IN_DSLK(Head);
			fflush(stdin);
			SapXep_Tang(Head, ptu);
			printf("\nDanh sach sau khi sap xep: \n");
			IN_DSLK(Head);
			break;
		case 6:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach FIFO: \n");
			IN_DSLK(Head);
			fflush(stdin);
			printf("\nNhap vao so de tim kiem: ");
			scanf("%d", &so);
			if(TimKiem(Head, so) != NULL)
				printf("\nSo co ton tai trong dslk");
			else
				printf("\nSo khong ton tai trong dslk");
			break;
		case 7:
			NHAP_DSLK_FIFO(Head, ptu);
			printf("\nDanh sach 1: \n");
			IN_DSLK(Head);
			fflush(stdin);
			printf("\n");
			NHAP_DSLK_FIFO(Head2, ptu);
			printf("\nDanh sach 2: \n");
			IN_DSLK(Head);
			printf("\n");
			fflush(stdin);
			GHEP(Head, Head2);
			SapXep_Tang(Head, ptu);
			IN_DSLK(Head);
			break;
		default:
			printf("Lua chon khong hop le.");
			goto nhan;
	}
}
