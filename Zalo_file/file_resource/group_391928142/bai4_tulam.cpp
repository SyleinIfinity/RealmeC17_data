#include <stdio.h>


struct SINHVIEN {
    char masv[15];
    char tensv[100];
    char lop[10];
    float dtb; 
}; 

struct NUT {
    SINHVIEN sv;
    NUT *tiep; 
}; 

NUT* BOSUNG_S(NUT *dau, NUT *ptu) {
    NUT *tg;
    if (dau == NULL) 
        dau = ptu;
    else {
        tg = dau;
        while (tg->tiep != NULL)
            tg = tg->tiep;
        tg->tiep = ptu; 
    } 
    return dau; 
} 

NUT* NHAP_SV(NUT *head, int n) {
    char tensv[100], masv[15], lop[10];
    float dtb;
	NUT *ptu; 

    for (int i = 1; i <= n; i++) {
        ptu= new NUT;
        ptu->tiep = NULL;
		fflush(stdin);
        printf("Sinh vien thu %d:\n", i);
        printf("Nhap ma sinh vien: ");
        gets(ptu->sv.masv);
        
        printf("Nhap ten cua sinh vien: ");
        gets(ptu->sv.tensv);

        printf("Nhap lop sinh vien dang hoc: ");
        gets(ptu->sv.lop);

        printf("Nhap diem trung binh cua sinh vien: ");
        scanf("%f", &ptu->sv.dtb); 

        head = BOSUNG_S(head, ptu);
        ptu= ptu->tiep; 
    } 
    return head; 
} 

void INDS_SV(NUT *dau) {
    NUT *tg = dau;

    printf("%-10s %-20s %-10s %-10s\n", "Ma SV", "Ten SV", "Lop", "DTB");
    printf("-------------------------------------------------------------\n");

    while (tg != NULL) {
        printf("%-10s %-20s %-10s %-10.2f\n", tg->sv.masv, tg->sv.tensv, tg->sv.lop, tg->sv.dtb); 
        tg = tg->tiep; 
    } 
} 
void TACHDANHSACH(NUT *head, NUT **DANHSACHTREN, NUT **DANHSACHDUOI){
	NUT *tg= head;
	while(tg!=NULL){
			NUT *ptu= new NUT;
			ptu->tiep= NULL;
			ptu->sv = tg->sv; 
			if (ptu->sv.dtb < 5)
            	*DANHSACHDUOI = BOSUNG_S(head, ptu);
        	else
            	*DANHSACHTREN = BOSUNG_S(head, ptu);

			tg=tg->tiep; 
	} 
} 

int main() {
    NUT *head = NULL;  
    NUT *DANHSACHTREN= NULL;
	NUT *DANHSACHDUOI=NULL; 
	int n; 
	        
    printf("Nhap so luong sinh vien can nhap: ");
    scanf("%d", &n); 
    head = NHAP_SV(head, n); 

    INDS_SV(head); 
    TACHDANHSACH(head,&DANHSACHTREN, &DANHSACHDUOI ); 
    printf("Danh sach sinh vien co diem trung binh tren 5 diem la: ");
    INDS_SV(DANHSACHTREN); 
    printf("Danh sach sinh vien co diem trung binh duoi 5 diem la: ");
    INDS_SV(DANHSACHDUOI);
	 
    return 0; 
}
