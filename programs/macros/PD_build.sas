/*****************************************************************************************/
* Program Name  : PD_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-21
* Description   : build temporary dataset for PD (Protocol Deviations) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.dv(encoding=utf8);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Protocol Deviations') then put "ER" "ROR: update PD_build.sas to read in only Protocol Deviations records from crf.PD.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PD_build.sas to handle PD.DELETED var appropriately.";
run;

data pp_final_pd(keep=subnum visitid visname visname dvnone cat_ dviddat_c dvstdat: dvterm dvirbna dvirbdat_c);
	set crf.dv(encoding=utf8 where=(pagename='Protocol Deviations' and deleted='f'));

	length cat_ $1000;
	cat_=catx(':FRCBRK',dvcat_dec,dvscat_dec);

	length dviddat_c $10;
	if dviddat>.z then dviddat_c=strip(put(dviddat,yymmdd10.));

	length dvstdat_c $10;
	if dvstdat>.z then dvstdat_c=strip(put(dvstdat,yymmdd10.));

	length dvirbdat_c $10;
	if dvirbdat>.z then dvirbdat_c=strip(put(dvirbdat,yymmdd10.));

	proc sort;
		by subnum dvstdat;
run;
