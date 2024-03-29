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


// -------------------------------------
// povrat naloga u pripremu
// -------------------------------------
function Povrat(lStorno)
local nRec

if lStorno==NIL 
  lStorno:=.f.
endif

if Logirati(goModul:oDataBase:cName, "DOK", "POVRAT" )
	lLogPovrat:=.t.
else
	lLogPovrat:=.f.
endif

O_SUBAN
O_PRIPR
O_ANAL
O_SINT
O_NALOG

SELECT SUBAN
set order to 4

cIdFirma:=gFirma
cIdFirma2:=gFirma
cIdVN:=cIdVN2:=space(2)
cBrNal:=cBrNal2:=space(8)

Box("",IF(lStorno,3,1),IF(lStorno,65,35))
 @ m_x+1,m_y+2 SAY "Nalog:"
 if gNW=="D"
  @ m_x+1,col()+1 SAY cIdFirma PICT "@!"
 else
  @ m_x+1,col()+1 GET cIdFirma PICT "@!"
 endif
 @ m_x+1,col()+1 SAY "-" GET cIdVN PICT "@!"
 @ m_x+1,col()+1 SAY "-" GET cBrNal VALID _f_brnal(@cBrNal)
 IF lStorno
   @ m_x+3,m_y+2 SAY "Broj novog naloga (naloga storna):"
   if gNW=="D"
    @ m_x+3,col()+1 SAY cIdFirma2
   else
    @ m_x+3,col()+1 GET cIdFirma2
   endif
   @ m_x+3,col()+1 SAY "-" GET cIdVN2 PICT "@!"
   @ m_x+3,col()+1 SAY "-" GET cBrNal2
 ENDIF
 read; ESC_BCR
BoxC()


if cBrNal="."
	IF !SigmaSif()
     		CLOSERET
  	ENDIF
  	private qqBrNal:=qqDatDok:=qqIdvn:=space(80)
  	qqIdVn:=padr(cidvn+";",80)
  	Box(,3,60)
   	do while .t.
    		@ m_x+1,m_y+2 SAY "Vrste naloga   "  GEt qqIdVn pict "@S40"
    		@ m_x+2,m_y+2 SAY "Broj naloga    "  GEt qqBrNal pict "@S40"
    		read
    		private aUsl1:=Parsiraj(qqBrNal,"BrNal","C")
    		private aUsl3:=Parsiraj(qqIdVN,"IdVN","C")
    		if aUsl1<>NIL .and. ausl3<>NIL
      			exit
    		endif
   	enddo
  	Boxc()
  	if Pitanje(,IF(lStorno,"Stornirati","Povuci u pripremu")+" naloge sa ovim kriterijem ?","N")=="D"
    		select suban
    		if !flock()
			Msg("SUBANALITIKA je zauzeta ",3)
			closeret
		endif

    private cFilt:="IdFirma=="+cm2str(cIdFirma)
    if aUsl1==".t." .and. aUsl3==".t."
      set filter to &cFilt
    else
      cFilt:=cFilt+".and."+aUsl1+".and."+aUsl3
      set filter to &cFilt
    endif


    MsgO("Prolaz kroz SUBANALITIKU...")
    go top
    do while !eof()
      select SUBAN; Scatter()
      select PRIPR
      if lStorno
         _idfirma := cIdFirma2
            _idvn := cIdVn2
           _brnal := cBrNal2
        _iznosbhd := -_iznosbhd
        _iznosdem := -_iznosdem
      endif
      append ncnl;  Gather2()
      select suban
      skip
      nRec:=recno()
      skip -1

      if !lStorno; dbdelete2(); endif

      go nRec
    enddo
    MsgC()
    MsgO("Prolaz kroz ANALITIKU...")
    select anal
    if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

    private cFilt:="IdFirma=="+cm2str(cIdFirma)
    if aUsl1==".t." .and. aUsl3==".t."
      set filter to &cFilt
    else
      cFilt:=cFilt+".and."+aUsl1+".and."+aUsl3
      set filter to &cFilt
    endif
    go top
    do while !eof()
      skip; nRec:=recno(); skip -1
      if !lStorno; dbdelete2(); endif
      go nRec
    enddo
    MsgC()

    MsgO("Prolaz kroz SINTETIKU...")
    select sint
    if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif
    altd()


    private cFilt:="IdFirma=="+cm2str(cIdFirma)
    if aUsl1==".t." .and. aUsl3==".t."
      set filter to &cFilt
    else
      cFilt:=cFilt+".and."+aUsl1+".and."+aUsl3
      set filter to &cFilt
    endif
    go top
    do while !eof()
      skip; nRec:=recno(); skip -1
      if !lStorno; dbdelete2(); endif
      go nRec
    enddo
    MsgC()
    MsgO("Prolaz kroz NALOZI...")
    select nalog
    if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif
    private cFilt:="IdFirma=="+cm2str(cIdFirma)
    if aUsl1==".t." .and. aUsl3==".t."
      set filter to &cFilt
    else
      cFilt:=cFilt+".and."+aUsl1+".and."+aUsl3
      set filter to &cFilt
    endif
    go top
    do while !eof()
      skip; nRec:=recno(); skip -1
      if !lStorno; dbdelete2(); endif
      go nRec
    enddo
    MsgC()

  endif
  closeret
endif


if Pitanje(,"Nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal+IF(lStorno," stornirati"," povuci u pripremu")+" (D/N) ?","D")=="N"
   closeret
endif

lBrisi:=.t.
IF !lStorno
  IF IzFMKIni("FIN","MogucPovratNalogaBezBrisanja","N",KUMPATH)=="D"
    lBrisi := ( Pitanje(,"Nalog "+cIdFirma+"-"+cIdVN+"-"+cBrNal+;
              " izbrisati iz baze azuriranih dokumenata (D/N) ?","D")=="D" )
  ENDIF
ENDIF

MsgO("SUBAN")

select SUBAN
seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
   select PRIPR; Scatter()
   select SUBAN; Scatter()
   select PRIPR
   if lStorno
      _idfirma := cIdFirma2
         _idvn := cIdVn2
        _brnal := cBrNal2
     _iznosbhd := -_iznosbhd
     _iznosdem := -_iznosdem
   endif
#ifdef XBASE
   append blank; Gather()
#else
   append ncnl; Gather2()
#endif
   select SUBAN
   skip
enddo

IF !lBrisi
  CLOSERET
ENDIF

if tbl_busy( F_SUBAN ) = 0
	msg("Datoteka je zauzeta ",3)
	closeret
endif

//if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

seek cidfirma+cidvn+cbrNal
DO WHILE !EOF() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  if !lStorno; dbdelete2(); endif
  go nRec
ENDDO
USE

MsgC()

MsgO("ANAL")
select ANAL; set order to 2

if tbl_busy( F_ANAL ) = 0
	msg("Datoteka je zauzeta ",3)
	closeret
endif

//if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  if !lStorno; dbdelete2(); endif
  go nRec
enddo
use
MsgC()


MsgO("SINT")
select sint;  set order to 2

if tbl_busy( F_SINT ) = 0
	msg("Datoteka je zauzeta ",3)
	closeret
endif

//if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  if !lStorno; dbdelete2(); endif
  go nRec
enddo

use
MsgC()

MsgO("NALOG")
select nalog

if tbl_busy( F_NALOG ) = 0
	msg("Datoteka je zauzeta ",3)
	closeret
endif
//if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

seek cidfirma+cidvn+cbrNal
do while !eof() .and. cIdFirma==IdFirma .and. cIdVN==IdVN .and. cBrNal==BrNal
  skip 1; nRec:=recno(); skip -1
  if !lStorno; dbdelete2(); endif
  go nRec
enddo
use
MsgC()

if lLogPovrat
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "POVRAT", nil, nil, nil, nil, "", "", cIdFirma+"-"+cIdVn+"-"+cBrNal, Date(), Date(), "", "Povrat naloga u pripremu")
endif

closeret
return



// --------------------------------
// tabela zauzeta
// --------------------------------
function tbl_busy( f_area )
local nTime
private cAlias := ALIAS( f_area )

if !( &(cAlias)->(flock()) )
 	   
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
		
		if ( &(cAlias)->(flock()) )
			exit
		endif
	    
		sleep(1)

	    enddo
	    
	    BoxC()

	    if nTime = 0 .and. !( &(cAlias)->(flock()) )
	
	    	Beep(4) 
 	    	BoxC() 
 	    	Msg("Timeout istekao !#Ponovite operaciju") 
 	    	close
		return 0
	
	    endif

endif

return 1


/*! \fn Preknjiz()
 *  \brief Preknjizenje naloga
 */
 
function Preknjiz()
*{
local fK1:="N"
local fk2:="N"
local fk3:="N"
local fk4:="N"
local cSK:="N"
nC:=50

O_PARAMS

private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)

select params
use

cIdFirma:=gFirma
picBHD:=FormPicL("9 "+gPicBHD,20)

O_PARTN

dDatOd:=CToD("")
dDatDo:=CToD("")

qqKonto:=SPACE(100)
qqPartner:=SPACE(100)
if gRJ=="D"
	qqIdRj:=SPACE(100)
endif

cTip:="1"

Box("",14,65)
set cursor on

cK1:="9"
cK2:="9"
cK3:="99"
cK4:="99"

if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	cK3:="999"
endif

cNula:="N"
cPreknjizi:="P"
cStrana:="D"
cIDVN:="88"
cBrNal:="00000001"
dDatDok:=date()
cRascl:="D"
private lRJRascl:=.f.

altd()

do while .t.
	@ m_x+1,m_y+6 SAY "PREKNJIZENJE SUBANALITICKIH KONTA"
 	if gNW=="D"
   		@ m_x+2,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cIdFirma:=Left(cIdFirma,2),.t.}
 	endif
 	@ m_x+3,m_y+2 SAY "Konto   " GET qqKonto  pict "@!S50"
 	@ m_x+4,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
 	if gRJ=="D"
		@ m_x+5,m_y+2 SAY "Rad.jed." GET qqIdRj pict "@!S50"
		@ m_x+6,m_y+2 SAY "Rasclaniti po RJ" GET cRascl pict "@!" valid cRascl$"DN"
 	endif
	@ m_x+7,m_y+2 SAY "Datum dokumenta od" GET dDatOd
 	@ m_x+7,col()+2 SAY "do" GET dDatDo

	// dodata mogucnost izbora i saldo (T), aMersed, 26.03.2004
 	@ m_x+8,m_y+2 SAY "Protustav/Storno/Saldo (P/S/T) " GET cPreknjizi valid cPreknjizi $ "PST" pict "@!"
 	// ako je cPreknjizi T onda mora odrediti na koju stranu knjizi
 	// posto moram provjeriti upravo upisanu varijablu ide READ
 	read
 	
	if cPreknjizi=="T" 
   		@ m_x+9,m_y+38 SAY "Duguje/Potrazuje (D/P)" GET cStrana valid cStrana $ "DP" pict "@!"
 	endif

 	@ m_x+10,m_y+2 SAY "Sifra naloga koji se generise" GET cIDVN
 	@ m_x+10,col()+2 SAY "Broj" GET cBrNal
 	@ m_x+10,col()+2 SAY "datum" GET dDatDok
 	if fk1=="D"
		@ m_x+11,m_y+2 SAY "K1 (9 svi) :" GET cK1
	endif
 	if fk2=="D"
		@ m_x+12,m_y+2 SAY "K2 (9 svi) :" GET cK2
	endif
 	if fk3=="D"
		@ m_x+13,m_y+2 SAY "K3 ("+cK3+" svi):" GET cK3
	endif
 	if fk4=="D"
		@ m_x+14,m_y+2 SAY "K4 (99 svi):" GET cK4
	endif

 	READ
	ESC_BCR
 
 	aUsl1:=Parsiraj(qqKonto,"IdKonto")
 	aUsl2:=Parsiraj(qqPartner,"IdPartner")
	if gRJ=="D" 
		if cRascl=="D"
			lRJRascl := .t.
		endif
	endif
	if gRJ=="D"
 		aUsl3:=Parsiraj(qqIdRj,"IdRj")
	endif
	if aUsl1<>NIL .and. aUsl2<>NIL
		exit
	endif
	
	if gRJ=="D" .and. aUsl3<>NIL
		exit
	endif
	
enddo
BoxC()

cIdFirma:=Left(cIdFirma,2)

O_PRIPR
O_KONTO
O_SUBAN

if cK1=="9"
	cK1:=""
endif
if cK2=="9"
	cK2:=""
endif
if cK3==REPL("9",LEN(ck3))
  	cK3:=""
else
  	cK3:=K3U256(cK3)
endif
if cK4=="99"
	cK4:=""
endif

select SUBAN

if (gRj=="D" .and. lRjRascl)
	set order to tag "9" //idfirma+idkonto+idrj+idpartner+...	
else
	set order to tag "1"
endif

cFilt1:="IDFIRMA=" + Cm2Str(cIdFirma) + ".and." + aUsl1 + ".and." + aUsl2 + IF(gRJ == "D", ".and." + aUsl3, "")+;
        IF(empty(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
        IF(empty(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))+;
        IF(fk1=="N","",".and.k1="+cm2str(ck1))+;
        IF(fk2=="N","",".and.k2="+cm2str(ck2))+;
        IF(fk3=="N","",".and.k3=ck3")+;
        IF(fk4=="N","",".and.k4="+cm2str(ck4))

cFilt1 := STRTRAN( cFilt1 , ".t..and." , "" )

if !(cFilt1==".t.")
	SET FILTER TO &cFilt1
endif

go top
EOF CRET

Pic:=PicBhd

if cTip=="3"
	m:="------  ------ ------------------------------------------------- --------------------- --------------------"
else
   	m:="------  ------ ------------------------------------------------- --------------------- -------------------- --------------------"
endif

nStr:=0
nUd:=0
nUp:=0      // DIN
nUd2:=0
nUp2:=0    // DEM
nRbr:=0

select pripr
go bottom
nRbr:=VAL(rbr)
select suban

do whileSC !eof()
	cSin:=LEFT(idkonto, 3)
 	nKd:=0
 	nKp:=0
 	nKd2:=0
 	nKp2:=0
	altd()
 	do whileSC !eof() .and.  cSin==LEFT(idkonto, 3)
     		cIdKonto:=IdKonto
     		cIdPartner:=IdPartner
		if gRj=="D"
			cIdRj:=idRj
     		endif
		nD:=0
     		nP:=0
     		nD2:=0
     		nP2:=0
		
		if (gRj=="D" .and. lRjRascl)
			bCond := {|| cIdKonto==IdKonto .and. IdRj==cIdRj .and. IdPartner==cIdPartner}
		else
			bCond := {|| cIdKonto==IdKonto .and. IdPartner==cIdPartner}
     		endif
		
		do whileSC !eof() .and. EVAL(bCond)
         		if d_P=="1"
           			nD+=iznosbhd
           			nD2+=iznosdem
         		else
           			nP+=iznosbhd
           			nP2+=iznosdem
         		endif
       			skip
     		enddo    // partner

     		select pripr
         
    		// dodata opcija za preknjizenje saldo T
     		if cPreknjizi=="T"
      			if round(nD-nP,2)<>0
       				append blank
       				replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
				replace d_p with iif(cStrana=="D","1","2"), iznosbhd with (nD-nP), iznosdem with (nD2 - nP2)
      				if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
		
		if cPreknjizi=="P"
      			if round(nD-nP,2)<>0
       				append blank
       				replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
       				replace  d_p with IIF(nD-nP > 0,"2","1"), iznosbhd with abs(nD-nP), iznosdem with abs(nD2-nP2)
      				if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
     		
		if cPreknjizi=="S"
        		if round(nD, 3)<>0
         			append blank
        			replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
         			replace  d_p with "1", iznosbhd with -nd, iznosdem with -nd2
        			if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
        		if round(nP, 3)<>0
         			append blank
         			replace idfirma with cIdFirma, idpartner with cIdPartner, idkonto with cIdKonto, idvn with cIdVn, brnal with cBrNal, datdok with dDatDok, rbr with str(++nRbr,4)
         			replace  d_p with "2", iznosbhd with -nP, iznosdem with -nP2
         			if gRj=="D"
					replace idrj with cIdRj
				endif
			endif
     		endif
     		select suban
   		nKd+=nD
		nKp+=nP  // ukupno  za klasu
   		nKd2+=nD2
		nKp2+=nP2  // ukupno  za klasu
 	enddo  // sintetika
 	nUd+=nKd
	nUp+=nKp   // ukupno za sve
 	nUd2+=nKd2
	nUp2+=nKp2   // ukupno za sve
enddo // eof
closeret
return
*}


