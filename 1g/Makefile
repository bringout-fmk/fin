VERZIJA=CDX
MODUL=FIN

PRGS=/dev/fmk/fin/main/1g/e.prg
CS=
ASMS=

include /sclib/Makefile_clipper

FMK_LIBS=fmk_roba.lib fmk_rab.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib partnst.lib  

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc1g_key.lib sc2g_cui.lib fa_1ugo.lib


MODUL_LIBS=fin_1bud.lib fin_1db.lib fin_1dok.lib fin_1gen.lib fin_1ost.lib fin_1par.lib fin_1rdb.lib fin_1rof.lib fin_1rpt.lib fin_1sif.lib fin_1ut.lib fin_2db.lib fin_2m.lib fin_1rpm.lib fin_s1je.lib fin_s1ti.lib fin_1sql.lib fin_2sql.lib fin_1rrg.lib

PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    mod 

mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /dev/fmk/fin/main/1g/
	/sclib/form_blinker_lnk.sh $(LINKCMD)
	/sclib/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk   @_bl_2_.lnk $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE

zip:
	/sclib/zip.sh h:\\cs\\FMK\\binary\\$(MODUL).zip ..\\chs\\\*.chs c:\\dev\\fmk\af\cl-af\\svi\\\*.chs ..\template\\\*.txt $(EXEDOSDEST)\\$(MODUL).EXE

commit:
	/sclib/commit.sh $(MODUL) h:\\cs\\FMK\\binary\\$(MODUL).zip
	/sclib/commit.sh $(MODUL) h:\\cs\\FMK\\binary\\sfx\\$(MODUL).exe
clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK

7exe:
	/sclib/7exe.sh h:\\cs\\fmk\\binary\\sfx\\$(MODUL).exe ..\\chs\\\*.chs \\dev\\fmk\\af\\cl-af\\svi\\\*.chs ..\\template\\\*.txt $(EXEDOSDEST)\\$(MODUL).EXE
	

