#include "\dev\fmk\fin\fin.ch"

/*! \file fmk/fin/razdb/1g/mnu_raz.prg
 *  \brief Menij razmjene podataka
 */
 
/*! \fn MnuRazmjenaPodataka() 
 *  \brief Menij razmjene podataka
 */
function MnuRazmjenaPodataka()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fakt->fin                   ")
AADD(opcexe, {|| FaktFin()})
AADD(opc, "2. ld->fin ")
AADD(opcexe, {|| LdFin()})
if IsPlanika() .or. IsPlNS()
	AADD(opc, "3. pos->fin ")
	AADD(opcexe, {|| PosFin()})
endif
AADD(opc, "4. blag->fin ")
AADD(opcexe, {|| BlagFin()})

Menu_SC("raz")

return
*}


/*! \fn PosFin()
 *  \brief Prenos prometa pologa
 */
function PosFin()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. pos polozi                   ")
AADD(opcexe, {|| PromVP2Fin()})

Menu_SC("pf")

return
*}

/*! \fn BlagFin()
 *  \brief Prenos blagajne
 */
function BlagFin()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. kontiranje blagajnickih naloga      ")
AADD(opcexe, {|| PrenBl2Fin()})

Menu_SC("bf")

return
*}



