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

function MnuOstOperacije()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. povrat dokumenta u pripremu          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","POVRATNALOGA"))
	AADD(opcexe, {|| PovratNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. preknjizenje     ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREKNJIZENJE"))
	AADD(opcexe, {|| Preknjizenje()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. prebacivanje kartica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREBKARTICA"))
	AADD(opcexe, {|| PrebKartica()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. ima u suban nema u nalog")
AADD(opcexe, {|| ImaUSubanNemaUNalog()})

AADD(opc, "5. otvorene stavke")
AADD(opcexe, {|| OStav()})

Menu_SC("oop")

return

