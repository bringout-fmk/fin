#include "\dev\fmk\fin\fin.ch"
#include "\dev\fmk\fin\razdb\1g\razdb.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 

/*! \file fmk/fin/razdb/1g/pos_fin.prg
 *  \brief Prenos podataka POS->FIN
 */


/*! \fn GetPrVPParams(cProdId, dDatOd, dDatDo)
 *  \brief Setuj parametre prenosa
 *  \param cProdId
 *  \param dDatOd
 *  \param dDatDo
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


function PromVP2Fin()
*{
private cProdId
private dDatOd
private dDatDo
private dDatDok
private KursLis:="1"

O_PrVP_DB()

if !GetPrVPParams(@cProdId, @dDatOd, @dDatDo, @dDatDok)
	return
endif

cPromVPDir:=GetTopsKumPath()
if (cPromVPDir == NIL)
	return
endif
AddBS(@cPromVPDir)

if file(cPromVPDir+"PROMVP.DBF")
	SELECT (F_T_PROMVP)
	USE (cPromVPDir+"PROMVP")
	set order to tag "1"
else
	MsgBeep("Ne postoji fajl PROMVP.DBF!")
	return
endif

// predji na shemu kontiranja
select trfp2
set filter to shema="P"
go top

cBrNal:=NextNal("22")
nRBr:=0
nIznos:=0
nIznDEM:=0
cBrDok:=""

do while !eof()
	private cPom:=trfp2->id
	nIznos:=GetPologIznos(cPom)
	nIznDem:=nIznos*Kurs(dDatDok, "D", "P")
	if round(nIznos,2)<>0
		select pripr
		append blank
		replace idvn with trfp2->idvn
		replace	idfirma with gFirma
		replace	brnal with cBrNal
		replace	rbr with STR(++nRBr,4)
		replace datdok with dDatDo
		replace	idkonto with trfp2->idkonto
		replace	d_p with trfp2->d_p
		replace	iznosbhd with nIznos
		replace	iznosdem with nIznDEM
		replace	brdok with cBrDok
		replace	opis with TRIM(trfp2->naz)
		select trfp2
	endif
	skip 1
enddo

return
*}


/*! \fn GetPologIznos(cPom)
 *  \brief Vraca iznos pologa za datumski period
 *  \param cPom - polje
 */
static function GetPologIznos(cPom)
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
	nIzn+=field->&cPom
	skip
enddo

return nIzn
*}


/*! \fn GetPosPolozi(aPolog, cIdPM)
 *  \brief Upisuje u matricu aPolog pologe
 *  \param aPolog - matrica pologa
 *  \param cIdPM - id prodajnog mjesta
 */
static function GetPosPolozi(aPolog, cIdPM)
*{
local nArr
nArr:=SELECT()
select F_T_PROMVP
set order to tag "1"
go top

do while !EOF() 
	if (field->pm <> cIdPM)
		skip
		loop
	endif
	if (field->datum > dDatDo .or. field->datum < dDatOd)
		skip
		loop
	endif

	AADD(aPolog, {field->pm, field->datum, field->polog01, field->polog02, field->polog03, field->polog04, field->polog05, field->polog06, field->polog07, field->polog08, field->ukupno})
	skip
enddo

return
*}


/*! \fn O_PrVP_DB()
 *  \brief Otvara potrebne tabele 
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


/*! \fn GetTopsKumPath(cPosId)
 *  \brief Vraca kum path TOPS-a
 *  \param cPosId - id pos
 */
static function GetTopsKumPath()
*{
O_KONCIJ
select koncij
set filter to idprodmjes=cProdId
go top

if field->idprodmjes<>cProdId
	MsgBeep("Ne postoji prodajno mjesto:" + cProdId + "##Prekidam operaciju!")
	return NIL
endif

cPath:=ALLTRIM(koncij->kumtops)

set filter to

if EMPTY(cPath)
	MsgBeep("Nije podesen kumpath TOPS-a u tabeli KONCIJ!")
	return NIL
endif

return cPath
*}









