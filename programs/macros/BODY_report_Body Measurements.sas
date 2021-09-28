/*****************************************************************************************/
* Program Name  : BODY_report_Body Measurements.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Body Measurements domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_body;
	where subnum="&ptn.";
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
			column vsdat visname vsperf_n vsreasnd vsdat_c waist weight height ("Auto-calculated in DB" height_bmi vsbmi_c);
			define vsdat      /order order=internal noprint;
			define visname    /display "Visit";
			define vsperf_n   /display "Check Box if|Not Assessed";
			define vsreasnd   /display "Reason|Not Done";
			define vsdat_c    /display "Date|Assessed" style=[htmlclass='min-width-1-0'];
			define waist      /display "Waist|Circumference";
			define weight     /display "Weight";
			define height     /display "Height";
			define height_bmi /display "Height|in Metric" style=[htmlclass='overline'];
			define vsbmi_c    /display "BMI" style=[htmlclass='overline'];


			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Body Measurements";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
