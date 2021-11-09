/*****************************************************************************************/
* Program Name  : ConvertLabsToXLSX.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-08
* Description   : add labs to Excel
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

data lbx;
	set crf.lbx(encoding=any);
run;

********************;
** Excel Listings **;
********************;
ods _all_ close;
ods excel file="&output./BOS-580-201_LBX.xlsx" 

	options(frozen_headers='YES'
   					  autofilter='ALL'
   					  sheet_interval='NOW'
   					  flow="tables"
					  sheet_name="LBX");

	proc print data=lbx noobs width=min;
	run;

ods excel close;
ods listing;
