#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_FI_VERZIJA "02.14"
#define D_FI_PERIOD '11.94-30.05.06'
#ifndef FMK_DEFINED
	#include "\dev\fmk\af\cl-af\fmk.ch"
#endif


#ifdef CDX
	#include "\dev\fmk\fin\cdx\fin.ch"
#else
	#include "\dev\fmk\fin\ax\fin.ch"
#endif
