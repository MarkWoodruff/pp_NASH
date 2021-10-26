/*****************************************************************************************/
* Program Name  : EX_report_Study Drug Administration.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-07
* Description   : report EX domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data domain_data;
	set pp_final_ex;
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
			column visitid visname exyn_dec exinjn_dec exstdat_c exstdat_cflag exsttim_c ("LocationSPNHDRFRCNDRLNCNTR" exloc1_ exloc2_ exloc3_) 
			       exvamtt_c exdoseyn_dec exreas_ exrxnyn_dec excoval;
			define visitid       /order order=internal noprint;
			define visname       /display "Visit";
			define exyn_dec      /display "Dosing|Performed?";
			define exinjn_dec    /display "Number of|Injections";
			define exstdat_cflag /display noprint;
			define exstdat_c     /display "Dosing|Date" style=[htmlclass='min-width-1-0'];
			define exsttim_c     /display "Start|Dosing|Time";
			define exloc1_       /display "1" style=[htmlclass='overline'];
			define exloc2_       /display "2" style=[htmlclass='overline'];
			define exloc3_       /display "3" style=[htmlclass='overline'];
			define exvamtt_c     /display "Total|Volume|Admin. (mL)";
			define exdoseyn_dec  /display "Full Dose|Admin.?";
			define exreas_       /display "Reasons";
			define exrxnyn_dec   /display "Injection Site|Reaction Occur?";
			define excoval       /display "Comments" style=[htmlclass='max-width-3-0'];

			compute exstdat_c;
				if exstdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &exstdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Study Drug Administration";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
