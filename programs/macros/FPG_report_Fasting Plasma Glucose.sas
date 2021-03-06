/*****************************************************************************************/
* Program Name  : FPG_report_Fasting Plasma Glucose.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : report FPG domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_fpg;
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
			column visitid visname lbfpgna lbperf_reasnd lbfast8_c lborres_u;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define lbfpgna       /display "Checkbox if subject|does not have T2DM" style=[htmlclass='max-width-3-0'];
			define lbperf_reasnd /display "FPG Obtained?|If no, reason" style=[htmlclass='max-width-3-0'];
			define lbfast8_c     /display "How long did|subject fast? (hrs)";
			define lborres_u     /display "Result, units";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "Note: External MRI data from BioTel Research will be added once it is received.";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Fasting Plasma Glucose";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
