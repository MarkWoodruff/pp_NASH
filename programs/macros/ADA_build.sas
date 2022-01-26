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
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff make sure missing dates are sorted appropriately.
* 2022-01-18 Mark Woodruff edit note to log.
* 2022-01-24 Mark Woodruff add missing_dates macro call, remove note to log.
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='ADA Collection'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ADA_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_ada(keep=subnum visitid visname lbperf_reas lbdat lbdat_c lbtim_c lbcoval);
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

%missing_dates(dsn=pp_final_ada,date=lbdat,date2=,pgmname=ADA_build);
