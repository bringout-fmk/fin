#include "\dev\fmk\fin\fin.ch"


/*! \fn KnjBlag()
 *  \brief Knjizenje blagajne
 */
function KnjBlag()
*{
O_EdBl()
ImeKol:={ ;
        {"F.",            {|| IdFirma }, "IdFirma" } ,;
        {"Broj",          {|| BrNal   }, "BrNal" },;
        {"Datum",         {|| DatNal  }, "DatNal" } ,;
        {"Konto",         {|| IdKonto }, "IdKonto", {|| .t.}, {|| P_Konto(@_IdKonto),.t. } } ,;
        {"Partner",       {|| IdPartn }, "IdPartn" } ,;
        {"D/P",           {|| D_P     }, "D_P" } ,;
        {"Tip",           {|| TipBlag }, "TipBlag" } ,;
        {ValDomaca(),     {|| transform(IznosBHD,FormPicL(gPicBHD,15)) }, "iznos "+ALLTRIM(ValDomaca()) } ,;
        {ValPomocna(),    {|| transform(IznosDEM,FormPicL(gPicDEM,10)) }, "iznos "+ALLTRIM(ValPomocna()) } ,;
        {"Opis",          {|| Opis    }, "OPIS" }, ;
        {"K1",            {|| K1      },   "k1" },;
        {"K2",            {|| K2      },   "k2" },;
        {"N1",            {|| N1      },   "n1" },;
        {"N2",            {|| N2      },   "n2" } ;
        }

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
	@ m_x+18,m_y+2 SAY "<c-N>  Nove Stavke    ³ <c-T> Brisi Stavku         "
	@ m_x+19,m_y+2 SAY "<c-P> Stampa Naloga   ³ <a-A> Azuriranje           "
	@ m_x+20,m_y+2 SAY "<c-F9> Brisi pripremu ³ <F10> Ostalo"
	ObjDbedit("Blag", 20, 77, {|| EdBlag()}, "", "Priprema blagajne...", , , , , 3)
BoxC()
closeret
return
*}


function EdBlag()
*{

return 
*}


function BlagNew()
*{
local cFirma:=gFirma
local cBrNal:=SPACE(6)
local cTipBl:="1"
local dDatum:=DATE()
local nIznos:=0
local cDP:="1"

O_EdBl()

Box("Knjizenje blagajne - unos", 18, 70)
	@ 2+m_x, 5+m_y SAY "Firma:" GET cFirma 
	@ 3+m_x, 5+m_y SAY "Tip blagajne:" 
	@ 4+m_x, 10+m_y SAY "1 - dinarska"  
	@ 5+m_x, 10+m_y SAY "2 - devizna   " GET cTipBl
	@ 6+m_x, 5+m_y SAY "Datum:" GET dDatum
	read
	cBrNal := BlNextNal(cFirma)
	@ 5+m_x, 50+m_y SAY "Broj naloga:" GET cBrNal VALID !Empty(cBrNal)
	
	@ 8+m_x, 5+m_y SAY "Duguje/potrazuje:" GET cDP VALID !Empty(cDP) .and. cDP$"12"
	@ 10+m_x, 5+m_y SAY "Iznos:" GET nIznos PICT PICDEM VALID !Empty(nIznos)
	
	
	read
BoxC()

if Pitanje(,"Azurirati nalog (D/N)?", "D") == "N"
	return
endif

AzurBlag(cFirma, cBrNal, dDatum, "", "", cDP, cTipBl, nIznos, 0, "", "", "", 0, 0)

return
*}




