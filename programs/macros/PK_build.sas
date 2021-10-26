/*****************************************************************************************/
* Program Name  : PK_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-15
* Description   : build temporary dataset for PK domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.pc(encoding=any);

	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='PK Collection') then put "ER" "ROR: update PK_build.sas to read in only PK records from crf.PC.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PK_build.sas to handle PC.DELETED var appropriately.";
run;

data pp_final_pk(keep=subnum visitid visname pcperf_reas pcdat_c pctim_c pccoval);
	set crf.pc(encoding=any where=(pagename='PK Collection' and deleted='f'));

	length pcperf_reas $700;
	pcperf_reas=catx(': ',pcperf_dec,pcreasnd);

	length pcdat_c $12;
	if pcdat>.z then pcdat_c=strip(put(pcdat,yymmdd10.));

	length pctim_c $12;
	if pctim>.z then pctim_c=strip(put(pctim,time5.));

	proc sort;
		by subnum visitid;
run;

%check_dates(dsn=pp_final_pk,date=pcdat_c);
