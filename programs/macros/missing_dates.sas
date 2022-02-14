/*****************************************************************************************/
* Program Name  : missing_dates.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-01-05
* Description   : macro to merge with SV and try to populate missing dates, for sorting.
*
* Revision History
* Date       By            Description of Change
* 2022-02-14 Mark Woodruff also merge by visitseq so can populate unscheduleds.
******************************************************************************************;

%macro missing_dates(dsn=,date=,date2=,pgmname=);

	data sv(keep=subnum visitid visname visitseq svstdt);
		set crf.sv(encoding=any where=(pagename='Visit Date' and deleted='f' and svstdt>.z));* and visitid^=777));

		proc sort;
			by subnum visitid visname visitseq;
	run;

	proc sort data=&dsn.;
		by subnum visitid visname visitseq;
	run;

	data _null_;
		set &dsn. end=eof;
		if eof then call symput("&dsn._before",strip(put(_n_,best.)));
	run;

	data &dsn._date
		 &dsn._nodate;
		set &dsn.;

		if &date.>.z %if &date2.^=  %then %do; or &date2.>.z %end; then output &dsn._date;
			else if &date.=. then output &dsn._nodate;
	run;

	data &dsn._nodate;
		merge sv
			  &dsn._nodate(in=inf);
		by subnum visitid visname visitseq;
		if inf;
	run;

	data &dsn.;
		set &dsn._date(in=indate)
			&dsn._nodate(in=innodate);

		format &date._sort yymmdd10.;
		if indate then do;
			if &date.>.z then &date._sort=&date.;
				%if &date2.^=  %then %do; else if &date2.>.z then &date._sort=&date2.; %end;
		end;
			else if innodate then &date._sort=svstdt;

		if &date._sort=. and subnum^='115-001' then put "ER" "ROR: update &pgmname..sas for missing dates for sorting purposes." SUBNUM=;

		proc sort;
			by subnum &date._sort;
	run;

	data _null_;
		set &dsn. end=eof;
		if eof then call symput("&dsn._after",strip(put(_n_,best.)));
	run;

	data _null_;
		if &&&dsn._before.^=&&&dsn._after. then put "ER" "ROR: update &pgmname..sas to fix number of records being adjusted for missing dates.";
	run;

%mend missing_dates;
