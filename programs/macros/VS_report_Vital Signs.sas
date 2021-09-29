/*****************************************************************************************/
* Program Name  : VS_report_Vital Signs.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : report Vital Signs domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_vs;
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
			column vsdat visname vsnd_reas vsdat_c vspos vstimp_c vstim1_c hr rr ("Temperature" temp vstempl_dec) space
			bp1 ("Blood Pressure|#2 (mmHg)" vstim2_c bp2) space 
				("Blood Pressure|#3 (mmHg)" vstim3_c bp3) space bp_avg;
			define vsdat     /order order=internal noprint;
			define visname   /display "Visit";
			define vsnd_reas /display "Not Done:|Reason";
			define vsdat_c   /display "Date|Assessed" style=[htmlclass='min-width-1-0'];
			define vspos     /display "Position";
			define vstimp_c  /display "Start Time|in Position";
			define vstim1_c  /display "Time|Assessed";
			define hr        /display "Heart|Rate";
			define rr        /display "Resp.|Rate";
			define temp        /display "Value" style=[htmlclass='overline'];
			define vstempl_dec /display "Location" style=[htmlclass='overline'];
			define space     /display " ";
			define bp1       /display "Blood Pressure|#1 (mmHg)";
			define vstim2_c  /display "Time" style=[htmlclass='overline'];
			define bp2       /display "Value" style=[htmlclass='overline'];
			define vstim3_c  /display "Time" style=[htmlclass='overline'];
			define bp3       /display "Value" style=[htmlclass='overline'];
			define bp_avg    /display "Average|(mmHg)";


			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Vital Signs";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
