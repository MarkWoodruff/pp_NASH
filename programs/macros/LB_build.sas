/*****************************************************************************************/
* Program Name  : LB_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-26
* Description   : build temporary dataset for LB (Safety Labs) domain
*
* Revision History
* Date       By            Description of Change
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2021-12-19 Mark Woodruff only trigger note to log if actual lab tests were done.
* 2021-12-30 Mark Woodruff only trigger note to log if actual lab tests were done, using *_dec vars.
* 2022-01-05 Mark Woodruff handle sorting of missing dates using both regular date and cortisol date.
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='Central Labs'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update LB_build.sas to handle LB.DELETED var appropriately.";
run;

data lb;
	set crf.lb(encoding=any where=(pagename='Central Labs' and deleted='f'));
run;

%missing_dates(dsn=lb,date=lbdat,date2=lbdat_cort,pgmname=LB_build);

data pp_final_lb(keep=subnum visitid visname lbhem_dec lbchem_dec lbser_dec lbcoag_dec lbtsh_dec lbfsh_dec lbhcg_dec lbcovid_dec lbdat_sort lbdat lbdat_c lbtim lbtim_c
					  lbcortsl_dec lbdatcort_c lbtimcort_c lbfast_dec lbcoval);
	set lb;

	if lbdat=. and (lbhem_dec not in ('No','') or lbchem_dec not in ('No','')) then put "ER" "ROR: update LB_build.sas to handle Unscheduled visits and/or missing dates correctly." SUBNUM= lbdat= lbhem= lbchem=;

	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lbtim_c $12;
	if lbtim>.z then lbtim_c=strip(put(lbtim,time5.));

	length lbdatcort_c $12;
	if lbdat_cort>.z then lbdatcort_c=strip(put(lbdat_cort,yymmdd10.));

	length lbtimcort_c $12;
	if lbtim_cort>.z then lbtimcort_c=strip(put(lbtim_cort,time5.));

	proc sort;
		by subnum lbdat lbtim;
run;

proc sort data=pp_final_lb;
	by subnum lbdat_sort lbdat lbtim;
run;
