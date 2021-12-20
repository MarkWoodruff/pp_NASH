/*****************************************************************************************/
* Program Name  : EOTS_listing_Listing of Discontinuations.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-12-14
* Description   : report all discontinuations in a listing
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data eot(keep=subnum eot_lastdose eot_date eot_reason);	
	set crf.ds(encoding=any where=(deleted='f' and pagename='End of Treatment' and complet_dec='No'));

	length eot_lastdose eot_date $10 eot_reason $5000;
	if dsexdat>.z then eot_lastdose=strip(put(dsexdat,yymmdd10.));
	if dsstdat>.z then eot_date=strip(put(dsstdat,yymmdd10.));

	length eot_reason $5000;
	eot_reason=catx(': ',dsdecod_dec,dswsoth,dspdoth,covidsp_dec,dstermot);
	if dswsoth^='' or dspdoth^='' or covidsp_dec^='' or dstermot^='' then 
		put "ER" "ROR: update EOTS_listing.sas to make sure EOT reasons working, they are now populated.";

	proc sort;
		by subnum;
run;

data eos(keep=subnum eos_date eos_reason);	
	set crf.ds(encoding=any where=(deleted='f' and pagename='End of Study' and dscomp_dec='No'));

	length eos_date $10 eos_reason $5000;
	if dsstdat>.z then eos_date=strip(put(dsstdat,yymmdd10.));

	length eos_reason $5000;
	eos_reason=catx(': ',dsdecod_prim_dec,dsterm);
	if dsdecdot^='' or dsdecod_covid_dec^='' or dsterm^='' then 
		put "ER" "ROR: update EOTS_listing.sas to make sure EOS reasons working, they are now populated." SUBNUM=;

	proc sort;
		by subnum;
run;

data domain_data;
	merge eot(in=int)
		  eos(in=ins);
	by subnum;

	space=' ';
run;

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column subnum ('SPNHDRFRCNDRLNCNTREnd of Treatment Form' eot_lastdose eot_date eot_reason) space ('SPNHDRFRCNDRLNCNTREnd of Study Form' eos_date eos_reason);
		define subnum        /order order=internal "Patient";
		define eot_lastdose  /display "Date of|Last Dose" style=[htmlclass='min-width-1-0'];
		define eot_date      /display "Date of Early|Termination" style=[htmlclass='min-width-1-0'];
		define eot_reason    /display "Primary Reason for|Treatment Termination" style=[htmlclass='max-width-4-0'];
		define space         /display " " style=[htmlclass='max-width-0-25']; 
		define eos_date      /display "Date of Early|Termination" style=[htmlclass='min-width-1-0'];
		define eos_reason    /display "Primary Reason for|Study Discontinuation" style=[htmlclass='max-width-4-0'];

		footnote "Note: Only patients with 'Did the subject complete the treatment/trial?' = 'No' will be included in this listing.";

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "Listing of Early Terminations and Discontinuations";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
