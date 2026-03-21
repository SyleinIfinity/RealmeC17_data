#include <stdio.h>
#include <stdlib.h>

struct NUT {
    int heso;        
    int somu;        
    NUT* tiep;
};

// them phan tu
void THEM_PT (NUT **Dau, int heso, int somu)
{
    // struct NUT* nutMoi = (struct NUT*)malloc(sizeof(struct NUT));
    NUT * nutMoi = new NUT;
    nutMoi->heso = heso;
    nutMoi->somu = somu;
    nutMoi->tiep = NULL;

    if (*Dau == NULL)
        *Dau = nutMoi;
    else
    {
        NUT *tg = *Dau;
        while (tg ->tiep != NULL)
        {
            tg = tg->tiep;
        }
        tg->tiep = nutMoi;
    }
}

// them da thuc
void themDaThuc (NUT **Dau)
{
    int n, i;
    printf ("nhap vao so phan tu cua da thuc: ");
    scanf ("%d", &n);

    for (i = 0; i < n; i++)
    {
        int heso, somu;
        printf("Nhap he so va so mu cho phan tu %d: ", i + 1);
        scanf("%d %d", &heso, &somu);
        THEM_PT(Dau, heso, somu);
    }
}
// in 
void inDaThuc (NUT *Dau)
{
    NUT *tg = Dau;
    while (tg != NULL)
    {
        if (tg->heso %2 == 0)
        {
            printf("%dx^%d", tg->heso, tg->somu);
            if (tg->tiep != NULL) {
                printf(" + ");
            }
           
        }
        tg = tg->tiep;
    } 
    printf(" 0\n");
}

main()
{
    NUT *dathuc1 = NULL;
    printf("Nhap da thuc :\n");
    themDaThuc(&dathuc1);
    printf("Da thuc 1: ");
    inDaThuc(dathuc1);

}