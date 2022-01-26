/*****************************************************************************************/
* Program Name  : VCTE_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-01
* Description   : build temporary dataset for VCTE domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-05 Mark Woodruff make sure missing dates are sorted appropriately.
******************************************************************************************;

data _null_;
	set crf.fa(encoding=any where=(pagename='VCTE'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update FA_build.sas to handle FA.DELETED var appropriately.";

	** ensure missing dates are sorted correctly **;
	if fadat=. and visname^='Screening' then put "ER" "ROR: update VCTE_build.sas to sort missing dates appropriately." SUBNUM= VISNAME=;
run;

data pp_final_vcte(keep=subnum visitid visname faperf_reas fafast8_dec fafast_c fadat fadat_c faorres_cap_c faorres_lsm_c facoval);
	set crf.fa(encoding=any where=(pagename='VCTE' and deleted='f'));

	length faperf_reas $700;
	faperf_reas=catx(': ',faperf_dec,fareasnd);

	length fafast_c $20;
	if fafast>.z then fafast_c=strip(put(fafast,best.));

	length fadat_c $20;
	if fadat>.z then fadat_c=strip(put(fadat,yymmdd10.));

	length faorres_cap_c $20;
	if faorres_cap>.z then faorres_cap_c=strip(put(faorres_cap,best.));

	length faorres_lsm_c $20;
	if faorres_lsm>.z then faorres_lsm_c=strip(put(faorres_lsm,best.));

	proc sort;
		by subnum fadat visitid;
run;
