/*****************************************************************************************/
* Program Name  : UNS_report_Unscheduled Visit.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Unscheduled Visit domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_uns;
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
			column visitid svstdt svstdt_c svupdes svupbm svupvs svupeg svuppe svupupt svupfpg svuplb svupvcte svupus svupmri 
					  svuppc svupada svuplb2 svupkit svuplb3;
			define visitid  /order order=internal noprint;
			define svstdt   /order order=internal noprint;
			define svstdt_c /display "Visit Date" style=[htmlclass='min-width-1-0 fixed unsfixed1'];
			define svupdes  /display "Reason for|Unscheduled" style=[htmlclass='fixed unsfixed2'];
			define SVUPBM   /display "Body|Measurements" style=[htmlclass='overline'];
			define SVUPVS   /display "Vital|Signs" style=[htmlclass='overline'];
			define SVUPEG   /display "ECG" style=[htmlclass='overline'];
			define SVUPPE   /display "Physical|Exam" style=[htmlclass='overline'];
			define SVUPUPT  /display "Urine|Pregnancy" style=[htmlclass='overline'];
			define SVUPFPG  /display "Fasting|Plasma|Glucose" style=[htmlclass='overline'];
			define SVUPLB   /display "Central Lab|Collection" style=[htmlclass='overline'];
			define SVUPVCTE /display "VCTE" style=[htmlclass='overline'];
			define SVUPUS   /display "Ultrasound" style=[htmlclass='overline'];
			define SVUPMRI  /display "MRI-PDFF" style=[htmlclass='overline'];
			define SVUPPC   /display "PK Sample|Collection" style=[htmlclass='overline'];
			define SVUPADA  /display "ADA|Collection" style=[htmlclass='overline'];
			define SVUPLB2  /display "Biomarkers" style=[htmlclass='overline'];
			define SVUPKIT  /display "Kit|Assignment" style=[htmlclass='overline'];
			define SVUPLB3  /display "Samples sent|to local lab" style=[htmlclass='overline'];


			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title fixed-domain-title"];
			line "Unscheduled Visit";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
