/*****************************************************************************************/
* Program Name  : QSS_report_Menstrual Summary.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-20
* Description   : report Menstrual Summary domain
*
* Revision History
* Date       By            Description of Change
* 2022-03-16 Mark Woodruff blank out qs16/qs17 depending on visit per AC.
******************************************************************************************;

data domain_data;
	set pp_final_qss;
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
			column visitid visname qsyn_nomc qs16_dec qs17_dec;
			define visitid   /order order=internal noprint;
			define visname   /display group "Visit";
			define qsyn_nomc /display group "Of Menstrual Potential?|If no, reason" style=[htmlclass='max-width-3-0'];
			define qs16_dec  /display group "At study start, menstrual|cycle best described asSUPER1" style=[htmlclass='max-width-4-0'];
			define qs17_dec  /display group "Compare menstrual cycle|from study start to todaySUPER2" style=[htmlclass='max-width-4-0'];

			compute qs16_dec;
				if visname^='Day 1' then call define(_col_,"style","style=[background=black]");
			endcomp;
			compute qs17_dec;
				if visname not in ('Day 85','Day 113/Early Termination') then call define(_col_,"style","style=[background=black]");
			endcomp;

			footnote "qss-footnote";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Menstrual Summary";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
