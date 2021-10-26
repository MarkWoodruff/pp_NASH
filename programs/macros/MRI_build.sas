/*****************************************************************************************/
* Program Name  : MRI_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for MRI domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.mo(encoding=any where=(pagename='MRI-PDFF'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update MRI_build.sas to handle MRI.DELETED var appropriately.";
run;

data pp_final_mri(keep=subnum mriperf_reas mofastyn_dec mofastn_c mostdat visitid visname mostdat_c);
	set crf.mo(encoding=any where=(pagename='MRI-PDFF' and deleted='f'));

	length mriperf_reas $700;
	mriperf_reas=catx(': ',moperf_dec,moreasnd);

	length mofastn_c $10;
	if mofastn>.z then mofastn_c=strip(put(mofastn,best.));

	length mostdat_c $20;
	if mostdat>.z then mostdat_c=strip(put(mostdat,yymmdd10.));

	proc sort;
		by subnum mostdat visitid visname;
run;

%check_dates(dsn=pp_final_mri,date=mostdat_c);

