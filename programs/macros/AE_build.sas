/*****************************************************************************************/
* Program Name  : AE_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-29
* Description   : build temporary dataset for AE (Adverse Events) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.ae(encoding=any);

	** ensure only informed consent records are present in crf.ds **;
	if ^(pagename='Adverse Events') then put "ER" "ROR: update AE_build.sas to read in only AE records from crf.AE.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update AE_build.sas to handle AE.DELETED var appropriately.";
run;

data pp_final_ae(keep=subnum visitid visname aenone_aespid aesi_aeisr aestdat aeendat start);* iestdat iestdat_c ieorres_dec ieenroll_dec ietestcd_dec sf_mri mostdat_c iereplc_dec iereplcn);
	set crf.ie(encoding=any where=(pagename='Adverse Events' and deleted='f'));

	length aenone_aespid $20;
	if aenone^='' or aespid>.z then aenone_aespid=catx('/frcbrk',aenone,strip(put(aespid,best.)));

	length aesi_aeisr $100;
	aesi_aeisr=catx('/frcbrk',aeaesiyn_dec,aeisryn_dec);

	length start $100;
	if aestdat>.z and aesttim>.z then start=catx('/frcbrk',put(aestdat,yymmdd10.),put(aesttim,time5.));
		else if aestdat>.z and aesttmun^='' then start=catx('/frcbrk',put(aestdat,yymmdd10.),'Unknown');
		else put "ER" "ROR: update AE_build.sas for start date/time algorithm.";

	length stop $100;
	if aeendat>.z and aeentim>.z then stop=catx('/frcbrk',put(aeendat,yymmdd10.),put(aeentim,time5.));
		else if aeendat>.z and aeentmun^='' then stop=catx('/frcbrk',put(aeendat,yymmdd10.),'Unknown');
		else if aeendat>.z and aeongo^='' then stop=catx('/frcbrk',put(aeendat,yymmdd10.),'Ongoing');
		else put "ER" "ROR: update AE_build.sas for stop date/time algorithm.";
	if aeongo^='' and aeentmun^='' then put "ER" "ROR: update AE_build.sas for stop time both unknown and ongoing.";

	proc sort;
		by subnum aestdat aeendat aeterm;
run;

%check_dates(dsn=pp_final_elig,date=iestdat_c);
