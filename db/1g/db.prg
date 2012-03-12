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


/*! \file fmk/fin/db/1g/db.prg
 *  \brief Funkcije za rad sa tabelama
 */
 
/*! \fn SifkPartnBank()
 *  \brief Dodaje u tabelu SifK stavke PARTN i BANK
 */
 
function SifkPartnBank()
*{
O_SIFK
set order to tag "ID2"
seek padr("PARTN",8)+"BANK"
if !found()
 if Pitanje(,"U sifk dodati PARTN/BANK  ?","D")=="D"
    append blank
    replace id with "PARTN" , oznaka with "BANK", naz with "Banke",;
            Veza with "N", Duzina with 16 , Tip with "C"
 endif
endif
use
return NIL
*}



/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 *  \brief Kopira podatke sa mreze radi brzine pregleda dokumenata, sluzi samo za pregled
 *  \param nArea    - podrucje
 *  \param cStaza  
 *  \param cIme 
 *  \param nIndexa
 *  \param cDefault
 */
 
function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*{
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)
if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odredisni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL


// -----------------------------------------------------------------
// provjerava da li u pripremi postoji vise razlicitih dokumenata
// -----------------------------------------------------------------
static function _is_vise_dok()
local lRet := .f.
local nTRec := RECNO()
local cBrNal 
local cTmpNal := "XXXXXXXX"

select pripr
go top

cTmpNal := field->brnal

do while !EOF() 

	cBrNal := field->brnal
	
	if  cBrNal == cTmpNal 
		
		
		cTmpNal := cBrNal
		
		skip
		loop
	
	else
		lRet := .t.
		exit
	endif
	
enddo

return lRet


// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
static function prov_duple_stavke() 
local cSeekNal
local lNalExist:=.f.

select pripr
go top

// provjeri duple dokumente
do while !EOF()
	
	cSeekNal := pripr->(idfirma + idvn + brnal)
	
	if dupli_nalog(cSeekNal)
		lNalExist := .t.
		exit
	endif
	
	select pripr
	skip
	
enddo

// postoje dokumenti dupli
if lNalExist
	MsgBeep("U pripremi su se pojavili dupli nalozi !!!")
	if Pitanje(,"Pobrisati duple naloge (D/N)?", "D")=="N"
		MsgBeep("Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!")
		return 1
	else
		Box(,1,60)
		
			cKumPripr := "P"
			@ m_x+1, m_y+2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty(cKumPripr) .or. cKumPripr $ "KP" PICT "@!"
			read
		BoxC()
		
		if cKumPripr == "P"
			// brisi pripremu
			return prip_brisi_duple()
		else
			// brisi kumulativ
			return kum_brisi_duple()
		endif
	endif
endif

return 0


// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
static function prip_brisi_duple()
local cSeek
select pripr
go top

do while !EOF()

	cSeek := pripr->(idfirma + idvn + brnal)
	
	if dupli_nalog( cSeek )
		// pobrisi stavku
		select pripr
		delete
	endif
	
	select pripr
	skip
enddo

return 0


// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
static function kum_brisi_duple()
local cSeek
select pripr
go top

cKontrola := "XXX"

do while !EOF()
	
	cSeek := pripr->(idfirma + idvn + brnal)
	
	if cSeek == cKontrola
		skip
		loop
	endif
	
	if dupli_nalog( cSeek )
		
		MsgO("Brisem stavke iz kumulativa ... sacekajte trenutak!")
		
		// brisi nalog
		select nalog
		
		if !flock()
			msg("Datoteka je zauzeta ",3)
			closeret
		endif
	
		set order to tag "1"
		go top
		seek cSeek
		
		if Found()
			
			do while !eof() .and. nalog->(idfirma+idvn+brnal) == cSeek
      				skip 1
				nRec:=RecNo()
				skip -1
      				DbDelete2()
      				go nRec
    			enddo
    		endif
		
		// brisi iz suban
		select suban
		if !flock()
			msg("Datoteka je zauzeta ",3)
			closeret
		endif
	
		set order to tag "4"
		go top
		seek cSeek
		if Found()
			do while !EOF() .and. suban->(idfirma + idvn + brnal) == cSeek
				
				skip 1
				nRec:=RecNo()
				skip -1
				DbDelete2()
				go nRec
			enddo
		endif
	
	
		// brisi iz sint
		select sint
		if !flock()
			msg("Datoteka je zauzeta ",3)
			closeret
		endif
	
		set order to tag "2"
		go top
		seek cSeek
		if Found()
			do while !EOF() .and. sint->(idfirma + idvn + brnal) == cSeek
				
				skip 1
				nRec:=RecNo()
				skip -1
				DbDelete2()
				go nRec
			enddo
		endif
	
		// brisi iz anal
		select anal
		if !flock()
			msg("Datoteka je zauzeta ",3)
			closeret
		endif
	
		set order to tag "2"
		go top
		seek cSeek
		if Found()
			do while !EOF() .and. anal->(idfirma + idvn + brnal) == cSeek
				
				skip 1
				nRec:=RecNo()
				skip -1
				DbDelete2()
				go nRec
			enddo
		endif
	
	
		MsgC()
	endif
	
	cKontrola := cSeek
	
	select pripr
	skip
enddo

return 0


// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
static function dupli_nalog(cSeek)
select nalog
set order to tag "1"
go top
seek cSeek
if Found()
	return .t.
endif
return .f.



/*! \fn Azur(lAuto)
 *  \brief Azuriranje knjizenja
 *  \param lAuto - .t. azuriraj automatski, .f. azuriraj sa pitanjem
 */
 
function Azur(lAuto)
local bErrHan, nC
local nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
	lLogAzur:=.t.
else
	lLogAzur:=.f.
endif

if (lAuto==NIL)
	lAuto:=.f.
endif

if !lAuto .and. Pitanje("pAz","Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N"
	return
endif

O_KONTO
O_PARTN
O_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG

// provjeri da li se u pripremi nalazi vise dokumenata... razlicitih
if _is_vise_dok() == .t.
	
	// provjeri za duple stavke prilikom azuriranja...
	if prov_duple_stavke() == 1 
		return
	endif
	
	// nafiluj sve potrebne tabele
	stnal( .t. )
endif

O_KONTO
O_PARTN
O_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG


fAzur:=.t.
select PSUBAN
if reccount2()==0
  fAzur:=.f.
endif
select PANAL
if reccount2()==0
  fAzur:=.f.
endif
select PSINT
if reccount2()==0
  fAzur:=.f.
endif


if !fAzur
  Beep(3)
  Msg("Niste izvrsili stampanje naloga ...",10)
  closeret
endif

if lLogAzur
	cOpis := pripr->idfirma + "-" + ;
		pripr->idvn + "-" + ;
		pripr->brnal

	EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
		nil, nil, nil, nil, ;
		cOpis, "", "", pripr->datdok, Date(), ;
		"", "Azuriranje dokumenta - poceo !")

endif

Box(,5,60)
select PSUBAN
set order to 1
go top

fIzgenerisi:=.f.
if reccount2()>9999 .and. !lAuto
  if Pitanje(,"Staviti na stanje bez provjere ?","N")=="D"
    fizgenerisi:=.t.
  endif
endif


do while !eof()
// prodji kroz PSUBAN i vidi da li je nalog zatvoren
// samo u tom slucaju proknjizi nalog u odgovarajuce datoteke

cNal:=IDFirma+IdVn+BrNal
IF "." $ cNal
  MsgBeep("Nalog "+IdFirma+"-"+idvn+"-"+(brnal)+;
          " sadrzi znak '.' i zato nece biti azuriran!")
  DO WHILE !EOF() .and. cNal==IDFirma+IdVn+BrNal
    SKIP 1
  ENDDO
  LOOP
ENDIF

@ m_x+1,m_y+2 SAY "Azuriram nalog: "+IdFirma+"-"+idvn+"-"+ALLTRIM(brnal)
nSaldo:=0

cEvIdFirma:=idfirma
cEvVrBrNal:=idvn+"-"+brnal
dDatNaloga:=datdok
dDatValute:=datval

do while !eof() .and. cNal==IdFirma+IdVn+BrNal

    if !empty(psuban->idpartner)
      select partn
      hseek psuban->idpartner

      if !found() .and. !fizgenerisi
        Beep(1)
        Msg("Stavka br."+psuban->rbr+": Nepostojeca sifra partnera!")
        IF PSUBAN->idvn=="00" .and. Pitanje(,"Preuzeti nepostojecu sifru iz sezone?","N")=='D'
          PreuzSezSPK("P")
        ELSE
          Boxc()
          select PSUBAN
	  zapp()
          select PANAL
	  zapp()
          select PSINT
	  zapp()
          closeret
        ENDIF
      endif
    endif
    if !empty(psuban->idkonto)
      select konto
      hseek psuban->idkonto
      if !found() .and. !fizgenerisi
        Beep(1)
        Msg("Stavka br."+psuban->rbr+": Nepostojeca sifra konta!")
        IF PSUBAN->idvn=="00" .and. Pitanje(,"Preuzeti nepostojecu sifru iz sezone?","N")=='D'
          PreuzSezSPK("K")
        ELSE
          Boxc()
          select PSUBAN
          zapp()
          select PANAL
          zapp()
          select PSINT
          zapp()
          closeret
        ENDIF
      endif
    endif
    select psuban

    if D_P=="1"
       nSaldo+=IznosBHD
    else
       nSaldo-=IznosBHD
    endif
    skip
enddo

if round(nSaldo,4)<>0 .and. gRavnot=="D"
  Beep(1)
  Msg("Neophodna ravnoteza naloga, azuriranje nece biti izvrseno!")
endif

// nalog je uravnotezen, azuriraj ga !
if round(nSaldo,4)==0  .or. gRavnot=="N" 

   if !( SUBAN->(flock()) .and. ;
   	ANAL->(flock()) .and.  ;
	SINT->(flock()) .and.  ;
	NALOG->(flock())  ) 
 	   
	    if gAzurTimeOut == nil
	    	nTime := 150
	    else
	        nTime := gAzurTimeOut
	    endif
	   
	    Box(,1, 40)

	    // daj mu vremena...
	    do while nTime > 0
	
		-- nTime

		@ m_x + 1, m_y + 2 SAY "timeout: " + ALLTRIM(STR(nTime))
		
		if ( SUBAN->(flock()) .and. ;
			ANAL->(flock()) .and.  ;
			SINT->(flock()) .and.  ;
			NALOG->(flock())  ) 
			exit
		endif
	    
		sleep(1)

	    enddo
	    
	    BoxC()

	    if nTime = 0 .and. !( SUBAN->(flock()) .and. ;
			ANAL->(flock()) .and.  ;
			SINT->(flock()) .and.  ;
			NALOG->(flock())  ) 
	
	    	Beep(4) 
 	    	BoxC() 
 	    	Msg("Timeout za azuriranje istekao!#Ne mogu azuriranti nalog...") 
 	    	closeret 
	
	endif
   endif 


  @ m_x+3,m_y+2 SAY "NALOZI         "
  select  SUBAN; SET ORDER TO 4  //"4","idFirma+IdVN+BrNal+Rbr"
  seek cNal
  if found()
  	BoxC()
  	Msg("Vec postoji u suban ? "+IdFirma+"-"+IdVn+"-"+ALLTRIM(BrNal)+ "  !")
  	closeret
  endif


  select  NALOG
  seek cNal
  if found()
  	BoxC()
	Msg("Vec postoji proknjizen nalog "+IdFirma+"-"+IdVn+"-"+ALLTRIM(BrNal)+ "  !")
        closeret
  endif // found()

  select PNALOG
  seek cNal
  if found()
    Scatter()
    _Sifra:=sifrakorisn
    select NALOG
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    sql_azur(.f.)
  else
    Beep(4)
    Msg("Greska... ponovi stampu naloga ...")
  endif

  @ m_x+3,m_y+2 SAY "ANALITIKA       "
  select PANAL
  seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select ANAL
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    select PANAL
    skip
  enddo

  @ m_x+3,m_y+2 SAY "SINTETIKA       "
  select PSINT
  seek cNal
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    Scatter()
    select SINT
    append ncnl
    sql_append()
    Gather2()
    GathSql()
    select PSINT
    skip
  enddo

  @ m_x+3,m_y+2 SAY "SUBANALITIKA   "
  select SUBAN
  set order to tag "3"
  select PSUBAN
  seek cNal
  nC:=0
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal

    @ m_x+3,m_y+25 SAY ++nC  pict "99999999999"

    Scatter()
    if _d_p=="1"; nSaldo:=_IznosBHD; else; nSaldo:= -_IznosBHD; endif
    SELECT SUBAN
    SEEK _IdFirma+_IdKonto+_IdPartner+_BrDok    // isti dokument
    nRec:=recno()
    do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
       if d_P=="1"; nSaldo+= IznosBHD; else; nSaldo -= IznosBHD; endif
       skip
    enddo

    if abs(round(nSaldo,3))<=gnLOSt
      go nRec
      do while  !eof() .and. (_IdFirma+_IdKonto+_IdPartner+_BrDok)== (IdFirma+IdKonto+IdPartner+BrDok)
        field->OtvSt:="9"
        skip
      enddo
      _OtvSt:="9"
    endif

    // dodaj u suban
    append ncnl
    sql_append()
    Gather2()
    GathSql()

    select PSUBAN
    skip
  enddo

if lLogAzur
	
	cOpis := cEvIdFirma + "-" + cEvVrBrNal

	EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
		nSaldo, nil, nil, nil, ;
		cOpis, "", "", dDatNaloga, dDatValute, ;
		"", "Azuriranje dokumenta - zavrsio !!!")

endif


  // nalog je uravnotezen, moze se izbrisati iz PRIPR
  
  select PRIPR
  seek cNal
  @ m_x+3,m_y+2 SAY "BRISEM PRIPREMU "
  do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    skip
    ntRec:=RECNO()
    skip -1
    dbdelete2()
    go ntRec
  enddo

endif // saldo == 0

select PSUBAN
enddo

BoxC()


select PRIPR
__dbpack()

select PSUBAN
zap
select PANAL
zap
select PSINT
zap
select PNALOG
zap

closeret
return




/*! \fn Dupli(cIdFirma,cIdVn,cBrNal)
 *  \brief Provjera duplog naloga
 *  \param cIdFirma
 *  \param cIdVn
 *  \param cBrNal
 */
 
function Dupli(cIdFirma,cIdVn,cBrNal)
*{
PushWa()

select NALOG
set order to 1
seek cIdFirma+cIdVN+cBrNal

if found()
   MsgO(" Dupli nalog ! ")
   Beep(3)
   MsgC()
   PopWa()
   return .f.
endif

PopWa()
return .t.


// --------------------------------
// validacija broja naloga
// --------------------------------
static function __val_nalog( cNalog )
local lRet := .t.
local cTmp
local cChar
local i

cTmp := RIGHT( cNalog, 4 )

// vidi jesu li sve brojevi
for i := 1 to LEN( cTmp )
	
	cChar := SUBSTR( cTmp, i, 1 )
	
	if cChar $ "0123456789"
		loop
	else
		lRet := .f.
		exit
	endif

next

return lRet






// ---------------------------------------------
// centralna funkcija za odredjivanje
// novog broja naloga !!!!
// cIdFirma - firma
// cIdVn - tip naloga
// ---------------------------------------------
function NextNal( cIdFirma, cIdVN )
local nArr
nArr:=SELECT()

if gBrojac=="1"
	select NALOG
	set order to 1
	seek cIdFirma+cIdVN+chr(254)
	skip -1
	altd()
	if ( idfirma + idvn == cIdFirma + cIdVN )
		
		// napravi validaciju polja ...
		do while !BOF()

			if !__val_nalog( field->brnal )
				skip -1
				loop
			else
				exit
			endif
		enddo
		
		cBrNal := NovaSifra(brNal)
	else
		cBrNal := "00000001"
	endif
else
	select NALOG
	set order to 2
	seek cIdFirma+chr(254)
	skip -1
	cBrNal:=padl(alltrim(str(val(brnal)+1)),8,"0")
endif

select (nArr)

return cBrNal


// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
function regen_tbl()

if !SigmaSIF("REGEN")
	MsgBeep("Ne diraj lava dok spava !")
	return
endif

// otvori sve potrebne tabele
O_SUBAN

if LEN( suban->brnal ) = 4
	msgbeep("potrebno odraditi modifikaciju FIN.CHS prvo !")
	return
endif

O_NALOG
O_ANAL
O_SINT

// pa idemo redom
select suban
_renum_convert()
select nalog
_renum_convert()
select anal
_renum_convert()
select sint
_renum_convert()


return


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
static function _renum_convert()
local xValue
local nCnt

set order to tag "0"
go top

Box(,2,50)

@ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

nCnt := 0
do while !EOF()
	xValue := field->brnal
	if !EMPTY(xValue)
		replace field->brnal with PADL(ALLTRIM(xValue), 8, "0")
		++ nCnt
	endif
	@ m_x + 2, m_y + 2 SAY PADR( "odradjeno " + ALLTRIM(STR(nCnt)), 45 )
	skip
enddo

BoxC()

return



// -----------------------------------------
// provjera podataka za migraciju f18
// -----------------------------------------
function f18_test_data()
local _a_sif := {}
local _a_data := {}
local _a_ctrl := {} 
local _chk_sif := .f.

if Pitanje(, "Provjera sifrarnika (D/N) ?", "N") == "D"
	_chk_sif := .t.
endif

// provjeri sifrarnik
if _chk_sif == .t.
	f18_sif_data( @_a_sif, @_a_ctrl )
endif

f18_fin_data( @_a_data, @_a_ctrl )

// prikazi rezultat testa
f18_rezultat( _a_ctrl, _a_data, _a_sif )

return



// -----------------------------------------
// provjera suban, anal, sint
// -----------------------------------------
static function f18_fin_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0
local _scan 

O_SUBAN
O_ANAL
O_SINT

Box(, 2, 60 )

select suban
set order to tag "4"
go top

do while !EOF()
	
	_firma := field->idfirma
	_tdok := field->idvn
	_brdok := field->brnal
	_dok := _firma + "-" + _tdok + "-" + ALLTRIM( _brdok )
	
	_rbr_chk := "xx"

	@ m_x + 1, m_y + 2 SAY "dokument: " + _dok

	do while !EOF() .and. field->idfirma == _firma ;
		.and. field->idvn == _tdok ;
		.and. field->brnal == _brdok
		
		_rbr := field->rbr
		
		@ m_x + 2, m_y + 2 SAY "redni broj dokumenta: " + PADL( _rbr, 5 )

		if _rbr == _rbr_chk
			// dodaj u matricu...
			_scan := ASCAN( data, {|var| var[1] == _dok } )
			if _scan == 0
				AADD( data, { _dok } ) 
			endif
		endif

		_rbr_chk := _rbr

		// kontrolni broj
		++ _n_c_stavke
		_n_c_iznos += ( field->iznosbhd )

		skip
	enddo

enddo

BoxC()

if _n_c_stavke > 0
	AADD( checksum, { "fin data", _n_c_stavke, _n_c_iznos } )
endif

return

