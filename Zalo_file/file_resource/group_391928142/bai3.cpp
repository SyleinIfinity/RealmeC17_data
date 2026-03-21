#include <stdio.h>

// Định nghĩa nút của danh sách liên kết
typedef struct NUT {
    int so;
    NUT *tiep;
} NUT;

// Hàm để tạo một nút mới
NUT *TAONUT(int so) {
    NUT *NUTMoi = new NUT;
    NUTMoi->so = so;
    NUTMoi->tiep = NULL;
    return NUTMoi;
}

// Hàm để thêm một nút vào cuối danh sách
NUT *THEMNUT_C(NUT *Dau, int soMoi) {
    NUT *NUTMoi = TAONUT(soMoi);
    if (Dau == NULL) {
        return NUTMoi;
    }
    NUT *cuoi = Dau;
    while (cuoi->tiep != NULL) {
        cuoi = cuoi->tiep;
    }
    cuoi->tiep = NUTMoi;
    return Dau;
}

NUT *CHEN_T(NUT *Dau, float so)
{
	NUT *PTU;
	PTU=TAONUT(so);
	if(Dau == NULL)
		Dau = PTU;
	else
	{
		PTU->tiep = Dau;
		Dau = PTU;
	}
	return Dau;
}

NUT *CHEN_PTU(NUT *Dau, float so)
{   
    NUT *tg = Dau ;
    NUT *t;
    NUT *PTU;
    if(tg->so > so)
        Dau= CHEN_T(Dau, so); 
    else  
    {
        while(tg != NULL && tg->so < so)
        {
           t = tg;
           tg = tg->tiep;
        }
        PTU = TAONUT(so);
        PTU->tiep = t->tiep;
        t->tiep= PTU;
    }
    return Dau;
}
NUT *TK(NUT *Dau, float so)
{
	NUT * tg = Dau;
	while(tg != NULL)
	{
		if(tg->so == so)
			return tg;
		tg= tg->tiep;
	}
	return NULL;
}
// Hàm để sắp xếp danh sách bằng Insertion Sort
NUT *SAP_XEP(NUT *Dau) {
    NUT *TANG = NULL;
    NUT *tg ;
    while(Dau!=NULL)
    {   
        tg=Dau;
        Dau = tg->tiep;
        tg->tiep=NULL;
        if(TANG == NULL)
            TANG = tg;
        else
        {
            TANG=CHEN_PTU(TANG,tg->so );
        }
            
    }
    return TANG;
}

// NUT* sortedInsert(NUT* newNUT, NUT* sorted) {
    
//     // Special case for the head end
//     if (sorted == NULL || 
//         sorted->so >= newNUT->so) {
//         newNUT->tiep = sorted;
//         sorted = newNUT;
//     }
//     else {
//         NUT* curr = sorted;
        
//         // Locate the NUT before the point
//           // of insertion
//         while (curr->tiep != NULL && 
//                curr->tiep->so < newNUT->so) {
//             curr = curr->tiep;
//         }
//         newNUT->tiep = curr->tiep;
//         curr->tiep = newNUT;
//     }
    
//     return sorted;
// }

// Hàm để in danh sách liên kết
void IN(NUT *NUT) {
    while (NUT != NULL) {
        printf("%d ", NUT->so);
        NUT = NUT->tiep;
    }
    printf("\n");
}

// Hàm để nhập danh sách từ người dùng
NUT *NHAP_DANH_SACH() {
    NUT *danhSach = NULL;
    int so;

    printf("Nhap cac phan tu (nhap 0 de ket thuc):\n");
    while (true) {
        scanf("%d", &so);
        if (so == 0) break; // Dừng khi người dùng nhập 0
        danhSach = THEMNUT_C(danhSach, so);
    }

    return danhSach;
}

// Hàm tách danh sách thành danh sách chẵn và lẻ
void TACH(NUT *Dau, NUT **danhSachChan, NUT **danhSachLe) {
    NUT *a = Dau;
    while (a != NULL) {
        if (a->so % 2 == 0) {
            *danhSachChan = THEMNUT_C(*danhSachChan, a->so);
        } else {
            *danhSachLe = THEMNUT_C(*danhSachLe, a->so);
        }
        a = a->tiep;
    }
}

// Hàm main
main() {
    NUT *danhSachLienKet = NHAP_DANH_SACH();
    printf("Danh sach ban dau:\n");
    IN(danhSachLienKet);

    // Sắp xếp danh sách
    danhSachLienKet = SAP_XEP(danhSachLienKet);
    printf("Danh sach sau khi sap xep:\n");
    IN(danhSachLienKet);

    // Tách danh sách
    NUT *danhSachChan = NULL;
    NUT *danhSachLe = NULL;
    TACH(danhSachLienKet, &danhSachChan, &danhSachLe);
    
    printf("Danh sach so chan:\n");
    IN(danhSachChan);
    printf("Danh sach so le:\n");
    IN(danhSachLe);

}