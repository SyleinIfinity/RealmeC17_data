#include<stdio.h>
struct NUT{
	int dlieu;
	NUT *tiep; 
};
NUT *TAONUT( int n)
{
	NUT *PTU = new NUT;
	PTU->dlieu = n;
	PTU->tiep = NULL;
	return PTU;
}
NUT *THEM_S(NUT *DAU, int n)
{
	NUT *PTU = TAONUT(n);
	NUT *tg;
	if(DAU==NULL)
		DAU = PTU;
	else
	{
		tg = DAU;
		while(tg->tiep != NULL)
			tg= tg->tiep;
		tg->tiep = PTU;
	}
	return DAU;
}
NUT *CHEN_T(NUT *DAU, int n)
{
	NUT *PTU = TAONUT(n);
	NUT *tg;
	if(DAU==NULL)
		DAU = PTU;
	else
	{
		PTU->tiep =DAU;
		DAU=PTU;
	}
	return DAU;
}
NUT *CHEN_TANG(NUT*DAU,int n)
{
	NUT *tg, *t;
	NUT *PTU;
	if(DAU->dlieu>n)
		DAU=CHEN_T(DAU,n);
	else
	{
		tg = DAU;
		while(tg->tiep!=NULL && tg->dlieu<n)
			tg=tg->tiep;
		PTU=TAONUT(n);
		PTU->tiep = tg->tiep;
		tg->tiep=PTU;
	}
	return DAU;	
}
void TACH(NUT *DAU, NUT *&CHAN, NUT *&LE)
{
	NUT *tg;
	while(DAU!=NULL){
		tg = DAU;
		DAU = tg->tiep;
		tg->tiep = NULL;
		if(tg->dlieu %2==0)
			if(CHAN==NULL)
				CHAN = tg;
			else
				CHAN=CHEN_TANG(CHAN,tg->dlieu);
		else
			if(LE==NULL)
				LE=tg;
			else
				LE=CHEN_TANG(LE,tg->dlieu);
	}
}
NUT *NHAP(NUT *DAU)
{
	int n;
	printf("nhap vao gia tri(nhap 0 de ket thuc): ");
	do{
		scanf("%d",&n);
		if(n!=0)
			DAU=THEM_S(DAU,n);
	}while(n!=0);
	return DAU;
}
void INDSLK(NUT *DAU)
{
	NUT *tg=DAU;
	while(tg!=NULL)
	{
		printf("%d ",tg->dlieu);
		tg = tg->tiep;
	}
}
main()
{
	NUT *H,*H1,*H2;
	H=NULL;
	H1=NULL;
	H2=NULL;
	H=NHAP(H);
	TACH(H,H1,H2);
	printf("day sau khi tach \n");
	INDSLK(H1);
	printf("\n");
	INDSLK(H2);
}
