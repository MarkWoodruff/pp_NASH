/*****************************************************************************************/
* Program Name  : SF_table_Screen Failures.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-13
* Description   : report Screen Failures in a table
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data sf_;
	set pp_final_elig;
	where ieorres_dec="No";
run;

data sf_one;
	set sf_;
	by subnum;

	trt=1;

	retain in01-in06 ex01-ex44;
	if first.subnum then do;
		in01=.; in02=.; in03=.; in04=.; in05=.; in06=.;
		ex01=.; ex02=.; ex03=.; ex04=.; ex05=.; ex06=.; ex07=.; ex08=.; ex09=.; ex10=.;
		ex11=.; ex12=.; ex13=.; ex14=.; ex15=.; ex16=.; ex17=.; ex18=.; ex19=.; ex20=.;
		ex21=.; ex22=.; ex23=.; ex24=.; ex25=.; ex26=.; ex27=.; ex28=.; ex29=.; ex30=.;
		ex31=.; ex32=.; ex33=.; ex34=.; ex35=.; ex36=.; ex37=.; ex38=.; ex39=.; ex40=.;
		ex41=.; ex42=.; ex43=.; ex44=.;
	end;

	%macro ie_1(i_or_e=,num=);
		if index(ietestcd_dec,"&i_or_e.&num.")>0 then &i_or_e.&num.=1;
	%mend ie_1;
	%ie_1(i_or_e=IN,num=01); %ie_1(i_or_e=IN,num=02); %ie_1(i_or_e=IN,num=03); %ie_1(i_or_e=IN,num=04); %ie_1(i_or_e=IN,num=05); %ie_1(i_or_e=IN,num=06);
	%ie_1(i_or_e=EX,num=01); %ie_1(i_or_e=EX,num=02); %ie_1(i_or_e=EX,num=03); %ie_1(i_or_e=EX,num=04); %ie_1(i_or_e=EX,num=05); %ie_1(i_or_e=EX,num=06);
	%ie_1(i_or_e=EX,num=07); %ie_1(i_or_e=EX,num=08); %ie_1(i_or_e=EX,num=09); %ie_1(i_or_e=EX,num=10); %ie_1(i_or_e=EX,num=11); %ie_1(i_or_e=EX,num=12);
	%ie_1(i_or_e=EX,num=13); %ie_1(i_or_e=EX,num=14); %ie_1(i_or_e=EX,num=15); %ie_1(i_or_e=EX,num=16); %ie_1(i_or_e=EX,num=17); %ie_1(i_or_e=EX,num=18);
	%ie_1(i_or_e=EX,num=19); %ie_1(i_or_e=EX,num=20); %ie_1(i_or_e=EX,num=21); %ie_1(i_or_e=EX,num=22); %ie_1(i_or_e=EX,num=23); %ie_1(i_or_e=EX,num=24);
	%ie_1(i_or_e=EX,num=25); %ie_1(i_or_e=EX,num=26); %ie_1(i_or_e=EX,num=27); %ie_1(i_or_e=EX,num=28); %ie_1(i_or_e=EX,num=29); %ie_1(i_or_e=EX,num=30);
	%ie_1(i_or_e=EX,num=31); %ie_1(i_or_e=EX,num=32); %ie_1(i_or_e=EX,num=33); %ie_1(i_or_e=EX,num=34); %ie_1(i_or_e=EX,num=35); %ie_1(i_or_e=EX,num=36);
	%ie_1(i_or_e=EX,num=37); %ie_1(i_or_e=EX,num=38); %ie_1(i_or_e=EX,num=39); %ie_1(i_or_e=EX,num=40); %ie_1(i_or_e=EX,num=41); %ie_1(i_or_e=EX,num=42);
	%ie_1(i_or_e=EX,num=43); %ie_1(i_or_e=EX,num=44);

	if last.subnum;
run;

data denom;
	trt=1;
run;

%counts(row= 1,dsn=sf_one,whr=%str(in01=1),showdenom=0,pct=0);
%counts(row= 2,dsn=sf_one,whr=%str(in02=1),showdenom=0,pct=0);
%counts(row= 3,dsn=sf_one,whr=%str(in03=1),showdenom=0,pct=0);
%counts(row= 4,dsn=sf_one,whr=%str(in04=1),showdenom=0,pct=0);
%counts(row= 5,dsn=sf_one,whr=%str(in05=1),showdenom=0,pct=0);
%counts(row= 6,dsn=sf_one,whr=%str(in06=1),showdenom=0,pct=0);
%counts(row= 7,dsn=sf_one,whr=%str(ex01=1),showdenom=0,pct=0);
%counts(row= 8,dsn=sf_one,whr=%str(ex02=1),showdenom=0,pct=0);
%counts(row= 9,dsn=sf_one,whr=%str(ex03=1),showdenom=0,pct=0);
%counts(row=10,dsn=sf_one,whr=%str(ex04=1),showdenom=0,pct=0);
%counts(row=11,dsn=sf_one,whr=%str(ex05=1),showdenom=0,pct=0);
%counts(row=12,dsn=sf_one,whr=%str(ex06=1),showdenom=0,pct=0);
%counts(row=13,dsn=sf_one,whr=%str(ex07=1),showdenom=0,pct=0);
%counts(row=14,dsn=sf_one,whr=%str(ex08=1),showdenom=0,pct=0);
%counts(row=15,dsn=sf_one,whr=%str(ex09=1),showdenom=0,pct=0);
%counts(row=16,dsn=sf_one,whr=%str(ex10=1),showdenom=0,pct=0);
%counts(row=17,dsn=sf_one,whr=%str(ex11=1),showdenom=0,pct=0);
%counts(row=18,dsn=sf_one,whr=%str(ex12=1),showdenom=0,pct=0);
%counts(row=19,dsn=sf_one,whr=%str(ex13=1),showdenom=0,pct=0);
%counts(row=20,dsn=sf_one,whr=%str(ex14=1),showdenom=0,pct=0);
%counts(row=21,dsn=sf_one,whr=%str(ex15=1),showdenom=0,pct=0);
%counts(row=22,dsn=sf_one,whr=%str(ex16=1),showdenom=0,pct=0);
%counts(row=23,dsn=sf_one,whr=%str(ex17=1),showdenom=0,pct=0);
%counts(row=24,dsn=sf_one,whr=%str(ex18=1),showdenom=0,pct=0);
%counts(row=25,dsn=sf_one,whr=%str(ex19=1),showdenom=0,pct=0);
%counts(row=26,dsn=sf_one,whr=%str(ex20=1),showdenom=0,pct=0);
%counts(row=27,dsn=sf_one,whr=%str(ex21=1),showdenom=0,pct=0);
%counts(row=28,dsn=sf_one,whr=%str(ex22=1),showdenom=0,pct=0);
%counts(row=29,dsn=sf_one,whr=%str(ex23=1),showdenom=0,pct=0);
%counts(row=30,dsn=sf_one,whr=%str(ex24=1),showdenom=0,pct=0);
%counts(row=31,dsn=sf_one,whr=%str(ex25=1),showdenom=0,pct=0);
%counts(row=32,dsn=sf_one,whr=%str(ex26=1),showdenom=0,pct=0);
%counts(row=33,dsn=sf_one,whr=%str(ex27=1),showdenom=0,pct=0);
%counts(row=34,dsn=sf_one,whr=%str(ex28=1),showdenom=0,pct=0);
%counts(row=35,dsn=sf_one,whr=%str(ex29=1),showdenom=0,pct=0);
%counts(row=36,dsn=sf_one,whr=%str(ex30=1),showdenom=0,pct=0);
%counts(row=37,dsn=sf_one,whr=%str(ex31=1),showdenom=0,pct=0);
%counts(row=38,dsn=sf_one,whr=%str(ex32=1),showdenom=0,pct=0);
%counts(row=39,dsn=sf_one,whr=%str(ex33=1),showdenom=0,pct=0);
%counts(row=40,dsn=sf_one,whr=%str(ex34=1),showdenom=0,pct=0);
%counts(row=41,dsn=sf_one,whr=%str(ex35=1),showdenom=0,pct=0);
%counts(row=42,dsn=sf_one,whr=%str(ex36=1),showdenom=0,pct=0);
%counts(row=43,dsn=sf_one,whr=%str(ex37=1),showdenom=0,pct=0);
%counts(row=44,dsn=sf_one,whr=%str(ex38=1),showdenom=0,pct=0);
%counts(row=45,dsn=sf_one,whr=%str(ex39=1),showdenom=0,pct=0);
%counts(row=46,dsn=sf_one,whr=%str(ex40=1),showdenom=0,pct=0);
%counts(row=47,dsn=sf_one,whr=%str(ex41=1),showdenom=0,pct=0);
%counts(row=48,dsn=sf_one,whr=%str(ex42=1),showdenom=0,pct=0);
%counts(row=49,dsn=sf_one,whr=%str(ex43=1),showdenom=0,pct=0);
%counts(row=50,dsn=sf_one,whr=%str(ex44=1),showdenom=0,pct=0);

data rows;
	set rowx1-rowx50;

	proc sort;
		by row;
run;

data dummy;
	do row=0 to 6,6.1,7 to 50;
		output;
	end;
run;

data final;
	merge dummy
		  rows;
	by row;
run;

data domain_data;
	set final;
run;

%let space2=%str(FRCSPCFRCSPCFRCSPCFRCSPC);
%let space4=%str(FRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPC);
proc format;
  	value rowfmt
	   0="Inclusion Criteria"
       1="&space2.01"
       2="&space2.02"
       3="&space2.03"
       4="&space2.04"
       5="&space2.05"
       6="&space2.06"
	 6.1="Exclusion Criteria"
	   7="&space2.01"
	   8="&space2.02"
	   9="&space2.03"
	  10="&space2.04"
	  11="&space2.05"
	  12="&space2.06"
	  13="&space2.07"
	  14="&space2.08"
	  15="&space2.09"
	  16="&space2.10"
	  17="&space2.11"
	  18="&space2.12"
	  19="&space2.13"
	  20="&space2.14"
	  21="&space2.15"
	  22="&space2.16"
	  23="&space2.17"
	  24="&space2.18"
	  25="&space2.19"
	  26="&space2.20"
	  27="&space2.21"
	  28="&space2.22"
	  29="&space2.23"
	  30="&space2.24"
	  31="&space2.25"
	  32="&space2.26"
	  33="&space2.27"
	  34="&space2.28"
	  35="&space2.29"
	  36="&space2.30"
	  37="&space2.31"
	  38="&space2.32"
	  39="&space2.33"
	  40="&space2.34"
	  41="&space2.35"
	  42="&space2.36"
	  43="&space2.37"
	  44="&space2.38"
	  45="&space2.39"
	  46="&space2.40"
	  47="&space2.41"
	  48="&space2.42"
	  49="&space2.43"
	  50="&space2.44";
run;

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column subnum iestdat visitid visname iestdat_c iec sf_mri mostdat_c;
		define subnum       /order order=internal "Patient" style=[htmlclass='patient-link sf min-width-0-75'];
		define iestdat      /order order=internal noprint;
		define visitid      /order order=internal noprint;
		define visname      /display "Visit";
		define iestdat_c    /display "Eligibility|Assessment|Date" style=[htmlclass='min-width-1-0'];
		*define ieorres_dec  /display "Eligible|for|Study?";
		*define ieenroll_dec /display "Enrolled without meeting|all IE requirements?|(include as PD)";
		define iec          /display "Inclusion and/or Exclusion Criteria Not Met" style=[htmlclass='max-width-7-5'];
		define sf_mri       /display "Screen Fail|and MRI|Performed?";
		define mostdat_c    /display "Date of MRI" style=[htmlclass='min-width-1-0'];

		*compute foldername;
			*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
		*endcomp;

		*compute age_raw;
			*if .z<input(age_raw,best.)<18 then call define(_col_,"style","style=[background=lightred]");
		*endcomp;

		*footnote "dm-footnote";

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Listing of Screen Failures";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
