/*****************************************************************************************/
* Program Name  : RunProfiles.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-14 (copied from BOS-172738-01 and modified)
* Description   : build patient profiles
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;
dm 'output' clear;
dm 'log' clear;

proc datasets lib=work kill nolist memtype=(data view);
quit;

%include "C:\Users\markw.consultant\_projects\global\setup.sas";
%setup;

options threads nomprint nomlogic nosymbolgen compress=yes;

*******************************;
** record program start time **;
*******************************;
data _null_;
	call symput('starttm',put(time(),time8.));
	call symput('today',put(today(),yymmdd10.));
	call symput('now',strip(put(year(today()),best.))||strip(put(month(today()),z2.))||strip(put(day(today()),z2.))||strip(put(hour(time()),z2.))||strip(put(minute(time()),z2.))||strip(put(round(second(time()),1),z2.)));
run;

ods listing close;

******************************************************;
** BUILD EACH REPORTABLE DOMAIN ACROSS ALL PATIENTS **;
******************************************************;
%include "&macros.\INFCON_build.sas"   / nosource2;
%include "&macros.\ELIG_build.sas"     / nosource2;
%include "&macros.\DM_build.sas"       / nosource2;
%include "&macros.\MH_build.sas"       / nosource2;

****************************************************************;
** SET UP INFRASTRUCTURE TO LOOP THROUGH PATIENTS AND DOMAINS **;
****************************************************************;
** create an empty dataset to merge onto DOMAIN_DATA when DOMAIN_DATA is empty **;
data empty(compress=no);
	empty="";
run;

** create template for incrementing IDX when no graphs to graph **;
ods path work.temp(update) sasuser.templat(update) sashelp.tmplmst(read);
proc template;
	define table incrementIDX;
		column a;
		define a;
		generic=on;
		end;
	end;
run;

*****************************************;
** get HTML code for patient dashboard **;
*****************************************;
** part + cohort, for lower left of patient cards **;
data cohort(keep=subnum part_cohort);
	set crf.ds(encoding=any where=(pagename='Informed Consent'));

	length cohort_c $100;
	if cohort_dec^='' then cohort_c=strip(cohort_dec);
		else cohort_c='Cohort TBD';

	length part_cohort $100;
	part_cohort=catx(': ','Part '||strip(part_dec),cohort_c);

	proc sort;
		by subnum;
run;

** patient status, for upper left of patient cards **;
** enrolled **;
data enrolled(keep=subnum enrolled);
	set crf.ie(encoding=any where=(deleted='f'));

	enrolled=strip(ieorres);

	proc sort;
		by subnum;
run;

** discontinued or completed **;
data eos(keep=subnum eos);
	set crf.ds(encoding=any where=(upcase(pagename)='END OF STUDY' and dsstdat>.z));

	eos=1;

	proc sort;
		by subnum;
run;

data patient_status(keep=subnum patient_status);
	merge enrolled
		  eos;
	by subnum;

	length patient_status $100;
	if eos=1 then patient_status='Discont.';
		else if enrolled='Y' then patient_status='Active';
		else if enrolled='N' then patient_status='Not Eligible';
		else put "ER" "ROR: update RunProfiles.sas to populate PATIENT_STATUS for new cases.";
run;

** latest visit **;
data latest_visit;
	set crf.sv(encoding=any);

	proc sort;
		by subnum svstdt;
		where svnd='';
run;

data latest_visit(keep=subnum latest_visit);
	set latest_visit;
	by subnum svstdt;
	if last.subnum;

	if visname='Unscheduled' then visname='Unsched.';

	length latest_visit $100;
	latest_visit=strip(visname);
run;

data patient_cards(keep=subnum part_cohort latest_visit patient_status);
	merge latest_visit
		  cohort
		  patient_status;
	by subnum;

	if index(part_cohort,': Cohort TBD')>0 and patient_status='Not Eligible' then part_cohort=strip(scan(part_cohort,1,':'));
run;

data patient_cards_code(keep=patient_cards_code);
	set patient_cards;
	by subnum;
	
	length status_tag $100;
	if lowcase(patient_status)='active' or (patient_status='' and index(upcase(latest_visit),'SCREENING')>0) then status_tag='active-patient';
		else status_tag='discontinued-patient';

	length patient_cards_code $32767;
	patient_cards_code="<section class='patient-card-grid-item "||strip(status_tag)||"'><a href='.\"||
	strip(subnum)||".htm'><p class='part-cohort'>"||strip(part_cohort)||"</p>
						  <p class='patient-visit'>"||strip(latest_visit)||"</p>
						  <p class='patient-status'>"||strip(patient_status)||"</p>
	<h1 class='patient-number'>"||strip(subnum)||"</h1></a></section>";
run;

data _null_;
	set patient_cards_code end=eof;

	retain num;
	num+1;

	length big_patient_cards_list1 big_patient_cards_list2 big_patient_cards_list3 big_patient_cards_list4 $32767;
	retain big_patient_cards_list1 big_patient_cards_list2 big_patient_cards_list3 big_patient_cards_list4;

	if num<=100 then 			  big_patient_cards_list1=catx(' ',big_patient_cards_list1,patient_cards_code);
		else if 100<num<=200 then big_patient_cards_list2=catx(' ',big_patient_cards_list2,patient_cards_code);
		else if 200<num<=300 then big_patient_cards_list3=catx(' ',big_patient_cards_list3,patient_cards_code);
		else if 300<num<=400 then big_patient_cards_list4=catx(' ',big_patient_cards_list4,patient_cards_code);

	bpcl1_length=length(strip(big_patient_cards_list1));
	bpcl2_length=length(strip(big_patient_cards_list2));
	bpcl3_length=length(strip(big_patient_cards_list3));
	bpcl4_length=length(strip(big_patient_cards_list4));

	if eof then do;
		call symput('big_patient_cards_list1',strip(big_patient_cards_list1));
		call symput('big_patient_cards_list2',strip(big_patient_cards_list2));
		call symput('big_patient_cards_list3',strip(big_patient_cards_list3));
		call symput('big_patient_cards_list4',strip(big_patient_cards_list4));
		call symput('bpcl1_length',strip(put(length(strip(big_patient_cards_list1)),best.)));
		call symput('bpcl2_length',strip(put(length(strip(big_patient_cards_list2)),best.)));
		call symput('bpcl3_length',strip(put(length(strip(big_patient_cards_list3)),best.)));
		call symput('bpcl4_length',strip(put(length(strip(big_patient_cards_list4)),best.)));
	end;
run;

%put &big_patient_cards_list2.;

data _null_;
	** throw warn1ng to log if patient list is about to run out of room inside variable **;
	%if %eval(&bpcl1_length.)>32000 %then %do; put "ER" "ROR: big_patient_cards_list1 is about to be GT 32,000 characters and will cause fail."; %end;
	%if %eval(&bpcl2_length.)>32000 %then %do; put "ER" "ROR: big_patient_cards_list2 is about to be GT 32,000 characters and will cause fail."; %end;
	%if %eval(&bpcl3_length.)>32000 %then %do; put "ER" "ROR: big_patient_cards_list3 is about to be GT 32,000 characters and will cause fail."; %end;
	%if %eval(&bpcl4_length.)>32000 %then %do; put "ER" "ROR: big_patient_cards_list4 is about to be GT 32,000 characters and will cause fail."; %end;
run;

********************************************;
** get list of patients for sidebar links **;
********************************************;
data patient_list(keep=subnum);
	set patient_cards;
	
	proc sort nodupkey;
		by subnum;
run;

proc sql noprint;
	select count(subnum) into :num_patients from patient_list;
	select subnum into :patient1 - :patient%cmpres(&num_patients.) from patient_list order by subnum;
quit; 

data patient_links(keep=patient_link_html);
	set patient_list;

	patient_link_html="<li><a href='"||strip(subnum)||".htm'>"||strip(subnum)||"</a></li>";
run;

data _null_;
	set patient_links end=eof;

	length big_patient_list $32767;
	retain big_patient_list;

	big_patient_list=catx(' ',big_patient_list,patient_link_html);

	bpl_length=length(strip(big_patient_list));

	if eof then do;
		call symput('big_patient_list',strip(big_patient_list));
		call symput('bpl_length',strip(put(length(strip(big_patient_list)),best.)));
	end;
run;

data _null_;
	%if %eval(&bpl_length.)>32000 %then %do;
		** throw warn1ng to log if patient list is about to run out of room inside variable **;
		put "ER" "ROR: big_patient_list is about to be GT 32,000 characters and will cause fail.";
	%end;
run;

**********************************;
** Breakdown of patients to log **;
**********************************;
%macro see_patients;
	%put There are %cmpres(&num_patients.) patients.;
	%do i=1 %to &num_patients.;
		%put Patient &i. is &&patient&i..;
	%end;
%mend see_patients;
%see_patients;

***************************************************************************************************;
** get list of all reportable domains.  current approach may not work on anything but Windows OS **;
***************************************************************************************************;
proc format;
	value $domainord
	"INFCON_report_Informed Consent.sas" = 1
	"ELIG_report_Eligibility.sas"        = 2
	"DM_report_Demographics.sas"		 = 3
	"MH_report_Medical History.sas"		 = 4;
run;

filename tmp pipe "dir ""&macros.\*.sas"" /b /s";

data report_progs(keep=report_prog report_link num);
	infile tmp dlm='Z';
	length report_prog_ report_prog $2000;
	input report_prog_;
	if index(report_prog_,'report')>0;

	** program filename **;
	report_prog=reverse(scan(reverse(report_prog_),1,'\'));

	** program text tag, for link **;
	report_link=tranwrd(scan(report_prog,3,'_'),'.sas','');

	num=input(put(report_prog,$domainord.),best.);

	proc sort;
		by num;
run;

*************************************************************;
** put list of all reportable domains into macro variables **;
*************************************************************;
data _null_;
	set report_progs;
	by num;
	call symput('rpg'||strip(put(num,best.)),report_prog);
run;

proc sql noprint;
	select count(REPORT_PROG) into :num_domains trimmed from report_progs;
quit;

*****************************************************************;
** get list of domain names (from filenames) for sidebar links **;
*****************************************************************;
data report_links(keep=report_link_html);
	set report_progs end=eof;
	by num;

	if num=1 then report_link_html="<li><a href='#top'>Return to Top</a></li><br><li><a href='#IDX'>"||strip(report_link)||"</a></li>";
		else if eof then report_link_html="<li><a href='#IDX"||strip(put((num-1),best.))||"'>"||strip(report_link)||"</a></li><br><li><p>Data: &data_dt.</p></li><li><p>Profile: &today.</p></li><br><li><a href='#top'>Return to Top</a></li>";
		else report_link_html="<li><a href='#IDX"||strip(put((num-1),best.))||"'>"||strip(report_link)||"</a></li>";
run;

data _null_;
	set report_links end=eof;
	length big_link_list $3000;
	retain big_link_list;
	big_link_list=catx(' ',big_link_list,report_link_html);
	if eof then call symput('big_link_list',strip(big_link_list));
run;

********************************************;
** breakdown of reportable domains to log **;
********************************************;
%macro see_domains;
	%put There are %cmpres(&num_domains.) reportable domains.;
	%do i=1 %to &num_domains.;
		%put Domain &i. is &&rpg&i..;
	%end;

	proc sql noprint;
		drop table patient_list;
		drop table report_progs;
	quit;
%mend see_domains;
%see_domains;

*************************************************************************;
** number of observations in a dataset for each patient, for debugging **;
*************************************************************************;
%macro nobs(dsn);
	%symdel nobs / nowarn;
	%global nobs nobs_&dsn.;
	%let dsid=%sysfunc(open(&dsn.));
	%let nobs=%sysfunc(attrn(&dsid.,nlobs));
	%let nobs_&dsn.=%sysfunc(attrn(&dsid.,nlobs));
	%let rc=%sysfunc(close(&dsid.));
	%if %symexist(p)=1 %then %do;
		%put Patient &PTN. has %cmpres(&nobs.) records in dataset &dsn., &&rpg&p..;
	%end;
		%else %do;
			%put Patient &PTN. has %cmpres(&nobs.) records in dataset &dsn.;
		%end;
%mend nobs;

%macro empty(dsn);
	%if &&nobs_&dsn..=0 %then %do;
		data &dsn.;
			merge &dsn. empty;
		run;
	%end;
%mend empty;

***************************************************;
** loop through patients and reportable domains. **;
***************************************************;
options mprint mlogic symbolgen;
%macro patients_domains(spt=,ept=,spn=,epn=);
	options ls=119;
	%if &spt=  %then %let spt=1;
	%if &ept=  %then %let ept=&num_domains.;
	%if &spn=  %then %let spn=1;
	%if &epn=  %then %let epn=&num_domains.;

	ods listing close;

	** loop through each patient individually **;
	%macro patients;
		options missing='' ls=119;

		%do ii=&spt. %to &ept.;
			%let PTN=&&patient&ii..;
			%put PTN=&ptn.;
			
			** general ODS options **;
			ods noresults; ** disables ODS tracking, and output is not sent to the results window;
			ods noproctitle; ** removes all procedure titles;
			options nobyline; ** avoids printing BY lines above each BY group;
			options nofontembedding; ** output files will rely on the fonts being installed on the computer used to view or print the font;
			ods _all_ close;
			goptions reset=all;

			%if &machine.=SERVER %then %do;
			%end;
				%else %if &machine.=USER %then %do;
					ods html5 nogtitle nogfootnote 
						options(svg_mode='inline')
						base="&output."
						path="&output."(url=none)
						gpath="&output."(url=none)
						contents="&PTN._c.htm"
						frame="&PTN._f.htm"
						body="&PTN._.htm"
						stylesheet=(URL="..\programs\assets\stylesheets\main_grid.css?Rev=&now."); ** make sure latest file is grabbed, not from cache **;
						*metatext='charset="utf-8" content="IE=edge"';
					ods graphics / outputfmt=svg imagemap=on;
				%end;

			*******************************************;
			** insert the patient number into titles **;
			*******************************************;
			data _null_;
				call symput("ptn_title","Patient &PTN.");
			run;

			** loop through each reportable domain individually **;
			%macro domains;
				%do p=&spn. %to &epn.;
					options missing='';
					%include "&macros.\&&rpg&p.." / nosource2;
					options missing='.';
				%end;
			%mend domains;
			%domains;

			%if &machine.=SERVER %then %do;
			%end;
				%else %if &machine.=USER %then %do;
					ods html5 close;
					ods results;
				%end;

			options notes;

			*************************************************************************;
			** read in complete HTML file for patient, insert HTML code for header **;
			** must write to new file, otherwise pre-existing code overwritten     **;
			*************************************************************************;
			data _null_;
				infile "&output.\&PTN._.htm" sharebuffers;
				file "&output.\&PTN..htm";
				input;

				_infile_=tranwrd(_infile_,'</head>','<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900"></head>');

				_infile_=tranwrd(_infile_,'<body class="body">','<body class="body">
					<!------------>                    
					<!-- HEADER -->                    
					<!------------>          
						<nav class="header-outnav">                     
							<a href=".\index.html">studies</a>                                    
							<a href=".\patients-bos-580-201.html">patients</a>
							<a href="C:\Users\markw.consultant\_projects\BOS-580-201\adhoc\output\BOS-580-201_QSR.htm">qsr</a>    
							<a href="https://bostonpharmaceuticals.sharepoint.com/580/AL/Forms/AllItems.aspx?FolderCTID=0x0120003DD49E81655FF240BC77BC321704F50F&viewid=a7471443%2De483%2D4894%2D8e59%2D2a205d9d319a&id=%2F580%2FAL%2FClinical%2FStudy%20BOS580%2D201%2FProtocols" target="_blank">protocol</a> 
							<a href="https://bostonpharmaceuticals.sharepoint.com/580/AL/Forms/AllItems.aspx?FolderCTID=0x0120003DD49E81655FF240BC77BC321704F50F&viewid=a7471443%2De483%2D4894%2D8e59%2D2a205d9d319a&id=%2F580%2FAL%2FClinical%2FStudy%20BOS580%2D201%2FData%5FMgmt%2FCRFs" target="_blank">crf</a>                          
						</nav>

						<div class="header-logo logo">                           
							<a class="logo" href="https://bostonpharmaceuticals.sharepoint.com/Pages/Home.aspx">                                
								<img src="..\programs\assets\images\bp-logo-white.png" alt="Company Logo">                            
							</a>                   
						</div>

						<div class="header-title">
							<h2 class="tagline">BOS-580-201-dummy Patient Profile</h2>
							<div class="progress-container">
								<div class="progress-bar" id="ProgBar"></div>
							</div> 
							<div class="space-under-progress-bar"></div>
						</div>

						<div class="patients-toggle">
							<a href="#" onclick="return false;" class="js-navigation" aria-haspopup="true" aria-owns="patient-sidebar" aria-expanded="false">&#9776;Patients</a>
						</div>     

					<!-------------------->                    
					<!-- DOMAIN SIDEBAR -->                    
					<!-------------------->  
						<div class="domain-sidebar" id="sub-header">
							<ul>'||"&big_link_list."||'</ul>
						</div>   

					<!--------------------->                    
					<!-- PATIENT SIDEBAR -->                    
					<!--------------------->                    
						<nav class="patient-sidebar js-nav" id="patient-sidebar" aria-hidden="true">  
							<ul>'||"&big_patient_list."||'</ul>
						</nav> 

					<div class="fromsas">
					<br>');

				** remove the unneeded c and b **;
				_infile_=tranwrd(_infile_,'th class="c ','th class="');
				_infile_=tranwrd(_infile_,'td class="c ','td class="');
				_infile_=tranwrd(_infile_,'span class="c ','span class="');
				_infile_=tranwrd(_infile_,'th class="b ','th class="');
				_infile_=tranwrd(_infile_,'td class="b ','td class="');
				_infile_=tranwrd(_infile_,'span class="b ','span class="');

				** when user specifies class, add back in default 'header' and 'data' classes as well **;
				if index(_infile_,'th class="')>0 and index(_infile_,'header')=0 then _infile_=tranwrd(_infile_,'th class="','th class="header ');
				if index(_infile_,'td class="')>0 and index(_infile_,'data')=0 and index(_infile_,'domain-title')=0 then _infile_=tranwrd(_infile_,'td class="','td class="data ');

				** for certain column headers, do not apply class to <td>, only <th> **;
				if index(_infile_,'td class="')>0 and index(_infile_,'overline')=0 then _infile_=tranwrd(_infile_,'overline',' ');
				if index(_infile_,'td class="')>0 and index(_infile_,'created')=0 then _infile_=tranwrd(_infile_,'created',' ');

				** avoid hard breaks on hyphens **;
				_infile_=tranwrd(_infile_,'12-','12&#8209;');
				_infile_=tranwrd(_infile_,'Gamma-','Gamma&#8209;');
				_infile_=tranwrd(_infile_,'Life-','Life&#8209;');
				_infile_=tranwrd(_infile_,'gastro-','gastro&#8209;');
				_infile_=tranwrd(_infile_,'Non-','Non&#8209;');
				_infile_=tranwrd(_infile_,'Day 22-28','Day 22&#8209;28');
				_infile_=tranwrd(_infile_,'Non-CR / Non-PD','Non&#8209;CR / Non&#8209;PD');
				_infile_=tranwrd(_infile_,'PARA-HILAR','PARA&#8209;HILAR');
				_infile_=tranwrd(_infile_,'T-WAVE','T&#8209;WAVE');
				*if index(_infile_,'702-0001')>0 and index(_infile_,'SUBJECTS')>0 then _infile_=tranwrd(_infile_,'702-0001','702&#8209;*0001');

				** for graphs generated by GTL, re-set classes to work with CSS **;
				_infile_=tranwrd(_infile_,'class="systemtitle"','class="domain-title"');
				_infile_=tranwrd(_infile_,'class="systemfooter"','class="footnote"');
				_infile_=tranwrd(_infile_,'class="systemfooter2"','class="footnote"');
				_infile_=tranwrd(_infile_,'class="systemfooter3"','class="footnote"');

				** replace patient number in titles **;
				_infile_=tranwrd(_infile_,'dummy Patient Profile',"&PTN. Patient Profile");

				** print +/- symbol **;
				if index(_infile_,'_PLUSMINUS_')>0 then _infile_=tranwrd(_infile_,'_PLUSMINUS_',' &plusmn; ');

				** force breaks in proc report **;
				if index(_infile_,'frcbrk')>0 then _infile_=tranwrd(_infile_,'frcbrk','<br>');

				** add javascript for adding classes to elements upon clicking **;
				_infile_=tranwrd(_infile_,'</body>',
					'<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
					 <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
					 <script src="..\programs\assets\js\js-navigation.js"></script>
					 <script src="..\programs\assets\js\progress-bar.js"></script>
					 <script src="..\programs\assets\js\toggle-mh.js"></script>
					 <script src="..\programs\assets\js\ecg_dt.js"></script>
					 <script src="..\programs\assets\js\tstnamddh.js"></script>
					 <script src="..\programs\assets\js\lbh_dt.js"></script>
					 </body>');  

				** when bolding Yes, make sure No is not bolded **;
				if index(_infile_,'class="data yes"')>0 and index(_infile_,'>No')>0 then _infile_=tranwrd(_infile_,'class="data yes"','class="data"');

				** AE/Med Timeline footnotes **;
				_infile_=tranwrd(_infile_,'add-no-data</span> </p>',
										  '</span> </p><p><span class="footnote">No data for this patient/domain.</span></p>');
				_infile_=tranwrd(_infile_,'add-no-plottable-data</span> </p>',
										  '</span> </p><p><span class="footnote">No valid plottable values for this patient/domain.</span></p>');
				_infile_=tranwrd(_infile_,'add-no-dosing-data</span> </p>',
										  '</span> </p><p><span class="footnote-no-indent">AE/CM data exists, but cannot plot by relative study day until dosing information is entered.</span></p>');
				_infile_=tranwrd(_infile_,'add-only-prior-data</span> </p>',
										  '</span> </p><p><span class="footnote-no-indent">AE/CM data exists, but outside of the plot area.  Only AEs and Meds after study day -42 will be plotted.  See AE and CM prints for detail.</span></p>');

				** offset anchors below sticky header by adding a new anchor and offset **;
				_infile_=tranwrd(_infile_,'<div id="IDX"','<span class="anchor" id="IDX"></span><div id="_IDX"');
				%macro offset_anchors;
					%do i=0 %to 100;
						_infile_=tranwrd(_infile_,%unquote(%nrbquote('<div id="IDX&i."')),%unquote(%nrbquote('<span class="anchor" id="IDX&i."></span><div id="_IDX&i."')));
					%end;
				%mend offset_anchors;
				%offset_anchors;	
/*
				***********************************************;
				** FROZEN COLUMNS TITLES MUST SPAN CORRECTLY **;
				***********************************************;
				** for domains with frozen columns, must make sure title only spans as many columns as necessary, to stick correctly.  this is now automatic. **;
				** for domains with frozen columns, must add a table container div, and a closing div for it.  manual component below. **;
				** for this study, use the NUM value above created via format **;
				span_loc=.;
				colspan=.;
				colspan_rmn=.;
				%macro frozen_columns(idx=,key_good=,key_bad=,colspan_frz=,);
					if index(_infile_,'td class="fixed-domain-title')>0 and index(_infile_,"&key_good.")>0 %if &key_bad.^=  %then %do; and index(_infile_,"&key_bad.")=0 %end; then do;
						span_loc=find(_infile_,'colspan="');
						if span_loc>0 then do;
							colspan=input(strip(scan(substr(_infile_,span_loc+9),1,'"')),best.);
							if colspan=. then colspan=0;
							if colspan>.z and %eval(&colspan_frz.)>.z then colspan_rmn=colspan-&colspan_frz.;
								else colspan_rmn=0;
							_infile_=tranwrd(_infile_,'colspan="'||strip(put(colspan,best.)),'colspan="'||strip(put(%eval(&colspan_frz.),best.)));
							_infile_=tranwrd(_infile_,'</td>','</td><td class="domain-title" style="white-space: pre" colspan="'||strip(put(colspan_rmn,best.))||'"></td>');
						end;
					end;
					_infile_=tranwrd(_infile_,%unquote(%nrbquote('</table></div></div></div></div><div style="padding-bottom: 8px; padding-top: 1px"><hr class="pagebreak"/><span class="anchor" id="IDX&idx.">')),%unquote(%nrbquote('</table></div></div></div></div></div><div style="padding-bottom: 8px; padding-top: 1px"><hr class="pagebreak"/><span class="anchor" id="IDX&idx.">')));
					_infile_=tranwrd(_infile_,%unquote(%nrbquote('id="_IDX%eval(&idx.-1)" style="padding-bottom: 8px; padding-top: 1px">')),%unquote(%nrbquote('id="_IDX%eval(&idx.-1)" style="padding-bottom: 8px; padding-top: 1px"><div class="table-container">')));
				%mend frozen_columns;
				%frozen_columns(idx=5, key_good=%str(>Unscheduled),key_bad=,colspan_frz=4);
				%frozen_columns(idx=10, key_good=%str(>Prior&#160;Cancer&#160;Therapy),key_bad=,colspan_frz=6);
				%frozen_columns(idx=19, key_good=%str(>Adverse),key_bad=,colspan_frz=6);
				%frozen_columns(idx=20, key_good=%str(>Concomitant),key_bad=,colspan_frz=6);
				%frozen_columns(idx=42, key_good=%str(>Electrocardiogram),key_bad=,colspan_frz=3);
				%frozen_columns(idx=44, key_good=%str(>Target),key_bad=Non,colspan_frz=8);
				%frozen_columns(idx=45, key_good=%str(>Non-),key_bad=,colspan_frz=6);
				%frozen_columns(idx=46, key_good=%str(>Response),key_bad=,colspan_frz=11);
				%frozen_columns(idx=48, key_good=%str(>Protocol),key_bad=,colspan_frz=3);
*/
/*
				*************************;
				** TOGGLING of columns **;
				*************************;
				** MH coding toggling **;
				if index(_infile_,'Medical')>0 and index(_infile_,'History</td>')>0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'History</td>','History<button class="toggle-button" id="toggle-mh" onclick="textMH()">Show Coding</button></td>');
				
				** PCT coding toggling **;
				if index(_infile_,'Prior')>0 and index(_infile_,'Cancer') and index(_infile_,'Therapy</td>')>0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'Therapy</td>','Therapy<button class="toggle-button" id="toggle-pct" onclick="textPCT()">Show Coding</button></td>');
				
				** CM coding toggling **;
				if index(_infile_,'Concomitant')>0 and index(_infile_,'Medications</td>')>0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'Medications</td>','Medications<button class="toggle-button" id="toggle-cm" onclick="textCM()">Show Coding</button></td>');
				
				** AE coding toggling **;
				if index(_infile_,'Adverse')>0 and index(_infile_,'Events</td>')>0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'Events</td>','Events<button class="toggle-button" id="toggle-ae" onclick="textAE()">Show Coding</button></td>');
				
				** TL toggle only measurements **;
				if index(_infile_,'Target')>0 and index(_infile_,'Lesion')>0 and index(_infile_,'Assessments</td>')>0 and index(_infile_,'Non')=0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'Assessments</td>','Assessments<button class="toggle-button" id="toggle-tl" onclick="textTL()">Show Only Measurements</button></td>');

				** RS toggle only investigator responses **;
				if index(_infile_,'Response')>0 and index(_infile_,'Summary')>0 and index(_infile_,'1.1</td>')>0 and index(_infile_,'domain-title')>0 then _infile_=tranwrd(_infile_,'1.1</td>','1.1<button class="toggle-button" id="toggle-rs" onclick="textRS()">Show Only Investigator Responses</button></td>');
*/

/*
				***************;
				** FOOTNOTES **;
				***************;
				** DM - Demographics **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">dm-footnote</span> </p>'
					,'<p><span class="footnote">Note: Ages <18 are highlighted in <span class="red-footnote">red</span>, as this was an inclusion criteria.</span> </p>');

				** TL - Target Lesion **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">tl-footnote</span> </p>',
					'<p><span class="footnote-num">SUPER1 LD = Longest Diameter, SAD = Short Axis Diameter (Nodes Only).</span><br><span class="footnote-num">SUPER2 Sum is calculated within clinical database.  Sum is checked against an independently calculated sum of measurements.  Incorrect values will be flaged in <span class="red-footnote">red</span>, and correct values will have a check mark (checkmark).  When a patient has any incorrect sums, an additional column showing the independently calculated sums will appear.</span></span></p>');

				** RS - Response **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">rs-footnote</span> </p>',
					'<p><span class="footnote">Note: <span class="green-footnote">Green</span> column headers indicate the column was programmatically created.  Target, Non-Target, and Overall responses are calculated independently and compared to the Investigator responses.  When they match, a check mark will be placed next to the Investigator response.  When they do not match, the Investigator response will be highlighted in <span class="red-footnote">red</span>, and an additional column showing the independently programmed response will appear, with a <span class="green-footnote">green</span> header.</span></span></p>');

				** VD - Visit Dates **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">vd-footnote</span> </p>',
					'<p><span class="footnote">Note: <span class="green-footnote">Green</span> column headers indicate the column was programmatically created.  <span class="red-footnote">Red</span> cells indicate visit occurred outside of protocol-defined window.</span> </p>');

				** HTWT - Height and Weight **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">htwt-footnote</span> </p>',
					'<p><span class="footnote-num">SUPER1 Screening/Baseline records are from the Height and Weight CRF, post-Screening/Baseline records are from the Weight CRF.</span></p>');

				** VS - Vital Signs **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">vs-footnote</span> </p>'
					,'<p><span class="footnote-num">SUPER1 For temperature, <span class="red-footnote">red</span> flags values outside the normal range of >35 - <38 &#176;C</span><br><span class="footnote-num">SUPER2 For pulse, <span class="red-footnote">red</span> flags values outside the normal range of 60 - 100 beats/min.</span><br><span class="footnote-num">SUPER3 For blood pressure, colors flag CTCAE Grades of Hypertension: <span class="yellow-footnote">yellow</span> = Grade 1 (&#8805;120 - <140 systolic, &#8805;80 - <90 diastolic), <span class="orange-footnote">orange</span> = Grade 2 (&#8805;140 - <160 systolic, &#8805;90 - <100 diastolic), <span class="red-footnote">red</span> = Grade 3 (&#8805;160 systolic, &#8805;100 diastolic).</span></p>');

				** VSPLOT - Vital Signs Plots **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">vsplot-footnote</span> </p>'
					,'<p><span class="footnote">Note: For temperature, <span class="red-footnote">red</span> flags values outside the normal range of >35 - <38 &#176;C.<br>For pulse, <span class="red-footnote">red</span> flags values outside the normal range of 60 - 100 beats/min.<br>For blood pressure, colors flag CTCAE Grades of Hypertension: <span class="yellow-footnote">yellow</span> = Grade 1 (&#8805;120 - <140 systolic, &#8805;80 - <90 diastolic), <span class="orange-footnote">orange</span> = Grade 2 (&#8805;140 - <160 systolic, &#8805;90 - <100 diastolic), <span class="red-footnote">red</span> = Grade 3 (&#8805;160 systolic, &#8805;100 diastolic).</span></p>');

				** ECG - Electrocardiogram **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">ecg-footnote</span> </p>'
					,'<p><span class="footnote-num">SUPER1 QTcF (msec) values >470 at Screening/Baseline are highlighted in <span class="red-footnote">red</span>, as this was an inclusion criteria.</span><br><span class="footnote-num">SUPER2 NCS = Not Clinically Significant, CS = Clinically Significant.  CS Interpretations will be highlighted in <span class="red-footnote">red.</span></span> </p>');

				** ECGPLOT - Electrocardiogram Plots **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">ecgplot-footnote</span> </p>'
					,'<p><span class="footnote">Note: QTcF (msec) values >470 at Screening/Baseline are highlighted in <span class="red-footnote">red</span>, as this was an inclusion criteria.<br>Timepoints with an interpretation of "Abnormal, Clinically Significant" will have all values at that timepoint highlighted in <span class="red-footnote">red.</span></span></p>');

				** SCT - Subsequent Cancer Therapy **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">sct-footnote</span> </p>'
					,'<p><span class="footnote-num">SUPER1 Treatment: WHODrug Anatomical Main Group/Product Name.<br>Surgery: MedDRA Body System/Preferred Term.</span></p>');

				** LBPLOTH - Labs - Hema Plots **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">lbploth-footnote</span> </p>',
					'<p><span class="footnote">Note:</span> <span class="footnote" style="color: #add8e6">Blue bands</span> <span class="footnote" style="color: #ffffff">indicate normal ranges.  Values outside those ranges are <span class="red-footnote">red</span>.</span></p>');

				** AE - Adverse Events **;
				_infile_=tranwrd(_infile_,'<p><span class="footnote">ae-footnote</span> </p>'
					,"<p><span class='footnote-num'>SUPER1 These fields are from an SAE Summary spreadsheet, delivered monthly.  Current version is &sae_date.</span> </p>");
*/

/*
				****************************;
				** LAB DROPDOWN SELECTORS **;
				****************************;
				if index(_infile_,'Name-TSTNAMDDH')>0 then _infile_=tranwrd(_infile_,'Name-TSTNAMDDH',"Name<br>&tstnamddh.");
				if index(_infile_,'Name-TSTNAMDDC')>0 then _infile_=tranwrd(_infile_,'Name-TSTNAMDDC',"Name<br>&tstnamddc.");
				if index(_infile_,'Name-TSTNAMDDG')>0 then _infile_=tranwrd(_infile_,'Name-TSTNAMDDG',"Name<br>&tstnamddg.");
				if index(_infile_,'Name-TSTNAMDDU')>0 then _infile_=tranwrd(_infile_,'Name-TSTNAMDDU',"Name<br>&tstnamddu.");
				if index(_infile_,'<td class="')>0 and index(_infile_,'picklbnm')>0 then do;
					length test $100;
					test=lowcase(scan(compress(compress(tranwrd(scan(_infile_,2,'>'),'&#160;',''),''),')'),1,'<'));
					test=tranwrd(test,'(','-');
					test=tranwrd(test,'%','-');
					test=tranwrd(test,',','-');
					if index(test,'160')=0 and test not in ('','/td') then _infile_=tranwrd(_infile_,'class="','class=" '||strip(test)||" ");
				end;
*/

				** fix some special characters **;
				_infile_=tranwrd(_infile_,'GEGEGE','&#8805;');
				_infile_=tranwrd(_infile_,'checkmark','&#10004;');

				** handle superscripts **;
				_infile_=tranwrd(_infile_,'SUPER1','<sup>1</sup>');	
				_infile_=tranwrd(_infile_,'SUPER2','<sup>2</sup>');
				_infile_=tranwrd(_infile_,'SUPER3','<sup>3</sup>');
				_infile_=tranwrd(_infile_,'SUPER4','<sup>4</sup>');
				_infile_=tranwrd(_infile_,'SUPER5','<sup>5</sup>');

				put _infile_;
			run;

			** Need .aspx files for Sharepoint **;
			data _null_;
				infile "&output.\&PTN..htm" sharebuffers;
				file "&output.\aspx\&PTN..aspx";
				input;

				_infile_=tranwrd(_infile_,'C:\Users\markw.consultant\_projects\BOS-580-201\adhoc\output\BOS-580-201_QSR.htm',
							  'https://bostonpharmaceuticals.sharepoint.com/580/AL/Forms/AllItems.aspx?FolderCTID=0x0120003DD49E81655FF240BC77BC321704F50F&viewid=a7471443%2De483%2D4894%2D8e59%2D2a205d9d319a&id=%2F580%2FAL%2FClinical%2FStudy%20BOS580%2D201%2FData%5FMgmt%2FPatient%20Profiles%2Foutput/BOS-580-201.aspx');
				_infile_=tranwrd(_infile_,'.html','.aspx');	
				_infile_=tranwrd(_infile_,'.htm','.aspx');	

				put _infile_;
			run;

			*********************************************************************************************;
			** delete old file, and content/frame files, after HTML header code inserted into new file **;
			** this method should be OS-agnostic, as long as fileref is specified as an argument       **;
			*********************************************************************************************;
			%macro file_delete(file);
				filename old_file "&output.\&PTN._.htm";
				%put %sysfunc(fdelete(old_file));

				filename _c_file "&output.\&PTN._c.htm";
				%put %sysfunc(fdelete(_c_file));

				filename _f_file "&output.\&PTN._f.htm";
				%put %sysfunc(fdelete(_f_file));
			%mend file_delete;
			%file_delete;	
		%end;
	%mend patients;
	%patients;
	ods listing;
%mend patients_domains;
*%patients_domains(spt=1,ept=&num_patients.,spn=1,epn=&num_domains.);
%patients_domains(spt=1,ept=5,spn=1,epn=&num_domains.);

*******************************************;
** create patient list dashboard in HTML **;
*******************************************;
data _null_;
	infile "&programs.\patients-BOS-580-201_frame.html" sharebuffers;
	file "&output.\patients-BOS-580-201.html";
	input;

	_infile_=tranwrd(_infile_,'DUMMYPATIENTCARDLIST1',"&big_patient_cards_list1.");
	_infile_=tranwrd(_infile_,'DUMMYPATIENTCARDLIST2',"&big_patient_cards_list2.");
	_infile_=tranwrd(_infile_,'DUMMYPATIENTCARDLIST3',"&big_patient_cards_list3.");
	_infile_=tranwrd(_infile_,'DUMMYPATIENTCARDLIST4',"&big_patient_cards_list4."); 
	_infile_=tranwrd(_infile_,'<h1>BOS-580-201 Patients</h1>',"<h1>BOS-580-201 Patients - Data as of &data_dt.</h1>");	
	_infile_=tranwrd(_infile_,'stylesheets\main.css',"stylesheets\main.css?Rev=&now.");

	put _infile_;
run;

*******************************************;
** create patient list dashboard in ASPX **;
*******************************************;
data _null_;
	infile "&output.\patients-BOS-580-201.html" sharebuffers;
	file "&output.\aspx\patients-BOS-580-201.aspx";
	input;

	_infile_=tranwrd(_infile_,'C:\Users\markw.consultant\_projects\BOS-580-201\adhoc\output\BOS-580-201_QSR.htm',
							  'https://bostonpharmaceuticals.sharepoint.com/580/AL/Forms/AllItems.aspx?FolderCTID=0x0120003DD49E81655FF240BC77BC321704F50F&viewid=a7471443%2De483%2D4894%2D8e59%2D2a205d9d319a&id=%2F580%2FAL%2FClinical%2FStudy%20BOS580%2D201%2FData%5FMgmt%2FPatient%20Profiles%2Foutput/BOS-580-201_QSR.aspx');
	_infile_=tranwrd(_infile_,'.html','.aspx');	
	_infile_=tranwrd(_infile_,'.htm','.aspx');	

	put _infile_;
run;

***************************************************************;
** record program end time, and print duration of run to log **;
***************************************************************;
data _null_;
	x=time();
	y=put(x,time8.);
	call symput('endtm',y);
run;

%put Program started at &starttm. and ended at &endtm.;
