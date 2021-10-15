/*****************************************************************************************/
* Program Name  : BIO_report_Exploratory Biomarkers.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-15
* Description   : report BIO domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_bio;
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
			column visitid visname lbfast_dec lbperf1_ lbperf2_ lbperf3_ lbperf4_ lbdat_c lbtim_c lbcoval;
			define visitid     /order order=internal noprint;
			define visname     /display "Visit";
			define lbfast_dec  /display "Fasting for at|least 8 hours?";
			define lbperf1_    /display "Sample for Fasting|Biomarkers Collected?|If No, Reason" style=[htmlclass='max-width-4-0'];
			define lbperf2_    /display "Sample for Other|Biomarkers Collected?|If No, Reason" style=[htmlclass='max-width-4-0'];
			define lbperf3_    /display "Sample for RNA|Analysis Collected?|If No, Reason" style=[htmlclass='max-width-4-0'];
			define lbperf4_    /display "Sample for DNA|Analysis Collected?|If No, Reason" style=[htmlclass='max-width-4-0'];
			define lbdat_c     /display "Collection|Date" style=[htmlclass='min-width-1-0'];
			define lbtim_c     /display "Collection|Time";
			define lbcoval     /display "Comment, if any" style=[htmlclass='max-width-4-0'];

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Exploratory Biomarkers";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
