#include "\dev\fmk\fin\fin.ch"

/*! \fn MnuBlag()
 *  \brief Osnovni menij blagajne
 */
function MnuBlag()
*{
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. knjizenje blagajne           ")
AADD(opcexe, {||BlagNew()})
AADD(opc, "2. pregled blagajne")
AADD(opcexe, {|| KnjBlag()})
AADD(opc, "3. blagajnici izvjestaj")
AADD(opcexe, {|| NotImp()})
AADD(opc, "4. kontiraj fin.nalog")
AADD(opcexe, {|| NotImp()})

Menu_SC("bl")

return
*}







