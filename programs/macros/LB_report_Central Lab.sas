/*****************************************************************************************/
* Program Name  : LB_report_Central Lab.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-26
* Description   : report LB (Safety Labs) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-27 Mark Woodruff put date/time for main sample under header.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff handle sorting of missing dates.
******************************************************************************************;

data domain_data;
	set pp_final_lb;
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
			column lbdat_sort lbdat lbtim visname ("Blood sample collected forSPNHDRFRCCNTR" lbhem_dec lbchem_dec lbser_dec lbcoag_dec lbtsh_dec lbfsh_dec lbhcg_dec lbcovid_dec lbdat_cflag lbdat_c lbtim_c)
				   space ("CortisolSPNHDRFRCCNTR" lbcortsl_dec lbdatcort_c lbtimcort_c) lbfast_dec lbcoval;
			define lbdat_sort    /order order=internal noprint;
			define lbdat         /order order=internal noprint;
			define lbtim         /order order=internal noprint;
			define visname       /display "Visit";
			define lbhem_dec     /display "Hema." style=[htmlclass='overline'];
			define lbchem_dec    /display "Chem." style=[htmlclass='overline'];
			define lbser_dec     /display "Serol." style=[htmlclass='overline'];
			define lbcoag_dec    /display "Coag." style=[htmlclass='overline'];
			define lbtsh_dec     /display "TSH" style=[htmlclass='overline'];
			define lbfsh_dec     /display "FSH+|Estrad." style=[htmlclass='overline'];
			define lbhcg_dec     /display "Serum|Preg." style=[htmlclass='overline'];
			define lbcovid_dec   /display "COVID-19" style=[htmlclass='overline'];
			define lbdat_cflag   /display noprint;
			define lbdat_c       /display "Date of|Sampling" style=[htmlclass='min-width-1-0 overline'];
			define lbtim_c       /display "Time of|Sampling" style=[htmlclass='overline'];
			define space         /display " ";
			define lbcortsl_dec  /display "Sample|Collected?" style=[htmlclass='overline'];
			define lbdatcort_c   /display "Date of|Sampling" style=[htmlclass='min-width-1-0 overline'];
			define lbtimcort_c   /display "Time of|Sampling" style=[htmlclass='overline'];
			define lbfast_dec    /display "Fasting for at|least 8h?";
			define lbcoval       /display "Comments" style=[htmlclass='max-width-4-0'];

			compute lbdat_c;
				if lbdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &lbdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Central Lab";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
