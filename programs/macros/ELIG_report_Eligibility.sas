/*****************************************************************************************/
* Program Name  : ELIG_report_Eligibility.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Eligibility domain
*
* Revision History
* Date       By            Description of Change
* 2021-09-28 Mark Woodruff use data_dt.
* 2021-10-01 Mark Woodruff add visitid and visname.
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data domain_data;
	set pp_final_elig;
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
			column iestdat visitid visname iestdat_cflag iestdat_c ieorres_dec ieenroll_dec ietestcd_dec sf_mri mostdat_c iereplc_dec iereplcn;
			define iestdat       /order order=internal noprint;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define iestdat_cflag /display noprint;
			define iestdat_c     /display "Eligibility|Assessment|Date" style=[htmlclass='min-width-1-0'];
			define ieorres_dec   /display "Eligible|for Study?";
			define ieenroll_dec  /display "Enrolled without meeting|all IE requirements?|(include as PD)";
			define ietestcd_dec  /display "Inclusion and/or|Exclusion Criteria Not Met";
			define sf_mri        /display "Screen Fail and|MRI Performed?";
			define mostdat_c     /display "Date of MRI" style=[htmlclass='min-width-1-0'];
			define iereplc_dec   /display "Replacing a|Previous Subject?";
			define iereplcn      /display "Subject ID of|Subject to be Replaced";

			compute iestdat_c;
				if iestdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &iestdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Eligibility";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
