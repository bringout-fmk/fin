#include "\dev\fmk\fin\fin.ch"
#include "\dev\fmk\fin\razdb\1g\razdb.ch"


/*! \fn GetPrVPParams(cProdId, dDatOd, dDatDo, dDatDok)
 *  \brief Setuj parametre prenosa
 *  \param cProdId - id prodavnice
 *  \param dDatOd - datum prenosa od
 *  \param dDatDo - datum prenosa do
 *  \param dDatDok - datum dokumenta
 */
function GetPrVPParams(cProdId, dDatOd, dDatDo, dDatDok)
*{
dDatOd:=DATE()-30
dDatDo:=DATE()
dDatDok:=DATE()
cProdId:=SPACE(2)

Box(,5,50)
	@ m_x+1, m_y+2 SAY "POS: prodajno mjesto:" GET cProdId VALID !Empty(cProdId)
	@ m_x+3, m_y+2 SAY "Datum od" GET dDatOd VALID !Empty(dDatOd)
	@ m_x+3, m_y+20 SAY "do" GET dDatDo VALID !Empty(dDatDo)
	@ m_x+5, m_y+2 SAY "Datum naloga:" GET dDatDok VALID !Empty(dDatDok)
	read
BoxC()

if LastKey()=K_ESC
	return .f.
else
	return .t.
endif

return
*}


/*! \fn PromVP2Fin()
 *  \brief Centralna funkcija za prenos PROMVP u FIN
 */
function PromVP2Fin()
*{
private cProdId
private dDatOd
private dDatDo
private dDatDok
private KursLis:="1"
private cTKPath:=""
private cProdKonto:=""

// otvori potrebne tabele
O_PrVP_DB()

// setuj parametre prenosa
if !GetPrVPParams(@cProdId, @dDatOd, @dDatDo, @dDatDok)
	return
endif

// daj TOPS.KUMPATH i prodavnicki konto iz KONCIJ
if !GetTopsParams(@cTKPath, @cProdKonto)
	return
endif

AddBS(@cTKPath)

// selektuj PROMVP kao F_T_PROMVP
if file(cTKPath + "PROMVP.DBF")
	SELECT (F_T_PROMVP)
	USE (cTKPath + "PROMVP")
	set order to tag "1"
else
	MsgBeep("Ne postoji fajl PROMVP.DBF!")
	return
endif

// predji na shemu kontiranja
select trfp2
// selektuj shemu "P" - polog pazara
set filter to shema="P"
go top

if (trfp2->shema <> "P")
	MsgBeep("Ne postoji definisana shema kontiranja!")
	return
endif


// daj naredni broj naloga
cBrNal:=NextNal("22")
nRBr:=0
nIznos:=0
nIznDEM:=0
cBrDok:=""
nCounter:=0
cIdKonto:=""

do while !eof()
	private cPom:=trfp2->id
	nIznos:=GetPologIznos(cPom)
	nIznDem:=nIznos*Kurs(dDatDok, "D", "P")
	cIdKonto:=trfp2->idkonto
	cIdkonto:=STRTRAN(cIdKonto,"A1",Right(trim(cProdKonto),1))
        cIdkonto:=STRTRAN(cIdKonto,"A2",Right(trim(cProdKonto),2))
	if Round(nIznos,2)<>0
		nCounter ++
		select pripr
		append blank
		replace idvn with trfp2->idvn
		replace	idfirma with gFirma
		replace	brnal with cBrNal
		replace	rbr with STR(++nRBr,4)
		replace datdok with dDatDo
		replace	idkonto with cIdKonto
		replace	d_p with trfp2->d_p
		replace	iznosbhd with nIznos
		replace	iznosdem with nIznDEM
		replace	brdok with cBrDok
		replace	opis with TRIM(trfp2->naz)
		select trfp2
	endif
	skip 1
enddo

if (nCounter > 0)
	MsgBeep("Preneseno " + ALLTRIM(STR(nCounter)) + " stavki.")
endif

return
*}


/*! \fn GetPologIznos(cField)
 *  \brief Vraca iznos pologa za datumski period
 *  \param cField - polje, npr "POLOG01"
 */
static function GetPologIznos(cField)
*{
local nArr
nArr:=SELECT()
select F_T_PROMVP
set order to tag "1"
go top

nIzn:=0
do while !EOF() 
	if (field->pm <> cProdId)
		skip
		loop
	endif
	if (field->datum > dDatDo .or. field->datum < dDatOd)
		skip
		loop
	endif
	nIzn+=field->&cField
	skip
enddo

select (nArr)

return nIzn
*}



/*! \fn O_PrVP_DB()
 *  \brief Otvaranje neophodnih tabela 
 */
static function O_PrVP_DB()
*{
O_KONCIJ
O_PARTN
O_SUBAN
O_KONTO
O_RNAL
O_NALOG
O_PRIPR
O_TRFP2

return
*}


/*! \fn GetTopsParams(cTKPath, cProdKonto)
 *  \brief Setuje TOPS kumpath i idkonto 
 *  \param cTKPath - kumpath tops
 *  \param cProdKonto - prodavnicki konto
 */
static function GetTopsParams(cTKPath, cProdKonto)
*{
O_KONCIJ
select koncij
// setuj filter po cProdId
set filter to idprodmjes=cProdId
go top
if field->idprodmjes<>cProdId
	MsgBeep("Ne postoji prodajno mjesto:" + cProdId + "##Prekidam operaciju!")
	return .f.
endif

cTKPath:=ALLTRIM(koncij->kumtops)
cProdKonto:=koncij->id

// vrati filter
set filter to

if EMPTY(cTKPath)
	MsgBeep("Nije podesen kumpath TOPS-a u tabeli KONCIJ!")
	return .f.
endif
if EMPTY(cProdKonto)
	MsgBeep("Ne postoji prodavnicki konto!")
	return .f.
endif

return .t.
*}


