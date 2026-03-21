#include <stdio.h>
#include <math.h>
main()
{
   int a, b, c, d;
   float x1, x2, x;
   printf("Nhap 3 so: ");
   scanf("%d%d%d", &a, &b, &c);
   d = b*b -4*a*c;
   if (d<0)
   	printf("Vo nghiem");
   else
   	if (d>0)
	{
		x1 = (-b+sqrt(d))/(2*a);
		x2 = (-b-sqrt(d))/(2*a);
		printf("x1= %f x2=%f", x1, x2);		
	}   	
	else
	{
		x = -b/(2.0*a);
		printf("x1 = x2 = %f",x );
	}
}


