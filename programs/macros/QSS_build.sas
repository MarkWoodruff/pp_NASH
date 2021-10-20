/*****************************************************************************************/
* Program Name  : QSS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-20
* Description   : build temporary dataset for QS (Menstrual Summary) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.qs(encoding=utf8 where=(pagename='Menstrual Summary'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update QSS_build.sas to handle QS.DELETED var appropriately.";
run;

data pp_final_qss(keep=subnum visitid visname qsyn_nomc qs16_dec qs17_dec);
	set crf.qs(encoding=utf8 where=(pagename='Menstrual Summary' and deleted='f'));

	length qsnomc_dec_ $2000;
	qsnomc_dec_=catx(', ',qsnomc_dec,qsnomcot);

	length qsyn_nomc $700;
	qsyn_nomc=catx(': ',qsyn_dec,qsnomc_dec_);

	proc sort;
		by subnum visitid visname;
run;
