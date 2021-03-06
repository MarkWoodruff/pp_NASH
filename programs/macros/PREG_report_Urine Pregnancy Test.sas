/*****************************************************************************************/
* Program Name  : PREG_report_Urine Pregnancy Test.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : report Urine Pregnancy Test domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-01 Mark Woodruff keep visitid visname.
******************************************************************************************;

data domain_data;
	set pp_final_preg;
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
			column visitid visname lbnd lbuptr_dec lbcoval;
			define visitid    /order order=internal noprint;
			define visname    /display "Visit";
			define lbnd       /display "Check Box|if Not Done";
			define lbuptr_dec /display "Result of|Urine Pregnancy Test";
			define lbcoval    /display "Comments, if any";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Urine Pregnancy Test (In-Clinic Lab)";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
