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
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/gendok/1g/mnu_gdok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: mnu_gdok.prg,v $
 * Revision 1.4  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 *
 */
 
/*! \file fmk/fin/gendok/1g/mnu_gdok.prg
 *  \brief Generacija dokumenata - menij
 */

/*! \fn MnuGenDok()
 *  \brief Menij generacije dokumenata
 */


function MnuGenDok()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. generacija dokumenta poc.stanja   ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","GENPOCSTANJA"))
	AADD(opcexe, {|| GenPocStanja()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. generisanje storna naloga ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","STORNONALOGA"))
	AADD(opcexe, {|| StornoNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


Menu_SC("gdk")

return
*}

