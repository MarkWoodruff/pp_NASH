/*****************************************************************************************/
* Program Name  : INFCON_report_Informed Consent.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-14
* Description   : report Informed Consent domain
*
* Revision History
* Date       By            Description of Change
* 2021-09-24 Mark Woodruff use SUBNUM.
******************************************************************************************;

data domain_data;
	set pp_final_infcon;
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
			footnote "No data for this patient/domain as of INSERTDATE.";
		%end;
		%else %do;
			column dsstdat_c dsicf_g_dec dsstdat_g_c pver part_dec;
			define dsstdat_c   /display "Date Informed|Consent Signed" style=[htmlclass='min-width-1-0'];
			define dsicf_g_dec /display "Genetic Informed|Consent Signed?";
			define dsstdat_g_c /display "Date Genetic|Consent Signed" style=[htmlclass='min-width-1-0'];
			define pver        /display "Protocol Version at|Study Entry";
			define part_dec    /display "Protocol Part";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Informed Consent";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
