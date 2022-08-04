/*****************************************************************************************/
* Program Name  : VS_report_Vital Signs.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : report Vital Signs domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ip;
run;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
