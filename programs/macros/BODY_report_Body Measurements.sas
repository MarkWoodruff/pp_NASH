/*****************************************************************************************/
* Program Name  : BODY_report_Body Measurements.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Body Measurements domain
*
* Revision History
* Date       By            Description of Change
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff handle sorting of records with missing dates.
* 2022-03-11 Mark Woodruff edit sort order for those with lots of missing visits.
******************************************************************************************;

data domain_data;
	set pp_final_body;
	where subnum="&ptn.";
run;

%check_dates(dsn=domain_data,date=vsdat_c);
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
			column sortvar vsdat visname vsdat_c vsperf_n vsreasnd vsdat_cflag waist weight height ("Auto-calculated in DB" height_bmi vsbmi_c);
			define sortvar     /order order=internal noprint;
			define vsdat       /order order=internal noprint;
			define visname     /display "Visit";
			define vsdat_c     /display "Date|Assessed" style=[htmlclass='min-width-1-0'];
			define vsperf_n    /display "Check Box if|Not Assessed";
			define vsreasnd    /display "Reason|Not Done";
			define vsdat_cflag /display noprint;
			define waist       /display "Waist|Circumference";
			define weight      /display "Weight";
			define height      /display "Height";
			define height_bmi  /display "Height|in Metric" style=[htmlclass='overline'];
			define vsbmi_c     /display "BMI" style=[htmlclass='overline'];

			compute vsdat_c;
				if vsdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &vsdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
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
