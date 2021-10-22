/*****************************************************************************************/
* Program Name  : ELIG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for ELIG (Eligibility) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-01 Mark Woodruff remove visit from check on pagename var.  add visitid and visname.
* 2021-10-06 Mark Woodruff sort by eligibility assessment date.
******************************************************************************************;

data _null_;
	set crf.ie(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Eligibility') then put "ER" "ROR: update ELIG_build.sas to read in only Eligibility records from crf.IE.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ELIG_build.sas to handle IE.DELETED var appropriately.";
run;

data _null_;
	set crf.mo(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename in ('Eligibility','MRI-PDFF')) then put "ER" "ROR: update ELIG_build.sas to read in only Eligibility records from crf.MO.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ELIG_build.sas to handle MO.DELETED var appropriately.";
run;

data elig(keep=subnum visitid visname iestdat iestdat_c ieorres_dec ieenroll_dec ietestcd_dec iereplc_dec iereplcn);
	set crf.ie(encoding=any where=(pagename='Eligibility' and deleted='f'));

	if ^(100<=sitenum<=129) then put "ER" "ROR: update Run_Profiles.sas for RPLCSBJ patient numbers";

	length iestdat_c $10;
	if iestdat>.z then iestdat_c=strip(put(iestdat,yymmdd10.));

	if index(upcase(visname),'UNSCH')>0 then put "ER" "ROR: update ELIG_build.sas for Unscheduled visit sorting and merging.";

	proc sort;
		by subnum visitid visname;
run;

data mo(keep=subnum visitid visname sf_mri mostdat_c);
	set crf.mo(encoding=any where=(pagename='Eligibility' and deleted='f'));

	length sf_mri $3;
	if mosf^='' then sf_mri='Yes';

	length mostdat_c $10;
	if mostdat>.z then mostdat_c=strip(put(mostdat,yymmdd10.));

	if index(upcase(visname),'UNSCH')>0 then put "ER" "ROR: update ELIG_build.sas for Unscheduled visit sorting and merging.";

	proc sort;
		by subnum visitid visname;
run;

data pp_final_elig(keep=subnum visitid visname visname iestdat iestdat_c ieorres_dec ieenroll_dec ietestcd_dec sf_mri mostdat_c iereplc_dec iereplcn);
	merge elig
		  mo;
	by subnum visitid visname;

	proc sort;
		by subnum iestdat;
run;
