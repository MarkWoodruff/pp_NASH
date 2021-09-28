/*****************************************************************************************/
* Program Name  : BODY_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for BODY (Body Measurements) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.vs(encoding=any where=(pagename='Body Measurements'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update UNS_build.sas to handle SV.DELETED var appropriately.";
run;

data pp_final_body(keep=subnum visname vsperf_n vsreasnd vsdat vsdat_c waist weight height height_bmi vsbmi_c);
	set crf.vs(encoding=any where=(pagename='Body Measurements' and deleted='f'));

	length vsdat_c $20;
	if vsdat>.z then vsdat_c=strip(put(vsdat,yymmdd10.));

	%macro value_unit(var=);
		length &var. $20;
		if vs&var.>.z or vs&var.u^='' then &var.=catx(' ',put(vs&var.,best.),vs&var.u);
	%mend;
	%value_unit(var=waist);
	%value_unit(var=weight);
	%value_unit(var=height);

	length height_bmi vsbmi_c $20;
	if vsheight_c>.z then height_bmi=strip(put(vsheight_c,best.))||' CM';
	if vsbmi>.z then vsbmi_c=strip(put(vsbmi,best.));

	proc sort;
		by subnum vsdat;
run;
