/*****************************************************************************************/
* Program Name  : MRI_report_MRI.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : report MRI domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-04 Mark Woodruff add external data.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2021-12-03 Mark Woodruff drop independently programmed check on average as we do not know number of pixels.
* 2022-01-05 Mark Woodruff do not sort on dates.
* 2022-01-19 Mark Woodruff add date of Biotel MRI transfer
* 2022-03-14 Mark Woodruff they moved location of average record to MOSEQ=10.
******************************************************************************************;

data domain_data;
	set pp_final_mri;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=mostdat_c);
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
			column visitid visname mostdat_cflag mostdat_c mosttim_c mriperf_reas mofastyn_dec mofastn_c
				("Couinaud SegmentSUPER1SPNHDRFRCNDRLNCNTR" measc_1 measc_2 measc_3 measc_4 measc_5 measc_6 measc_7 measc_8 measc_9 measc_10);
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define mostdat_cflag /display noprint;
			define mostdat_c     /display "Date of MRI" style=[htmlclass='min-width-1-0'];
			define mosttim_c     /display "Time|of MRISUPER1";
			define mriperf_reas  /display "Performed?|If No, Reason" style=[htmlclass='max-width-3-0'];
			define mofastyn_dec  /display "Fasting|4h?";
			define mofastn_c     /display "Hours|Fasting?";
			define measc_1       /display "I" style=[htmlclass='overline'];
			define measc_2       /display "II" style=[htmlclass='overline'];
			define measc_3       /display "III" style=[htmlclass='overline'];
			define measc_4       /display "IVa" style=[htmlclass='overline'];
			define measc_5       /display "IVb" style=[htmlclass='overline'];
			define measc_6       /display "IV" style=[htmlclass='overline'];
			define measc_7       /display "VI" style=[htmlclass='overline'];
			define measc_8       /display "VII" style=[htmlclass='overline'];
			define measc_9       /display "VIII" style=[htmlclass='overline'];
			define measc_10      /display "Average" style=[htmlclass='overline'];

			compute mostdat_c;
				if mostdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &mostdat_cflag_foot.=1 %then %do;
				footnote "mridate-footnote";
			%end;
				%else %do;
					footnote "mri-footnote";
				%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "MRI";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
