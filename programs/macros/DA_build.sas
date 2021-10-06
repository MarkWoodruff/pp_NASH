/*****************************************************************************************/
* Program Name  : DA_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for DA (Kit Assignment) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.da(encoding=any);

	if pagename^='Kit Assignment' then put "ER" "ROR: update DA_build.sas to read in only Kit Assignment records.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update DA_build.sas to handle DA.DELETED var appropriately.";
run;

data pp_final_da(keep=subnum visitid visname dareplac_dec dadisdat_c dadistim_c dakitno1-dakitno3 dadisdat2_c dadistim2_c);
	set crf.da(encoding=any where=(pagename='Kit Assignment' and deleted='f'));

	length dadisdat_c $12;
	if dadisdat>.z then dadisdat_c=strip(put(dadisdat,yymmdd10.));

	length dadistim_c $12;
	if dadistim>.z then dadistim_c=strip(put(dadistim,time5.));

	length dadisdat2_c $12;
	if dadisdat2>.z then dadisdat2_c=strip(put(dadisdat2,yymmdd10.));

	length dadistim2_c $12;
	if dadistim2>.z then dadistim2_c=strip(put(dadistim2,time5.));

	proc sort;
		by subnum visitid visname;
run;
