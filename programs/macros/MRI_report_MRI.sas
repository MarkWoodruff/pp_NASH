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
			column mostdat visitid visname mostdat_cflag mostdat_c mosttim_c mriperf_reas mofastyn_dec mofastn_c
				("Couinaud SegmentSUPER1SPNHDRFRCNDRLNCNTR" measc_2 measc_3 measc_4 measc_5 measc_6 measc_7 measc_8 measc_9 measc_10) space
			    ("AverageSPNHDRFRCNDRLNCNTR" meas_flag measc_1 measc_avg);
			define mostdat       /order order=internal noprint;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define mostdat_cflag /display noprint;
			define mostdat_c     /display "Date of MRI" style=[htmlclass='min-width-1-0'];
			define mosttim_c     /display "Time|of MRISUPER1";
			define mriperf_reas  /display "Performed?|If No, Reason" style=[htmlclass='max-width-3-0'];
			define mofastyn_dec  /display "Fasting|4h?";
			define mofastn_c     /display "Hours|Fasting?";
			define measc_2        /display "I" style=[htmlclass='overline'];
			define measc_3        /display "II" style=[htmlclass='overline'];
			define measc_4        /display "III" style=[htmlclass='overline'];
			define measc_5        /display "IVa" style=[htmlclass='overline'];
			define measc_6        /display "IVb" style=[htmlclass='overline'];
			define measc_7        /display "IV" style=[htmlclass='overline'];
			define measc_8        /display "VI" style=[htmlclass='overline'];
			define measc_9        /display "VII" style=[htmlclass='overline'];
			define measc_10       /display "VIII" style=[htmlclass='overline'];
			define space         /display "";
			define meas_flag     /display noprint;
			define measc_1        /display "BiotelSUPER1" style=[htmlclass='overline'];
			define measc_avg      /display "Internally|CalculatedSUPER2" style=[htmlclass='overline created'];

			compute mostdat_c;
				if mostdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			compute measc_1;
				*if meas_flag=1 then call define(_col_,"style","style=[background=red]");
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
