/*****************************************************************************************/
* Program Name  : VSPLOT_report_Vital Signs Plot.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-10
* Description   : report Vital Signs Plot domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_vsplot;
	where subnum="&ptn.";
run;

** make axes adjust automatically **;
%global min_vsdy max_vsdy exist_vsdy exist_vsdat exist_day1 incremnt;
%let min_vsdy=0;
%let max_vsdy=0;
%let exist_vsdy=0;
%let exist_vsdat=0;
%let exist_day1=0;
%let incremnt=10;

data _null_;
	set domain_data;
	by subnum;

	retain min_vsdy_ max_vsdy_ exist_vsdy exist_vsdat exist_day1;
	if first.subnum then do;
		min_vsdy_=.;
		max_vsdy_=.;
		exist_vsdy=.;
		exist_vsdat=.;
		exist_day1=.;
	end;

	if vsdy>.z then exist_vsdy=1;
	if vsdat>.z then exist_vsdat=1;
	if rfstdt>.z then exist_day1=1;
	if vsdy>max_vsdy_ then max_vsdy_=vsdy;
	if .z<vsdy<min_vsdy_ or min_vsdy_=. then min_vsdy_=vsdy;

	if 0<=max_vsdy_<=200 then incremnt=10;
		else if 200<max_vsdy_<=300 then incremnt=20;
		else if 300<max_vsdy_<=400 then incremnt=25;
		else if 400<max_vsdy_<=500 then incremnt=30;
		else if 500<max_vsdy_ then incremnt=35;

	if last.subnum then do;
		if min_vsdy_>.z then min_vsdy=floor(((floor(min_vsdy_)-1)/5))*5;
		if max_vsdy_>.z then max_vsdy=ceil(((ceil(max_vsdy_)+1)/incremnt))*incremnt;
		if exist_vsdy>.z then call symput('exist_vsdy',strip(put(exist_vsdy,best.)));
		if exist_vsdat>.z then call symput('exist_vsdat',strip(put(exist_vsdat,best.)));
		if exist_day1>.z then call symput('exist_day1',strip(put(exist_day1,best.)));
		if min_vsdy>.z then call symput('min_vsdy',strip(put(min_vsdy,best.)));
		if max_vsdy>.z then call symput('max_vsdy',strip(put(max_vsdy,best.)));
		if incremnt>.z then call symput('incremnt',strip(put(incremnt,best.)));
	end;
run;

%nobs(domain_data);

%macro report_domain;
	%if &nobs.=0 %then %do;
		data domain_data;
			merge domain_data empty;
		run;
	%end;

	options orientation=landscape nodate nonumber nobyline leftmargin=2.0in;

	ods proclabel='Vital Signs Plots';
	ods graphics / height=900px width=1150px imagename="vsgraph_&ptn." imagemap=on noborder;

	%if %eval(&exist_vsdy.)>0 %then %do;
		data dum;
			set domain_data(keep=valuen_abn_y valuen_abn_o valuen_abn_r);
			if _n_=1;
			valuen_abn_y=1;
			valuen_abn_o=1;
			valuen_abn_r=1;
		run;

		data domain_data;
			set dum
				domain_data;
		run;

		proc sgpanel data=domain_data noautolegend nocycleattrs pad=0;
			title "Vital Signs Plots";
			footnote "vsplot-footnote";
			panelby paneln / onepanel layout=rowlattice uniscale=column novarname spacing=5 rowheaderpos=left 
							 headerattrs=(color=white family=Lato size=10 style=normal weight=bold)
							 headerbackcolor=cx7A7A7A;
			*band x=vsdy upper=rnghigh lower=rnglow / fillattrs=(color=cxadd8e6 transparency=0.5);
			*refline 0 / axis=x lineattrs=(thickness=1 color=black);

			styleattrs backcolor=cx293f50 wallcolor=cxd2d2d2;
			band    x=vsdy lower=valuen_low upper=valuen_high / fill fillattrs=(transparency=1);
			band    x=vsdy lower=nr_low upper=nr_high / fill fillattrs=(color=cxadd8e6 transparency=0.55);
			series  x=vsdy y=valuen       / lineattrs=(color=black pattern=solid thickness=2) nomissinggroup name='bp' markerattrs=(symbol=circlefilled size=11);
			scatter x=vsdy y=valuen       / markerattrs=(symbol=circlefilled size=22 color=black)    tip=(rfstdt visname vsnd vsreasnd1 vsdat_c vsdy vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1_sys bp1_dia bp2_sys bp2_dia bp3_sys bp3_dia bp_avg_sys bp_avg_dia);
			scatter x=vsdy y=valuen       / markerattrs=(symbol=circlefilled size=19 color=white)    tip=(rfstdt visname vsnd vsreasnd1 vsdat_c vsdy vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1_sys bp1_dia bp2_sys bp2_dia bp3_sys bp3_dia bp_avg_sys bp_avg_dia);
			scatter x=vsdy y=valuen_abn_y / markerattrs=(symbol=circlefilled size=19 color=cxFFFF00) tip=(rfstdt visname vsnd vsreasnd1 vsdat_c vsdy vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1_sys bp1_dia bp2_sys bp2_dia bp3_sys bp3_dia bp_avg_sys bp_avg_dia);
			scatter x=vsdy y=valuen_abn_o / markerattrs=(symbol=circlefilled size=19 color=cxFFA500) tip=(rfstdt visname vsnd vsreasnd1 vsdat_c vsdy vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1_sys bp1_dia bp2_sys bp2_dia bp3_sys bp3_dia bp_avg_sys bp_avg_dia);
			scatter x=vsdy y=valuen_abn_r / markerattrs=(symbol=circlefilled size=19 color=red)      tip=(rfstdt visname vsnd vsreasnd1 vsdat_c vsdy vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1_sys bp1_dia bp2_sys bp2_dia bp3_sys bp3_dia bp_avg_sys bp_avg_dia);
			
			rowaxis grid display=(nolabel) offsetmax=0.1 refticks=(values)
							 valueattrs=(color=white family=Lato size=9 style=normal weight=normal);
			colaxis grid label='Study Day' offsetmax=0.02 refticks=(label values) values=(&min_vsdy. to &max_vsdy. by 5)
							 labelattrs=(color=white family=Lato size=12 style=normal weight=bold)
							 valueattrs=(color=white family=Lato size=10 style=normal weight=normal);
			*&min_vsdy. to -5 by 5 1 5 to &max_vsdy. by 5;
		run;
	%end;
	%else %do;
		%if &exist_vsdat.=0 %then %do; title "Vital Signs Plot add-no-data"; %end;
			%else %if &exist_vsdat.=1 and &exist_day1.=0 %then %do; title "Vital Signs Plot add-no-dosing-data"; %end;
		data _null_;
			a=1;
			file print ods=(template='IncrementIDX');
			put _ods_;
		run;
	%end;

	title;
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;

ods graphics / reset=all;
