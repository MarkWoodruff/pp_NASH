/*****************************************************************************************/
* Program Name  : RAND_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-01
* Description   : build temporary dataset for RAND (Randomization) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching VS.
******************************************************************************************;

data pp_final_rand(keep=subnum visitid visname dsstdat_c cohort_dec);
	set crf.ds(encoding=utf8 where=(pagename='Randomization'));

	length dsstdat_c $10;
	if dsstdat>.z then dsstdat_c=strip(put(dsstdat,yymmdd10.));

	cohort_dec=tranwrd(cohort_dec,' �',' -');

	proc sort;
		by subnum visitid visname;
run;

%check_dates(dsn=pp_final_rand,date=dsstdat_c);
