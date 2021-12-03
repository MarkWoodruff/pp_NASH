/*****************************************************************************************/
* Program Name  : Check_MELD_scores.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-16
* Description   : check MELD scores
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

** From LabConnect OSD **;
** MELD(i) = 0.957 × ln(Cr) + 0.378 × ln(bilirubin) + 1.120 × ln(INR) + 0.643);

** From Wiki **;
** MELD = 3.78×ln[serum bilirubin (mg/dL)] + 11.2×ln[INR] + 9.57×ln[serum creatinine (mg/dL)] + 6.43;

* From paper;
** MELD = 9.57 × loge (Cr mg/dL) + 3.78 × loge (bili mg/dL) + 11.20 × loge (INR) + 6.43;

data lbx;
	set crf.lbx(encoding=any where=(pagename='Lab Results' and deleted='f'));

	%macro c_to_n(var=);
		if index(&var.,'<')>0 then &var.n=input(strip(substr(&var.,index(&var.,'<')+1)),best.);
			else if index(&var.,'>')>0 then &var.n=input(strip(substr(&var.,index(&var.,'>')+1)),best.);
			else if anyalpha(&var.)=0 and index(&var.,':')=0 then &var.n=input(strip(&var.),best.);
	%mend c_to_n;
	%c_to_n(var=lborres);
run;

%macro tests(test=);
	data lbx_&test.(keep=subnum lbdat &test. visit);
		set lbx(where=(lbtestcd="&test."));
		&test.=lborresn;

		proc sort;
			by subnum visit lbdat;
	run;

	data lbx_&test.;
		set lbx_&test.;
		by subnum visit lbdat;
		if last.visit;
	run;
%mend tests;
%tests(test=INR);
%tests(test=BILI);
%tests(test=CREAT);

data screening;
	merge lbx_inr
		  lbx_bili
		  lbx_creat;
	by subnum visit;
run;

data screening;
	set screening;

	%macro adj(var=);
		if &var.>.z and &var.<1 then &var._adj=1;
			else &var._adj=&var.;

		log_&var._adj=log(&var._adj);

		log_&var.=log(&var.);
	%mend adj;
	%adj(var=creat);
	%adj(var=bili);
	%adj(var=inr);

	if log_creat>.z and log_bili>.z and log_inr>.z then meld_osd=(0.957*log_creat) + (0.378*log_bili) + (1.120*log_INR) + 0.643;
	if log_creat_adj>.z and log_bili_adj>.z and log_inr_adj>.z then meld_paper=round(((9.57*log_creat_adj) + (3.78*log_bili_adj) + (11.20*log_INR_adj) + 6.43),1);
run;

proc print width=min;
	*where subnum='110-001';
	*where subnum='106-016';
	var	subnum visit inr creat bili meld_paper;
	where meld_osd>.z;
run;
