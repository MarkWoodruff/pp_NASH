/*****************************************************************************************/
* Program Name  : ECGPLOT_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-11
* Description   : build temporary dataset for ECGPLOT domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

%include "&macros.\ECG_build.sas";
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

data ecgplot;
	merge rfstdt
		  pp_final_ecg(in=inv where=(egnd=''));
	by subnum;
	if inv;

	format egdat yymmdd10.;

	if egdat>=rfstdt>.z then ecgdy=(egdat-rfstdt)+1;
		else if rfstdt>egdat>.z then ecgdy=(egdat-rfstdt);		
run;

proc format;
	value ecgpaneln
	1="Heart Rate"
	2="QT Interval"
	3="PR Interval"
	4="QRS Interval"
	5="RR Interval"
	6="QTcF";
run;

data ecgplot;
	set ecgplot;

	if eghr>.z and ^(45<eghr<90) then put "ER" "ROR: update ECGPLOT_build.sas for HR ranges" SUBNUM=;
	if egqt>.z and ^(330<egqt<480) then put "ER" "ROR: update VSPLOT_build.sas for QT ranges" SUBNUM=;
	if egpr>.z and ^(110<egpr<215) then put "ER" "ROR: update VSPLOT_build.sas for PR ranges" SUBNUM=;
	if egqrs>.z and ^(-65<egqrs<130) then put "ER" "ROR: update VSPLOT_build.sas for QRS ranges" SUBNUM=;
	if egrr>.z and ^(0<egrr<1200) then put "ER" "ROR: update VSPLOT_build.sas for RR ranges" SUBNUM=;
	if egqtcf>.z and ^(350<egqtcf<470) then put "ER" "ROR: update VSPLOT_build.sas for QTcF ranges" SUBNUM=;
	
	format paneln ecgpaneln.;
	%macro transpose(paneln=,varin=,low=,high=);
	valuen_low=.;
	valuen_high=.;
	if &varin.>.z then do;
		paneln=&paneln.;
		valuen=&varin.;
		valuen_low=&low.;
		valuen_high=&high.;
		output;
	end;
	%mend transpose;
	%transpose(paneln=1,varin=eghr,  low=45,high=90);
	%transpose(paneln=2,varin=egqt,  low=330,high=480);
	%transpose(paneln=3,varin=egpr,  low=110,high=215);
	%transpose(paneln=4,varin=egqrs, low=-65,high=130);
	%transpose(paneln=5,varin=egrr,  low=0,high=1200);
	%transpose(paneln=6,varin=egqtcf,low=350,high=470);
run;

data pp_final_ecgplot;
	set ecgplot;

	if paneln=6 then do;
		if 450<egqtcf<=480 then valuen_abn_y=valuen;
			else if 480<egqtcf<=500 then valuen_abn_o=valuen;
			else if 500<egqtcf then valuen_abn_r=valuen;
	end;

	** labels for tooltips **;
	label visname='Visit'
		  egnd='Not Done'
		  egnd_reas='Reason Not Done'
		  egdat_c='Date Performed'
		  egtims_c='Start Time Supine Position'
		  egtim_c='Time Performed'
		  eghr_c='Heart Rate'
		  egqt_c='QT Interval'
		  egpr_c='PR Interval'
		  egqrs_c='QRS Interval'
		  egrr_c='RR Interval'
		  egqtcf_c='QTcF'
		  egorres_c='Results, Specify';
run;