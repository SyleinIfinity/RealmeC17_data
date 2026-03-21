#include <stdio.h>
#include <stdlib.h>

typedef struct Nut {
    float duLieu; 
    struct Nut* tiepTheo;
} Nut;

Nut* taoNut(float duLieu) {
    Nut* nutMoi = (Nut*)malloc(sizeof(Nut));
    nutMoi->duLieu = duLieu;
    nutMoi->tiepTheo = NULL;
    return nutMoi;
}

void themVaoDau(Nut** dau, float duLieu) {
    Nut* nutMoi = taoNut(duLieu);
    nutMoi->tiepTheo = *dau;
    *dau = nutMoi;
    printf("Da them %.2f vao dau danh sach.\n", duLieu);
}

void themVaoCuoi(Nut** dau, float duLieu) {
    Nut* nutMoi = taoNut(duLieu);
    if (*dau == NULL) {
        *dau = nutMoi;
        printf("Da them %.2f vao cuoi danh sach.\n", duLieu);
        return;
    }
    Nut* tam = *dau;
    while (tam->tiepTheo != NULL) {
        tam = tam->tiepTheo;
    }
    tam->tiepTheo = nutMoi;
    printf("Da them %.2f vao cuoi danh sach.\n", duLieu);
}

void chenSoTangDan(Nut** dau, float duLieu) {
    Nut* nutMoi = taoNut(duLieu);
    if (*dau == NULL || (*dau)->duLieu >= duLieu) {
        nutMoi->tiepTheo = *dau;
        *dau = nutMoi;
        printf("Da chen %.2f vao danh sach tang dan.\n", duLieu);
        return;
    }
    Nut* tam = *dau;
    while (tam->tiepTheo != NULL && tam->tiepTheo->duLieu < duLieu) {
        tam = tam->tiepTheo;
    }
    nutMoi->tiepTheo = tam->tiepTheo;
    tam->tiepTheo = nutMoi;
    printf("Da chen %.2f vao danh sach tang dan.\n", duLieu);
}

void xoaSoTaiViTri(Nut** dau, float duLieu, int viTri) {
    Nut* tam = *dau;
    Nut* truoc = NULL;
    int dem = 0;

    while (tam != NULL) {
        if (tam->duLieu == duLieu) {
            dem++;
            if (dem == viTri) {
                if (truoc == NULL) {
                    *dau = tam->tiepTheo;
                } else {
                    truoc->tiepTheo = tam->tiepTheo;
                }
                free(tam);
                printf("Da xoa %.2f tai vi tri %d khoi danh sach.\n", duLieu, viTri);
                return;
            }
        }
        truoc = tam;
        tam = tam->tiepTheo;
    }
    printf("Khong tim thay %.2f tai vi tri %d trong danh sach.\n", duLieu, viTri);
}

void sapXepTangDan(Nut** dau) {
    if (*dau == NULL) return;
    Nut* i = *dau;
    while (i != NULL) {
        Nut* j = i->tiepTheo;
        while (j != NULL) {
            if (i->duLieu > j->duLieu) {
                float tam = i->duLieu;
                i->duLieu = j->duLieu;
                j->duLieu = tam;
            }
            j = j->tiepTheo;
        }
        i = i->tiepTheo;
    }
    printf("Da sap xep danh sach tang dan.\n");
}

int kiemTra(Nut* dau, float khoa) {
    Nut* tam = dau;
    while (tam != NULL) {
        if (tam->duLieu == khoa) {
            printf("So %.2f co trong danh sach.\n", khoa);
            return 1;
        }
        tam = tam->tiepTheo;
    }
    printf("So %.2f khong co trong danh sach.\n", khoa);
    return 0;
}

Nut* ghepDanhSachTangDan(Nut* dau1, Nut* dau2) {
    Nut* ketQua = NULL;
    while (dau1 != NULL && dau2 != NULL) {
        if (dau1->duLieu <= dau2->duLieu) {
            themVaoCuoi(&ketQua, dau1->duLieu);
            dau1 = dau1->tiepTheo;
        } else {
            themVaoCuoi(&ketQua, dau2->duLieu);
            dau2 = dau2->tiepTheo;
        }
    }
    while (dau1 != NULL) {
        themVaoCuoi(&ketQua, dau1->duLieu);
        dau1 = dau1->tiepTheo;
    }
    while (dau2 != NULL) {
        themVaoCuoi(&ketQua, dau2->duLieu);
        dau2 = dau2->tiepTheo;
    }
    printf("Da ghep hai danh sach thanh danh sach tang dan.\n");
    return ketQua;
}

void inDanhSach(Nut* dau) {
    Nut* tam = dau;
    while (tam != NULL) {
        printf("%.2f -> ", tam->duLieu);
        tam = tam->tiepTheo;
    }
    printf("NULL\n");
}

int main() {
    Nut* danhSach1 = NULL;
    Nut* danhSach2 = NULL;
    int luaChon, viTri;
    float giaTri;

    do {
        printf("================Menu=====================\n");
        printf("|1. Tao day so LIFO                     |\n");
        printf("|2. Tao day so FIFO                     |\n");
        printf("|3. Chen so vao day tang dan            |\n");
        printf("|4. Xoa so khoi day                     |\n");
        printf("|5. Sap xep day tang dan                |\n");
        printf("|6. Kiem tra so trong day               |\n");
        printf("|7. Ghep hai day thanh day tang dan     |\n");
        printf("|8. Thoat                               |\n");
        printf("-----------------------------------------\n");
        printf("Lua chon cua ban: ");
        scanf("%d", &luaChon);

        switch (luaChon) {
            case 1:
                printf("Nhap cac so (nhap ky tu khac de ket thuc):\n");
                do {
                    if (scanf("%f", &giaTri) != 1) break;
                    themVaoDau(&danhSach1, giaTri);
                } while (1);
                while (getchar() != '\n');
                inDanhSach(danhSach1);
                break;
            case 2:
                printf("Nhap cac so (nhap ky tu khac de ket thuc):\n");
                do {
                    if (scanf("%f", &giaTri) != 1) break;
                    themVaoCuoi(&danhSach1, giaTri);
                } while (1);
                while (getchar() != '\n');
                inDanhSach(danhSach1);
                break;
            case 3:
                printf("Nhap so: ");
                scanf("%f", &giaTri);
                sapXepTangDan(&danhSach1);
                chenSoTangDan(&danhSach1, giaTri);
                inDanhSach(danhSach1);
                break;
             case 4:
                printf("Nhap so can xoa: ");
                scanf("%f", &giaTri);
                printf("Nhap vi tri can xoa: ");
                scanf("%d", &viTri);
                xoaSoTaiViTri(&danhSach1, giaTri, viTri);
                inDanhSach(danhSach1);
                break;
            case 5:
                sapXepTangDan(&danhSach1);
                inDanhSach(danhSach1);
                break;
            case 6:
                printf("Nhap so can tim: ");
                scanf("%f", &giaTri);
                if (kiemTra(danhSach1, giaTri)) {
                    printf("So %.2f co trong day.\n", giaTri);
                } else {
                    printf("So %.2f khong co trong day.\n", giaTri);
                }
                inDanhSach(danhSach1);
                break;
            case 7:
                printf("Nhap cac so cho day thu hai (nhap ky tu khac de ket thuc):\n");
                do {
                    if (scanf("%f", &giaTri) != 1) break; 
                    themVaoCuoi(&danhSach2, giaTri);
                } while (1);
                while (getchar() != '\n');
                danhSach1 = ghepDanhSachTangDan(danhSach1, danhSach2);
                sapXepTangDan(&danhSach1);
                inDanhSach(danhSach1);
                break;
            case 8:
                printf("Thoat chuong trinh.\n");
                break;
            default:
                printf("Lua chon khong hop le.\n");
        }
    } while (luaChon != 8);

    return 0;
}

