/*****************************************************************************************/
* Program Name  : PREG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : build temporary dataset for PREG (Urine Pregnancy, or In-Clinic Lab) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-01 Mark Woodruff refine filters now that have data.  keep visitid visname.
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='Urine Pregnancy'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PREG_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_preg(keep=subnum visitid visname lbnd lbuptr_dec lbcoval);
	set crf.lb(encoding=any where=(pagename='Urine Pregnancy' and deleted='f'));

	proc sort;
		by subnum visitid visname;
run;
