/*****************************************************************************************/
* Program Name  : ELIG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for ELIG (Eligibility) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.ie(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(visname='Registration' and pagename='Eligibility') then put "ER" "ROR: update ELIG_build.sas to read in only Eligibility records from crf.IE.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ELIG_build.sas to handle IE.DELETED var appropriately.";
run;

data _null_;
	set crf.mo(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(visname='Registration' and pagename='Eligibility') then put "ER" "ROR: update ELIG_build.sas to read in only Eligibility records from crf.MO.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ELIG_build.sas to handle MO.DELETED var appropriately.";
run;

data elig(keep=subnum iestdat_c ieorres_dec ieenroll_dec ietestcd_dec iereplc_dec iereplcn);
	set crf.ie(encoding=any where=(pagename='Eligibility' and deleted='f'));

	length iestdat_c $10;
	if iestdat>.z then iestdat_c=strip(put(iestdat,yymmdd10.));

	proc sort;
		by subnum;
run;

data mo(keep=subnum sf_mri mostdat_c);
	set crf.mo(encoding=any where=(pagename='Eligibility' and deleted='f'));

	length sf_mri $3;
	if mosf^='' then sf_mri='Yes';

	length mostdat_c $10;
	if mostdat>.z then mostdat_c=strip(put(mostdat,yymmdd10.));

	proc sort;
		by subnum;
run;

data pp_final_elig(keep=subnum iestdat_c ieorres_dec ieenroll_dec ietestcd_dec sf_mri mostdat_c iereplc_dec iereplcn);
	merge elig
		  mo;
	by subnum;
run;
