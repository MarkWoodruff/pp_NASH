/*****************************************************************************************/
* Program Name  : LBC_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-22
* Description   : build temporary dataset for LBC (Central Labs) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.lbx(encoding=any);

	if pagename^='Lab Results' then	put "ER" "ROR: update LBC_build.sas to filter on proper PAGENAME, and add new domain as necessary.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update LBC_build.sas to handle LBX.DELETED var appropriately.";
run;

data pp_final_lbc(keep=subnum visname lbrefid yob_sex visit lbdat lbdat_c lbfast_dec lbcat lbtestcd lbtest lborres_lborresu nr lbstresc_lbstresu nrst
					   lbnrind lbstat_lbreasnd lbspec lbcoval);
	set crf.lbx(encoding=any where=(pagename='Lab Results' and deleted='f'));

	if lbdat=. then put "ER" "ROR: update LBC_build.sas to handle Unscheduled visits and/or missing dates correctly.";

	length yob_sex $100;
	yob_sex=catx(' - ',yob,sex);

	length lbdat_c $12;
	if lbdat>.z then lbdat_c=strip(put(lbdat,yymmdd10.));

	length lborres_lborresu $200;
	lborres_lborresu=catx(' ',lborres,lborresu);

	length nr $200;
	nr=catx(' - ',lbornrlo,lbornrhi);

	length lbstresc_lbstresu $200;
	lbstresc_lbstresu=catx(' ',lbstresc,lbstresu);

	length nrst $200;
	nrst=coalescec(catx(' - ',lbstnrlo,lbstnrhi),lbstnrc);

	length lbstat_lbreasnd $1300;
	lbstat_lbreasnd=catx(':FRCBRK',lbstat,lbreasnd);

	proc sort;
		by subnum lbdat lbcat lbtest;
run;
