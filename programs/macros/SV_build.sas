/*****************************************************************************************/
* Program Name  : SV_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for SV (Subject Visit) domain
*
* Revision History
* Date       By            Description of Change
* 2021-12-09 Mark Woodruff update comment.
******************************************************************************************;

data _null_;
	set crf.sv(encoding=any);

	** ensure only informed consent records are present in crf.sv **;
	if ^(pagename='Visit Date') then put "ER" "ROR: update SV_build.sas to read in only Visit Date records from crf.SV.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update SV_build.sas to handle SV.DELETED var appropriately.";
run;

data pp_final_sv(keep=subnum visitid visname svnd_c svreasnd svstdt_c);
	set crf.sv(encoding=any where=(pagename='Visit Date' and deleted='f' and visname^='Unscheduled'));

	length svnd_c $3;
	if svnd^='' then svnd_c='Yes';

	length svstdt_c $20;
	if svstdt>.z then svstdt_c=strip(put(svstdt,yymmdd10.));

	proc sort;
		by subnum visitid;
run;
