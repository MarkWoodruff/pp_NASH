/*****************************************************************************************/
* Program Name  : CM_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : build temporary dataset for CM domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.cm(encoding=any);

	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='Concomitant Medications') then put "ER" "ROR: update CM_build.sas to read in only CM records from crf.CM.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update CM_build.sas to handle CM.DELETED var appropriately.";
run;

data pp_final_cm(keep=subnum visitid visname cmtrt_c cmindc_c cmaeno cmmhno dose route frequency cmstdat cmendat dates coding);
	set crf.cm(encoding=any where=(pagename='Concomitant Medications' and deleted='f'));

	length cmtrt_c $700;
	if cmnone^='' then cmtrt_c='No Concomitant Medications taken during the study.';
		else cmtrt_c=strip(cmtrt);

	length cmindc_c $4700;
	cmindc_c=catx(', ',cmindc_dec,cmindcsp);

	length dose $200;
	if cmdosu_dec='Other' then dose=catx(' ',cmdose,cmdosuot);
		else if index(cmdosu_dec,'=')>0 then dose=catx(' ',cmdose,scan(cmdosu_dec,1,'='));
		else put "ER" "ROR: update CM_build.sas for other dose units.";

	length route $200;
	route=catx(': ',cmroute_dec,cmrteot);

	length frequency $200;
	frequency=catx(': ',cmdosfrq_dec,cmfrqot);
	
	length dates $100;
	if cmendat>.z and cmongo^='' then put "ER" "ROR: update CM_build.sas to handle both a stop date and ongoing.";
	if cmendat>.z then dates=strip(cmstdat)||'/frcbrk'||strip(put(cmendat,yymmdd10.));
		else if cmongo^='' then dates=strip(cmstdat)||'/frcbrk'||'Ongoing';

	length coding $3100;
	if drug_name^='' or preferred_name^='' then do;
		put "ER" "ROR: update CM_build.sas to make sure proper coding terms are being used, now that they are populated";
		coding=strip(drug_name)||'/frcbrk'||strip(preferred_name);
	end;

	proc sort;
		by subnum cmstdat cmendat;
run;
