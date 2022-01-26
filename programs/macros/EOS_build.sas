/*****************************************************************************************/
* Program Name  : EOS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-12-13
* Description   : build temporary dataset for EOS (End of Study) domain
*
* Revision History
* Date       By            Description of Change
* 2022-01-24 Mark Woodruff refine note to log now that DSTERM is populated.
******************************************************************************************;

data _null_;
	set crf.ds(encoding=any);

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update EOS_build.sas to handle DS.DELETED var appropriately.";
run;

data pp_final_eos(keep=subnum visitid visname dsstdat_c dscomp_dec dsdecod_prim_dec dsdthdat_c dsaeno dspdno primary_reason covid);
	set crf.ds(encoding=any where=(pagename='End of Study' and deleted='f'));

	%macro datec(var=);
		length &var._c $10;
		if &var.>.z then &var._c=strip(put(&var.,yymmdd10.));
	%mend datec;
	%datec(var=dsstdat);
	%datec(var=dsdthdat);

	length primary_reason $5000;
	primary_reason=catx(': ',dsdecod_prim_dec,dsterm);
	if dsdecdot^='' or dsdecod_covid_dec^='' then 
		put "ER" "ROR: update EOS_build.sas to make sure EOS reasons working, they are now populated." SUBNUM=;

	length covid $5000;
	covid=catx(': ',dsdecod_covid_dec,dsdecdot);

	proc sort;
		by subnum visitid visname;
run;
