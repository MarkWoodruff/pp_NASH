/*****************************************************************************************/
* Program Name  : VSPLOT_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-10
* Description   : build temporary dataset for VSPLOT domain
*
* Revision History
* Date       By            Description of Change
* 2021-11-29 Mark Woodruff update note to log for RR to not include 10.
******************************************************************************************;

%include "&macros.\VS_build.sas";
%include "&macros.\EX_build.sas";

** get RFSTDT **;
proc sort data=pp_final_ex out=rfstdt;
	by subnum exstdat;
	where exstdat>.z and exyn_dec='Yes';
run;

data rfstdt(keep=subnum rfstdt);
	set rfstdt;
	by subnum exstdat;
	if first.subnum;

	format rfstdt yymmdd10.;
	rfstdt=exstdat;
run;

data vsplot;
	merge rfstdt
		  pp_final_vs(in=inv where=(vsnd=''));
	by subnum;
	if inv;

	format vsdat yymmdd10.;

	if vsdat>=rfstdt>.z then vsdy=(vsdat-rfstdt)+1;
		else if rfstdt>vsdat>.z then vsdy=(vsdat-rfstdt);		
run;

proc format;
	value vspaneln
	1="Pulse (bpm)"
	2="Resp. (brpm)"
	3="Temp. (°C)"
	4="Syst. Avg. (mmHg)"
	5="Dias. Avg. (mmHg)";
run;

data vsplot;
	set vsplot;

	if hrn>.z and ^(50<hrn<105) then put "ER" "ROR: update VSPLOT_build.sas for HR ranges" SUBNUM=;
	if rrn>.z and ^(10<=rrn<25) then put "ER" "ROR: update VSPLOT_build.sas for RR ranges" SUBNUM= rrn= rr=;
	if tempn_std>.z and ^(30<tempn_std<40) then put "ER" "ROR: update VSPLOT_build.sas for Temp ranges" SUBNUM=;
	if bp_avg_sysn>.z and ^(80<bp_avg_sysn<210) then put "ER" "ROR: update VSPLOT_build.sas for Systolic ranges" SUBNUM=;
	if bp_avg_dian>.z and ^(50<bp_avg_dian<120) then put "ER" "ROR: update VSPLOT_build.sas for Diastolic ranges" SUBNUM=;
	
	format paneln vspaneln.;
	%macro transpose(paneln=,varin=,low=,high=,nr_low=,nr_high=);
	valuen_low=.;
	valuen_high=.;
	nr_low=.;
	nr_high=.;
	if &varin.>.z then do;
		paneln=&paneln.;
		valuen=&varin.;
		valuen_low=&low.;
		valuen_high=&high.;
		nr_low=&nr_low.;
		nr_high=&nr_high.;
		output;
	end;
	%mend transpose;
	%transpose(paneln=1,varin=hrn,        low=50,high=105,nr_low=60,nr_high=100);
	%transpose(paneln=2,varin=rrn,        low=10,high=25, nr_low=10,nr_high=10);
	%transpose(paneln=3,varin=tempn_std,  low=30,high=40, nr_low=35,nr_high=38);
	%transpose(paneln=4,varin=bp_avg_sysn,low=80,high=210,nr_low=80,nr_high=120);
	%transpose(paneln=5,varin=bp_avg_dian,low=50,high=120,nr_low=50,nr_high=80);
run;

data pp_final_vsplot;
	set vsplot;

	** Pulse (Heart Rate) grading **;
	if paneln=1 then do;
		if .z<valuen<60 or valuen>100 then valuen_abn_r=valuen;
	end;

	** Temp grading **;
	if paneln=3 then do;
		if .z<valuen<35 or valuen>38 then valuen_abn_r=valuen;
	end;

	if paneln=4 then do;
		if 120<=valuen<140 then valuen_abn_y=valuen;
			else if 140<=valuen<160 then valuen_abn_o=valuen;
			else if 160<=valuen then valuen_abn_r=valuen;
	end;

	if paneln=5 then do;
		if 80<=valuen<90 then valuen_abn_y=valuen;
			else if 90<=valuen<100 then valuen_abn_o=valuen;
			else if 100<=valuen then valuen_abn_r=valuen;
	end;

	** labels for tooltips **;
	label RFSTDT='First Dose Date'
		  VISNAME='Visit'
		  VSND='Not Done'
		  vsreasnd1='Reason Not Done'
		  VSDAT_C='Date'
		  VSDY='Study Day'
		  VSPOS='Position'
		  VSTIMP_C='Start Time in Position'
		  VSTIM1_C='Time Assessed'
		  HR='Heart Rate'
		  RR='Respiratory Rate'
		  TEMP='Temperature'
		  VSTEMPL_DEC='Temp. Location'
		  BP1_SYS='Systolic Value #1'
		  BP1_DIA='Diastolic Value #1'
		  BP2_SYS='Systolic Value #1' 
		  BP2_DIA='Diastolic Value #2'  
		  BP3_SYS='Systolic Value #1' 
		  BP3_DIA='Diastolic Value #3' 
		  BP_AVG_SYS='Systolic Value Average' 
		  BP_AVG_DIA='Diastolic Value Average';
run;
