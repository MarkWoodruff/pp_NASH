/*****************************************************************************************/
* Program Name  : RAND_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-01
* Description   : build temporary dataset for RAND (Randomization) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data pp_final_rand(keep=subnum dsstdat_c cohort_dec);
	set crf.ds(encoding=utf8 where=(pagename='Randomization'));

	length dsstdat_c $10;
	if dsstdat>.z then dsstdat_c=strip(put(dsstdat,yymmdd10.));

	proc sort;
		by subnum;
run;
