#include<stdio.h>
main()
{
    int trau_dung , trau_nam, trau_gia;
    for(trau_dung = 1; trau_dung<100; trau_dung++)
	{
        for(trau_nam = 1; trau_nam<100; trau_nam++)
		{
            for(trau_gia = 1; trau_gia<100; trau_gia++)
			{
                if(((trau_dung + trau_nam + trau_gia) == 100) && (trau_dung*15 + trau_nam*9 + trau_gia) == 300)
				{
                    printf("So trau dung: %d",trau_dung);
                    printf("\nSo trau nam: %d",trau_nam);
                    printf("\nSo trau gia: %d\n\n",trau_gia);
                }
            }
        }
    }
}
