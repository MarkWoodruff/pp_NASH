/*****************************************************************************************/
* Program Name  : VCTE_report_Fibroscan (VCTE).sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-01
* Description   : report VCTE domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-05-23 Mark Woodruff order by visit since only Screening and Day 85.
******************************************************************************************;

data domain_data;
	set pp_final_vcte;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=fadat_c);
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
			column visitid visname fadat_cflag fadat_c faperf_reas fafast8_dec fafast_c faorres_cap_c faorres_lsm_c facoval;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define fadat_cflag   /display noprint;
			define fadat_c       /display "Date" style=[htmlclass='min-width-1-0'];
			define faperf_reas   /display "Performed?|If No, Reason" style=[htmlclass='max-width-3-0'];
			define fafast8_dec   /display "Fasting at|least 8 hours?";
			define fafast_c      /display "If No, Number|of Hours Fasted";
			define faorres_cap_c /display "CAP|Score";
			define faorres_lsm_c /display "LSM|Score";
			define facoval       /display "Comments";

			compute fadat_c;
				if fadat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &fadat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Fibroscan (VCTE)";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
