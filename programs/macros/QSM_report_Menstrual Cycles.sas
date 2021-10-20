/*****************************************************************************************/
* Program Name  : QSM_report_Menstrual Cycles.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-20
* Description   : report Menstrual Cycles domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_qsm;
	where subnum="&ptn.";
	space=' ';
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
			column visname qsstdat_c qsendat_c;
			define visname   /display group "Visit";
			define qsstdat_c /display group "Start Date" style=[htmlclass='min-width-1-0'];
			define qsendat_c /display group "Stop Date" style=[htmlclass='min-width-1-0'];

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Menstrual Cycles";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
