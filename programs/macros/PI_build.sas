/*****************************************************************************************/
* Program Name  : PI_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-15
* Description   : build temporary dataset for PI domain
*
* Revision History
* Date       By            Description of Change
* 2022-07-11 Mark Woodruff finish domain now that it is populated.
******************************************************************************************;

data _null_;
	set crf.pi(encoding=any);
	
	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='PI Signature') then put "ER" "ROR: update PI_build.sas to read in only PI records from crf.PI.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update PI_build.sas to handle PI.DELETED var appropriately.";
run;

data pp_final_pi(keep=subnum visitid visname pisign);
	set crf.pi(encoding=any where=(pagename='PI Signature' and deleted='f'));

	proc sort;
		by subnum visitid;
run;
