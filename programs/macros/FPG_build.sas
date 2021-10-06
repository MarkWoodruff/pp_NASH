/*****************************************************************************************/
* Program Name  : FPG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for FPG (Fasting Plasma Glucose) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='Fasting Plasma Glucose'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update FPG_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_fpg(keep=subnum visitid visname lbfpgna lbperf_reasnd lbfast8_c lborres_u);
	set crf.lb(encoding=any where=(pagename='Fasting Plasma Glucose' and deleted='f'));

	length lbperf_reasnd $700;
	lbperf_reasnd=catx(': ',lbperf_dec,lbreasnd);

	length lbfast8_c $10;
	if lbfast8>.z then lbfast8_c=strip(put(lbfast8,best.));

	length lborres_u $200;
	if lborres^='' or lborresu_dec^='' then lborres_u=catx(' ',lborres,lborresu_dec);

	proc sort;
		by subnum visitid visname;
run;
