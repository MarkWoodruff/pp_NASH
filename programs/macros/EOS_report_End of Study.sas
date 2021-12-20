/*****************************************************************************************/
* Program Name  : EOS_report_End of Study.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-12-13
* Description   : report EOS domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_eos;
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
			column dsstdat_cflag dsstdat_c dscomp_dec primary_reason dsdthdat_c dsaeno dspdno covid;
			define dsstdat_cflag  /display noprint;
			define dsstdat_c      /display "Date of Completion|or Early Termination" style=[htmlclass='min-width-1-0'];
			define dscomp_dec     /display "Did the Subject|Complete the Trial?";
			define primary_reason /display "Primary Reason for|Study Discontinuation" style=[htmlclass='max-width-4-0'];
			define dsdthdat_c     /display "Death Date" style=[htmlclass='min-width-1-0'];
			define dsaeno         /display "Adverse|Event #";
			define dspdno         /display "Protocol|Deviation #";
			define covid          /display "If COVID|related, specify";

			compute dsstdat_c;
				if dsstdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &dsstdat_cflag_foot.=1 %then %do;
				footnote "eosdate-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "End of Study";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
