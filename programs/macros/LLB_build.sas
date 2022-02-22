/*****************************************************************************************/
* Program Name  : LLB_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-02-22
* Description   : build temporary dataset for LLB (Local Labs) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any where=(pagename='Local Lab Results'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update LLB_build.sas to handle LB.DELETED var appropriately.";
run;

data llb;
	set crf.lb(encoding=any where=(pagename='Local Lab Results' and deleted='f'));
run;

%missing_dates(dsn=llb,date=lbdat,date2=,pgmname=LLB_build);

data pp_final_llb(keep=subnum visitid visname visitseq lbaeno_ lbrefid lbdat lbdat_c lbdat_sort lbtim lbtim_c lbfast_dec lbtest_ lborres lbu nr
	lbstnrc lbcoval);
	set llb;

	length lbaeno_ $20;
	if lbaeno>.z then lbaeno_=strip(put(lbaeno,best.));
	
	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lbtim_c $12;
	if lbtim>.z then lbtim_c=strip(put(lbtim,time5.));

	length lbtest_ $200;
	lbtest_=catx(': ',lbtest_dec,lbtestot);

	length lbu $200;
	lbu=catx(': ',lborresu_dec,lborresuot);

	length nr $200;
	nr=strip(lbornrlo)||' - '||strip(lbornrhi);

	proc sort;
		by subnum lbdat_sort lbdat lbtim;	
run;
