#include "\dev\fmk\fin\fin.ch"
#include "blag.ch"


/*! \fn CreBlagDB()
 *  \brief Kreiranje tabele BLAG.DBF
 */
function CreBlagDB()
*{
// BLAG.DBF
aDbf:={}
AADD(aDbf,{"IDFIRMA"  , "C",  2, 0})  
AADD(aDbf,{"BRNAL"    , "C",  6, 0})  
AADD(aDbf,{"DATNAL"   , "D",  8, 0})  
AADD(aDbf,{"IDKONTO"  , "C",  7, 0})  
AADD(aDbf,{"IDPARTN"  , "C",  6, 0})  
AADD(aDbf,{"D_P"      , "C",  1, 0})  
AADD(aDbf,{"TIPBLAG"  , "C",  1, 0})  
AADD(aDbf,{"IZNOSBHD" , "N", 21, 5})  
AADD(aDbf,{"IZNOSDEM" , "N", 21, 5})  
AADD(aDbf,{"OPIS"     , "C", 20, 0})  
AADD(aDbf,{"K1"       , "C",  5, 0})  
AADD(aDbf,{"K2"       , "C",  5, 0})  
AADD(aDbf,{"N1"       , "N", 10, 5})  
AADD(aDbf,{"N2"       , "N", 10, 5})  

if !File((KUMPATH + "blag.dbf"))
	DBCREATE2(KUMPATH + "blag.dbf", aDbf)
endif

CREATE_INDEX("1", "IDFIRMA+BRNAL+DTOS(DATNAL)", KUMPATH + "blag.dbf", .t.)
CREATE_INDEX("2", "IDFIRMA+BRNAL+IDPARTN", KUMPATH + "blag.dbf", .t.)

return
*}


/*! \fn O_EdBl()
 *  \brief Otvara tabele nephodne za knjizenje blagajne
 */
function O_EdBl()
*{
O_KONTO
O_PARTN
O_VALUTE
O_BLAG

return
*}


function BlNextNal(cIdFirma)
*{
O_BLAG
select blag
set order to tag "1"
go bottom

nBrNal := VAL(field->brnal)
++ nBrNal
cRet := PADR(STR(nBrNal), 6)

return cRet
*}



/*! \fn AzurBlag()
 *  \brief azuriranje blagajne
 */
function AzurBlag(cIdFirma, cBrNal, dDatNal, cIdKonto, cIdPartn, cDP, cTipBlag, nIzn1, nIzn2, cOpis, cK1, cK2, nN1, nN2 )
*{
// azuriranje blagajne
O_BLAG
select blag
append blank

replace idfirma with cIdFirma
replace brnal with cBrNal
replace datnal with dDatNal
replace idkonto with cIdKonto
replace idpartn with cIdPartn
replace d_p with cDP
replace tipblag with cTipBlag
replace iznosbhd with nIzn1
replace iznosdem with nIzn2
replace opis with cOpis
replace k1 with cK1
replace k2 with cK2
replace n1 with nN1
replace n2 with nN2

return
*}


/*! \fn BlagDelete(cIdFirma, cBrNal)
 *  \brief Brisanje naloga iz tabele blagajna
 */
function BlagDelete(cIdFirma, cBrNal)
*{
O_BLAG
select blag
// brnal
set order to tag "1"
go top
seek cIdFirma + cBrNal

if Found() 
	delete
endif

return
*}







