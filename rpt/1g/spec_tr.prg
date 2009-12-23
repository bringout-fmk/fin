#include "fin.ch"


// ---------------------------------------------
// izvjestaj specifikacija troskova
// fuelboss - specifican
// ---------------------------------------------
function r_spec_tr()
local dD_from
local dD_to
local cKtoList
local cKtoKart
local cSp_ld
local cGroup
local cKonto

private nLD_ras := 0
private nLD_pri := 0
private nFIN_ras := 0
private nFIN_pri := 0
private nKALK_pri := 0
private nKALK_ras := 0

O_KONTO
O_RJ

// uslovi izvjestaja
if g_vars( @dD_from, @dD_to, @cGroup, @cKtoList, @cKtoKart, @cSp_ld ) == 0
	return
endif

START PRINT CRET

__r_head()

// uzmi podatke fin-a
__gen_fin( dD_from, dD_to, cGroup, cKtoList, cKtoKart )

// daj konto za kalk
cKonto := _g_gr_kto( cGroup )

// uzmi podatke kalk-a
__gen_kalk( dD_from, dD_to, cKonto )

if cSp_ld == "D"
	__get_ld( dD_from, cGroup )
endif

?
? "-----------------------------------------------------"
? "REKAPITULACIJA TROSKOVA:"
? "-----------------------------------------------------"
? "                   prihod         rashod        total"
? "-----------------------------------------------------"
? "place            ", STR(nLD_pri,12,2), ;
	STR(nLD_ras,12,2), ;
	STR(nLD_pri-nLD_ras,12,2)
? "roba             ", STR(nKALK_pri,12,2), ;
	STR(nKALK_ras,12,2), ;
	STR(nKALK_pri-nKALK_ras,12,2)
? "fin              ", STR(nFIN_pri,12,2), ;
	STR(nFIN_ras,12,2),;
	STR(nFIN_pri-nFIN_ras,12,2)
? "-----------------------------------------------------"


FF
END PRINT

return


// ---------------------------------------------
// vraca konto grupe
// ---------------------------------------------
static function _g_gr_kto( cId )
local xRet := ""
local nTArea := SELECT()

O_RJ
select rj
seek cId

if FOUND()
	xRet := field->konto
endif

select (nTArea)
return xRet


// ---------------------------------------------
// vraca konto grupe
// ---------------------------------------------
static function _g_gr_naz( cId )
local xRet := ""
local nTArea := SELECT()

O_RJ
select rj
seek cId

if FOUND()
	xRet := ALLTRIM( field->naz )
endif

select (nTArea)
return xRet


// ---------------------------------------------
// vraca naziv konta
// ---------------------------------------------
static function _g_kt_naz( cId )
local xRet := ""
local nTArea := SELECT()

O_KONTO
select konto
seek cId

if FOUND()
	xRet := ALLTRIM( field->naz )
endif

select (nTArea)
return xRet


// ---------------------------------------------
// header izvjestaja
// ---------------------------------------------
static function __r_head()
?
? "pregled troskova"
return


// --------------------------------------------------
// generisi podatke iz fin-a
// --------------------------------------------------
static function __gen_fin()

return

// --------------------------------------------------
// generisi podatke iz kalk-a
// --------------------------------------------------
static function __gen_kalk( dD_from, dD_to, cKto )
local cPath := STRTRAN( KUMPATH, "FIN", "KALK" )
local cIdFirma := gFirma

select (102)
use ( cPath + SLASH + "kalk" ) alias "ka_exp"
select ka_exp
// mkonto
set order to tag "3"
go top

seek cIdFirma + cKto

nIzlNV := 0   
nUlNV := 0
nUlKol := 0
nIzKol := 0
nKolNeto := 0
nKolicina := 0
	
do while !EOF() .and. cIdFirma == field->idfirma ;
	.and. cKto == field->mkonto 

	// provjeri datum
	if field->datdok > dD_to .or. field->datdok < dD_from
		skip
		loop
	endif

  	if field->mu_i == "1" .or. field->mu_i == "5"
    		  
		if field->idvd == "10"
      			nKolNeto := abs(field->kolicina-field->gkolicina-field->gkolicin2)
    		else
      			nKolNeto := abs(field->kolicina)
    		endif

    		if ( field->mu_i == "1" .and. field->kolicina > 0 ) ;
		  	.or. ( field->mu_i == "5" .and. field->kolicina < 0 )
         		
			nKolicina += nKolNeto    
         		nUlKol += nKolNeto    
         		nUlNV += ( nKolNeto * field->nc )      
    		  
		else
         		
			nKolicina -= nKolNeto
         		nIzlKol += nKolNeto
         		nIzlNV += ( nKolNeto * field->nc )

    		endif
	endif

	skip
enddo 
 
// sada imam podatke, ispisi ih...

? "KALK podaci...."
?
? "----------------------------------------------------"
? "objekat              nvu          nvi         ukupno"
? "----------------------------------------------------"
? cKto, PADR( _g_kt_naz( cKto ), 30), STR(nUlNV,12,2), ;
	STR(nIzlNV,12,2), STR(nUlNV-nIzlNV,12,2)
?

nKALK_ras += ( nUlNv-nIzlNV)

return




// -------------------------------------------
// vraca linije i header
// -------------------------------------------
static function _g_ld_line( cLine )

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

cTxt := PADR("R.br", 5)
cTxt += SPACE(1)
cTxt += PADR("Ime i prezime radnika", 30)
cTxt += SPACE(1)
cTxt += PADR("Sati", 8)
cTxt += SPACE(1)
cTxt += PADR("Bruto", 12)
cTxt += SPACE(1)
cTxt += PADR("Neto", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.PIO", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.ZDR", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.NEZ", 12)
cTxt += SPACE(1)
cTxt += PADR("Porez", 12)

if ld_exp->tp_1 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-1", 12 )
endif
if ld_exp->tp_2 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-2", 12 )
endif
if ld_exp->tp_3 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-3", 12 )
endif
if ld_exp->tp_4 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-4", 12 )
endif
if ld_exp->tp_5 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-5", 12 )
endif

? cLine
? cTxt
? cLine

return


// ----------------------------------------------------------
// printanje reporta iz ld-a
// ----------------------------------------------------------
static function __get_ld( dD_from, cGroup )
local cLine
local nU_sati := 0
local nU_bruto := 0 
local nU_neto := 0
local nU_d_pio := 0
local nU_d_nez := 0
local nU_d_zdr := 0
local nU_i_por := 0
local nU_o_por := 0
local nU_tp_1 := 0
local nU_tp_2 := 0
local nU_tp_3 := 0
local nU_tp_4 := 0
local nU_tp_5 := 0
local nT_sati := 0
local nT_bruto := 0 
local nT_neto := 0
local nT_d_pio := 0
local nT_d_nez := 0
local nT_d_zdr := 0
local nT_i_por := 0
local nT_o_por := 0
local nT_tp_1 := 0
local nT_tp_2 := 0
local nT_tp_3 := 0
local nT_tp_4 := 0
local nT_tp_5 := 0
local nCol := 15
local cPath := STRTRAN( PRIVPATH, "FIN", "LD" )

select (101)
use ( cPath + SLASH + "r_export" ) alias "ld_exp"
index on group + idradn + STR(godina,4) + STR(mjesec,2) tag "1"
select ld_exp
set order to tag "1"
go top

? "Pregled utroska po grupama za: ", STR(MONTH(dD_from)) ;
	+ "/" + STR(YEAR(dD_from))
?

P_COND2

_g_ld_line( @cLine ) 

nCnt := 0
do while !EOF()

	// n.str
	if prow() > 64 
		FF
	endif
	
	cGr_id := field->group
	cGr_naz := field->gr_naz

	nU_sati := 0
	nU_bruto := 0 
	nU_neto := 0
	nU_d_pio := 0
	nU_d_nez := 0
	nU_d_zdr := 0
	nU_i_por := 0
	nU_o_por := 0
	nU_tp_1 := 0
	nU_tp_2 := 0
	nU_tp_3 := 0
	nU_tp_4 := 0
	nU_tp_5 := 0

	? SPACE(1), "Objekat: ", ;
		"(" + cGr_id + ")", ;
		PADR( cGr_naz, 30 )

	do while !EOF() .and. field->group == cGr_id

		// n.str
		if prow() > 64 
			FF
		endif

		? PADL( ALLTRIM(STR(++nCnt)) + ".", 5 )
		@ prow(), pcol()+1 SAY PADR( field->r_naz, 30 )
		@ prow(), nCol:=pcol()+1 SAY STR(field->sati, 8, 2)
		@ prow(), pcol()+1 SAY STR(field->bruto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->neto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_pio, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_zdr, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_nez, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->izn_por, 12, 2)

		if field->tp_1 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_1, 12, 2)
		endif
		if field->tp_2 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_2, 12, 2)
		endif
		if field->tp_3 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_3, 12, 2)
		endif
		if field->tp_4 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_4, 12, 2)
		endif
		if field->tp_5 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_5, 12, 2)
		endif

		nU_sati += field->sati
		nU_bruto += field->bruto
		nU_neto += field->neto
		nU_d_pio += field->dop_pio
		nU_d_nez += field->dop_nez
		nU_d_zdr += field->dop_zdr
		nU_i_por += field->izn_por
		nU_o_por += field->osn_por
		nU_tp_1 += field->tp_1
		nU_tp_2 += field->tp_2
		nU_tp_3 += field->tp_3
		nU_tp_4 += field->tp_4
		nU_tp_5 += field->tp_5
		
		nT_sati += field->sati
		nT_bruto += field->bruto
		nT_neto += field->neto
		nT_d_pio += field->dop_pio
		nT_d_nez += field->dop_nez
		nT_d_zdr += field->dop_zdr
		nT_i_por += field->izn_por
		nT_o_por += field->osn_por
		nT_tp_1 += field->tp_1
		nT_tp_2 += field->tp_2
		nT_tp_3 += field->tp_3
		nT_tp_4 += field->tp_4
		nT_tp_5 += field->tp_5

		skip
	enddo

	// total po grupi....
	? cLine
	? PADL( "Ukupno " + cGr_id + ":", 25 )
	@ prow(), nCol SAY STR( nU_sati, 8, 2 )
	@ prow(), pcol()+1 SAY STR( nU_bruto, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_neto, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_pio, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_zdr, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_nez, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_i_por, 12, 2 )
	
	if nU_tp_1 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_1, 12, 2 )
	endif
	if nU_tp_2 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_2, 12, 2 )
	endif
	if nU_tp_3 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_3, 12, 2 )
	endif
	if nU_tp_4 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_4, 12, 2 )
	endif
	if nU_tp_5 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_5, 12, 2 )
	endif
	
	? 

enddo

// total za sve....
? cLine
? "UKUPNO: "
@ prow(), nCol SAY STR( nT_sati, 8, 2 )
@ prow(), pcol()+1 SAY STR( nT_bruto, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_neto, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_pio, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_zdr, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_nez, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_i_por, 12, 2 )
	
if nT_tp_1 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_1, 12, 2 )
endif
if nT_tp_2 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_2, 12, 2 )
endif
if nT_tp_3 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_3, 12, 2 )
endif
if nT_tp_4 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_4, 12, 2 )
endif
if nT_tp_5 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_5, 12, 2 )
endif
	
? cLine

// ukalkulisi u rashod
nLD_ras += nT_bruto + nT_d_zdr + nT_d_nez

return


// --------------------------------------------------
// kreiranje tabele za izvjestaj
// --------------------------------------------------
static function cre_r_tbl()
local aDbf := {}

// fin, kalk
AADD(aDbf,{ "IDKONTO", "C", 7, 0 })
AADD(aDbf,{ "OPIS", "C", 50, 0 })
AADD(aDbf,{ "IZN_DUG", "N", 15, 2 })
AADD(aDbf,{ "IZN_POT", "N", 15, 2 })
AADD(aDbf,{ "SALDO", "N", 15, 2 })
AADD(aDbf,{ "DATUM", "D", 8, 0 })
AADD(aDbf,{ "MODUL", "C", 1, 0 })

// ld podaci
AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "R_NAZ", "C", 30, 0 })
AADD(aDbf,{ "GROUP", "C", 7, 0 })
AADD(aDbf,{ "NAZIV", "C", 15, 0 })
AADD(aDbf,{ "MJESEC", "N", 2, 0 })
AADD(aDbf,{ "GODINA", "N", 4, 0 })
AADD(aDbf,{ "TP_1", "N", 12, 2 })
AADD(aDbf,{ "TP_2", "N", 12, 2 })
AADD(aDbf,{ "TP_3", "N", 12, 2 })
AADD(aDbf,{ "TP_4", "N", 12, 2 })
AADD(aDbf,{ "TP_5", "N", 12, 2 })
AADD(aDbf,{ "SATI", "N", 12, 2 })
AADD(aDbf,{ "PRIHOD", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_UK", "N", 12, 2 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "UKUPNO", "N", 12, 2 })

t_exp_create( aDbf )

O_R_EXP

// index on ......
index on modul + group + idradn + STR(godina,4) + STR(mjesec,2) tag "1"
index on modul + idkonto tag "2"


return



// -------------------------------------------------------
// uslovi reporta
// -------------------------------------------------------
static function g_vars( dD_from, dD_to, cGroup, cKtoList, cKtoKart, ;
	cSpecLd )
local nRet := 1
local nBoxX := 10
local nBoxY := 65
local nX := 1
local nTArea := SELECT()

dD_from := DATE()-30
dD_to := DATE()
cSpecLD := "D"
cKtoList := SPACE(200)
cKtoKart := SPACE(200)
cGroup := SPACE(6)

O_PARAMS
private cSection := "S"
private cHistory := " "
private aHistory := {}

RPar("d1", @dD_from)
RPar("d2", @dD_to)
RPar("ld", @cSpecLD)
RPar("kl", @cKtoList)
RPar("kk", @cKtoKart)
RPar("gr", @cGroup)

Box(, nBoxX, nBoxY )
		
	@ m_x + nX, m_y + 2 SAY "Za period od:" GET dD_From
	@ m_x + nX, col() + 1 SAY "do:" GET dD_to

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Grupa:" GET cGroup ;
		VALID p_rj( @cGroup )

	++ nX

	@ m_x + nX, m_y + 2 SAY "Specifikacija LD (D/N)?" GET cSpecLd ;
		VALID cSpecLd $ "DN" PICT "@!"
	
	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "FIN konta   - lista:" GET cKtoList ;
		PICT "@S30"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "FIN konta - kartica:" GET cKtoKart ;
		PICT "@S30"


	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
	return nRet
endif

// write params
WPar("d1", dD_from)
WPar("d2", dD_to)
WPar("ld", cSpecLD)
WPar("kl", cKtoList)
WPar("kk", cKtoKart)
WPar("gr", cGroup)

select params
use

select (nTArea)
return nRet



