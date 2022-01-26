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
* 2021-10-15 Mark Woodruff use correct pagename value, now that it is populated with Reconsent records.
* 2021-12-09 Mark Woodruff remove check on pagename.
* 2022-01-05 Mark Woodruff make sure missing dates are sorted appropriately.
******************************************************************************************;

** ensure DELETED var is being handled correctly **;
data _null_;
	set crf.ds(encoding=any where=(pagename='Reconsent Log'));
	if deleted^='f' then put "ER" "ROR: handle DELETED var appropriately.";

	** ensure missing dates are sorted correctly **;
	if ricdat=. then put "ER" "ROR: update RECON_build.sas to sort missing dates appropriately." SUBNUM=;
run;

data pp_final_recon(keep=subnum dsseq_c rpver ricv ricdat_c);
	set crf.ds(encoding=any where=(pagename='Reconsent Log'));

	length dsseq_c $10;
	if dsseq>.z then dsseq_c=strip(put(dsseq,best.));

	length ricdat_c $10;
	if ricdat>.z then ricdat_c=strip(put(ricdat,yymmdd10.));

	proc sort;
		by subnum;
run;
