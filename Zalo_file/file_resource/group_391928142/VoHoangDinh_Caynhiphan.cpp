#include <stdio.h>

struct NUT {
    int dlieu;
    NUT *Trai, *Phai; 
}; 

NUT *BOSUNG_CAY(NUT *goc, NUT *ptu) {
    if (goc == NULL) 
        return ptu;
    else {
        NUT *tg = goc;
        NUT *truoc = NULL;
        
        while (tg != NULL) {
            truoc = tg;
            if (ptu->dlieu < tg->dlieu) 
                tg = tg->Trai;
            else 
                tg = tg->Phai;
            
        }
        if (ptu->dlieu < truoc->dlieu) 
            truoc->Trai = ptu;
        else 
            truoc->Phai = ptu;      
	}
    return goc; 
} 

void TrongCay(NUT *&goc) {
    int Giatri[] = {9, 10, 4, 3, 15, 23, 2, 67, 1, 29}; 
    int n = 10;  
    for (int i = 0; i < n; i++) {
        NUT *ptu = new NUT;
        ptu->dlieu = Giatri[i];
        ptu->Trai = NULL;
        ptu->Phai = NULL; 
        goc = BOSUNG_CAY(goc, ptu); 
    } 
} 

void DUYET_GIUA(NUT *goc) {
    if (goc != NULL) {
        DUYET_GIUA(goc->Trai);
        printf("%d ", goc->dlieu);
        DUYET_GIUA(goc->Phai); 
    } 
} 

void DUYET_TRUOC(NUT *goc) {
    if (goc != NULL) {
        printf("%d ", goc->dlieu);
        DUYET_TRUOC(goc->Trai);
        DUYET_TRUOC(goc->Phai); 
    } 
} 

void DUYET_SAU(NUT *goc) {
    if (goc != NULL) {
        DUYET_SAU(goc->Trai);
        DUYET_SAU(goc->Phai); 
        printf("%d ", goc->dlieu);
    } 
} 

int TIMKIEM(NUT *goc, int x) {
    if (goc == NULL)
        return 0;
    else {
        NUT *tg = goc;
        while (tg != NULL && tg->dlieu != x) {
            if (tg->dlieu > x)
                tg = tg->Trai;
            else
                tg = tg->Phai;
        } 
        return tg != NULL ? 1 : 0; 
    } 
} 

main() {
    NUT *goc = NULL;
    int x;
    int option;
    TrongCay(goc);
    do {
        printf("\n==================================================\n");
        printf("Gia tri cua cay: 9, 10, 4, 3, 15, 23, 2, 67, 1, 29\n");
        printf("==================================================\n");
        printf("\nMenu:\n");
        printf("1) Duyet giua\n");
        printf("2) Duyet truoc\n");
        printf("3) Duyet sau\n");
        printf("4) Tim kiem phan tu\n");
        printf("5) Chen phan tu\n");
        printf("6) Thoat\n");
        printf("Chon mot option: ");
        scanf("%d", &option);

        switch (option) {
            case 1:
                printf("Duyet giua: ");
                DUYET_GIUA(goc);
                printf("\n");
                break;
            case 2:
                printf("Duyet truoc: ");
                DUYET_TRUOC(goc);
                printf("\n");
                break;
            case 3:
                printf("Duyet sau: ");
                DUYET_SAU(goc);
                printf("\n");
                break;
            case 4:
                printf("Nhap gia tri ban muon tim kiem trong cay: ");
                scanf("%d", &x);
                if (TIMKIEM(goc, x))
                    printf("Da tim thay %d trong cay\n", x);
                else
                    printf("Khong tim thay\n");
                break;
            case 5: {
                int Giatri;
                printf("Nhap gia tri muon chen: ");
                scanf("%d", &Giatri);
                NUT *ptu = new NUT;
                ptu->dlieu = Giatri;
                ptu->Trai = NULL;
                ptu->Phai = NULL;
                goc = BOSUNG_CAY(goc, ptu);
                printf("Cay sau khi chen %d:\n", Giatri);
                DUYET_GIUA(goc);
                printf("\n");
                break;
            }
            case 6:
                printf("Thoat chuong trinh.\n");
                break;
            default:
                printf("Option khong hop le. Vui long chon lai.\n");
        }
    } while (option != 6);

}
