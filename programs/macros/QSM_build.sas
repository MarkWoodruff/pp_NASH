/*****************************************************************************************/
* Program Name  : QSM_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-20
* Description   : build temporary dataset for QS (Menstrual Cycles) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.qs(encoding=utf8 where=(pagename='Menstrual Cycle'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update QSM_build.sas to handle QS.DELETED var appropriately.";

	if qsstdat=. then put "ER" "ROR: update QS_build.sas to handle missing dates in sorting.";
run;

data pp_final_qsm(keep=subnum visitid visname qsstdat_c qsendat_c);
	set crf.qs(encoding=utf8 where=(pagename='Menstrual Cycle' and deleted='f'));

	length qsstdat_c $12;
	if qsstdat>.z then qsstdat_c=strip(put(qsstdat,yymmdd10.));

	length qsendat_c $12;
	if qsendat>.z then qsendat_c=strip(put(qsendat,yymmdd10.));

	proc sort;
		by subnum visitid visname;
run;
