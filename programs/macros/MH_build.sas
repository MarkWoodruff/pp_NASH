/*****************************************************************************************/
* Program Name  : MH_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for MH (Medical History) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-01 Mark Woodruff remove visit from check on pagename var.
******************************************************************************************;

data _null_;
	set crf.mh(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Medical History') then put "ER" "ROR: update MH_build.sas to read in only Medical History records from crf.MH.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update DM_build.sas to handle MH.DELETED var appropriately.";

	** check that coding is working properly once it is populated **;
	if pt_term^='' or soc_term^='' then put "ER" "ROR: check MH_build.sas to make sure coding is being handled appropriately.";
run;

data pp_final_mh(keep=subnum mhnd_c mhterm dates ongoing mhsev_dec coding);
	set crf.mh(encoding=any where=(pagename='Medical History' and deleted='f'));

	length mhnd_c $3;
	if mhnd^='' then mhnd_c='Yes';

	length dates $200;
	if mhstdat^='' or mhendat^='' then dates=strip(mhstdat)||'/frcbrk'||strip(mhendat);

	length ongoing $3;
	if mhongo^='' then ongoing='Yes';

	length coding $20;
	if pt_term^='' or soc_term^='' then coding=strip(soc_term)||'/frcbrk'||strip(pt_term);

	proc sort;
		by subnum;
run;
