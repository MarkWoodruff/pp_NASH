/*****************************************************************************************/
* Program Name  : EOT_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-12-09
* Description   : build temporary dataset for EOT (End of Treatment) domain
*
* Revision History
* Date       By            Description of Change
* 2021-12-13 Mark Woodruff update primary reason.
* 2022-01-18 Mark Woodruff update note to log.
* 2022-02-14 Mark Woodruff remove note to log as primary_reason working as intended.
******************************************************************************************;

data _null_;
	set crf.ds(encoding=any);

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update EX_build.sas to handle EX.DELETED var appropriately.";
run;

data pp_final_eot(keep=subnum visitid visname dsexdat_c dsstdat_c complet_dec dsdecod_dec dsaeno dthdat_c dspdno dablind_dec primary_reason);
	set crf.ds(encoding=any where=(pagename='End of Treatment' and deleted='f'));

	%macro datec(var=);
		length &var._c $10;
		if &var.>.z then &var._c=strip(put(&var.,yymmdd10.));
	%mend datec;
	%datec(var=dsexdat);
	%datec(var=dsstdat);
	%datec(var=dthdat);

	length primary_reason $5000;
	primary_reason=catx(': ',dsdecod_dec,dswsoth,dspdoth,covidsp_dec,dstermot);

	proc sort;
		by subnum visitid visname;
run;
