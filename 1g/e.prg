#include "\dev\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                         Copyright Sigma-com software 1996-2006 
 * ----------------------------------------------------------------
 */

/*! \file fmk/fin/main/1g/e.prg
 */

#ifndef CPP
EXTERNAL DESCEND
EXTERNAL RIGHT
#endif



#ifndef LIB

/*! \fn function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
 *  \brief Main fja za FIN.EXE
 */
function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
*{
  MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)
return
*}

#endif


/*! \fn MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)
 *  \brief Glavna funkcija Fin aplikacijskog modula
 */
 
function MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)
*{
local oPos
local cModul

//SET LOGLEVEL TO 5
//SET LOGFILE TO pos.log
//cPom:=SET(_SET_DEVICE)

PUBLIC gKonvertPath:="D"

oFin:=TFinModNew()
cModul:="FIN"

PUBLIC goModul

goModul:=oFin
oFin:init(NIL, cModul, D_FI_VERZIJA, D_FI_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oFin:run()

return
*}


