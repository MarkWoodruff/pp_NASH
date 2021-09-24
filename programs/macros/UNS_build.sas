/*****************************************************************************************/
* Program Name  : UNS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for UNS (Unscheduled Visit) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.sv(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Visit Date') then put "ER" "ROR: update UNS_build.sas to read in only Unscheduled records from crf.SV.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update UNS_build.sas to handle SV.DELETED var appropriately.";
run;

data pp_final_uns(keep=subnum visitid svstdt svstdt_c svupdes svupbm svupvs svupeg svuppe svupupt svupfpg svuplb svupvcte svupus svupmri 
					  svuppc svupada svuplb2 svupkit svuplb3);
	set crf.sv(encoding=any where=(pagename='Visit Date' and deleted='f' and visname='Unscheduled'));

	length svstdt_c $20;
	if svstdt>.z then svstdt_c=strip(put(svstdt,yymmdd10.));

	proc sort;
		by subnum visitid svstdt;
run;

