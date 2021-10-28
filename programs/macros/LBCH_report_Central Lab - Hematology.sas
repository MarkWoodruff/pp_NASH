/*****************************************************************************************/
* Program Name  : LBCH_report_Central Lab - Hematology.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-22-15
* Description   : report LBC domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data domain_data;
	set pp_final_lbc;
	where subnum="&ptn." and lbcat='Hematology';
	space=' ';
run;

%nobs(domain_data);

** get all lab tests for each patient for dropdown **;
data tstnam;
	set pp_final_lbc(where=(subnum="&ptn." and lbcat='Hematology' and lbtest^=''));

	length tstnam $100;
	tstnam=strip(lbtest);

	proc sort;
		by subnum tstnam;
run;

data tstnam(keep=subnum tstnam);
	set tstnam;
	by subnum tstnam;
	if first.tstnam;
run;

data _null_ test;
	set tstnam end=eof;

	length valuetag $50;
	valuetag=lowcase(strip(compress(compress(tstnam,''),')')));
	valuetag=tranwrd(valuetag,'%','-');
	valuetag=tranwrd(valuetag,'(','-');
	valuetag=tranwrd(valuetag,',','-');
	valuetag=tranwrd(valuetag,'/','-');
	valuetag=tranwrd(valuetag,'\','-');
	valuetag=tranwrd(valuetag,'.','-');

	length text $2000;
	if _n_=1 then text="<select id='tstnamddh'><option value='tstnamddh-all' selected>-- Show All --</option><option value='"||strip(valuetag)||"'>"||strip(tstnam)||"</option>";
		else text="<option value='"||strip(valuetag)||"'>"||strip(tstnam)||"</option>";
	if eof then text=strip(text)||'</select>';

	length tstnamddh $5000;
	retain tstnamddh;
	if valuetag^='' then tstnamddh=cats(tstnamddh,text);
	if length(tstnamddh)>4800 then put "ER" "ROR: update LBC_report_Central Lab Results.sas for length of tstnamddh";

	if valuetag not in ('basophils','basophils-leukocytes','eosinophils','eosinophils-leukocytes','ery-meancorpuscularhemoglobin','ery-meancorpuscularvolume',
		'erythrocytes','hematocrit','hemoglobin','leukocytes','lymphocytes','lymphocytes-leukocytes','monocytes','monocytes-leukocytes',
		'neutrophils','neutrophils-leukocytes','platelets','reticulocyte-erythrocytes')
		then put "ER" "ROR: update LBCH_report_Labs - Hematology.sas and tstnamddh.js for TSTNAM values for dropdown: " valuetag=;
	%global tstnamddh;
	%let tstnamddh= ;
	call symput('tstnamddh',strip(tstnamddh));
run;

%put tstnamddh=&tstnamddh.;

%macro report_domain;
	%if &nobs.=0 %then %do;
		data domain_data;
			merge domain_data empty;
		run;
	%end;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(report)=[htmlid='lbch']
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		%if &nobs.=0 %then %do;
			column subnum;
			define subnum /order order=internal noprint;
			footnote "No data for this patient/domain as of &data_dt..";
		%end;
		%else %do;
			column lbdat visit lbdat_cflag lbdat_c lbtest labflag_tanja
				("Original UnitsSPNHDRFRCCNTR" lborres_lborresu nr) space 
				("Standard UnitsSPNHDRFRCCNTR" lbstresc_lbstresu nrst) labflag_lbnrind lbnrind 
				 lbrefid yob_sex lbfast_dec lbstat_lbreasnd lbspec lbcoval;* lbcat;
			define lbdat             /order order=internal noprint;
			define visit             /display "Visit|Name";
			define lbdat_cflag       /display noprint;
			define lbdat_c           /display "Lab Date" style=[htmlclass='min-width-1-0'];
			define lbtest            /display "Lab Test-TSTNAMDDC" style=[htmlclass='picklbnm min-width-1-75'];
			define labflag_tanja     /display noprint;
			define lborres_lborresu  /display "Result-UnitsSUPER1" style=[htmlclass='overline'];
			define nr                /display "Normal|Range" style=[htmlclass='overline'];
			define space             /display " ";
			define lbstresc_lbstresu /display "Result-UnitsSUPER1" style=[htmlclass='overline'];
			define nrst              /display "Normal|Range" style=[htmlclass='overline'];
			define labflag_lbnrind   /display noprint;
			define lbnrind           /display "Ref. Range|IndicatorSUPER2";
			define lbrefid           /display "Specimen|ID" style=[htmlclass='lbcc-other hidden'];
			define yob_sex           /display "YOB-|Sex" style=[htmlclass='lbcc-other hidden'];
			define lbfast_dec        /display "Fast?" style=[htmlclass='lbcc-other hidden'];
			*define lbcat             /display "Lab|Cagegory" style=[htmlclass='lbcc-other hidden'];
			define lbstat_lbreasnd   /display "Comp. Status-|Reason" style=[htmlclass='max-width-2-0 lbcc-other hidden'];
			define lbspec            /display "Specimen|Type" style=[htmlclass='lbcc-other hidden'];
			define lbcoval           /display "Comments" style=[htmlclass='max-width-6-0 lbcc-other hidden'];

			*compute foldername;
				*if foldername='Unscheduled' then call define(_col_,"style","style=[background=yellow]");
			*endcomp;

			%macro makered(var=);
				compute &var.;
					%if &var.=lbnrind %then %do;
						if labflag_lbnrind=1 then call define(_col_,"style/merge","style=[background=cxff7676]");
					%end;

					%if &var.=lborres_lborresu or &var.=lbstresc_lbstresu %then %do;
						if labflag_tanja=1 then call define(_col_,"style/merge","style=[background=yellow]");
						if labflag_tanja=2 then call define(_col_,"style/merge","style=[background=orange]");
						if labflag_tanja=3 then call define(_col_,"style/merge","style=[background=cxff7676]");
					%end;

					%if &var.=lbdat_c %then %do;
						if lbdat_cflag=1 then call define(_col_,"style/merge","style=[background=yellow]");
					%end;

					visit_lag=lag(visit);
					if visit^=visit_lag and visit^='Screening' then call define(_col_,"style/merge","style=[bordertopcolor=black bordertopstyle=solid bordertopwidth=1px]");
				endcomp;
			%mend makered;
			%makered(var=visit);
			%makered(var=lbdat_c);
			%makered(var=lbtest);
			%makered(var=lborres_lborresu);
			%makered(var=nr);
			%makered(var=space);
			%makered(var=lbstresc_lbstresu);
			%makered(var=nrst);
			%makered(var=lbnrind);
			%makered(var=lbrefid);
			%makered(var=yob_sex);
			%makered(var=lbfast_dec);
			%makered(var=lbstat_lbreasnd);
			%makered(var=lbspec);
			%makered(var=lbcoval);

			%if &lbdat_cflag_foot.=1 %then %do;
				footnote "lbxhemadate-footnote";
			%end;
				%else %do;
					footnote "lbxhema-footnote";
				%end;
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Central Lab - Hematology";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
