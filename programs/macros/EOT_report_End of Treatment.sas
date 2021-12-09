/*****************************************************************************************/
* Program Name  : EOT_report_End of Treatment.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-12-09
* Description   : report EOT domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_eot;
	where subnum="&ptn.";
run;

%check_dates(dsn=domain_data,date=dsstdat_c);
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
			column dsexdat_c dsstdat_c complet_dec dsdecod_dec dsaeno dthdat_c dspdno dablind_dec;
			define dsexdat_c   /display "Date of|Last Dose" style=[htmlclass='min-width-1-0'];
			define dsstdat_c   /display "Date of Completion|or Early Termination" style=[htmlclass='min-width-1-0'];
			define complet_dec /display "Complete Treatment|per Protocol?";
			define dsdecod_dec /display "Primary Reason for|Early TerminationSUPER1" style=[htmlclass='max-width-4-0'];
			define dsaeno      /display "Adverse|Event #";
			define dthdat_c    /display "Death Date" style=[htmlclass='min-width-1-0'];
			define dspdno      /display "Protocol|Deviation #";
			define dablind_dec /display "Treatment|Unblinded?";

			compute dsstdat_c;
				if dsstdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &dsstdat_cflag_foot.=1 %then %do;
				footnote "eotdate-footnote";
			%end;
				%else %do;
					footnote "eot-footnote";
				%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "End of Treatment";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
