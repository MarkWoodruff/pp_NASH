/*****************************************************************************************/
* Program Name  : QS_report_Monthly Questionnaire.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-19
* Description   : report Monthly Questionnaire domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
******************************************************************************************;

data domain_data;
	set pp_final_qs;
	where subnum="&ptn.";
	space=' ';
run;

%check_dates(dsn=domain_data,date=qsdat_c);
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
			column qsdat visname qsperf_reas qsdat_cflag qsdat_c c1 c2;*
				   ("In the last month, on averageSPNHDRFRCNDRLNCNTR" 
				   ("Juice/Soda (pop)SPNHDRFRCCNTR" qs01_dec qs02_dec qs03_dec qs04_dec qs05_dec) space
				   ("AlcoholSPNHDRFRCCNTR" qs06_dec qs07_dec qs08_dec qs09_dec) space
				   ("Sweet/DessertSPNHDRFRCCNTR" qs10_dec qs11_dec qs12_dec qs13_dec));
			define qsdat       /order order=internal noprint;
			define visname     /display group "Visit";
			define qsperf_reas /display group "Completed?|Reason";
			define qsdat_cflag /display noprint;
			define qsdat_c     /display group "Date of|Assessment" style=[htmlclass='min-width-1-0'];
			define c1          /display "Question" style=[htmlclass='max-width-7-0'];
			define c2          /display "In the last month, on average" style=[htmlclass='max-width-7-0'];
			/*
			define qs01_dec    /display "Fruit Juice";
			define qs02_dec    /display "Fruit Drink";
			define qs03_dec    /display "Regular Soda";
			define qs04_dec    /display "Diet Soda";
			define qs05_dec    /display "Desire";
			define space       /display " ";
			define qs06_dec    /display "Beer";
			define qs07_dec    /display "Wine";
			define qs08_dec    /display "Hard Alcohol";
			define qs09_dec    /display "Desire";
			define qs10_dec    /display "Muffins, Doughnuts, Sweet|Rolls, Danish, Pop-Tarts";
			define qs11_dec    /display "Pies, Ice Cream, Cakes,|Cookies, Brownies";
			define qs12_dec    /display "Candy, Candy Bars,|Chocolate, Chocolate Bars";
			define qs13_dec    /display "Desire";*/

			compute c1;
				if c1 in ("BLDJuice/Soda (pop)X",'BLDAlcohol','BLDSweet/Dessert') then 
					call define(_col_,"style","style=[bordertopcolor=black bordertopstyle=solid bordertopwidth=1px]");
			endcomp;
			compute c2;
				if c1 in ("BLDJuice/Soda (pop)X",'BLDAlcohol','BLDSweet/Dessert') then 
					call define(_col_,"style","style=[bordertopcolor=black bordertopstyle=solid bordertopwidth=1px]");
			endcomp;

			compute qsdat_c;
				if qsdat_cflag=1 then call define(_col_,"style","style=[background=yellow]");
			endcomp;

			%if &qsdat_cflag_foot.=1 %then %do;
				footnote "date-footnote";
			%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Monthly Questionnaire";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
