/*****************************************************************************************/
* Program Name  : LBC_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-22
* Description   : build temporary dataset for LBC (Central Labs) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-25 Mark Woodruff add LABFLAG.
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-01 Mark Woodruff use lbornrhin rather than lbornrhi in computations.
* 2021-11-05 Mark Woodruff added Cortisol flagging
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2021-11-22 Mark Woodruff evolve Cortisol flagging.  Add visits to note to log.
* 2021-12-09 Mark Woodruff create visname_ to use in check_dates, more standardized.
******************************************************************************************;

data _null_;
	set crf.lbx(encoding=any);

	if pagename^='Lab Results' then	put "ER" "ROR: update LBC_build.sas to filter on proper PAGENAME, and add new domain as necessary.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update LBC_build.sas to handle LBX.DELETED var appropriately.";
run;	

data pp_final_lbc(keep=subnum visitid visname lbrefid yob_sex visit lbdat lbdat_c lbfast_dec lbcat lbtestcd lbtest lborres_lborresu nr lbstresc_lbstresu nrst
					   lbnrind lbstat_lbreasnd lbspec lbcoval labflag_lbnrind labflag_tanja lborresn lbornrhin lborresu);
	set crf.lbx(encoding=any where=(pagename='Lab Results' and deleted='f') rename=(lbstresn=lbstresn_theirs));

	if lbdat=. then put "ER" "ROR: update LBC_build.sas to handle Unscheduled visits and/or missing dates correctly.";

	** flag Cortisol **;
	if lbtestcd in ('AMCORT','CORTISOL','MIDCORT','PMCORT') then cortisol=1;

	** for check_dates macro **;
	visname=strip(visit);
	
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

	** red highlighting based on outside normal range, or CRF H/L flag exists **;
	if lbnrind^='' or .z<lborresn<lbornrlon or .z<lbornrhin<lborresn or .z<lbstrescn<lbstnrlon or .z<lbstnrhin<lbstrescn then labflag_lbnrind=1;

	** red highlighting based on Tanja requests **;
	if lbornrhin>.z then lbornrhi_2=lbornrhin*2;
	if lbornrhin>.z then lbornrhi_5=lbornrhin*5;

	if lbtestcd='GLUC' then do;
		if lborresu^='mg/dL' then put "ER" "ROR: update LBC_build.sas for Glucose units flagging for Tanja";
		if lborresu='mg/dL' then do;
			if .z<lborresn<56 then labflag_tanja=2;
				else if 56<=lborresn<=70 then labflag_tanja=1;
		end;
	end;
		else if lbtest in ('Amylase','Lipase') then do;
			if .z<lbornrhi_2<lborresn<=lbornrhi_5 then labflag_tanja=1;
				else if .z<lbornrhi_5<lborresn then labflag_tanja=2;
		end;
		else if lbtestcd='BILI' and lbtest in ('Bilirubin') then do;
			if .z<lbornrhi_2<=lborresn then labflag_tanja=1;
		end;
		else if lbtest='Platelets' then do;
			if lborresu^='K/uL' then put "ER" "ROR: update LBC_build.sas for Platelets units flagging for Tanja";
			if lborresu='K/uL' then do;
				if .z<lborresn<150 then labflag_tanja=1;
			end;
		end;
		else if lbtest='Prothrombin Intl. Normalized Ratio' then do;
			if lborresn>1.5 then labflag_tanja=1;
		end;
		else if cortisol=1 then do;
			if lbstrescn>.z and lbstnrlon>.z and lbstnrhin>.z and ^(.z<lbstnrlon<lbstrescn<lbstnrhin) then labflag_tanja=1;
		end;

	proc sort;
		by subnum lbdat lbcat lbtest;
run;

** get first dose date **;
data ex;
	set crf.ex(encoding=any where=(pagename='Study Drug Administration' and exyn_dec='Yes' and deleted='f'));

	format rfstdt yymmdd10.;
	rfstdt=exstdat;

	proc sort;
		by subnum rfstdt;
run;

data ex(keep=subnum rfstdt);
	set ex;
	by subnum rfstdt;
	if first.subnum;
run;

data pp_final_lbc;
	merge ex
		  pp_final_lbc(in=inl);
	by subnum;
	if inl;

	if .z<rfstdt<lbdat then postbase=1;
		else postbase=0;

	proc sort;
		by subnum lbcat lbtest lbdat;
run;

data base(keep=subnum lbcat lbtest base);
	set pp_final_lbc;
	by subnum lbcat lbtest lbdat;

	retain base;
	if first.lbtest then base=.;
	if postbase=0 then base=lborresn;

	if last.lbtest;
run;

data pp_final_lbc;
	merge base
		  pp_final_lbc;
	by subnum lbcat lbtest;

	proc sort;
		by subnum lbdat lbcat lbtest;
run;

data pp_final_lbc;
	set pp_final_lbc;

	** ALT, AST **;
	if lbtest in ('Alanine Aminotransferase') then do;
		if .z<base<(1.5*lbornrhin) and postbase=1 then do;
			flagelig=1;
			if .z<(lbornrhin*8)<=lborresn then labflag_tanja=3;
				else if .z<(lbornrhin*5)<=lborresn then labflag_tanja=2;
				else if .z<(lbornrhin*3)<=lborresn then labflag_tanja=1;
		end;
		if lborresu^='IU/L' then put "ER" "ROR: update LBC_build.sas for ALT units in flagging.";
		if .z<(1.5*lbornrhin)<=base and lborresu='IU/L' and postbase=1 then do;
			flagelig=2;
			if 500<=lborresn then labflag_tanja=2;
				else if 300<=lborresn then labflag_tanja=1;				
		end;
	end;
	if lbtest='Aspartate Aminotransferase' then do;
		if postbase=1 then do;
			flagelig=1;
			if .z<(lbornrhin*20)<lborresn then labflag_tanja=3;
				else if .z<(lbornrhin*5)<lborresn<=(lbornrhin*20) then labflag_tanja=2;
				else if .z<(lbornrhin*2.5)<lborresn<=(lbornrhin*5) then labflag_tanja=1;
		end;
	end;
run;

proc sort data=pp_final_lbc;
	by subnum lbdat lbcat lbtest;
run;

** standardize visits for merging with check_dates **;
data rand(keep=subnum cohort_dec);
	set crf.ds(encoding=utf8 where=(pagename='Randomization'));

	cohort_dec=tranwrd(cohort_dec,' –',' -');

	proc sort;
		by subnum;
run;

data pp_final_lbc;
	merge rand
		  pp_final_lbc(in=inl);
	by subnum;
	if inl;

	visname_=strip(visname);
	if visname_='Day 15' and cohort_dec in ('Part A - A1','Part A - A4','Part A - A5') then visname_='Day 15 monthly';
		else if visname_='Day 15' and cohort_dec in ('Part A - A2','Part A - A3') then visname_='Day 15 bi-weekly';
	if visname_='Day 43' and cohort_dec in ('Part A - A1','Part A - A4','Part A - A5') then visname_='Day 43 monthly';
		else if visname_='Day 43' and cohort_dec in ('Part A - A2','Part A - A3') then visname_='Day 43 bi-weekly';
run;
