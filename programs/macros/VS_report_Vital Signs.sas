/*****************************************************************************************/
* Program Name  : VS_report_Vital Signs.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : report Vital Signs domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_vs;
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
			column vsdat visname vsnd_reas vsdat_c vspos vstimp_c vstim1_c hrn hr rr tempn ("Temp.SUPER2SPNHDRFRCCNTR" temp vstempl_dec) space
			("Blood Pressure (mmHg)SUPER3SPNHDRFRCNDRLNCNTR" 
				bp1_sysn bp1_dian ("Value #1SPNHDRFRCCNTR" bp1_sys bp1_dia) space
				bp2_sysn bp2_dian ("Value #2SPNHDRFRCCNTR" vstim2_c bp2_sys bp2_dia) space 
				bp3_sysn bp3_dian ("Value #3SPNHDRFRCCNTR" vstim3_c bp3_sys bp3_dia) space 
				bp_avg_sysn bp_avg_dian ("AverageSPNHDRFRCCNTR" bp_avg_sys bp_avg_dia));
			define vsdat       /order order=internal noprint;
			define visname     /display "Visit";
			define vsnd_reas   /display "Not Done:|Reason";
			define vsdat_c     /display "Date|Assessed" style=[htmlclass='min-width-1-0'];
			define vspos       /display "Position";
			define vstimp_c    /display "Start Time|in Position";
			define vstim1_c    /display "Time|Assessed";
			define hrn         /display noprint;
			define hr          /display "Heart|RateSUPER1";
			define rr          /display "Resp.|Rate";
			define tempn       /display noprint;
			define temp        /display "Value" style=[htmlclass='overline'];
			define vstempl_dec /display "Loc." style=[htmlclass='overline'];
			define space       /display " ";
			define bp1_sysn    /display noprint;
			define bp1_dian    /display noprint;
			define bp1_sys     /display "Sys." style=[htmlclass='overline'];
			define bp1_dia     /display "Dia." style=[htmlclass='overline'];
			define vstim2_c    /display "Time" style=[htmlclass='overline'];
			define bp2_sysn    /display noprint;
			define bp2_dian    /display noprint;
			define bp2_sys     /display "Sys." style=[htmlclass='overline'];
			define bp2_dia     /display "Dia." style=[htmlclass='overline'];
			define vstim3_c    /display "Time" style=[htmlclass='overline'];
			define bp3_sysn    /display noprint;
			define bp3_dian    /display noprint;
			define bp3_sys     /display "Sys." style=[htmlclass='overline'];
			define bp3_dia     /display "Dia." style=[htmlclass='overline'];
			define bp_avg_sysn /display noprint;
			define bp_avg_dian /display noprint;
			define bp_avg_sys  /display "Sys." style=[htmlclass='overline'];
			define bp_avg_dia  /display "Dia." style=[htmlclass='overline'];

			compute hr;
				if .z<hrn<60 or hrn>100 then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute temp;
				if .z<tempn<=35 or tempn>=38 then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp1_sys;
				if 120<=bp1_sysn<140 then call define(_col_,"style/merge","style=[background=yellow");
					else if 140<=bp1_sysn<160 then call define(_col_,"style/merge","style=[background=orange");
					else if 160<=bp1_sysn then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp2_sys;
				if 120<=bp2_sysn<140 then call define(_col_,"style/merge","style=[background=yellow");
					else if 140<=bp2_sysn<160 then call define(_col_,"style/merge","style=[background=orange");
					else if 160<=bp2_sysn then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp3_sys;
				if 120<=bp3_sysn<140 then call define(_col_,"style/merge","style=[background=yellow");
					else if 140<=bp3_sysn<160 then call define(_col_,"style/merge","style=[background=orange");
					else if 160<=bp3_sysn then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp_avg_sys;
				if 120<=bp_avg_sysn<140 then call define(_col_,"style/merge","style=[background=yellow");
					else if 140<=bp_avg_sysn<160 then call define(_col_,"style/merge","style=[background=orange");
					else if 160<=bp_avg_sysn then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp1_dia;
				if 80<=bp1_dian<90 then call define(_col_,"style/merge","style=[background=yellow");
					else if 90<=bp1_dian<100 then call define(_col_,"style/merge","style=[background=orange");
					else if 100<=bp1_dian then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp2_dia;
				if 80<=bp2_dian<90 then call define(_col_,"style/merge","style=[background=yellow");
					else if 90<=bp2_dian<100 then call define(_col_,"style/merge","style=[background=orange");
					else if 100<=bp2_dian then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp3_dia;
				if 80<=bp3_dian<90 then call define(_col_,"style/merge","style=[background=yellow");
					else if 90<=bp3_dian<100 then call define(_col_,"style/merge","style=[background=orange");
					else if 100<=bp3_dian then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;
			compute bp_avg_dia;
				if 80<=bp_avg_dian<90 then call define(_col_,"style/merge","style=[background=yellow");
					else if 90<=bp_avg_dian<100 then call define(_col_,"style/merge","style=[background=orange");
					else if 100<=bp_avg_dian then call define(_col_,"style/merge","style=[background=cxff7676");
			endcomp;

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			*compute age_raw;
				*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
			*endcomp;

			footnote "vs-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Vital Signs";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
