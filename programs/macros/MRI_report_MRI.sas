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
******************************************************************************************;

data domain_data;
	set pp_final_mri;
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
			column mostdat visitid visname mostdat_cflag mostdat_c mriperf_reas mofastyn_dec mofastn_c;
			define mostdat       /order order=internal noprint;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define mostdat_cflag /display noprint;
			define mostdat_c     /display "Date of MRI|Examination" style=[htmlclass='min-width-1-0'];
			define mriperf_reas  /display "Performed?|If No, Reason" style=[htmlclass='max-width-3-0'];
			define mofastyn_dec  /display "Fasting for 4 Hours|Prior to Procedure?";
			define mofastn_c     /display "How Many Hours Was|Subject Fasting?";

			compute mostdat_c;
				if mostdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &mostdat_cflag_foot.=1 %then %do;
				footnote "mridate-footnote";
			%end;
				%else %do;
					footnote "Note: External MRI data from BioTel Research will be added once it is received.";
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
