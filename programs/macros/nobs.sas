/*****************************************************************************************/
* Program Name  : nobs.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-05
* Description   : number of obs
* Notes         : 
* Revision History
* Date       By            Description of Change
******************************************************************************************;

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
