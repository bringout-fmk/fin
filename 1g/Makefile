VERZIJA=CDX
MODUL=FIN

SRCDOSROOT=c:\\dev\\fmk\\fin\\1g\\

EOBJCOPY=echo nemam sta kopirati
PRGS=e.prg
EXE_PRGS=e.prg

FMK_LIBS=fmk_roba.lib fmk_rab.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib fmk_exp.lib fmk_lok.lib fmk_ugov.lib 

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc1g_key.lib sc2g_cui.lib sc_epl2.lib sc_gvp.lib

MODUL_LIBS=fin_1bud.lib fin_1db.lib fin_1dok.lib fin_1gen.lib fin_1ost.lib fin_1par.lib fin_1rdb.lib fin_1rof.lib fin_1rpt.lib fin_1sif.lib fin_1ut.lib fin_2db.lib fin_2m.lib fin_1rpm.lib fin_s1je.lib fin_1sql.lib fin_2sql.lib fin_1rrg.lib

include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper

LIBEXE:=@echo pokrenute make exe  !
CPLIB:=@echo pokrenuti make exe !
RMLIB:=@echo pokrenuti make exe !
e.obj : $(SC_BUILD_HOME_DIR)/sclib/sc.ch $(SC_BUILD_HOME_DIR)/sclib/std_cdx.ch ../fin.ch

lib: exe
