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


function MnuPregledDokumenata()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. kontrola zbira datoteka                     ")
AADD(opcexe, {|| KontrZb()})

AADD(opc, "2. stampanje azuriranog dokumenta")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","MNUSTAMPAAZURNALOGA"))
	AADD(opcexe, {|| MnuStampaAzurNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. stampa liste dokumenata")
AADD(opcexe, {|| StDatN()})

AADD(opc, "4. kontrola zbira datoteka za period - BETA")
AADD(opcexe, {|| KontrZb(.t.)})

Menu_SC("pgl")

return

