#include "\dev\fmk\fin\fin.ch"

// vars
static __delimit
static __rbr
static __nalbr


// ----------------------------------------
// import elba txt... glavna funkcija
// ----------------------------------------
function _imp_elba_txt( cTxt )
local nItems

if cTxt == nil
	cTxt := ""
endif

// provjeri da li je priprema prazna
if __ck_pripr() > 0
	MsgBeep("Priprema mora biti prazna !!!#Ispraznite pripremu i ponovite proceduru.")
	return
endif

O_PRIPR
O_NALOG

// delimiter je TAB
__delimit := CHR(9)

// uzmi lokaciju fajla txt ako nije proslijedjeno...
if EMPTY( cTxt )
	_g_elba_file( @cTxt )
endif

// napuni pripremu sa stavkama... iz txt
nItems := _g_elba_items( cTxt )

if nItems > 0
	MsgBeep("Obradjeno: " + ALLTRIM(STR(nItems)) + " stavki.#Stavke se nalaze u pripremi.")
endif

return



// -------------------------------------------------------
// provjerava koliko zapisa postoji u pripremi
// -------------------------------------------------------
static function __ck_pripr()
local nReturn := 0
O_PRIPR
select pripr
nReturn := RecCount2()
return nReturn



// -------------------------------------------------------
// vraca gdje se nalazi txt fajl za import
// -------------------------------------------------------
static function _g_elba_file( cTxt )
cTxt := EXEPATH + "elba.txt"
return


// -------------------------------------------------------
// vraca matricu napunjenu stavkama iz txt fajla...
// -------------------------------------------------------
static function _g_elba_items( cTxt )
local nItems := 0
local aTemp := {}
local aHeader := {}
local aItem := {}
local cTemp := ""
local nFLines := 0
local nLStart := 0
local i
local cNalBr

__nalbr := ""
__rbr := 0

// broj linija fajla....
nFLines := brlinfajla( cTxt )

for i:=1 to nFLines

	// pomocna matrica...
	aTemp := sljedlin( cTxt, nLStart )
	
	// pocetak sljedece pretrage...
	nLStart := aTemp[2]

	// tekst ...
	cTemp := aTemp[1]

	if EMPTY(cTemp)
		loop
	endif

	aItem := TokToNiz( cTemp, __delimit )

	if aItem[1] $ "+-"
	
		// nema dovoljno elemenata...
		if LEN(aItem) < 12
			loop
		endif
		
		// ovo je transakcija, dodaj u pripr	
		_ins_elba_item( aItem, aHeader )
		
		++ nItems
		
	else
		
		// ovo su parametri izvoda...
		aHeader := aItem
		
		if EMPTY( __nalbr )
			__nalbr := PADL( aHeader[1], 4 , "0" )
		endif
		
	endif
	
	
next


return nItems


// ----------------------------------------------------
// insert stavke u pripremu
// aItem - matrica sa stavkom
// aHeader - ovo su parametri header izvoda...
// ----------------------------------------------------
static function _ins_elba_item( aItem, aHeader )
local cKtoVB := PADR("2001", 7)
local cKtoKup := PADR("2120", 7)
local cKtoDob := PADR("5430", 7)
local cDP

// aItem
// ----------------------------------------------------
// {1} - tip transakcije (+/-)
// {2} - datum i vrijeme "27.11.2006 15:15:02"
// {3} - broj transakcije
// {4} - uplata UP, ili ???
// {5} - 2664508 ????
// {6} - 0 ????
// {7} - Banka naziv
// {8} - transakcijski racun primaoca
// {9} - naziv firme
// {10} - opis + "/" + racun + puni naziv firme
// {11} - valuta KM ili ????
// {12} - iznos


// aHeader
// -------------------------
// {1} - broj izvoda
// {2} - datum od
// {3} - datum do

// prva stavka naloga....

cDP := _g_elba_dp( aItem[1] )
dDatDok := _g_elba_date( aItem[2] )
cOpis := _g_opis( aItem[10] )
cBrVeze := _g_br_veze( aItem[1], dDatDok, aItem[10] )

select pripr
append blank

replace idfirma with gFirma
replace idvn with "I1"
replace brnal with __nalbr
replace brdok with cBrVeze
replace opis with cOpis
replace rbr with STR(++__rbr, 4)
replace datdok with dDatDok
replace d_p with cDP
replace idkonto with _g_konto( aItem[1], aItem[10] )
replace idpartner with _g_partn( aItem[1], aItem[9], aItem[8] )

if ALLTRIM(aItem[11]) == "KM"
	replace iznosbhd with VAL( aItem[12] )
else
	replace iznosdem with VAL( aItem[12] )
endif


// druga stavka naloga, racun vb
// PROTUSTAVKA....

if cDP == "1"
	cDP := "2"
else
	cDP := "1"
endif

select pripr
append blank

replace idfirma with gFirma
replace idvn with "I1"
replace brnal with __nalbr
replace rbr with STR(++__rbr, 4)
replace datdok with dDatDok
replace d_p with cDP
replace opis with cOpis
replace brdok with cBrVeze
replace idkonto with cKtoVB

if ALLTRIM(aItem[11]) == "KM"
	replace iznosbhd with VAL( aItem[12] )
else
	replace iznosdem with VAL( aItem[12] )
endif

return


// ---------------------------------------------
// vraca datum iz elba txt datumskog polja
// ---------------------------------------------
static function _g_elba_date( cDate )
local dDate 
dDate := CTOD( LEFT( cDate, 10 ) )
return dDate


// ---------------------------------------------
// vraca D/P za tip transakcije
// ---------------------------------------------
static function _g_elba_dp( cTransType )
local cRet := "1"

cTransType := ALLTRIM(cTransType)
do case
	case cTransType == "-"
		cRet := "1"
	case cTransType == "+"
		cRet := "2"
endcase

return cRet


// -----------------------------------------------
// vraca konto po pretpostavci...
// -----------------------------------------------
static function _g_konto( cTrans, cOpis )
local cKonto := "?????"
local cKtoKup := PADR("2120", 7)

// ako je uplata na nas racun onda je to KUPAC 2120
if ALLTRIM(cTrans) == "+"
	cKonto := cKtoKup
	return cKonto
endif

if ALLTRIM(cTrans) == "-"

	do case
		case "PDV" $ cOpis
			cKonto := PADR("5609", 7)
		
		case "VOLKS" $ cOpis
			cKonto := PADR("3370", 7)
		
		otherwise 
			cKonto := PADR("5430", 7)
	endcase

endif

return cKonto

// --------------------------------------------------
// uzmi partnera za stavku
// --------------------------------------------------
static function _g_partn( cTrType, cTxt, cTrRN )

if ALLTRIM( cTrType ) == "+"
	// trazi partnera za uplate na zr
	_g_part_upl( cTxt )

elseif ALLTRIM( cTrType ) == "-"
	// trazi partnera za isplate sa zr
	_g_part_isp( cTxt, cTrRN )
endif

return


// -----------------------------------------------
// vraca id partnera za uplate na zr
// -----------------------------------------------
static function _g_part_upl( cTxt )
local nTArea := SELECT()
local cDesc := ""
local cBank := ""
local cPartnId := "?????"

// uzmi banku i opis ako postoji "/"
if LEFT(cTxt, 1) == "/"
	cDesc := ALLTRIM( SUBSTR( cTxt, 18, LEN(cTxt) ) )
	cBank := ALLTRIM( SUBSTR( cTxt, 2, 16 ) )
else
	cDesc := ALLTRIM( cTxt )
endif

// pokusaj naci po banci...
cPartnId := _src_p_bank( cBank )

// ako nema nista, pokusaj po nazivu....
if EMPTY(cPartnId)
	cPartnId := _src_p_desc( cDesc )
endif

// ako nema nista... ???
if EMPTY(cPartnId)
	
	Msgbeep("Nepostojeci partner !!!#Opis: " + PADR(cDesc, 30))
	cPartnId := PADR(cDesc, 3) + ".."
	
	// otvori sifranik..
	p_firma(@cPartnId)
	
	// setuj partneru transakcijski racun
	_set_part_bank( cPartnId, cBank )

endif


select (nTArea)

return cPartnId


// -----------------------------------------------
// vraca id partnera za isplate sa zr
// -----------------------------------------------
static function _g_part_isp( cTxt, cTrRN )
local nTArea := SELECT()
local cDesc := ""
local cBank := ""
local cPartnId := "?????"

// uzmi banku i opis ako postoji "/"
if LEFT(cTxt, 1) == "/"
	cDesc := ALLTRIM( SUBSTR( cTxt, 18, LEN(cTxt) ) )
else
	cDesc := ALLTRIM( cTxt )
endif

// pokusaj naci po banci...
cPartnId := _src_p_bank( cTrRN )

// ako nema nista, pokusaj po nazivu....
if EMPTY(cPartnId)
	cPartnId := _src_p_desc( cDesc )
endif

// ako nema nista... ???
if EMPTY(cPartnId)
	
	Msgbeep("Nepostojeci partner !!!#Opis: " + PADR(cDesc, 30))
	cPartnId := PADR(cDesc, 3) + ".."
	
	// otvori sifranik..
	p_firma(@cPartnId)
	
	// setuj partneru transakcijski racun
	_set_part_bank( cPartnId, cTrRN )

endif


select (nTArea)

return cPartnId


// ------------------------------------------------
// setovanje bank racuna za partnera
// ------------------------------------------------
static function _set_part_bank( cPartn, cBank )
local cRead := ""

altd()

// nema banke, nista...
if EMPTY(cBank)
	return
endif

// prvo procitaj polje bank
cRead := IzSifK("PARTN", "BANK", cPartn )

if !EMPTY(cRead)
	cBank += "," + cRead
endif

USifK("PARTN", "BANK", cPartn, cBank)

return



// ------------------------------------------------------
// pretraga partnera po nazivu ili dijelu naziva
// ------------------------------------------------------
static function _src_p_desc( cDesc )
local aTemp
local cTemp := ""
local cPartner := ""

if EMPTY(cDesc)
	return cPartner
endif

aTemp := TokToNiz( cDesc, " ")

if LEN(aTemp) > 1
	cTemp := ALLTRIM( aTemp[1] )

	if LEN( cTemp ) < 4
		cTemp += " " + ALLTRIM( aTemp[2] )
	endif
else
	cTemp := ALLTRIM(aTemp[1])
endif

O_PARTN
set order to tag "naz"
go top
seek cTemp

if FOUND()
	cPartner := partn->id
endif

return cPartner


// -------------------------------------------
// pretraga po banci - SIFV
// -------------------------------------------
static function _src_p_bank( cBank )
local cPartner := ""

if EMPTY(cBank)
	return cPartner
endif

O_SIFV
select sifv
set order to tag "NAZ"

go top

seek PADR("PARTN", 8) + PADR("BANK", 4) + cBank

if FOUND()
	
	// ako si nasao po banci to je to!
	cPartner := ALLTRIM( sifv->idsif )
	
endif

return cPartner



// ----------------------------------------------
// vraca opis ...
// ----------------------------------------------
static function _g_opis( cOpis )
local cRet := ""
local aTemp

aTemp := TokToNiz( cOpis, "/" )

cRet := ALLTRIM( aTemp[1] )

return cRet


// -------------------------------------------------
// vraca broj veze...
// -------------------------------------------------
static function _g_br_veze( cTrans, dDatum, cOpis )
local cRet := ""

do case 
	case "PDV" $ cOpis
		cRet := "pdv " + PADL( ALLTRIM( STR( MONTH(dDatum) - 1 ) ), 2, "0")
endcase

return cRet




