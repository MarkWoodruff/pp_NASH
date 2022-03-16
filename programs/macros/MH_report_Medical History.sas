/*****************************************************************************************/
* Program Name  : MH_report_Medical History.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Medical History domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-06 Mark Woodruff coding removed from DB.
* 2021-10-22 Mark Woodruff add pageseq;
* 2022-03-11 Mark Woodruff add coding.
******************************************************************************************;

data domain_data;
	set pp_final_mh;
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
			column visitid visname mhnd_c pageseq_c mhterm coding dates ongoing mhsev_dec;
			define visitid   /order order=internal noprint;
			define visname   /display "Visit";
			define mhnd_c    /display "No Relevant|Medical History";
			define pageseq_c /display "Medical|History No.";
			define mhterm    /display "Diagnosis/Procedure";
			define coding    /display "System Organ Class/|Preferred Term" style=[htmlclass='max-width-3-0'];
			define dates     /display "Start Date/|Stop Date" style=[htmlclass='min-width-1-25'];
			define ongoing   /display "Ongoing?";
			define mhsev_dec /display "CTCAE Grade";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Medical History";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
