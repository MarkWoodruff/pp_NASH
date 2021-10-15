/*****************************************************************************************/
* Program Name  : INFCON_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-14
* Description   : build temporary dataset for INFCON (Informed Consent) domain
*
* Revision History
* Date       By            Description of Change
* 2021-09-24 Mark Woodruff use SUBNUM.
* 2021-10-15 Mark Woodruff add Reconsent to check of pagename.
******************************************************************************************;

** ensure only informed consent records are present in crf.ds **;
data _null_;
	set crf.ds(encoding=any);
	if ^(pagename in ('Randomization','Informed Consent','Reconsent Log')) then put "ER" "ROR: update INFCON_build.sas to read in only Informed Consent records.";
run;

** ensure DELETED var is being handled correctly **;
data _null_;
	set crf.ds(encoding=any)
		crf.dm(encoding=any)
		crf.ie(encoding=any)
		crf.mh(encoding=any)
		crf.ae(encoding=any)
		crf.sv(encoding=any)
		crf.da(encoding=any);
	if deleted^='f' then put "ER" "ROR: handle DELETED var appropriately.";
run;

data pp_final_infcon(keep=subnum dsstdat_c dsicf_g_dec dsstdat_g_c pver part_dec);
	set crf.ds(encoding=any where=(pagename='Informed Consent'));

	length dsstdat_c $10;
	if dsstdat>.z then dsstdat_c=strip(put(dsstdat,yymmdd10.));

	if dsicf_g_dec not in ('No','Yes') and dsicf_g^='' then put "ER" "ROR: update INFCON_build.sas for 'Was Genetic Informed Consent Signed?'";

	length dsstdat_g_c $10;
	if dsstdat_g>.z then dsstdat_g_c=strip(put(dsstdat_g,yymmdd10.));

	proc sort;
		by subnum;
run;
