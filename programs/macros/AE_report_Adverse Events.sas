/*****************************************************************************************/
* Program Name  : AE_report_Adverse Events.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-03
* Description   : report Adverse Events domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ae;
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
			column aespid aenone_aespid coding start stop aesi_aeisr aeout_aesev aerel_aeser aeacn_
				      sae_hosp aeslife aesdisab aescong aesmie aesdth_;
			define aespid        /order order=internal noprint;
			define aenone_aespid /display "AE#";
			define coding        /display "Adverse Event/|System Organ Class/|Preferred Term" style=[htmlclass='max-width-4-0'];
			define start         /display "Start Date/|Start Time" style=[htmlclass='min-width-1-0'];
			define stop          /display "Stop Date/|Stop Time" style=[htmlclass='min-width-1-0'];
			define aesi_aeisr    /display "AESI?|ISR?";
			define aeout_aesev   /display "Outcome/|Severity";
			define aerel_aeser   /display "Rel. to Drug/|Serious?";
			define aeacn_        /display "Action w/ Drug/|Action w/ Subject";
			define sae_hosp      /display "Req. or Prol.|Hosp., Dates";
			define aeslife       /display "Life|Threat.";
			define aesdisab      /display "Disab. or|Incap.";
			define aescong       /display "CA or|Birth Def.";
			define aesmie        /display "Other|MIE";
			define aesdth_       /display "Death/|Death Date";

			compute iestdat_c;
				if iestdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Adverse Events";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
