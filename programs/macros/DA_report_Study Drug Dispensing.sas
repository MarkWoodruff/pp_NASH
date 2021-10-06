/*****************************************************************************************/
* Program Name  : DA_report_Study Drug Dispensing.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : report DA domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_da;
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
			column visitid visname dareplac_dec dadisdat_c dadistim_c dakitno1-dakitno3 dadisdat2_c dadistim2_c;
			define visitid      /order order=internal noprint;
			define visname      /display "Visit";
			define dareplac_dec /display "Replacing a|Damaged Kit?";
			define dadisdat_c   /display "Date Kit|Assigned" style=[htmlclass='min-width-1-0'];
			define dadistim_c   /display "Time Kit|Assigned";
			define dakitno1     /display "Kit Number 1";
			define dakitno2     /display "Kit Number 2";
			define dakitno3     /display "Kit Number 3";
			define dadisdat2_c  /display "Date Syringe(s)|Loaded" style=[htmlclass='min-width-1-0'];
			define dadistim2_c  /display "Time Syringe(s)|Loaded";

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			*footnote "Note: External MRI data from BioTel Research will be added once it is received.";
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Study Drug Dispensing";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
