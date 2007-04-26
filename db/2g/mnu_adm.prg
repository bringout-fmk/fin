#include "\dev\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */


/*! \file fmk/fin/db/2g/mnu_adm.prg
 *  \brief Administrativni menij
 */

/*! \fn MnuAdminDB()
 *  \brief Administrativni meni
 */

function MnuAdminDB()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                         ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc, "2. security")
AADD(opcexe, {|| MnuSecMain()})

if is_fmkrules()
	AADD(opc, "3. fmk pravila - rules ")
	AADD(opcexe, {|| p_fmkrules(,,, aRuleCols, bRuleBlock ) })
endif

Menu_SC("adm")

return
*}

