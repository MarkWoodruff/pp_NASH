/*****************************************************************************************/
* Program Name  : ADA_report_ADA Sample.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-15
* Description   : report ADA domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
******************************************************************************************;

data domain_data;
	set pp_final_ada;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=lbdat_c);
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
			column visitid visname lbperf_reas lbdat_cflag lbdat_c lbtim_c lbcoval;
			define visitid     /order order=internal noprint;
			define visname     /display "Visit";
			define lbperf_reas /display "Sample Collected?|If No, Reason" style=[htmlclass='max-width-4-0'];
			define lbdat_cflag /display noprint;
			define lbdat_c     /display "Collection|Date" style=[htmlclass='min-width-1-0'];
			define lbtim_c     /display "Collection|Time";
			define lbcoval     /display "Comment, if any" style=[htmlclass='max-width-4-0'];

			compute lbdat_c;
				if lbdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &lbdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "ADA Sample";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
