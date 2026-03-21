#include<stdio.h>
struct NUT
	{
		int dlieu;
		NUT *tiep;
	};

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

void NHAP_DSLK(NUT *&Dau, NUT *&ptu) {
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

NUT	*ChenVaoCuoi(NUT *Dau, NUT *ptu, int x)
{
    	NUT *tg;
	ptu = TAONUT(x);
    	if (Dau == NULL)
     	return ptu;
     else
     {
     	tg = Dau;
    		while (tg->tiep != NULL)
        		tg = tg->tiep;
    		tg->tiep = ptu;
	}

    return Dau;
}

NUT	*ChenVaoDau(NUT *Dau, NUT *ptu, int x)
{
	ptu = TAONUT(x);
    	if (Dau == NULL)
     	return ptu;
     else
     {
     	ptu->tiep = Dau;
     	Dau = ptu;
	}
    return Dau;
}

NUT *ChenSauNut(NUT *Dau, NUT *ptu, int spt, int viTri)
{
    	NUT *tg, *NutSau;
	tg = Dau;
    	int i = 1;
    	ptu = TAONUT(spt);
    	while (tg != NULL && i < viTri)
    	{
        	tg = tg->tiep;
        	i++;
    	}
    	if (tg == NULL)
	{
        	NUT *NutSau = Dau;
        	while (NutSau->tiep != NULL)
            	NutSau = NutSau->tiep;
        	NutSau->tiep = ptu;
    	}
	else
	{
        	ptu->tiep = tg->tiep;
        	tg->tiep = ptu;
    	}

    return Dau;
}

NUT *ChenTruocNut(NUT *Dau,NUT *ptu,int spt,int viTri)
{
	NUT *tg;
	int i =1;
	tg=Dau;
	ptu= TAONUT(spt);
	if(viTri==1)
	{
		ptu->tiep=Dau;
		Dau=ptu;
		return Dau;
	}
	else 
	{
		while(tg->tiep!=NULL && i<viTri-1)
		{
			tg=tg->tiep;
			i++;
		}
		ptu->tiep=tg->tiep;
		tg->tiep=ptu;
		return Dau;
	}
	return Dau;
}

NUT *XoaPhanTuDau(NUT *Dau)
{
    	if (Dau == NULL)
        return Dau;
     else
     {
     	    	NUT *ptuDau;
	ptuDau = Dau;
    	Dau = Dau->tiep;
    	delete ptuDau;
	}
    	
    	return Dau;
}

NUT *XoaPhanTuCuoi(NUT *Dau)
{
	NUT *ptuCuoi, *tg;
    	if (Dau == NULL)
        return Dau;
     else
     {
     	tg = Dau;
		ptuCuoi = NULL;
		while(tg->tiep != NULL)
		{
			ptuCuoi = tg;
			tg = tg->tiep;
		}
		if(ptuCuoi !=NULL)
		{
			ptuCuoi->tiep = NULL;
			delete tg;
		}
		else
		{
			delete Dau;
			Dau = NULL;
		}
	}
    	return Dau;
}

NUT *XoaSauNut(NUT *Dau,NUT *ptu)
{
    	NUT *NutSauDo;
    	if(Dau == NULL || ptu == NULL || ptu->tiep == NULL)
    		return Dau;
    	else
    	{
    		NutSauDo = ptu->tiep;
    		ptu->tiep = NutSauDo->tiep;
    		delete NutSauDo;
	}
	return Dau;
}

NUT *XoaTruocNut(NUT *Dau,NUT *ptu)
{
	NUT *truoc, *tg;
	if(Dau ==NULL || ptu==Dau)
		return Dau;
	else
	{
		truoc = NULL;
		tg = Dau;
		while(tg != NULL && tg->tiep != ptu)
		{
			truoc = tg;
			tg = tg->tiep;
		}
		
		if(tg == NULL)
			return Dau;
		else
			if(truoc != NULL)
				truoc->tiep = ptu;
			else
				Dau = ptu;
	}
    return Dau;
}

NUT *XoaToanBo(NUT *Dau)
{
    	NUT *NutHienTai, *NutSauDo;
    	NutHienTai = Dau;
    	while (NutHienTai != NULL)
	{
       	NutSauDo = NutHienTai->tiep;
       	delete NutHienTai;
       	NutHienTai = NutSauDo;
    	}
    	Dau=NULL;
    	return Dau;
}

void IN_DSLK(NUT *Dau)
{
	NUT *tg;
	tg=Dau;
	while(tg != NULL)
	{
		printf("%d ", tg->dlieu);
		if((tg->dlieu != NULL || tg->dlieu==0) && tg->tiep !=NULL)
			printf("-> ");
		tg = tg->tiep;
	}
}

main()
{
	NUT *Head, *Head2, *ptu, *tg;
	Head = NULL;
	int so, n;
	n = 0;
	NHAP_DSLK(Head, ptu);
	do
	{
		printf("\n");
		printf("--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--");
		printf("\n");
		printf("|(0)Ket thuc chuong trinh\n");
		printf("|(1)Chen phan tu (NUT) vao cuoi danh sach.\n");
		printf("|(2)Chen phan tu (NUT) vao dau danh sach.\n");
		printf("|(3)Chen phan tu (NUT) vao sau nut p.\n");
		printf("|(4)Chen phan tu (NUT) vao truoc nut p.\n");
		printf("|(5)Xoa phan tu(NUT) dau cua danh sach.\n");
		printf("|(6)Xoa phan tu(NUT) cuoi cua danh sach.\n");
		printf("|(7)Xoa phan tu (NUT) dung sau nut p.\n");
		printf("|(8)Xoa phan tu (NUT) dung truoc nut p.\n");
		printf("|(9)Xoa toan bo danh sach lien ket.\n");
		printf("\n");
		printf("--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--MENU--");
		printf("\n");
		fflush(stdin);
		printf("Nhap vao lua chon: ");
	     scanf(" %d", &n);
		switch(n)
		{
			case 0:
				printf("Ket thuc chuong trinh");
				break;
			case 1:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vao so de chen: ");
				scanf("%d", &so);
				Head = ChenVaoCuoi(Head, ptu, so);
				printf("\nDanh sach lien ket sau khi chen: \n");
				IN_DSLK(Head);
				break;
			case 2:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vao so de chen: ");
				scanf("%d", &so);
				Head = ChenVaoDau(Head, ptu, so);
				printf("\nDanh sach lien ket sau khi chen: \n");
				IN_DSLK(Head);
				break;
			case 3:
				int vitri;
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vao so de chen: ");
				scanf("%d", &so);
				printf("Nhap vi tri nut p (1 la nut dau): ");
				scanf("%d", &vitri);
				Head = ChenSauNut(Head, ptu, so, vitri);
				printf("\nDanh sach lien ket sau khi chen: \n");
				IN_DSLK(Head);
				break;
			case 4:
				int vitri2;
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vao so de chen: ");
				scanf("%d", &so);
				printf("Nhap vi tri nut p (1 la nut dau): ");
				scanf("%d", &vitri2);
				Head = ChenTruocNut(Head, ptu, so, vitri2);
				printf("\nDanh sach lien ket sau khi chen: \n");
				IN_DSLK(Head);
				break;
			case 5:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				Head = XoaPhanTuDau(Head);
				printf("\nDanh sach lien ket sau khi xoa: \n");
				IN_DSLK(Head);
				break;
			case 6:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				Head = XoaPhanTuCuoi(Head);
				printf("\nDanh sach lien ket sau khi xoa: \n");
				IN_DSLK(Head);
				break;
			case 7:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vi tri nut p (1 la nut dau): ");
				scanf("%d", &so);
				tg = Head;
				for (int i = 1; i < so && tg != NULL; i++)
					tg = tg->tiep;
				Head = XoaSauNut(Head, tg);
				printf("\nDanh sach lien ket sau khi xoa: \n");
				IN_DSLK(Head);
				break;
			case 8:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				fflush(stdin);
				printf("\nNhap vi tri nut p (1 la nut dau): ");
				scanf("%d", &so);
				tg = Head;
				for (int i = 1; i < so && tg != NULL; i++)
					tg = tg->tiep;
				Head = XoaTruocNut(Head, tg);
				printf("Da xoa phan tu dung truoc nut tai vi tri %d.\n", so);
				printf("\nDanh sach lien ket sau khi xoa: \n");
				IN_DSLK(Head);
				break;
			case 9:
				printf("\nDanh sach lien ket: \n");
				IN_DSLK(Head);
				Head = XoaToanBo(Head);
				printf("\nDanh sach lien ket sau khi xoa: \n");
				if(Head == NULL)
					printf("Danh sach lien ket rong:");
				break;
			default:
				printf("Lua chon khong hop le.");
				break;
		}
	} while(n!=0);
	
}

























