/*****************************************************************************************/
* Program Name  : DA_report_Study Drug Dispensing.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : report DA domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
******************************************************************************************;

data domain_data;
	set pp_final_da;
	where subnum="&ptn.";
	space=' ';
run;

%global convfoot;
%let convfoot=;
data _null_;
	set domain_data;
	call symput('convfoot',strip(convfoot));
run;

%check_dates(dsn=domain_data,date=dadisdat_c);
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
			column visitid visname dareplac_dec dadisdat_cflag ("Collected in GMTSPNHDRFRCNDRLNCNTR" dadisdat_c dadistim_c) space
				   ("Converted to localSUPER1SPNHDRFRCNDRLNCNTR" dstc newdt newtm) dakitno1-dakitno3 dadisdat2_c dadistim2_c diffc;
			define visitid      /order order=internal noprint;
			define visname      /display "Visit";
			define dareplac_dec /display "Replacing a|Damaged Kit?";
			define dadisdat_cflag /display noprint;
			define dadisdat_c   /display "Date Kit|Assigned" style=[htmlclass='min-width-1-0'];
			define dadistim_c   /display "Time Kit|Assigned";
			define space        /display " " style=[htmlclass='max-width-0-25'];
			define dstc         /display "During|DST?" style=[htmlclass='created'];
			define newdt        /display "Date Kit|Assigned" style=[htmlclass='min-width-1-0 created'];
			define newtm        /display "Time Kit|Assigned" style=[htmlclass='created'];
			define dakitno1     /display "Kit 1";
			define dakitno2     /display "Kit 2";
			define dakitno3     /display "Kit 3";
			define dadisdat2_c  /display "Date Syringe(s)|Loaded" style=[htmlclass='min-width-1-0'];
			define dadistim2_c  /display "Time Syringe(s)|Loaded";
			define diffc        /display "Minutes from|Assign. to Loading" style=[htmlclass='created'];

			compute dadisdat_c;
				if dadisdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &dadisdat_cflag_foot.=1 %then %do;
				footnote "dadate-footnote";
			%end;
				%else %do;
					footnote "da-footnote";
				%end;
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
