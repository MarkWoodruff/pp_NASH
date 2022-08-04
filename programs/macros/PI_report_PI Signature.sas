/*****************************************************************************************/
* Program Name  : PI_report_PI Signature.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2022-07-11
* Description   : report PI domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data domain_data;
	set pp_final_pi;
	where subnum="&ptn.";
	space=' ';
run;

%nobs(domain_data);

%macro report_domain;
	%if &nobs.=0 %then %do;
		data domain_data;
			merge domain_data empty;
		run;
	%end;

	options orientation=portrait nodate nonumber nobyline;

	proc report data=domain_data nowd headline headskip missing spacing=1 split="|" center formchar(2)='_'
		style(header)=[just=l asis=on] 
		style(column)=[just=l asis=on] 
		style(lines) =[just=l asis=on];

		%if &nobs.=0 %then %do;
			column subnum;
			define subnum /order order=internal noprint;
			footnote "No data for this patient/domain as of &data_dt..";
		%end;
		%else %do;
			column visitid pisign;
			define visitid      /order order=internal noprint;
			define pisign       /display style=[htmlclass='max-width-7-75'] "By checking this box, I certify that the data (including related queries) are true and correct to the best of my knowledge.|My electronic signature is equivalent to my handwritten signature on an official document.";
		%end;

		compute before _page_ / style=[just=l htmlclass="fixed-domain-title domain-title"];
			line "PI Signature";
		endcomp;
	run;
	
	footnote;
%mend report_domain;
%report_domain;

** ensure data is not carried over to next domain **;
proc sql;
	drop table domain_data;
quit;
