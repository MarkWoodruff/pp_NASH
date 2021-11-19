/*****************************************************************************************/
* Program Name  : ECGPLOT_report_ECG Plot.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-11
* Description   : report ECG Plot domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ecgplot;
	where subnum="&ptn.";
run;

** make axes adjust automatically **;
%global min_ecgdy max_ecgdy exist_ecgdy exist_egdat exist_day1 incremnt;
%let min_ecgdy=0;
%let max_ecgdy=0;
%let exist_ecgdy=0;
%let exist_egdat=0;
%let exist_day1=0;
%let incremnt=10;

data _null_;
	set domain_data;
	by subnum;

	retain min_ecgdy_ max_ecgdy_ exist_ecgdy exist_egdat exist_day1;
	if first.subnum then do;
		min_ecgdy_=.;
		max_ecgdy_=.;
		exist_ecgdy=.;
		exist_egdat=.;
		exist_day1=.;
	end;

	if ecgdy>.z then exist_ecgdy=1;
	if egdat>.z then exist_egdat=1;
	if rfstdt>.z then exist_day1=1;
	if ecgdy>max_ecgdy_ then max_ecgdy_=ecgdy;
	if .z<ecgdy<min_ecgdy_ or min_ecgdy_=. then min_ecgdy_=ecgdy;

	if 0<=max_ecgdy_<=200 then incremnt=10;
		else if 200<max_ecgdy_<=300 then incremnt=20;
		else if 300<max_ecgdy_<=400 then incremnt=25;
		else if 400<max_ecgdy_<=500 then incremnt=30;
		else if 500<max_ecgdy_ then incremnt=35;

	if last.subnum then do;
		if min_ecgdy_>.z then min_ecgdy=floor(((floor(min_ecgdy_)-1)/5))*5;
		if max_ecgdy_>.z then max_ecgdy=ceil(((ceil(max_ecgdy_)+1)/incremnt))*incremnt;
		if exist_ecgdy>.z then call symput('exist_ecgdy',strip(put(exist_ecgdy,best.)));
		if exist_egdat>.z then call symput('exist_egdat',strip(put(exist_egdat,best.)));
		if exist_day1>.z then call symput('exist_day1',strip(put(exist_day1,best.)));
		if min_ecgdy>.z then call symput('min_ecgdy',strip(put(min_ecgdy,best.)));
		if max_ecgdy>.z then call symput('max_ecgdy',strip(put(max_ecgdy,best.)));
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

	ods proclabel='ECG Plots';
	ods graphics / height=900px width=1150px imagename="ecggraph_&ptn." imagemap=on noborder;

	%if %eval(&exist_ecgdy.)>0 %then %do;
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
			title "ECG Plots";
			footnote "ecgplot-footnote";
			panelby paneln / onepanel layout=rowlattice uniscale=column novarname spacing=5 rowheaderpos=left 
							 headerattrs=(color=white family=Lato size=10 style=normal weight=bold)
							 headerbackcolor=cx7A7A7A;
			*band x=ecgdy upper=rnghigh lower=rnglow / fillattrs=(color=cxadd8e6 transparency=0.5);
			*refline 0 / axis=x lineattrs=(thickness=1 color=black);

			styleattrs backcolor=cx293f50 wallcolor=cxd2d2d2;
			band    x=ecgdy lower=valuen_low upper=valuen_high / fill fillattrs=(transparency=1);
			*band    x=ecgdy lower=nr_low upper=nr_high / fill fillattrs=(color=cxadd8e6 transparency=0.55);
			series  x=ecgdy y=valuen       / lineattrs=(color=black pattern=solid thickness=2) nomissinggroup name='bp' markerattrs=(symbol=circlefilled size=11);
			scatter x=ecgdy y=valuen       / markerattrs=(symbol=circlefilled size=22 color=black)    tip=(visname egnd egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c);
			scatter x=ecgdy y=valuen       / markerattrs=(symbol=circlefilled size=19 color=white)    tip=(visname egnd egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c);
			scatter x=ecgdy y=valuen_abn_y / markerattrs=(symbol=circlefilled size=19 color=cxFFFF00) tip=(visname egnd egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c);
			scatter x=ecgdy y=valuen_abn_o / markerattrs=(symbol=circlefilled size=19 color=cxFFA500) tip=(visname egnd egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c);
			scatter x=ecgdy y=valuen_abn_r / markerattrs=(symbol=circlefilled size=19 color=red)      tip=(visname egnd egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c);
			
			rowaxis grid display=(nolabel) offsetmax=0.1 refticks=(values)
							 valueattrs=(color=white family=Lato size=9 style=normal weight=normal);
			colaxis grid label='Study Day' offsetmax=0.02 refticks=(label values) values=(&min_ecgdy. to &max_ecgdy. by 5)
							 labelattrs=(color=white family=Lato size=12 style=normal weight=bold)
							 valueattrs=(color=white family=Lato size=10 style=normal weight=normal);
			*&min_ecgdy. to -5 by 5 1 5 to &max_ecgdy. by 5;
		run;
	%end;
	%else %do;
		%if &exist_egdat.=0 %then %do; title "ECG Plot add-no-data"; %end;
			%else %if &exist_egdat.=1 and &exist_day1.=0 %then %do; title "ECG Plot add-no-dosing-data"; %end;
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
