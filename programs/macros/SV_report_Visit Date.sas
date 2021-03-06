/*****************************************************************************************/
* Program Name  : SV_report_Visit Date.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : report Visit Date domain
*
* Revision History
* Date       By            Description of Change
* 2022-03-16 Mark Woodruff add visit day flagging against protocol specified window.
******************************************************************************************;

data domain_data;
	set pp_final_sv;
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
			column visitid visname svstdt_c svnd_c svreasnd visflag vistext;
			define visitid   /order order=internal noprint;
			define visname   /display "Visit";
			define svstdt_c  /display "Visit Date" style=[htmlclass='min-width-1-0'];
			define svnd_c    /display "Not Done?";
			define svreasnd  /display "Reason Not Done";
			define visflag   /display noprint;
			define vistext   /display "Within Protocol Specified Window?SUPER1" style=[htmlclass='created'];

			compute vistext;
				if visflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			footnote "SUPER1 BP calculation.  Not compared for Day 1, or for Day 113/Early Termination when patient terminated early.";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Visit Date";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
