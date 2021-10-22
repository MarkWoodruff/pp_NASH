/*****************************************************************************************/
* Program Name  : PD_report_Protocol Deviations.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-21
* Description   : report Protocol Deviations domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_pd;
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
			column dvstdat dvnone cat_ dviddat_c dvstdat_c dvterm dvirbna dvirbdat_c;
			define dvstdat    /order order=internal noprint;
			define dvnone     /display "Check if no|Deviations";
			define cat_       /display "Category: Subcategory" style=[htmlclass='max-width-3-0'];
			define dviddat_c  /display "Date|Identified" style=[htmlclass='min-width-1-0'];
			define dvstdat_c  /display "Deviation|Date" style=[htmlclass='min-width-1-0'];
			define dvterm     /display "Description of Deviation" style=[htmlclass='max-width-5-0 RPLCSBJ'];
			define dvirbna    /display "Check if IRB did not|need to be notified";
			define dvirbdat_c /display "Date IRB|Informed" style=[htmlclass='min-width-1-0'];

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Protocol Deviations";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
