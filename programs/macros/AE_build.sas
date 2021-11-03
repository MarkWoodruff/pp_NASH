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

data pp_final_ae(keep=subnum aespid aenone_aespid aeterm aesi_aeisr aestdat aeendat start stop aeout_aesev aerel_aeser aeacn_
				      sae_hosp aeslife aesdisab aescong aesmie aesdth_ coding);
	set crf.ae(encoding=any where=(pagename='Adverse Events' and deleted='f'));

	length aenone_aespid $20;
	if aenone^='' then aenone_aespid='None';
		else if aespid>.z then aenone_aespid=strip(put(aespid,best.));

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

	length aeout_aesev $100;
	aeout_aesev=catx('/frcbrk',aeout,aesev);

	length aerel_aeser $100;
	aerel_aeser=catx('/frcbrk',aerel,aeser);

	length coding $5000;
	coding=catx('/frcbrk',aeterm,coalescec(soc_term,'UNCODED'),coalescec(pt_term,'UNCODED'));

	length aeacn_ $100;
	aeacn_=catx('/frcbrk',aeacn,catx(': ',aeacnsub,aeacnsot));

	length hosp_dates $100;
	if aeadmiss>.z and aedischa>.z then hosp_dates=catx('/frcbrk',put(aeadmiss,yymmdd10.),put(aedischa,yymmdd10.));
		else if aeadmiss>.z and aehospon^='' then hosp_dates=catx('/frcbrk',put(aeadmiss,yymmdd10.),'Continuing');
		else if aeadmiss>.z then hosp_dates=strip(put(aeadmiss,yymmdd10.))||'/';

	length sae_hosp $100;
	sae_hosp=catx(': ',aeshosp_dec,hosp_dates);
	if aeadmiss>.z or aedischa>.z then put "ER" "ROR: update AE_build.sas now that SAE Hospitalization is updated.";

	length aesdth_ $100;
	if aedthdat>.z then aesdth_=catx('/frcbrk',aesdth,strip(put(aedthdat,yymmdd10.)));
		else aesdth_=strip(aesdth);

	proc sort;
		by subnum aespid aestdat aeendat aeterm;
run;
