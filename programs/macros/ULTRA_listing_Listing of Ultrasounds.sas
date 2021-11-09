/*****************************************************************************************/
* Program Name  : ULTRA_listing_Listing of Ultrasounds.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-11-01
* Description   : report Ultrasound Findings in a listing
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_ultra;

	length faorres_any $4;
	if faorres_g_dec='Yes' or faorres_s_dec='Yes' then faorres_any='Yes';
		else if faorres_g_dec='No' and faorres_s_dec='No' then faorres_any='No';
		else if faorres_g_dec^='' or faorres_s_dec^='' then put "ER" "ROR: update ULTRA_report_Ultrasound.sas for more reasons.";
run;

/*
<select id='ultradd'>
	<option value='ultradd-all' selected>-- Show All --</option>
	<option value='yes'>Yes</option>
	<option value='No'>No</option>
</select>
*/

%macro report_domain;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(report)=[htmlid='ultralist']
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		column subnum fadat visitid visname fadat_c faperf_reas faorres_g_dec faorres_s_dec faorres_any faorres_dec;
		define subnum        /order order=internal "Patient" style=[htmlclass='patient-link ultra min-width-0-75'];
		define fadat         /order order=internal noprint;
		define visitid       /order order=internal noprint;
		define visname       /display "Visit";
		define fadat_c       /display "Date" style=[htmlclass='min-width-1-0'];
		define faperf_reas   /display "Performed?|If No, Reason" style=[htmlclass='max-width-5-0'];
		define faorres_g_dec /display "Does Subject|Have Gallstones?" style=[htmlclass='boldyes'];
		define faorres_s_dec /display "Does Subject|Have Sludge?" style=[htmlclass='boldyes'];
		define faorres_any   /display "Does Subject Have|Gallstones or Sludge?-ULTRADD" style=[htmlclass='boldyes pickultra created'];
		define faorres_dec   /display "Investigator|Assessment";

		footnote "ultra-footnote";

		compute before _page_ / style=[just=l htmlclass="domain-title"];
			line "Listing of Ultrasound Findings";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
