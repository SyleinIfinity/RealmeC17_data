#include <stdio.h>
int  USCLN(int a, int b)
{
	while (a!=b)
		if (a>b)
			a = a-b;
		else
		 	b = b -a;
	return a;		 	
}
int  USCLN(int a, int b)
{
	int r;
	while (a%b !=0)
	{
		r = a%b;
		a = b;
		b = r;
	}		
	return b;		 	
}
int  KTC(int so)
{
	if (so%2 == 0)
		return 1;
	else
		return 0;	
}
int  KTC(int so)
{
	return (a%2==0? 1: 0);
}
char  DIEMCHU(float tb)
{
	if (dtb>=8.5)
		return 'A';
	else
		
}
char  DIEMCHU(float tb)
{
	return (tb>=8.5? 'A': tb..........)
}
main()
{
}
