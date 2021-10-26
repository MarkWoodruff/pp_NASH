/*****************************************************************************************/
* Program Name  : RAND_report_Randomization.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-01
* Description   : report Randomization domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching VS.
******************************************************************************************;

data domain_data;
	set pp_final_rand;
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
			column visitid visname dsstdat_cflag dsstdat_c cohort_dec;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define dsstdat_cflag /display noprint;
			define dsstdat_c     /display "Date" style=[htmlclass='min-width-1-0'];
			define cohort_dec    /display "Cohort";

			compute dsstdat_c;
				if dsstdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &dsstdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Randomization";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
