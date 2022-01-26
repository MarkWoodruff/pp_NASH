/*****************************************************************************************/
* Program Name  : ECG_report_ECG.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : report ECG domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-21 Mark Woodruff add EGQTCF.
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff handle sorting of missing dates.
******************************************************************************************;

data domain_data;
	set pp_final_ecg;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=egdat_c);
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
			column egdat_sort egdat visname egdat_cflag egdat_c egnd_reas egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf egqtcf_c egorres_c;
			define egdat_sort  /order order=internal noprint;
			define egdat       /order order=internal noprint;
			define visname     /display "Visit";
			define egdat_cflag /display noprint;
			define egdat_c     /display "Date|Performed" style=[htmlclass='min-width-1-0'];
			define egnd_reas   /display "Not Done:|Reason" style=[htmlclass='max-width-3-5'];
			define egtims_c    /display "Start Time|Supine Position";
			define egtim_c     /display "Time|Performed";
			define eghr_c      /display "Heart|Rate";
			define egqt_c      /display "QT|Interval";
			define egpr_c      /display "PR|Interval";
			define egqrs_c     /display "QRS|Interval";
			define egrr_c      /display "RR|Interval";
			define egqtcf      /display noprint;
			define egqtcf_c    /display "QTcFSUPER1";
			define egorres_c   /display "Results, Specify" style=[htmlclass='max-width-3-75'];

			compute egqtcf_c;
				if 450<egqtcf<=480 then call define(_col_,"style/merge","style=[background=yellow");
					else if 480<egqtcf<=500 then call define(_col_,"style/merge","style=[background=orange");
					else if 500<egqtcf then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;

			compute egdat_c;
				if egdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &egdat_cflag_foot.=1 %then %do;
				footnote "ecgdate-footnote";
			%end;
				%else %do;
					footnote "ecg-footnote";
				%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "ECG";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
