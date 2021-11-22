/*****************************************************************************************/
* Program Name  : AE_listing_Listing of Adverse Events.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-19
* Description   : report AEs in a listing
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ae;
run;

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column ("AEL1FX" subnum) aespid ("AEL2FX" aenone_aespid) ae_flag ("AEL3FX" coding) start stop aesi_aeisr aeout_aesev aeacn_ aerel_aeser
			      ("SAE, check all that applySPNHDRFRCNDRLNCNTR" sae_hosp aeslife aesdisab aescong aesmie) aesdth_;
		define subnum        /order order=internal "Patient" style=[htmlclass='fixed aelfixed1 patient-link ae'];
		define aespid        /order order=internal noprint;
		define aenone_aespid /display "AE#" style=[htmlclass='fixed aelfixed2'];
		define ae_flag       /display noprint;
		define coding        /display "Adverse Event/|SOC/PT" style=[htmlclass='fixed aelfixed3 max-width-4-0'];
		define start         /display "Start Date/|Start Time" style=[htmlclass='min-width-1-0'];
		define stop          /display "Stop Date/|Stop Time" style=[htmlclass='min-width-1-0'];
		define aesi_aeisr    /display "AESI?|ISR?";
		define aeout_aesev   /display "Outcome/|Severity";
		define aeacn_        /display "Action w/ Drug/|Action w/ Subject";
		define aerel_aeser   /display "Rel. to Drug/|Serious?";
		define sae_hosp      /display "Req. or Prol.|Hosp., Dates";
		define aeslife       /display "Life|Threat.";
		define aesdisab      /display "Disab. or|Incap.";
		define aescong       /display "CA or|Birth Def.";
		define aesmie        /display "Other|MIE";
		define aesdth_       /display "Death/|Death Date";

		footnote "ae-footnote";

		compute coding;
			if ae_flag=1 then call define(_col_,"style/merge","style=[background=yellow");
		endcomp;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Adverse Events";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
