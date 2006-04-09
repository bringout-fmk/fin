#include "\dev\fmk\fin\fin.ch"

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


PROC PZagBlag(nDug,nPot,m,cBrDok,pici,cDinDem,dDatDok)
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
    if cdindem=="1"
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


