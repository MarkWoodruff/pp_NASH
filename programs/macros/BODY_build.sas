/*****************************************************************************************/
* Program Name  : BODY_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for BODY (Body Measurements) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching VS.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff handle sorting of records with missing dates.
******************************************************************************************;

data _null_;
	set crf.vs(encoding=any where=(pagename='Body Measurements'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update BODY_build.sas to handle SV.DELETED var appropriately.";
run;

data body;
	set crf.vs(encoding=any where=(pagename='Body Measurements' and deleted='f'));
run;

%missing_dates(dsn=body,date=vsdat,pgmname=BODY_build);

data pp_final_body(keep=subnum visitid visname vsperf_n vsreasnd vsdat_sort vsdat vsdat_c waist weight height height_bmi vsbmi_c);
	set body;

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
		by subnum vsdat_sort vsdat;
run;
