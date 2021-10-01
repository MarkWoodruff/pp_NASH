/*****************************************************************************************/
* Program Name  : RECON_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-28
* Description   : build temporary dataset for RECON (Reconsent) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-01 Mark Woodruff refine check on pagename now that have more records.
******************************************************************************************;

** ensure only informed consent records are present in crf.ds **;
data _null_;
	set crf.ds(encoding=any);

	if (rpver^='' or ricv^='' or ricdat>.z) or pagename not in ('Randomization','Informed Consent') then put
		"ER" "ROR: update RECON_build.sas to read in only Reconsent records.";
run;

** ensure DELETED var is being handled correctly **;
data _null_;
	set crf.ds(encoding=any);
	if deleted^='f' then put "ER" "ROR: handle DELETED var appropriately.";
run;

data pp_final_recon(keep=subnum dsseq_c rpver ricv ricdat_c);
	set crf.ds(encoding=any where=(pagename='Reconsent'));

	length dsseq_c $10;
	if dsseq>.z then dsseq_c=strip(put(dsseq,best.));

	length ricdat_c $10;
	if ricdat>.z then ricdat_c=strip(put(ricdat,yymmdd10.));

	proc sort;
		by subnum;
run;
