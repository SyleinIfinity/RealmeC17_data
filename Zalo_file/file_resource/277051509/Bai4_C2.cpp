#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct SinhVien {
    char masv[15]; 
    char tensv[50];
    char lop[20];
    float dtb;
};

struct NUT {
    struct SinhVien sv;
    struct NUT* tiep;
};

struct NUT* BS_SFF(struct NUT* dau, struct SinhVien sv) {
    struct NUT* ptu = (struct NUT*)malloc(sizeof(struct NUT));
    ptu->sv = sv;
    ptu->tiep = NULL;

    if (dau == NULL) {
        return ptu;
    } else {
        struct NUT* tg = dau;
        while (tg->tiep != NULL) {
            tg = tg->tiep;
        }
        tg->tiep = ptu;
        return dau;
    }
}

void Nhap_DSFF(struct NUT** Dau) {
    *Dau = NULL; // Initialize the head to NULL
    char Q;
    struct NUT* ptu;

    do {
        ptu = (struct NUT*)malloc(sizeof(struct NUT));

        printf("Nhap ma sinh vien: ");
        scanf("%s", ptu->sv.masv);

        printf("Nhap ten sinh vien: ");
        scanf(" %s", ptu->sv.tensv);

        printf("Nhap lop sinh vien: ");
        scanf("%s", ptu->sv.lop);

        printf("Nhap diem trung binh: ");
        scanf("%f", &ptu->sv.dtb);

        ptu->tiep = NULL;

        *Dau = BS_SFF(*Dau, ptu->sv);

        fflush(stdin);
        printf("Ban co muon nhap tiep khong (Y: co, N: khong): ");
        scanf(" %c", &Q);
    } 
    while (Q == 'Y' || Q == 'y');
}

void inDanhSach(struct NUT* dau) {
    printf("%-10s %-20s %-10s %-10s\n", "Ma SV", "Ten SV", "Lop", "DTB");
    printf("-------------------------------------------------------------\n");
    struct NUT* tg = dau;
    while (tg != NULL) {
        printf("%-10s %-20s %-10s %-10.2f\n", tg->sv.masv, tg->sv.tensv, tg->sv.lop, tg->sv.dtb);
        tg = tg->tiep;
    }
}

void TachSv(struct NUT *dau, struct NUT **dduoi5, struct NUT **dtren5) {
    struct NUT *tg = dau;
    while (tg != NULL) {
        if (tg->sv.dtb < 5) {
            *dduoi5 = BS_SFF(*dduoi5, tg->sv);
        } else {
            *dtren5 = BS_SFF(*dtren5, tg->sv);
        }
        tg = tg->tiep;
    }
}

void xoaSinhVienTheoLop(struct NUT** dau) {
    struct NUT* tg = *dau;
    struct NUT* truoc = NULL;
    char lop[20];

    printf("Nhap lop can xoa sinh vien: ");
    scanf("%19s", lop);

    while (tg != NULL) {
        if (strcmp(tg->sv.lop, lop) == 0) {
            if (truoc == NULL) {
                *dau = tg->tiep;
                tg = *dau;
            } else {
                truoc->tiep = tg->tiep;
                tg = truoc->tiep;
            }
        } else {
            truoc = tg;
            tg = tg->tiep;
        }
    }
}

int main() {
    struct NUT* head = NULL;
    struct NUT* duoi5 = NULL;
    struct NUT* tren5 = NULL;
    int n;
    int luaChon;

    do {
        printf("Chuong trinh quan ly sinh vien\n");
        printf("1. Nhap danh sach sinh vien\n");
        printf("2. In danh sach sinh vien\n");
        printf("3. Phan loai sinh vien theo diem\n");
        printf("4. Xoa sinh vien theo lop\n");
        printf("0. Thoat\n");
        printf("Nhap lua chon: ");
        scanf("%d", &luaChon);

        switch (luaChon) {
            case 1:
                Nhap_DSFF(&head);
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
                inDanhSach(head);
                break;
            case 0:
                printf("Thoat chuong trinh.\n");
                break;
            default:
                printf("Lua chon khong hop le. Vui long chon lai.\n");
        }
    } while (luaChon != 0);

}
