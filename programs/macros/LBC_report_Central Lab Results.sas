/*****************************************************************************************/
* Program Name  : LBC_report_Central Lab Results.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-22-15
* Description   : report LBC domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_lbc;
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
			column lbdat visit lbdat_c lbrefid yob_sex lbfast_dec lbcat lbtest 
				("Original UnitsSPNHDRFRCCNTR" lborres_lborresu nr) space 
				("Standard UnitsSPNHDRFRCCNTR" lbstresc_lbstresu nrst) lbnrind lbstat_lbreasnd lbspec lbcoval;
			define lbdat             /order order=internal noprint;
			define visit             /display group "Visit|Name";
			define lbdat_c           /display group "Lab Date" style=[htmlclass='min-width-1-0'];
			define lbrefid           /display group "Specimen|ID";
			define yob_sex           /display group "YOB-|Sex";
			define lbfast_dec        /display group "Fast?";
			define lbcat             /display group "Lab|Cagegory";
			define lbtest            /display "Lab|Test";
			define lborres_lborresu  /display "Result-Units" style=[htmlclass='overline'];
			define nr                /display "Normal|Range" style=[htmlclass='overline'];
			define space             /display " ";
			define lbstresc_lbstresu /display "Result-Units" style=[htmlclass='overline'];
			define nrst              /display "Normal|Range" style=[htmlclass='overline'];
			define lbnrind           /display "Ref. Range|Indicator";
			define lbstat_lbreasnd   /display "Comp. Status-|Reason" style=[htmlclass='max-width-2-0'];
			define lbspec            /display "Specimen|Type";
			define lbcoval           /display "Comments" style=[htmlclass='max-width-4-0'];

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "dm-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Central Lab Results";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
