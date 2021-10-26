/*****************************************************************************************/
* Program Name  : BIO_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-15
* Description   : build temporary dataset for BIO domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any);

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update BIO_build.sas to handle LB.DELETED var appropriately.";
run;

data pp_final_bio(keep=subnum visitid visname lbfast_dec lbperf1_ lbperf2_ lbperf3_ lbperf4_ lbdat_c lbtim_c lbcoval);
	set crf.lb(encoding=any where=(pagename='Exploratory Biomarkers' and deleted='f'));

	%macro lbperf(seq=);
		length lbperf&seq._ $700;
		lbperf&seq._=catx(': ',lbperf&seq._dec,lbreasnd&seq.);
	%mend lbperf;
	%lbperf(seq=1);
	%lbperf(seq=2);
	%lbperf(seq=3);
	%lbperf(seq=4);

	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lbtim_c $12;
	if lbtim>.z then lbtim_c=strip(put(lbtim,time5.));

	proc sort;
		by subnum visitid;
run;

%check_dates(dsn=pp_final_bio,date=lbdat_c);
