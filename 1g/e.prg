/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fin.ch"

EXTERNAL DESCEND
EXTERNAL RIGHT


#ifndef LIB

/*  function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
 *  Main fja za FIN.EXE
 */
function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
  MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)
return

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


