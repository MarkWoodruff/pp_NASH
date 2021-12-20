/*****************************************************************************************/
* Program Name  : check_dates.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-26
* Description   : macro to check against visit dates in VS
*
* Revision History
* Date       By            Description of Change
* 2021-12-09 Mark Woodruff add VISNAME_.
* 2021-12-19 Mark Woodruff remove note to log for 'not done' records - they are fine.
******************************************************************************************;

%macro check_dates(dsn=,date=,mrgvars=%str(visitid visname));

	data dates(keep=subnum visitid visname svstdt_c visname_);
		set crf.sv(encoding=any where=(pagename='Visit Date' and deleted='f' and visname^='Unscheduled'));

		*if svnd^='' then put "ER" "ROR: update check_dates.sas to exclude 'not done' records.";

		length svstdt_c $20;
		if svstdt>.z then svstdt_c=strip(put(svstdt,yymmdd10.));

		visname_=strip(visname);

		proc sort;
			by subnum &mrgvars.;
	run;

	proc sort data=&dsn.;
		by subnum &mrgvars.;
	run;

	data &dsn.(drop=visname_);
		merge dates
		  	  &dsn.(in=inp);
		by subnum &mrgvars.;
		if inp;

		if svstdt_c^='' and &date.^='' and svstdt_c^=&date. then do;
			put "Note: dates not matching for " subnum= "in &dsn. domain.";
			&date.flag=1;
		end;
	run;

	data _null_;
		set &dsn.;
		%global &date.flag_foot;
		%let &date.flag_foot=0;
		if &date.flag=1 then call symput("&date.flag_foot",strip(put(1,best.)));
	run;
	%put &date.flag_foot=&&&date.flag_foot..;

%mend check_dates;
