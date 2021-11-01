/*****************************************************************************************/
* Program Name  : SF_table_Incidence of Screen Failures.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-13
* Description   : report Screen Failures in a table
*
* Revision History
* Date       By            Description of Change
* 2021-10-27 Mark Woodruff add number of screen fails.
* 2021-10-28 Mark Woodruff add category totals.
******************************************************************************************;

******************************************;
** denoms for percentages and column Ns **;
******************************************;
data adsl(keep=subnum trt);
	set crf.ie(encoding=any where=(pagename='Eligibility' and deleted='f'));

	trt=1;

	proc sort nodupkey;
		by subnum;
run;

proc freq data=adsl noprint;
	tables trt/out=denom;
run;

data row0;
	set denom;
	length bign $500;
	bign=strip(put(count,best.));
run;

proc transpose data=row0 out=rowx0 prefix=c;
	id trt;
	var bign;
run;

%let n1=0;
data _null_;
	set denom;
	call symput('n'||strip(put(trt,best.)),strip(put(count,best.)));
run;

data sf_;
	set pp_final_elig;
	where ieorres_dec="No";
run;

data sf_one;
	set sf_;
	by subnum;

	trt=1;

	retain any in01-in06 ex_any ex01-ex44 in01_in06 ex01_ex05 ex06_ex13 ex14_ex24 ex25_ex34 ex35_ex44;
	if first.subnum then do;
		in01=.; in02=.; in03=.; in04=.; in05=.; in06=.;
		ex01=.; ex02=.; ex03=.; ex04=.; ex05=.; ex06=.; ex07=.; ex08=.; ex09=.; ex10=.;
		ex11=.; ex12=.; ex13=.; ex14=.; ex15=.; ex16=.; ex17=.; ex18=.; ex19=.; ex20=.;
		ex21=.; ex22=.; ex23=.; ex24=.; ex25=.; ex26=.; ex27=.; ex28=.; ex29=.; ex30=.;
		ex31=.; ex32=.; ex33=.; ex34=.; ex35=.; ex36=.; ex37=.; ex38=.; ex39=.; ex40=.;
		ex41=.; ex42=.; ex43=.; ex44=.; any=.;
		in01_in06=.; ex_any=.; ex01_ex05=.; ex06_ex13=.; ex14_ex24=.; ex25_ex34=.; ex35_ex44=.;
	end;

	%macro ie_1(i_or_e=,num=);
		if index(ietestcd_dec,"&i_or_e.&num.")>0 then do;
			&i_or_e.&num.=1;
			any=1;
		end;
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

	if last.subnum then do;
		if in01=1 or in02=1 or in03=1 or in04=1 or in05=1 or in06=1 then in01_in06=1; 
		if ex01=1 or ex02=1 or ex03=1 or ex04=1 or ex05=1 then ex01_ex05=1;
		if ex06=1 or ex07=1 or ex08=1 or ex09=1 or ex10=1 or ex11=1 or ex12=1 or ex13=1 then ex06_ex13=1; 
		if ex14=1 or ex15=1 or ex16=1 or ex17=1 or ex18=1 or ex19=1 or ex20=1 or ex21=1 or ex22=1 or ex23=1 or ex24=1 then ex14_ex24=1; 
		if ex25=1 or ex26=1 or ex27=1 or ex28=1 or ex29=1 or ex30=1 or ex31=1 or ex32=1 or ex33=1 or ex34=1 then ex25_ex34=1; 
		if ex35=1 or ex36=1 or ex37=1 or ex38=1 or ex39=1 or ex40=1 or ex41=1 or ex42=1 or ex43=1 or ex44=1 then ex35_ex44=1;
		if ex01_ex05=1 or ex06_ex13=1 or ex14_ex24=1 or ex25_ex34=1 or ex35_ex44=1 then ex_any=1;
		output;
	end;
run;

%counts(row= 0,dsn=sf_one,whr=%str(any=1),showdenom=0);

%counts(row= 1,dsn=sf_one,whr=%str(in01_in06=1),showdenom=0);
%counts(row= 2,dsn=sf_one,whr=%str(in01=1),showdenom=0);
%counts(row= 3,dsn=sf_one,whr=%str(in02=1),showdenom=0);
%counts(row= 4,dsn=sf_one,whr=%str(in03=1),showdenom=0);
%counts(row= 5,dsn=sf_one,whr=%str(in04=1),showdenom=0);
%counts(row= 6,dsn=sf_one,whr=%str(in05=1),showdenom=0);
%counts(row= 7,dsn=sf_one,whr=%str(in06=1),showdenom=0);

%counts(row= 8,dsn=sf_one,whr=%str(ex_any=1),showdenom=0);
%counts(row= 9,dsn=sf_one,whr=%str(ex01_ex05=1),showdenom=0);
%counts(row=10,dsn=sf_one,whr=%str(ex01=1),showdenom=0);
%counts(row=11,dsn=sf_one,whr=%str(ex02=1),showdenom=0);
%counts(row=12,dsn=sf_one,whr=%str(ex03=1),showdenom=0);
%counts(row=13,dsn=sf_one,whr=%str(ex04=1),showdenom=0);
%counts(row=14,dsn=sf_one,whr=%str(ex05=1),showdenom=0);

%counts(row=15,dsn=sf_one,whr=%str(ex06_ex13=1),showdenom=0);
%counts(row=16,dsn=sf_one,whr=%str(ex06=1),showdenom=0);
%counts(row=17,dsn=sf_one,whr=%str(ex07=1),showdenom=0);
%counts(row=18,dsn=sf_one,whr=%str(ex08=1),showdenom=0);
%counts(row=19,dsn=sf_one,whr=%str(ex09=1),showdenom=0);
%counts(row=20,dsn=sf_one,whr=%str(ex10=1),showdenom=0);
%counts(row=21,dsn=sf_one,whr=%str(ex11=1),showdenom=0);
%counts(row=22,dsn=sf_one,whr=%str(ex12=1),showdenom=0);
%counts(row=23,dsn=sf_one,whr=%str(ex13=1),showdenom=0);

%counts(row=24,dsn=sf_one,whr=%str(ex14_ex24=1),showdenom=0);
%counts(row=25,dsn=sf_one,whr=%str(ex14=1),showdenom=0);
%counts(row=26,dsn=sf_one,whr=%str(ex15=1),showdenom=0);
%counts(row=27,dsn=sf_one,whr=%str(ex16=1),showdenom=0);
%counts(row=28,dsn=sf_one,whr=%str(ex17=1),showdenom=0);
%counts(row=29,dsn=sf_one,whr=%str(ex18=1),showdenom=0);
%counts(row=30,dsn=sf_one,whr=%str(ex19=1),showdenom=0);
%counts(row=31,dsn=sf_one,whr=%str(ex20=1),showdenom=0);
%counts(row=32,dsn=sf_one,whr=%str(ex21=1),showdenom=0);
%counts(row=33,dsn=sf_one,whr=%str(ex22=1),showdenom=0);
%counts(row=34,dsn=sf_one,whr=%str(ex23=1),showdenom=0);
%counts(row=35,dsn=sf_one,whr=%str(ex24=1),showdenom=0);

%counts(row=36,dsn=sf_one,whr=%str(ex25_ex34=1),showdenom=0);
%counts(row=37,dsn=sf_one,whr=%str(ex25=1),showdenom=0);
%counts(row=38,dsn=sf_one,whr=%str(ex26=1),showdenom=0);
%counts(row=39,dsn=sf_one,whr=%str(ex27=1),showdenom=0);
%counts(row=40,dsn=sf_one,whr=%str(ex28=1),showdenom=0);
%counts(row=41,dsn=sf_one,whr=%str(ex29=1),showdenom=0);
%counts(row=42,dsn=sf_one,whr=%str(ex30=1),showdenom=0);
%counts(row=43,dsn=sf_one,whr=%str(ex31=1),showdenom=0);
%counts(row=44,dsn=sf_one,whr=%str(ex32=1),showdenom=0);
%counts(row=45,dsn=sf_one,whr=%str(ex33=1),showdenom=0);
%counts(row=46,dsn=sf_one,whr=%str(ex34=1),showdenom=0);

%counts(row=47,dsn=sf_one,whr=%str(ex35_ex44=1),showdenom=0);
%counts(row=48,dsn=sf_one,whr=%str(ex35=1),showdenom=0);
%counts(row=49,dsn=sf_one,whr=%str(ex36=1),showdenom=0);
%counts(row=50,dsn=sf_one,whr=%str(ex37=1),showdenom=0);
%counts(row=51,dsn=sf_one,whr=%str(ex38=1),showdenom=0);
%counts(row=52,dsn=sf_one,whr=%str(ex39=1),showdenom=0);
%counts(row=53,dsn=sf_one,whr=%str(ex40=1),showdenom=0);
%counts(row=54,dsn=sf_one,whr=%str(ex41=1),showdenom=0);
%counts(row=55,dsn=sf_one,whr=%str(ex42=1),showdenom=0);
%counts(row=56,dsn=sf_one,whr=%str(ex43=1),showdenom=0);
%counts(row=57,dsn=sf_one,whr=%str(ex44=1),showdenom=0);

data rows;
	set rowx0-rowx57;

	proc sort;
		by row;
run;

data dummy;
	do row=0 to 57;
		output;
	end;
run;

data final;
	merge dummy
		  rows;
	by row;
run;

%let space2=%str(FRCSPCFRCSPCFRCSPCFRCSPC);
%let space4=%str(FRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPCFRCSPC);
proc format;
  	value rowfmt
	   0="Overall count of Screen Failure Patients"
	   1="Inclusion Criteria"
       2="&space2.01: Male or Female, age 18 to 75"
       3="&space2.02: BMI within range of 30 to 45 kg/mSUPER2"
       4="&space2.03: Liver fat VCTE CAP Score > 300 dB/m"
       5="&space2.04: Liver injury and fibrosis, VCTE LSM score 7 to 9.9 kPa and AST > 20 U/L"
       6="&space2.05: Contraception requirements"
       7="&space2.06: Communication with Investigator, understanding study"
	   8="Exclusion Criteria"
	   9="Hepato-biliary Related"
	  10="&space2.01: Clinical, laboratory or radiologic evidence of cirrhosis"
	  11="&space2.02: History of cholecystitis or cholecystectomy w/in prior 24w"
	  12="&space2.03: Gallstones or biliary sludge and a history of biliary disease symptoms"
	  13="&space2.04: History of pancreatic injury, pancreatitis, or pancreatic disease"
	  14="&space2.05: Confirmed abnormalities in specified hepatic biomarkers"
	  15="Endocrine Related"
	  16="&space2.06: Change in body weight."
	  17="&space2.07: History of T1 diabetes, diabetic ketoacidosis, positive GAD auto-antibodies"
	  18="&space2.08: T2DM with a history of diabetic complications"
	  19="&space2.09: Prior history of significant bone disease such as osteoporosis"
	  20="&space2.10: History of bone fracture or bone surgery"
	  21="&space2.11: Cushing's disease or Cushing's syndrome"
	  22="&space2.12: TSH outside the normal reference range (unless free T4 is within NR)"
	  23="&space2.13: Hemoglobin A1c > 9.5%"
	  24="Other Medical"
	  25="&space2.14: Confirmed positive PCR-based COVID-19 test"
	  26="&space2.15: Poorly controlled hypertension"
	  27="&space2.16: Significant illness which has not resolved within 2 weeks prior to first dose"
	  28="&space2.17: Chronic infection with hepatitis B virus (HBV) or hepatitis C virus (HCV)"
	  29="&space2.18: Known immunocompromised status"
	  30="&space2.19: Compromised renal eGFR < 60 mL/min/1.73 m2 by CKD-EPI equation"
	  31="&space2.20: History or current diagnosis of ECG abnormalities"
	  32="&space2.21: History of malignancy of any organ system (2 exceptions), within the past 5y"
	  33="&space2.22: Bariatric surgery or biliary diversion"
	  34="&space2.23: Major surgery within 6 weeks of Screening"
	  35="&space2.24: Disorder which in the Inv. opinion might jeopardize safety or compliance"
	  36="General"
	  37="&space2.25: History of hypersensitivity to drugs of similar biological class"
	  38="&space2.26: Subjects with contraindications to MRI"
	  39="&space2.27: Waist circumference > 57"
	  40="&space2.28: Females who are pregnant or breastfeeding"
	  41="&space2.29: History of drug abuse w/in 12m prior to dosing or evidence of such abuse"
	  42="&space2.30: History of excessive alcohol intake"
	  43="&space2.31: Heavy smoking"
	  44="&space2.32: Donation/loss of >=450 mL blood within 8w prior to initial dosing"
	  45="&space2.33: Prisoners or subjects who are involuntarily incarcerated"
	  46="&space2.34: Compulsorily detained for treatment of psychiatric or physical illness"
	  47="Concomitant Medications"
	  48="&space2.35: Any vaccination in the 2 weeks prior to randomization"
	  49="&space2.36: Vitamin E (>= 800 IU/day) or pioglitazone w/in 90d prior to first dose"
	  50="&space2.37: Use of insulin, GLP-1 receptor agonists, or DPP-4 antagonists"
	  51="&space2.38: Anti-lipid medication"
	  52="&space2.39: Drugs associated with induced steatosis"
	  53="&space2.40: Use of other investigational drugs at the time of enrollment"
	  54="&space2.41: Use of weight loss drugs, currently or in the past 12 weeks"
	  55="&space2.42: Acetaminophen > 2g per day for consec. 5d in previous 30d prior to dosing"
	  56="&space2.43: Pharmacotherapy for osteoporosis within 90 days prior to dosing"
	  57="&space2.44: Oral or injected corticosteroids for >7d consec., within 90d prior to dosing";
run;

data final;
	set final;
	by row;

	length c0 $700;
	c0=put(row,rowfmt.);

	array columns c1;
	do over columns;
		if index(columns,'()')>0 and index(columns,'NA, NA')>0 then columns=put(0,2.);
		if columns='' then columns=put(0,3.);
	end;

	array columns_ c0 c1;
	do over columns_;
		if row in (15,24,36,47) then columns_="frcbrk"||columns_;
	end;

	if row=0 then section=1;
		else if 1<=row<=7 then section=2;
		else section=3;

	pgcount=1;

	section2=section;
run;

data domain_data;
	set final;
run;

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column section section2 row c0 c1;

		define section   /order order=internal noprint;
		define section2  /display noprint;
		define row       /order order=internal noprint;
		define c0        /display "Screen Failure due toSUPER1" style=[htmlclass='max-width-7-75 fixed dispfixed1'];
		define c1        /display "Screened|Patients|(N=&n1.)";

		compute c0;
			if row in (1,8,9,15,24,36,47) then call define(_col_,"style/merge","style=[font_weight=bold text_decoration=underline]");
			if row in (0) then call define(_col_,"style/merge","style=[font_weight=bold]");
		endcomp;

		** blank line before each section **;
		compute after section; 
			length text $50;
			if section^=9 then do;
				text=' ';
				num=10;
			end;
				else do;
					text='';
					num=0;
				end;
			line text $varying. num;
		endcomp;
		
		footnote "SUPER1 Patients can be counted in multiple rows, as they can fail due to multiple inclusion and/or exclusion criteria.";

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Incidence of Screen Failures";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
