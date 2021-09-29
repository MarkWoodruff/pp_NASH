/*****************************************************************************************/
* Program Name  : PREG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : build temporary dataset for PREG (Urine Pregnancy, or In-Clinic Lab) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Central Labs') then put "ER" "ROR: update PREG_build.sas to read in only Urine Pregnancy records from crf.LB.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PREG_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_preg(keep=subnum lbnd lbuptr lbuptr_dec lbcoval);
	set crf.lb(encoding=any where=((lbuptr^='' or lbuptr_dec^='') and deleted='f'));

	proc sort;
		by subnum;
run;
