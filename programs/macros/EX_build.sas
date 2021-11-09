/*****************************************************************************************/
* Program Name  : EX_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-07
* Description   : build temporary dataset for EX (Study Drug Admin) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
******************************************************************************************;

data _null_;
	set crf.ex(encoding=any);

	if pagename^='Study Drug Administration' then put "ER" "ROR: update EX_build.sas to read in only Study Drug Administration records.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update EX_build.sas to handle EX.DELETED var appropriately.";
run;

data pp_final_ex(keep=subnum visitid visname exyn_dec exinjn_dec exstdat_c exsttim_c exloc1_ exloc2_ exloc3_ exvamtt_c exdoseyn_dec exreas_ exrxnyn_dec excoval);
	set crf.ex(encoding=any where=(pagename='Study Drug Administration' and deleted='f'));

	length exstdat_c $12;
	if exstdat>.z then exstdat_c=strip(put(exstdat,yymmdd10.));

	length exsttim_c $12;
	if exsttim>.z then exsttim_c=strip(put(exsttim,time5.));

	%macro loc(num=);
		length exloc&num._ $200;
		if exloc&num._dec^='' then exloc&num._=strip(exloc&num._dec);
			else if exlocot&num.^='' then exloc&num._='Other: '||strip(exlocot&num.);
	%mend loc;
	%loc(num=1);
	%loc(num=2);
	%loc(num=3);

	length exvamtt_c $100;
	if exvamtt>.z then exvamtt_c=strip(put(exvamtt,best.));

	length exreas_ $200;
	if exreasot^='' then exreas_='Other: '||strip(exreasot);
		else exreas_=strip(exreas_dec);

	proc sort;
		by subnum visitid visname;
run;

