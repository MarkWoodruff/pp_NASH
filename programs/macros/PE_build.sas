/*****************************************************************************************/
* Program Name  : PE_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : build temporary dataset for PE domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.pe(encoding=any);

	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='Physical Exam') then put "ER" "ROR: update PE_build.sas to read in only PE records from crf.PE.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PE_build.sas to handle PE.DELETED var appropriately.";
run;

data pp_final_pe(keep=subnum visitid visname peperf_reas peperf_reas2 peres_desc peae pemh);
	set crf.pe(encoding=any where=(pagename='Physical Exam' and deleted='f'));

	length peperf_reas $700;
	peperf_reas=catx(': ',peperf_dec,pereasnd);

	length peperf_reas2 $700;
	peperf_reas2=catx(': ',peperf2_dec,pereasnd2);

	length peres_desc $700;
	if peres_abd_dec^='' or pedesc_abd^='' then peres_desc=catx(': ',peres_abd_dec,pedesc_abd);

	proc sort;
		by subnum visitid;
run;
