#include "fin.ch"

 
function Izvjestaji()
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. kartica                      ")
AADD(opcexe,{|| Kartica()})
AADD(opc,"2. bruto bilans")
AADD(opcexe,{|| Bilans()})
AADD(opc,"3. specifikacije")
AADD(opcexe,{|| MnuSpecif()})
AADD(opc,"4. specifikacije po godinama")
AADD(opcexe,{|| MnuSpecGod()})
AADD(opc,"5. proizvoljni izvjestaji")
AADD(opcexe,{|| Proizv()})
AADD(opc,"6. dnevnik naloga")
AADD(opcexe,{|| DnevnikNaloga()})
AADD(opc,"7. ostali izvjestaji")
AADD(opcexe,{|| Ostalo()})
AADD(opc,"8. blagajnicki nalog")
AADD(opcexe,{|| blag_azur()})

Menu_SC("izvj")

return .f.

