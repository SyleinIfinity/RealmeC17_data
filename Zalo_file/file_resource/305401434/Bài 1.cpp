#include<stdio.h>
main()
{
    int ga, cho;
	for(ga = 1; ga <= 36; ga++)
	{
        cho = 36 - ga;
	    if((2*ga + 4*cho) == 100)
		{
            printf("So con ga: %d\n", ga);
            printf("So con cho: %d\n", cho);
        }
    }
}
