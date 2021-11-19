/*****************************************************************************************/
* Program Name  : PI_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-15
* Description   : build temporary dataset for PI domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.pi(encoding=any);

	put "ER" "ROR: there are now records in PI Signature domain.";
	
	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='PI Signature') then put "ER" "ROR: update PI_build.sas to read in only PI records from crf.PI.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PI_build.sas to handle PI.DELETED var appropriately.";
run;
/*
data pp_final_pi(keep=subnum visitid visname peperf_reas peperf_reas2 peres_desc peae pemh);
	set crf.pi(encoding=any where=(pagename='Physical Exam' and deleted='f'));

	length peperf_reas $700;
	peperf_reas=catx(': ',peperf_dec,pereasnd);

	length peperf_reas2 $700;
	peperf_reas2=catx(': ',peperf2_dec,pereasnd2);

	length peres_desc $700;
	if peres_abd_dec^='' or pedesc_abd^='' then peres_desc=catx(': ',peres_abd_dec,pedesc_abd);

	proc sort;
		by subnum visitid;
run;
*/