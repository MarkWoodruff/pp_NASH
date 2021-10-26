/*****************************************************************************************/
* Program Name  : CM_report_Concomitant Medications.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : report CM domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add pageseq_c;
******************************************************************************************;

data domain_data;
	set pp_final_cm;
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
			column pageseq_c cmtrt_c coding cmindc_c cmaeno cmmhno dates dose route frequency;
			define pageseq_c /display "CM|No.";
			define cmtrt_c   /display "Medication" style=[htmlclass='max-width-3-0'];
			define coding    /display "Coding" style=[htmlclass='max-width-3-0'];
			define cmindc_c  /display "Indication,|Specify" style=[htmlclass='max-width-3-0'];
			define cmaeno    /display "AE|ID";
			define cmmhno    /display "MH|ID";
			define dates     /display "Start Date/|Stop Date" style=[htmlclass='min-width-1-0'];
			define dose      /display "Dose, Unit";
			define route     /display "Route";
			define frequency /display "Frequency";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Concomitant Medications";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
