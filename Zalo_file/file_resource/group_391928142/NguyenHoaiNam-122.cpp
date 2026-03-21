#include<stdio.h>
struct NUT 	{
				float so;
				NUT *tiep; 
			};
NUT *TAONUT(float DLIEU)
{
	NUT *NUT_MOI ;
	NUT_MOI = new NUT;
	NUT_MOI->so = DLIEU;
	NUT_MOI->tiep = NULL;
	return NUT_MOI;
}
NUT *CHEN_S(NUT *DAU, float DLIEU)
{
	
	NUT *trg,*PTU;
	PTU = TAONUT(DLIEU);
	if(DAU == NULL)
		DAU = PTU;
	else
	{
		trg = DAU;
		while(trg->tiep != NULL)
			trg = trg->tiep;
		trg->tiep = PTU;
	}
	return DAU;
}
NUT *CHEN_T(NUT *DAU, float DLIEU)
{
	NUT *PTU;
	PTU=TAONUT(DLIEU);
	if(DAU == NULL)
		DAU = PTU;
	else
	{
		PTU->tiep = DAU;
		DAU = PTU;
	}
	return DAU;
}
NUT *CHEN_PTU(NUT *DAU, float DLIEU)
{   
    NUT *trg = DAU ;
    NUT *t;
    NUT *PTU;
    if(trg->so > DLIEU)
        DAU= CHEN_T(DAU, DLIEU); 
    else  
    {
        while(trg != NULL && trg->so < DLIEU)
        {
           t = trg;
           trg = trg->tiep;
        }
        PTU = TAONUT(DLIEU);
        PTU->tiep = t->tiep;
        t->tiep= PTU;
    }
    return DAU;
}
NUT *TK(NUT *DAU, float DLIEU)
{
	NUT * trg = DAU;
	while(trg != NULL)
	{
		if(trg->so == DLIEU)
			return trg;
		trg= trg->tiep;
	}
	return NULL;
}
	
NUT *XOA(NUT *DAU, float DLIEU)
{
	NUT *trg = TK(DAU,DLIEU);
	NUT *tr;
	if(trg == DAU)
	{
		DAU = trg->	tiep;
		trg->tiep=NULL;
	}
	else
	{
		tr = DAU;
		while(tr->tiep != trg )
			tr = tr->tiep;
		tr->tiep = trg->tiep;
		trg->tiep = NULL;
	}
	return DAU;
}
NUT *SAPXEP_T(NUT *DAU)
{
    NUT *TANG = NULL;
    NUT *trg ;
    while(DAU!=NULL)
    {   
        trg=DAU;
        DAU = trg->tiep;
        trg->tiep=NULL;
        if(TANG == NULL)
            TANG = trg;
        else
        {
            TANG=CHEN_PTU(TANG,trg->so );
        }
            
    }
    return TANG;
}
NUT *GHEP(NUT *DAU1, NUT *DAU2)
{
	NUT *trg = DAU1;
	while(trg->tiep != NULL)
		trg = trg->tiep;
	trg->tiep = DAU2;
	DAU2=NULL;
	return DAU1;
}
void XUAT(NUT *DAU)
{
	NUT* tg = DAU;
    while (tg != NULL) {
        printf("%.2f -> ", tg->so);
        tg = tg->tiep;
    }
    printf("NULL\n");
}
main()
{
	NUT *H,*T,*H2;
	int luachon, n;
	float gtr;
	H=NULL;
	H2=NULL;
	do{
		printf("------------------menu----------------\n");
		printf("| 1. Nhap danh sach lien ket FIFO    |\n");
		printf("| 2. Nhap danh sach lien ket LIFO    |\n");
		printf("| 3. Chen 1 so thich hop vao day tang|\n");
		printf("| 4. Xoa 1 phan tu ra khoi danh sach |\n");
		printf("| 5. Sap xep cho day tang dan        |\n");
		printf("| 6. Kiem tra 1 so co trong day      |\n");
		printf("| 7. Ghep 2 day thanh 1 day tang     |\n");
		printf("| 0. Thoat                           |\n");
		printf("------------------menu----------------\n");
		printf("nhap vao lua chon: ");
		scanf("%d",&luachon);
		switch(luachon)
		{
			case 1:
				printf("nhap vao cac gia tri(nhap gtri khac so de ket thuc): ");
			 	do
				{
	                if (scanf("%f", &gtr) != 1) 
						break;
	                H=CHEN_S(H,gtr);
	            } while (true);
	            while(getchar() != '\n');
	            XUAT(H);
	            break;
	        case 2:
	        	printf("nhap vao cac gia tri(nhap gtri khac so de ket thuc): ");
			 	do
				{
	                if (scanf("%f", &gtr) != true)
						break;
	                H=CHEN_T(H,gtr);
	            } while (true);
	            while(getchar() != '\n');
	            XUAT(H);
	            break;
	        case 3:
                printf("Nhap vao gia tri can chen: ");
                scanf("%f",&gtr);
                H=CHEN_PTU(H,gtr);
                XUAT(H);
                break;
            case 4:
            	printf("Nhap vao so can xoa: ");
            	scanf("%f",&gtr);
            	H=XOA(H,gtr);
            	XUAT(H);
            	break;
            case 5:
            	H=SAPXEP_T(H);
            	printf("Day sau khi sap xep: \n");
            	XUAT(H);
            	break;
            case 6:
            	printf("Nhap vao so can tim: ");
            	scanf("%f",&gtr);
            	T = TK(H,gtr);
            	if(T==NULL)
            		printf("So %0.2f khong co trong day !\n",gtr);
            	else
            		printf("So %0.2f co xuat hien trong day !\n",gtr);
            	break;
            case 7:
            	printf("nhap vao day thu 2: \n");
            	printf("------------------menu----------------\n");
            	printf("| 1. Nhap danh sach lien ket FIFO    |\n");
				printf("| 2. Nhap danh sach lien ket LIFO    |\n");
				printf("| 0. Thoat                           |\n");
				printf("------------------menu----------------\n");
				printf("Nhap vao lua chon: ");
				scanf("%d",&n);
				switch(n)
				{
					case 1:
						printf("nhap vao cac gia tri(nhap gtri khac so de ket thuc): ");
					 	do
						{
			                if (scanf("%f", &gtr) != 1) 
								break;
			                H2=CHEN_S(H2,gtr);
			            } while (true);
			            while(getchar() != '\n');
			            XUAT(H2);
		            	break;
					case 2:
						printf("nhap vao cac gia tri(nhap gtri khac so de ket thuc): ");
					 	do
						{
			                if (scanf("%f", &gtr) != 1) 
								break;
			                H2=CHEN_T(H2,gtr);
			            } while (true);
			            while(getchar() != '\n');
			            XUAT(H2);
		            	break;	
					case 0:	
						printf("Thoat chuong trinh !");
	        			break;
	        		default:
			        	printf("gia tri nhap vao khong hop le vui long nhap lai\n");
				}	
            	H=GHEP(H,H2);
            	H=SAPXEP_T(H);
            	printf("Day so sau khi ghep: \n");
            	XUAT(H);
            	break;
	        case 0:
	        	printf("Thoat chuong trinh !");
	        	break;
	        default:
	        	printf("gia tri nhap vao khong hop le vui long nhap lai\n");
	        	break;
		}
	}while(luachon!=0);
	

}
