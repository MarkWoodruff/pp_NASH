/*****************************************************************************************/
* Program Name  : ULTRA_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for ULTRA domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.fa(encoding=any where=(pagename='Ultrasound'));

	if faorres>.z or faorres_dec^='' then put "ER" "ROR: make sure ULTRA_build.sas vars FAORRES/FAORRES_DEC working now that populated.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ULTRA_build.sas to handle FA.DELETED var appropriately.";
run;

data pp_final_ultra(keep=subnum visitid visname faperf_reas fadat fadat_c faorres_g_dec faorres_s_dec faorres_dec);
	set crf.fa(encoding=any where=(pagename='Ultrasound' and deleted='f'));

	length faperf_reas $700;
	faperf_reas=catx(': ',faperf_dec,fareasnd);

	length fadat_c $20;
	if fadat>.z then fadat_c=strip(put(fadat,yymmdd10.));

	proc sort;
		by subnum fadat visitid;
run;

%check_dates(dsn=pp_final_ultra,date=fadat_c);
