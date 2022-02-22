/*****************************************************************************************/
* Program Name  : LLB_report_Local Lab.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-02-22
* Description   : report LLB (Local Labs) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_llb;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=lbdat_c);
%nobs(domain_data);

proc sort data=domain_data;
	by subnum lbdat_sort lbdat lbtim;
run;

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
			column lbdat_sort lbdat lbtim visname lbaeno_ lbrefid lbdat_cflag lbdat_c lbtim_c lbfast_dec lbtest_ lborres lbu nr lbstnrc lbcoval;
			define lbdat_sort   /order order=internal noprint;
			define lbdat        /order order=internal noprint;
			define lbtim        /order order=internal noprint;
			define visname      /display "Visit";
			define lbaeno_      /display "AE";
			define lbrefid      /display "Lab Ref ID";
			define lbdat_cflag  /display noprint;
			define lbdat_c      /display "Lab Date";
			define lbtim_c      /display "Lab|Time";
			define lbfast_dec   /display "Fasting?";
			define lbtest_      /display "Lab Test";
			define lborres      /display "Lab|Result";
			define lbu          /display "Lab|Unit";
			define nr           /display "Normal|Range";
			define lbstnrc      /display "Non-Numeric|Reference Range";
			define lbcoval      /display "Comments";

			compute lbdat_c;
				if lbdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &lbdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Local Lab Assessment";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
