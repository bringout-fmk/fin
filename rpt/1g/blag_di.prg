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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */

#define DABLAGAS lBlagAsis.and._IDVN==cBlagIDVN


/*! \fn Blagajna()
 *  \brief Blagajna dnevni izvjestaj
 */
 
function Blagajna()
*{
local nRbr,nCOpis:=0,cOpis:=""
private pici:=FormPicL("9,"+gPicDEM,12)

lSumiraj := ( IzFMKINI("BLAGAJNA","DBISumirajPoBrojuVeze","N",PRIVPATH)=="D" )
O_KONTO
O_ANAL
O_PRIPR

GO TOP
_IDVN:=idvn; cIdfirma:=idfirma; cBrdok:=brnal
IF DABLAGAS
  cKontoBlag := PADR(IzFMKINI("BLAGAJNA","Konto","202000",PRIVPATH),7)
  // CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",PRIVPATH+"PRIPR")
  SET ORDER TO TAG "2"
  SEEK cidfirma+_idvn+cBrDok+cKontoBlag
  IF !FOUND() .or. Pitanje(,"Postoji knjizenje na kontu blagajne! Regenerisati knjizenje? (D/N)","N")=="D"
    IF FOUND()
      DO WHILE !EOF() .and. cidfirma+_idvn+cBrDok+cKontoBlag == idFirma+IdVN+BrNal+IdKonto
        SKIP 1; nRec:=RECNO(); SKIP -1
        DBDELETE2()
        GO (nRec)
      ENDDO
    ENDIF
    // CREATE_INDEX("1","idFirma+IdVN+BrNal+Rbr",PRIVPATH+"PRIPR")
    SET ORDER TO TAG "1"
    GO TOP
    lEOF:=.f.
    DO WHILE !EOF() .and. !lEOF .and. cidfirma+_idvn+cBrDok == idFirma+IdVN+BrNal
      SKIP 1; lEOF:=EOF(); nRec:=RECNO(); SKIP -1
      Scatter("w")
        APPEND BLANK
        // promijeni konto i predznak, te nuliraj partnera, rj, funk i fond
        wIdKonto   := cKontoBlag
        wIdPartner := SPACE(LEN(wIdPartner))
        wD_P       := IF(wD_P="1","2","1")
        IF gRJ=="D"
          wIdRj := SPACE(LEN(widrj))
        ENDIF
        if gTroskovi=="D"
          wFunk := SPACE(LEN(wFunk))
          wFond := SPACE(LEN(wFond))
        endif
      Gather("w")
      GO (nRec)
    ENDDO
  ENDIF
  SET ORDER TO TAG "1"
  go top
ENDIF

cDinDem:="1"
Box(,3,60)
 @ m_x+1,m_y+2 SAY ValDomaca()+"/"+ValPomocna()+" blagajnicki izvjestaj (1/2):" GET cDinDem
 read
 if cDinDem=="1"
   cIdKonto:=padr("2020",7)
   pici:=FormPicL("9,"+gPicBHD,12)
 else
   cIdKonto:=padr("2050",7)
 endif
 IF DABLAGAS
   cIdKonto := cKontoBlag
 ENDIF

 dDatdok:=datdok

 @ m_x+2,m_Y+2 SAY "Datum:" GET dDatDok
 @ m_x+3,m_Y+2 SAY "Konto blagajne:" GET cIdKonto valid P_Konto(@cIdKonto)
 read
BoxC()

SELECT PRIPR

start print cret
?
F12CPI
?? space(12)
if cdindem=="1"
  ?? "("+ValDomaca()+")"
else
  ?? "DEVIZNI ("+ValPomocna()+")"
endif
?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
?? space(8),"Broj:",cBrDok
?
?
nRbr:=0
nDug:=nPot:=0
nCol1:=20
? "    ------- ------------------------- --------------------- -------------- ---------------"
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? m:="    ------- ------------ ------------ --------------------- -------------- ---------------"
do while !eof()
  IF PROW() > 49+gPStranica
    PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
  ENDIF
  IF lSumiraj
    nPomD:=nPomP:=0
    cBrDok2:=brdok
    cOpis:=""
    nStavki:=0
    DO WHILE !EOF() .and. brdok==cBrDok2
      if idkonto<>cidkonto
        skip 1
        loop
      else
        if nPomD<>0 .and. d_p=="2" .or. nPomP<>0 .and. d_p=="1"
          // ovo se moze desiti ako su iste temeljnice za naplatu i isplatu
          exit
        endif
      endif
      if cdindem=="1"  // dinari !!!!
        if d_p=="1"
          nPomD+=iznosbhd
        else
          nPomP+=iznosbhd
        endif
      else
        if d_p=="1"
          nPomD+=iznosdem
        else
          nPomP+=iznosdem
        endif
      endif
      IF !EMPTY(opis)
        cOpis += opis
        ++nStavki
      ENDIF
      skip 1
    ENDDO
    IF PROW() > 49+gPStranica-nStavki
      PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
    ENDIF
    ? "    *",str(++nRbr,3)+". *"
    if nPomD<>0
      ?? " "+cbrdok2+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(cbrdok2,11)+"*"
    endif
    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis,20)
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomD,pici),14)
    @ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomP,pici),14)
    nDug += nPomD
    nPot += nPomP
    OstatakOpisa(cOpis,nCOpis)
  ELSE
    if idkonto<>cidkonto
      skip
      loop
    endif
    ? "    *",str(++nRbr,3)+". *"
    if d_p=="1"
      ?? " "+brdok+" *"+space(12)+"*"
    else
      ?? space(12)+"* "+padr(brdok,11)+"*"
    endif
    nCOpis:=pcol()+1
    ?? " "+PADR(cOpis:=ALLTRIM(opis),20)
    nCol1:=pcol()+1
    if cdindem=="1"  // dinari !!!!

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        nDug+=iznosbhd
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        nPot+=iznosbhd
      endif

    else

      if d_p=="1"
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        nDug+=iznosdem
      else
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        @ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        nPot+=iznosdem
      endif

    endif
    OstatakOpisa(cOpis,nCOpis)
    skip 1
  ENDIF
enddo
select anal
//CREATE_INDEX("ANALi1","IdFirma+IdKonto+dtos(DatNal)","ANAL")
hseek cIdfirma+cIdkonto
nDugSt:=nPotSt:=0
do while !eof() .and. idfirma==cIdfirma .and. idkonto==cIdkonto .and. datnal<=dDatDok

   if cDindem=="1"
     nDugSt+=dugbhd
     nPotSt+=potbhd
   else
     nDugSt+=dugdem
     nPotSt+=potdem
   endif
   
   skip
enddo
? m
@ prow()+1,10 SAY "Promet blagajne:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m
@ prow()+1,10 SAY "Saldo od "+dtoc(ddatdok-1)+":"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst,pici),14)
? m
@ prow()+1,10 SAY "Ukupan primitak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug,pici),14)

@ prow()+1,10 SAY "Izdatak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(npot,pici),14)

? m
@ prow()+1,10 SAY "Saldo na dan:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndugst-npotst+ndug-npot,pici),14)
? m
@ prow()+1,10 SAY "Slovima:"
@ prow(),pcol()+1 SAY Slovima(round(ndugst-npotst+ndug-npot,2),iif(cdindem=="1",ValDomaca(),ValPomocna()))
? m
?
?
@ prow()+1,25 SAY "  ___________________            ______________________"
@ prow()+1,25 SAY "     Blagajna                           Kontrola       "
FF
end print
closeret


function PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)

// zavrsetak prethodne stranice:
// -----------------------------
? m
@ prow()+1,10 SAY "Promet blagajne, prenos:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m
FF
// sljedeca stranica:
// ------------------
F12CPI
?? space(12)
if cDinDem=="1"
      ?? "("+ValDomaca()+")"
else
      ?? "DEVIZNI ("+ValPomocna()+")"
endif
?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
?? space(8),"Broj:",cBrDok
?
?
? "    ------- ------------------------- --------------------- -------------- ---------------"
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? m
@ prow()+1,10 SAY "Promet blagajne, donos:"
@ prow(),ncol1 SAY PADL(TRANSFORM(ndug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(npot,pici),14)
? m

return
*}


/*! \fn Slovima(nIzn,cDinDem)
 *  \brief Ispisuje neki iznos nIzn slovima
 *  \param nIzn    - iznos
 *  \param cDinDem - domaca/strana valuta
 */
 
function Slovima(nIzn,cDinDem)
*{
local nPom; cRez:=""
fI:=.f.

if nIzn<0
  nIzn:=-nIzn
  cRez:="negativno:"
endif

if (nPom:=int(nIzn/10**9))>=1
   if nPom==1
     cRez+="milijarda"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDinDEM)
      if right(cRez,1) $ "eiou"
        cRez+="milijarde"
      else
        cRez+="milijardi"
     endif
   endif
   nIzn:=nIzn-nPom*10**9
   fi:=.t.
endif
if (nPom:=int(nIzn/10**6))>=1
   if fi; cRez+="i"; endif
   fi:=.t.
   if nPom==1
     cRez+="milion"
   else
     Stotice(nPom,@cRez,.f.,.f.,cDINDEM)
     cRez+="miliona"
   endif
   nIzn:=nIzn-nPom*10**6
   f6:=.t.
endif
if (nPom:=int(nIzn/10**3))>=1
   if fi; cRez+="i"; endif
   fi:=.t.
   if nPom==1
     cRez+="hiljadu"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDINDEM)
     if right(cRez,1) $ "eiou"
       cRez+="hiljade"
     else
       cRez+="hiljada"
     endif
   endif
   nIzn:=nIzn-nPom*10**3
endif
if fi .and. nIzn>=1; cRez+="i"; endif
Stotice(nIzn,@cRez,.t.,.t.,cDINDEM)
return
*}



/*! \todo Ova funkcija vec postoji i u fakt-u treba je prebaciti u /sclib 
 */

/*! \fn Stotice(nIzn,cRez,fDecimale,fMnozina,cDinDem)
 *  \brief 
 *  \param nIzn
 *  \param cRez
 *  \param fDecimale
 *  \param fMnozina
 *  \param cDinDem
 */
 
function Stotice(nIzn,cRez,fDecimale,fMnozina,cDinDem)
*{
local fDec,fSto:=.f.

if (nPom:=int(nIzn/100))>=1
   aSl:={ "stotinu", "dvijestotine", "tristotine", "~etiristotine",;
          "petstotina","{eststotina","sedamstotina","osamstotina","devetstotina"}
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom*100
   fSto:=.t.
endif

fDec:=.f.
do while .t.
if int(nIzn)>10 .and. int(nIzn)<20
   aSl:={ "jedanest", "dvanest", "trinest", "~etrnest",;
          "petnest","{esnest","sedamnest","osamnest","devetnest"}
   cRez+=aSl[int(nIzn)-10]
   nIzn:=nIzn-int(nIzn)
endif
if (nPom:=int(nIzn/10))>=1
   aSl:={ "deset", "dvadeset", "trideset", "~etrdeset",;
          "pedeset","{ezdeset","sedamdeset","osamdeset","devedeset"}
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom*10
endif
if (nPom:=int(nIzn))>=1
    aSl:={ "jedan", "dva", "tri", "~etiri",;
           "pet","{est","sedam","osam","devet"}
   if fmnozina
        aSl[1]:="jedna"
        aSl[2]:="dvije"
   endif
   cRez+=aSl[nPom]
   nIzn:=nIzn-nPom
endif

if !fDecimale; exit; endif

if fdec; cRez+="/100"; exit; endif
fDec:=.t.
fMnozina:=.f.
nizn:=round(nIzn*100,0)
if nizn>0
 if !empty(cRez)
  cRez+=" "+cDINDEM+" i "
 endif
else
 if empty(cRez)
  cRez:="nula "+ValPomocna()
 else
  cRez+=" "+cDINDEM
 endif
 exit
endif
enddo


return cRez
*}


// stampa blagajne na osnovu azuriranog dokumenta
function blag_azur()
*{
local nRbr:=0
local nCOpis:=0
local cOpis:=""
private pici:=FormPicL("9,"+gPicDEM,12)
private cLine := ""

lSumiraj := ( IzFMKINI("BLAGAJNA","DBISumirajPoBrojuVeze","N",PRIVPATH)=="D" )

O_PARTN
O_KONTO
O_ANAL
O_SUBAN

cDinDem:="1"

Box(,4,60)
	@ m_x+1,m_y+2 SAY ValDomaca()+"/"+ValPomocna()+" blagajnicki izvjestaj (1/2):" GET cDinDem
 	read
 	if cDinDem=="1"
   		cIdKonto:=padr("2020",7)
   		pici:=FormPicL("9,"+gPicBHD,12)
 	else
   		cIdKonto:=padr("2050",7)
 	endif

 	dDatdok:=datdok
	cIdFirma := gFirma
	cTipDok := SPACE(2)
	cBrDok := SPACE(8)
	
	@ m_x+2,m_Y+2 SAY "Dokument:" GET cIdFirma VALID !EMPTY(cIdFirma)
	@ m_x+2,m_Y+15 SAY "-" GET cTipDok VALID !EMPTY(cTipDok)
	@ m_x+2,m_Y+20 SAY "-" GET cBrDok VALID !EMPTY(cBrDok)
	
	read

	// precesljaj dokument radi konta i datuma, pa ponudi
	dat_kto_blag(@dDatDok, @cIdKonto, cIdFirma, cTipDok, cBrDok)
	
	@ m_x+3,m_Y+2 SAY "Datum:" GET dDatDok
 	@ m_x+4,m_Y+2 SAY "Konto blagajne:" GET cIdKonto valid P_Konto(@cIdKonto)
 	read
BoxC()

if LastKey()==K_ESC
	return
endif

SELECT SUBAN
set order to tag "4"
hseek cIdFirma+cTipDok+cBrDok

// nisam pronasao dokument
if !FOUND()
	MsgBeep("Dokument " + cIdFirma + "-" + cTipDok + "-" + cBrDok + " ne postoji!")
	return
endif

start print cret


nRbr:=0
nDug:=0
nPot:=0
nCol1:=20

// setuj liniju reporta
set_line(@cLine)

// stampaj zaglavlje reporta
st_bl_zagl(cLine, cDinDem, cIdFirma, cTipDok, cBrDok, dDatDok)

do while !eof() .and. field->idfirma == cIdFirma .and. field->idvn == cTipDok .and. field->brnal == cBrDok

	IF PROW() > 49+gPStranica
    		PZagBlag(nDug,nPot,cLine,cBrDok,pici,cDinDem,dDatDok)
  	ENDIF
  	IF lSumiraj
    		nPomD:=nPomP:=0
    		cBrDok2:=brdok
    		cOpis:=""
    		nStavki:=0
    		DO WHILE !EOF() .and. brdok==cBrDok2
      			if idkonto<>cIdKonto
        			skip 1
        			loop
      			else
        			if nPomD<>0 .and. d_p=="2" .or. nPomP<>0 .and. d_p=="1"
          				// ovo se moze desiti ako su iste 
					// temeljnice za naplatu i isplatu
          				exit
        			endif
      			endif
      			if cDinDem=="1"  // dinari !!!!
        			if d_p=="1"
          				nPomD+=iznosbhd
        			else
          				nPomP+=iznosbhd
        			endif
      			else
        			if d_p=="1"
          				nPomD+=iznosdem
        			else
          				nPomP+=iznosdem
        			endif
      			endif
      			IF !EMPTY(opis)
        			cOpis += opis
        			++nStavki
      			ENDIF
      			skip 1
    		ENDDO
    		IF PROW() > 49+gPStranica-nStavki
      			PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
    		ENDIF
		
    		? "    *", str(++nRbr, 3) + ". *"
    		
		if nPomD<>0
      			?? " " + cBrDok2 + " *" + space(12) + "*"
    		else
      			?? space(12) + "* " + padr(cBrDok2, 11) + "*"
    		endif
		
    		nCOpis:=pcol()+1
    		?? " "+PADR(cOpis,20)
    		nCol1:=pcol()+1
    		@ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomD,pici),14)
    		@ prow(),pcol()+1 SAY PADL(TRANSFORM(nPomP,pici),14)
    		nDug += nPomD
    		nPot += nPomP
    		OstatakOpisa(cOpis,nCOpis)
	ELSE
    	if idkonto <> cIdkonto
      		skip
      		loop
    	endif
    	? "    *",str(++nRbr,3)+". *"
    	if d_p=="1"
      		?? " "+brdok+" *"+space(12)+"*"
    	else
      		?? space(12)+"* "+padr(brdok,11)+"*"
    	endif
    	nCOpis:=pcol()+1
    	?? " "+PADR(cOpis:=ALLTRIM(opis),20)
    	nCol1:=pcol()+1
    	if cDinDem=="1"  // dinari !!!!
		if d_p=="1"
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        		nDug+=iznosbhd
      		else
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
       	 		@ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosbhd,pici),14)
        		nPot+=iznosbhd
      		endif
	else
		if d_p=="1"
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        		nDug+=iznosdem
      		else
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(0,pici),14)
        		@ prow(),pcol()+1 SAY PADL(TRANSFORM(iznosdem,pici),14)
        		nPot+=iznosdem
      		endif
	endif
    	OstatakOpisa(cOpis,nCOpis)
    	skip 1
	ENDIF
enddo

// procesljaj staro stanje
select anal
hseek cIdfirma+cIdkonto

nDugSt:=0
nPotSt:=0

do while !eof() .and. idfirma==cIdfirma .and. idkonto==cIdkonto .and. datnal<dDatDok
	if cDinDem=="1"
     		nDugSt+=dugbhd
     		nPotSt+=potbhd
   	else
     		nDugSt+=dugdem
     		nPotSt+=potdem
   	endif
   	skip
enddo

? cLine
@ prow()+1,10 SAY "Promet blagajne:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDug,pici),14)
@ prow(),pcol()+1 SAY PADL(TRANSFORM(nPot,pici),14)
? cLine
@ prow()+1,10 SAY "Saldo od "+dtoc(dDatDok-1)+":"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugst-nPotst,pici),14)
? cLine
@ prow()+1,10 SAY "Ukupan primitak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugSt-nPotSt+nDug,pici),14)
@ prow()+1,10 SAY "Izdatak:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nPot,pici),14)
? cLine
@ prow()+1,10 SAY "Saldo na dan:"
@ prow(),ncol1 SAY PADL(TRANSFORM(nDugSt-nPotSt+nDug-nPot,pici),14)
? cLine
@ prow()+1,10 SAY "Slovima:"
@ prow(),pcol()+1 SAY Slovima(round(ndugst-npotst+ndug-npot,2),iif(cdindem=="1",ValDomaca(),ValPomocna()))
? cLine
?
?

@ prow()+1,25 SAY "  ___________________            ______________________"
@ prow()+1,25 SAY "     Blagajna                           Kontrola       "

FF

end print

closeret
return


// vrati konto naloga
static function dat_kto_blag(dDatum, cKonto, cFirma, cIdVn, cBrNal)
local nLenKto
local cTmpKto
select suban
set order to tag "4"
hseek cFirma+cIdVn+cBrNal

// nisam pronasao dokument
if !FOUND()
	MsgBeep("Dokument " + cFirma + "-" + cIdVn + "-" + cBrNal + " ne postoji!")
	return
endif

do while !EOF() .and. suban->(idfirma + idvn + brnal) == cFirma + cIdVn + cBrNal
	nTmpKto := field->idkonto
	nLenKto := LEN(ALLTRIM(nTmpKto))
	if nLenKto > 4
		if LEFT(nTmpKto, 4) == "2020"
			cKonto := nTmpKto
			dDatum := field->datdok
			exit
		endif
	endif
	skip
enddo

return


// setovanje linije za izvjestaj
static function set_line(cLine)
local cRazmak := SPACE(1)
cLine := ""
cLine += SPACE(4)
cLine += REPLICATE("-", 7)
cLine += cRazmak
cLine += REPLICATE("-", 25)
cLine += cRazmak
cLine += REPLICATE("-", 21)
cLine += cRazmak
cLine += REPLICATE("-", 14)
cLine += cRazmak
cLine += REPLICATE("-", 15)

return


// stampa zaglavlja blagajne
function st_bl_zagl(cLine, cDinDem, cIdFirma, cTipDok, cBrDok, dDatDok )
?
F12CPI

?? space(12)

if cDinDem=="1"
  	?? "("+ValDomaca()+")"
else
  	?? "DEVIZNI ("+ValPomocna()+")"
endif

?? " BLAGAJNICKI IZVJESTAJ OD ", dDatDok
?? space(8),"Broj:",cBrDok
? SPACE(20)
?? "na osnovu dokumenta: " + cIdFirma + "-" + cTipDok + "-" + cBrDok
?
?
? cLine
? "    * Redni*       Temeljnica        *        OPIS         *    ULAZ      *    IZLAZ     *"
? "    * broj *                         *                     *              *              *"
? "    *      *            *            *                     *              *              *"
? cLine

return
