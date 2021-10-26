/*****************************************************************************************/
* Program Name  : LB_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-26
* Description   : build temporary dataset for LB (Safety Labs) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.lb(encoding=any);

	if pagename^='Lab Results' then	put "ER" "ROR: update LBC_build.sas to filter on proper PAGENAME, and add new domain as necessary.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update LBC_build.sas to handle LBX.DELETED var appropriately.";
run;

data pp_final_lbc(keep=subnum visname lbrefid yob_sex visit lbdat lbdat_c lbfast_dec lbcat lbtestcd lbtest lborres_lborresu nr lbstresc_lbstresu nrst
					   lbnrind lbstat_lbreasnd lbspec lbcoval labflag);
	set crf.lbx(encoding=any where=(pagename='Lab Results' and deleted='f') rename=(lbstresn=lbstresn_theirs));

	if lbdat=. then put "ER" "ROR: update LBC_build.sas to handle Unscheduled visits and/or missing dates correctly.";

	length yob_sex $100;
	yob_sex=catx(' - ',yob,sex);

	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lborres_lborresu $200;
	lborres_lborresu=catx(' ',lborres,lborresu);

	length nr $200;
	nr=catx(' - ',lbornrlo,lbornrhi);

	length lbstresc_lbstresu $200;
	lbstresc_lbstresu=catx(' ',lbstresc,lbstresu);

	%macro c_to_n(var=);
		if index(&var.,'<')>0 then &var.n=input(strip(substr(&var.,index(&var.,'<')+1)),best.);
			else if index(&var.,'>')>0 then &var.n=input(strip(substr(&var.,index(&var.,'>')+1)),best.);
			else if anyalpha(&var.)=0 and index(&var.,':')=0 then &var.n=input(strip(&var.),best.);
	%mend c_to_n;
	%c_to_n(var=lborres);
	%c_to_n(var=lbornrlo);
	%c_to_n(var=lbornrhi);
	%c_to_n(var=lbstresc);
	%c_to_n(var=lbstnrlo);
	%c_to_n(var=lbstnrhi);

	length nrst $200;
	nrst=coalescec(catx(' - ',lbstnrlo,lbstnrhi),lbstnrc);

	length lbstat_lbreasnd $1300;
	lbstat_lbreasnd=catx(':FRCBRK',lbstat,lbreasnd);

	if lbnrind^='' or .z<lborresn<lbornrlon or .z<lbornrhin<lborresn or .z<lbstrescn<lbstnrlon or .z<lbstnrhin<lbstrescn then labflag=1;

	proc sort;
		by subnum lbdat lbcat lbtest;
run;
