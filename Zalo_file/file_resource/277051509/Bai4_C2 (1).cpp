#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct SinhVien {
    char masv[15]; 
    char tensv[50];
    char lop[20];
    float diemtrungbinh;
};

struct NUT {
    SinhVien sv;
    NUT* tiep;
};


NUT* BOSUNG_S(NUT* dau, SinhVien sv) {
    NUT* ptu = (NUT*)malloc(sizeof(NUT));
    ptu->sv = sv;
    ptu->tiep = NULL;

    if (dau == NULL) {
        return ptu;
    } else {
        NUT* tg = dau;
        while (tg->tiep != NULL) {
            tg = tg->tiep;
        }
        tg->tiep = ptu;
        return dau;
    }
}


NUT* NHAP_SV(NUT* head, int n) {
    for (int i = 1; i <= n; i++) {
        SinhVien sv;
        printf("Sinh vien thu %d:\n", i);
        printf("Nhap ma sinh vien: ");
        scanf("%15s", sv.masv);

        printf("Nhap ten sinh vien: ");
        scanf(" %49[^\n]", sv.tensv);

        printf("Nhap lop sinh vien: ");
        scanf("%19s", sv.lop);

        printf("Nhap diem trung binh: ");
        scanf("%f", &sv.diemtrungbinh);

        head = BOSUNG_S(head, sv);
    }
    return head;
}


void inDanhSach(NUT* dau) {
    printf("%-10s %-20s %-10s %-10s\n", "Ma SV", "Ten SV", "Lop", "DTB");
    printf("-------------------------------------------------------------\n");
    NUT* tg = dau;
    while (tg != NULL) {
        printf("%-10s %-20s %-10s %-10.2f\n", tg->sv.masv, tg->sv.tensv, tg->sv.lop, tg->sv.diemtrungbinh);
        tg = tg->tiep;
    }
}


void TachSv(NUT *dau, NUT **duoi5, NUT **tren5) {
    NUT *tg= dau;
    while (tg != NULL) {
        if (tg->sv.diemtrungbinh < 5) {
            *duoi5 = BOSUNG_S(*duoi5, tg->sv);
        } else {
            *tren5 = BOSUNG_S(*tren5, tg->sv);
        }
        tg = tg->tiep;
    }
}


void xoaSinhVienTheoLop(NUT** dau) {
    NUT* tg = *dau;
    NUT* truoc = NULL;
    char lop[20];

    printf("Nhap lop can xoa sinh vien: ");
    scanf("%19s", lop);

    while (tg != NULL) {
        if (strcmp(tg->sv.lop, lop) == 0) {
            if (truoc == NULL) 
			{
                *dau = tg->tiep;
                free(tg);
                tg = *dau;
            } 
			else
			{ 
                truoc->tiep = tg->tiep;
                free(tg);
                tg = truoc->tiep;
            }
        } else {
            truoc = tg;
            tg = tg->tiep;
        }
    }
}

// Hàm main
int main() {
    NUT* head = NULL;
    NUT* duoi5 = NULL;
    NUT* tren5 = NULL;
    int n;
    int luaChon;

    do {
        printf("\nChuong trinh quan ly sinh vien\n");
        printf("1. Nhap danh sach sinh vien\n");
        printf("2. In danh sach sinh vien\n");
        printf("3. Phan loai sinh vien theo diem\n");
        printf("4. Xoa sinh vien theo lop\n");
        printf("0. Thoat\n");
        printf("Nhap lua chon: ");
        scanf("%d", &luaChon);

        switch (luaChon) {
            case 1:
                printf("Nhap so luong sinh vien: ");
                scanf("%d", &n);
                head = NHAP_SV(head, n);
                break;
            case 2:
                printf("\nDanh sach sinh vien:\n");
                inDanhSach(head);
                break;
            case 3:
                TachSv(head, &duoi5, &tren5);
                printf("\nDanh sach sinh vien co diem trung binh tu 5 diem:\n");
                inDanhSach(tren5);
                printf("\nDanh sach sinh vien co diem trung binh duoi 5:\n");
                inDanhSach(duoi5);
                break;
            case 4:
                xoaSinhVienTheoLop(&head);
                break;
            case 0:
                printf("Thoat chuong trinh.\n");
                break;
            default:
                printf("Lua chon khong hop le. Vui long chon lai.\n");
        }
    } while (luaChon != 0);
}
