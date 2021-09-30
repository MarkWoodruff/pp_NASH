/*****************************************************************************************/
* Program Name  : ECG_report_ECG.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : report ECG domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ecg;
	where subnum="&ptn.";
	space=' ';
run;

%nobs(domain_data);

%macro report_domain;
	%if &nobs.=0 %then %do;
		data domain_data;
			merge domain_data empty;
		run;
	%end;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		%if &nobs.=0 %then %do;
			column subnum;
			define subnum /order order=internal noprint;
			footnote "No data for this patient/domain as of &data_dt..";
		%end;
		%else %do;
			column egdat visname egnd_reas egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf_c egorres_c;
			define egdat     /order order=internal noprint;
			define visname   /display "Visit";
			define egnd_reas /display "Not Done:|Reason";
			define egdat_c   /display "Date|Performed" style=[htmlclass='min-width-1-0'];
			define egtims_c  /display "Start Time|Supine Position";
			define egtim_c   /display "Time|Performed";
			define eghr_c    /display "Heart|Rate";
			define egqt_c    /display "QT|Interval";
			define egpr_c    /display "PR|Interval";
			define egqrs_c   /display "QRS|Interval";
			define egrr_c    /display "RR|Interval";
			define egqtcf_c  /display "QTcF";
			define egorres_c /display "Results, Specify" style=[htmlclass='max-width-3-75'];


			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "ECG";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
