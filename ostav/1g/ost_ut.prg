#include "\dev\fmk\fin\fin.ch"


/*! \fn OStUndo()
 *  \brief Otvorene stavke - UNDO operacija
 */
function OStUndo()
*{

if !SigmaSif("SCUNDO")
	MsgBeep("Nemate ovlastenja za koristenje ove operacije!")
	return
endif

MsgBeep("Prije ove operacije obavezno arhivirati podatke!")

dDatOd:=CToD("")
dDatDo:=DATE()
cPartn:=SPACE(6)
cKonto:="2120"
cVNal:=PADR("61;",40)
cDp:="2"

O_SUBAN
select suban

cKonto:=PADR(cKonto, LEN(suban->idkonto))
cPartn:=PADR(cPartn, LEN(suban->idPartner))

// setuj parametre
if GetVars(@dDatOd, @dDatDo, @cPartn, @cKonto, @cDp, @cVNal) == 0
	MsgBeep("Operacija prekinuta !!!")
	return
endif

// pokreni undo opciju
OStRunUndo(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)


return
*}


/*! \fn GetVars(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)
 *  \brief Setuj parametre
 */
static function GetVars(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)
*{
O_PARTN
O_KONTO

Box(,5,60)
	@ m_x+1,m_y+2 SAY "Datum od" GET dDatOd 
	@ m_x+1,m_y+21 SAY "do" GET dDatDo 
	@ m_x+2,m_y+2 SAY "Konto   " GET cKonto VALID P_KontoFin(@cKonto) PICT "@!"
  	@ m_x+3,m_y+2 SAY "Partner (prazno-svi)" GET cPartn VALID EMPTY(cPartn) .or. P_Firma(@cPartn) PICT "@!"
  	@ m_x+4,m_y+2 SAY "Konto duguje / potrazuje" GET cDp WHEN {|| cDp:=iif(cKonto='54','1','2'), .t.} VALID cDp$"12 "
  	@ m_x+5,m_y+2 SAY "Vrste naloga" GET cVNal 
  	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

return 1
*}


/*! \fn OStRunUndo()
 *  \brief glavna funkcija obrade dokumenta 
 */
static function OStRunUndo(dDOd, dDDo, cIdPartn, cIdKonto, cDugPot, cVNal)
*{
select suban
set order to tag "1"
go top

if !Empty(cIdPartn)
	seek gFirma + cIdKonto + cIdPartn
else
	seek gFirma + cIdKonto
endif

cBrNal:=""
cTipNal:=""
cKupac:=""

Box(, 3, 70)

do while !EOF() .and. field->idkonto=cIdKonto .and. field->datdok <= dDatDo
	// uzmi broj prvog naloga
	cBrNal := field->brnal
	cTipNal := field->idvn
	cKupac := field->idpartner
	
	select partn
	hseek cKupac
	select suban
	
	@ 1+m_x, 2+m_y SAY "Partner: " + partn->naz
	
	// ako tip naloga nije u zadatim tipovima naloga
	if AT(cTipNal, cVNal)==0
		skip
		loop
	endif
	
	nIznBhd := 0
	nIznDem := 0
	
	@ 2+m_x, 2+m_y SAY "Nalog: " + gFirma + "-" + cTipNal + "-" + ALLTRIM(cBrNal)
	
	do while !EOF() .and. field->idkonto=cIdKonto .and. field->idpartner=cKupac .and. field->datdok <= dDatDo .and. field->brnal=cBrNal .and. field->idvn=cTipNal
		
		do case
			case cDugPot == "1"
				// varijanta duguje
				if (field->d_p == "2")
					skip
				endif
				
			case cDugPot == "2"
				// varijanta potrazuje
				// uplate
				if (field->d_p == "1")
					skip
				endif
		endcase
		
		nIznBhd += field->iznosbhd
		nIznDem += field->iznosdem
		
		@ 3+m_x, 2+m_y SAY SPACE(50)
		@ 3+m_x, 2+m_y SAY "Suma += " + ALLTRIM(STR(nIznBhd))
		
		skip
		
		// ako je sljedeci nalog razlicit, updateuj postojeci sa sumom
		if (field->brnal<>cBrNal .or. field->idvn <> cTipNal)
			skip -1
			Scatter()
			_iznosbhd := nIznBhd
			_iznosdem := nIznDem
			_brdok := ""
			_otvst := ""
			Gather()
			skip
		else
			// izbrisi prethodnu stavku
			skip -1
			delete
			skip
		endif
	enddo
enddo

BoxC()

return
*}







