#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_FI_VERZIJA "02.01"
#define D_FI_PERIOD '11.94-17.01.06'
#ifndef FMK_DEFINED
	#include "\dev\fmk\af\cl-af\fmk.ch"
#endif


#ifdef CDX
	#include "\dev\fmk\fin\cdx\fin.ch"
#else
	#include "\dev\fmk\fin\ax\fin.ch"
#endif
