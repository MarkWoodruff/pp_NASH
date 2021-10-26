/*****************************************************************************************/
* Program Name  : ADA_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-15
* Description   : build temporary dataset for ADA domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='ADA Collection'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ADA_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_ada(keep=subnum visitid visname lbperf_reas lbdat_c lbtim_c lbcoval);
	set crf.lb(encoding=any where=(pagename='ADA Collection' and deleted='f'));

	length lbperf_reas $700;
	lbperf_reas=catx(': ',lbperf_dec,lbreasnd);

	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lbtim_c $12;
	if lbtim>.z then lbtim_c=strip(put(lbtim,time5.));

	proc sort;
		by subnum visitid;
run;

%check_dates(dsn=pp_final_ada,date=lbdat_c);
