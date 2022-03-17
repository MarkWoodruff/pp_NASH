/*****************************************************************************************/
* Program Name  : LBPLOTC_report_Central Lab - Chemistry Plots.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-03-17
* Description   : report LBCPLOTC domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_lbcplot;
	where subnum="&ptn." and lbstresn>.z and lbcat='Chemistry';
run;

************************************************************************;
** define height of graph dynamically, using number of tests as input **;
************************************************************************;
proc freq data=domain_data noprint;
	tables lbtest/out=lbtest;
run;

%let test_height=200;
data _null_;
	set lbtest end=eof;
	by lbtest;
	test_count+1;
	test_height=test_count*200;
	if eof then call symput('test_height',strip(put((test_height+60),best.)));
run;

******************************************;
** define axes dynamically, data-driven **;
******************************************;
%global min_lbdy max_lbdy exist_lbdy exist_lbdat exist_rfstdt has_valuen_flag has_range;
%let min_lbdy=0;
%let max_lbdy=0;
%let exist_lbdy=0;
%let exist_lbdat=0;
%let exist_rfstdt=0;
%let has_valuen_flag=0;
%let has_range=0;

data _null_;
	set domain_data;
	by subnum;

	retain min_lbdy_ max_lbdy_ exist_lbdy exist_lbdat exist_rfstdt has_valuen_flag has_range;
	if first.subnum then do;
		min_lbdy_=.;
		max_lbdy_=.;
		exist_lbdy=.;
		exist_lbdat=.;
		exist_rfstdt=.;
		has_valuen_flag=.;
		has_range=.;
	end;

	if lbdy>.z then exist_lbdy=1;
	if lbdat>.z then exist_lbdat=1;
	if rfstdt>.z then exist_rfstdt=1;
	if lbdy>max_lbdy_ then max_lbdy_=lbdy;
	if .z<lbdy<min_lbdy_ or min_lbdy_=. then min_lbdy_=lbdy;
	if lbstresn_y>.z then has_valuen_flag=1;
	if lbstnrlon>.z and lbstnrhin>.z then has_range=1;

	if last.subnum then do;
		if min_lbdy_>.z then min_lbdy=5*floor(min_lbdy_/5);
		if max_lbdy_>.z then max_lbdy=5*ceil(max_lbdy_/5);
		if exist_lbdy>.z then call symput('exist_lbdy',strip(put(exist_lbdy,best.)));
		if exist_lbdat>.z then call symput('exist_lbdat',strip(put(exist_lbdat,best.)));
		if exist_rfstdt>.z then call symput('exist_rfstdt',strip(put(exist_rfstdt,best.)));
		if min_lbdy>.z then call symput('min_lbdy',strip(put(min_lbdy,best.)));
		if max_lbdy>.z then call symput('max_lbdy',strip(put(max_lbdy,best.)));
		if has_valuen_flag>.z then call symput('has_valuen_flag',strip(put(has_valuen_flag,best.)));
		if has_range>.z then call symput('has_range',strip(put(has_range,best.)));
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

	ods proclabel='Central Lab - Chemistry Plots';
	ods graphics / height=&test_height.px width=1150px imagename="lbcgraph_&ptn." imagemap=on noborder;

	%if %eval(&exist_lbdy.)>0 %then %do;
		proc sgpanel data=domain_data noautolegend nocycleattrs pad=0;
			title 'Central Lab - Chemistry Plots';
			footnote "lbplotc-footnote";
			panelby lbtest   / onepanel layout=rowlattice uniscale=column novarname spacing=5 rowheaderpos=left 
						     headerattrs=(color=white family=Lato size=8 style=normal weight=bold)
						     headerbackcolor=CX7A7A7A;

			%if &has_range.=1 %then %do;
				band x=lbdy upper=lbstnrhin lower=lbstnrlon / fillattrs=(color=cxadd8e6 transparency=0.25);
			%end;

			inset lbstresu / position=topleft textattrs=(color=black family=Lato size=9 style=normal weight=bold) nolabel;
			styleattrs backcolor=cx293f50 wallcolor=cxd2d2d2;
			series  x=lbdy y=lbstresn / lineattrs=(color=black pattern=solid thickness=1) nomissinggroup name='bp' markerattrs=(symbol=circlefilled size=11);
			scatter x=lbdy y=lbstresn / markerattrs=(symbol=circlefilled size=22 color=blue) tip=(visname lbdat lbstresc lbstresu lbstnrlon lbstnrhin);
			scatter x=lbdy y=lbstresn / markerattrs=(symbol=circlefilled size=19 color=white) tip=(visname lbdat lbstresc lbstresu lbstnrlon lbstnrhin);
			%if &has_valuen_flag.=1 %then %do;
				scatter x=lbdy y=lbstresn_y / markerattrs=(symbol=circlefilled size=19 color=yellow) tip=(visname lbdat lbstresc lbstresu lbstnrlon lbstnrhin);
			%end;

			rowaxis grid display=(nolabel) offsetmax=0.1 refticks=(values)
							 valueattrs=(color=white family=Lato size=7 style=normal weight=normal)
							 labelattrs=(color=white family=Lato size=10 style=normal weight=bold);
			colaxis grid label='Study Day' offsetmax=0.02 refticks=(label values) values=(&min_lbdy. to &max_lbdy. by 5)
							 labelattrs=(color=white family=Lato size=10 style=normal weight=bold)
							 valueattrs=(color=white family=Lato size=7 style=normal weight=normal);
		run;
	%end;
	%else %do;
		%if &exist_lbdat.=0 %then %do; title "Central Lab - Chemistry Plots add-no-data"; %end;
			%else %if &exist_lbdat.=1 and &exist_rfstdt.=0 %then %do; title "Central Lab - Chemistry Plots add-no-dosing-data"; %end;
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
