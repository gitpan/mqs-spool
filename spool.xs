#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


MODULE = mqs::spool		PACKAGE = mqs::spool		

#include <stdio.h>

char * gen_name(char * dir)
	CODE:
		char * pname = tempnam(dir,"mqs");
		RETVAL = pname;
	OUTPUT:
		RETVAL


int write_file(char * file,char * content)
	CODE:
		FILE * fd;
		int returned_value = 1;
		if((fd = fopen(file,"w")) != NULL)
		{
			fprintf(fd,content);
			fclose(fd);
		}
		else
		{
			returned_value = -1;
		}
		RETVAL = returned_value;
	OUTPUT:
		RETVAL

