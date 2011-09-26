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


/*! \file fmk/fin/razdb/1g/ldfin.prg
 *  \brief Prenos podataka LD->FIN
 */
 
/*! \fn LdFin() 
 *  \brief Prenos podataka LD->FIN
 */

function LdFin()
local cPath
local nIznos
private cShema:="1"
private dDatum:=DATE()
private _godina:=YEAR(DATE())
private _mjesec:=MONTH(DATE())
private _ldpath:=PADR( STRTRAN(KUMPATH, SLASH + "FIN", SLASH + "LD"), 60)
private cSection:="L"
private cHistory:=" "
private aHistory:={}

O_PARAMS

RPar("lk", @_ldpath)
RPar("sh", @cShema)

Box("#KONTIRANJE OBRACUNA PLATE", 10, 75)
	
	@ m_x+2, m_y+2 SAY "GODINA:" GET _godina PICT "9999"
	@ m_x+3, m_y+2 SAY "MJESEC:" GET _mjesec PICT "99"
	@ m_x+5, m_y+2 SAY "Shema kontiranja:" GET cShema PICT "@!"
	@ m_x+6, m_y+2 SAY "Datum knjizenja :" GET dDatum
	
	@ m_x+8, m_y+2 SAY "LD kumulativ:" GET _ldpath VALID !EMPTY(_ldpath)
	
	READ
BoxC()

if LASTKEY() == K_ESC
	close all
	return
endif

select params

WPar("lk", _ldpath)
WPar("sh", cShema)

select params
use

cPath := ALLTRIM(_ldpath)

O_RNAL
O_NALOG
O_PRIPR
O_TRFP3

if file( cPath + "REKLD.DBF")
	use (cPath + "REKLD.DBF") new
	set order to 1
else
	MsgBeep("Niste pokrenuli rekapitulaciju LD-a!")
	close all
	return
endif

if file(cPath + "REKLDP.DBF")
	use (cPath + "REKLDP.DBF") new
	set order to 1
endif

select trfp3
set filter to shema=cShema
go top

cBrNal := nextnal( gFirma, trfp3->idvn )

select trfp3

nRBr:=0
nIznos:=0

do while !eof()
	
	private cPom:=trfp3->id
	
	if "#RN#"$cPom
		
		select rnal
		go top
		
		do while !eof()
			cPom:=trfp3->id
			cBrDok:=rnal->id
			cPom:=STRTRAN(cPom,"#RN#",cBrDok)
			nIznos:=&cPom
			if round(nIznos,2)<>0
				select pripr
				append blank
				replace idvn     with trfp3->idvn
				replace	idfirma  with gFirma
				replace	brnal    with cBrNal
				replace	rbr      with STR(++nRBr,4)
				replace datdok   with dDatum
				replace	idkonto  with trfp3->idkonto
				replace	d_p      with trfp3->d_p
				replace	iznosbhd with nIznos
				replace	brdok    with cBrDok
				replace	opis     with TRIM(trfp3->naz)+" "+STR(_mjesec,2)+"/"+STR(_godina,4)
				select rnal
			endif
			skip 1
		enddo
		select trfp3
	
	elseif "#AH#" $ cPom

		cPom := STRTRAN(cPom, "#AH#", "")
		
		altd()
		
		cIznos := &cPom
		
		select trfp3
		
	else
		
		nIznos := &cPom
		cBrDok := ""
		
		if round(nIznos,2)<>0
			
			select pripr
			append blank
			
			replace idvn     with trfp3->idvn
			replace	idfirma  with gFirma
			replace	brnal    with cBrNal
			replace	rbr      with STR(++nRBr,4)
			replace datdok   with dDatum
			replace	idkonto  with trfp3->idkonto
			replace	d_p      with trfp3->d_p
			replace	iznosbhd with nIznos
			replace	brdok    with cBrDok
			replace	opis     with TRIM(trfp3->naz)+" "+STR(_mjesec,2)+"/"+STR(_godina,4)
			select trfp3
		endif
	endif
	skip 1
enddo

close all
return


// ------------------------------------------------------------
// autorski honorari prenos REKLD
// cTag: "2" - po partneru, "3" - izdanju, "4" - izdanje partner
// cOpis: trazi opis pri trazenju
// ------------------------------------------------------------
function ah_rld(cId, cTag, cOpis)
local nTArea := SELECT()
local nIzn1 := 0
local nIzn2 := 0
local cTmp := ""

if cTag == nil
	cTag := "1"
endif
if cOpis == nil
	cOpis := ""
endif

select rekld
set order to tag &cTag
go top
seek str(_godina,4) + str(_mjesec,2) + cId

altd()

do while !EOF() .and. godina == STR(_godina, 4) .and. ;
		mjesec == STR(_mjesec, 2) .and. ;
		ALLTRIM(id) == cId
	
	cTmp := field->idpartner
	cIzdanje := field->izdanje

	nIzn1 := 0
	nIzn2 := 0

	do while !EOF() .and. godina == STR(_godina,4) .and. ;
		mjesec == STR(_mjesec, 2) .and. ;
		ALLTRIM(id) == cId .and. ;
		IF(cTag=="2" .or. cTag == "4", idpartner == cTmp, .t.) .and. ;
		IF(cTag=="3" .or. cTag == "4", izdanje == cIzdanje, .t.)
		
		if !EMPTY(cOpis) .and. AT(cOpis, cIzdanje) == 0
			skip
			loop
		endif
		
		nIzn1 += iznos1
		nIzn2 += iznos2
		
		skip 
	enddo

	cBrDok := ""
	
	if cTag == "3" .or. cTag == "1" .or. cTag == "4"
		cTmp := ""
	endif
	
	// dodaj u pripremu
	if ROUND(nIzn1, 2) <> 0
		
		select pripr
		append blank
			
		replace idvn with trfp3->idvn
		replace	idfirma with gFirma
		replace	brnal with cBrNal
		replace	rbr with STR( ++ nRBr, 4)
		replace datdok with dDatum
		replace	idkonto with trfp3->idkonto
		replace	d_p with trfp3->d_p
		replace	iznosbhd with nIzn1
		replace idpartner with cTmp
		replace	brdok with cBrDok
		
		cNalOpis := TRIM(trfp3->naz) + " za " + STR(_mjesec,2) + "/" + STR(_godina, 4)
	
		replace opis with cNalOpis
	
	endif
	
	select rekld
enddo

select (nTArea)
return




/*! \fn RLD(cId, nIz12)
 *  \brief
 *  \param cId
 *  \param nIz12
 */
 
function RLD(cId, nIz12)
*{
local npom1:=0, npom2:=0, nVrati
if nIz12==NIL
	niz12:=1
endif
RekapLD(cid,_godina,_mjesec,@npom1,@npom2)
if nIz12==1
	nVrati:=npom1
else
	nVrati:=npom2
endif
return nVrati
*}


/*! \fn RekapLD(cId, nGodina, nMjesec, nIzn1, nIzn2, cOpis)
 *  \brief Rekapitulacija LD
 *  \param cId
 *  \param nGodina
 *  \param nMjesec
 *  \param nIzn1
 *  \param nIzn2
 *  \param cOpis
 */
function RekapLD(cId, nGodina, nMjesec, nIzn1, nIzn2, cOpis)
*{
local nArr:=SELECT()

if SELECT("REKLD")=0
	return
endif

if copis=NIL
  copis:=""
endif

select rekld
nizn1:=nizn2:=0
seek str(ngodina,4)+str(nmjesec,2)+cid

do while !eof() .and. godina+mjesec+id = str(ngodina,4)+str(nmjesec,2)+cid
	nizn1 += iznos1
	nizn2 += iznos2
	skip 1
enddo

select (nArr)
return
*}


/*! \fn RLDP(cId, cBrDok, nIz12)
 *  \brief
 *  \param cId
 *  \param cBrDok
 *  \param nIz12
 */
function RLDP(cId, cBrDok, nIz12)
*{
local npom1:=0, npom2:=0
if niz12=NIL
	niz12:=1
endif
RekapLDP(cid,_godina,_mjesec,@npom1,@npom2,cBrDok)
if niz12==1
 return npom1
else
 return npom2
endif
return 0
*}


/*! \fn RekapLDP(cId, nGodina, nMjesec, nIzn1, nIzn2, cBrDok)
 *  \brief
 *  \param cId
 *  \param nGodina
 *  \param nMjesec
 *  \param nIzn1
 *  \param nIzn2
 *  \param cBrDok
 */

function RekapLDP(cId, nGodina, nMjesec, nIzn1, nIzn2, cBrDok)
*{
local nArr:=SELECT()

if SELECT("REKLDP")=0
	return
endif

if cBrDok==NIL
  cBrDok:=""
endif

select rekldp
nizn1:=nizn2:=0
seek str(ngodina,4)+str(nmjesec,2)+cid

do while !eof() .and. godina+mjesec+id = str(ngodina,4)+str(nmjesec,2)+cid
	if idrnal=cBrDok
		nizn1 += iznos1
		nizn2 += iznos2
	endif
	skip 1
enddo

select (nArr)
return
*}
