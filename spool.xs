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


