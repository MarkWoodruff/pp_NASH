/*****************************************************************************************/
* Program Name  : DM_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for DM (Demographics) domain
*
* Revision History
* Date       By            Description of Change
* 2021-12-09 Mark Woodruff update comment.
******************************************************************************************;

data _null_;
	set crf.dm(encoding=any);

	** ensure only informed consent records are present in crf.dm **;
	if ^(visname='Screening' and pagename='Demographics') then put "ER" "ROR: update DM_build.sas to read in only Demographics records from crf.DM.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update DM_build.sas to handle DM.DELETED var appropriately.";
run;

data pp_final_dm(keep=subnum age_c sex_dec dmfertl_dec ethnic_dec race_dec raceoth);
	set crf.dm(encoding=any where=(pagename='Demographics' and deleted='f'));

	length age_c $3;
	if age>.z then age_c=strip(put(age,best.));

	proc sort;
		by subnum;
run;
