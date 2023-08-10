/*****************************************************************************************/
* Program Name  : VS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : build temporary dataset for VS (Vital Signs) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-21 Mark Woodruff add HRN, TEMPN.
* 2021-10-26 Mark Woodruff add flagging for dates not matching VS.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2021-11-10 Mark Woodruff keep vsnd.  add tempn_std.
* 2021-12-05 Mark Woodruff update buildvar macro for lengths.
* 2022-01-05 Mark Woodruff add note to log for missing dates.
* 2022-08-22 Mark Woodruff remove note to log for HR vars, working correctly.
* 2023-04-26 Mark Woodruff replace bad degree symbol with unicode so will render correctly in HTML.
******************************************************************************************;

data _null_;
	set crf.vs(encoding=any where=(pagename='Vital Signs'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update VS_build.sas to handle VS.DELETED var appropriately.";

	** ensure HR vars entered correctly **;
	*if (vsnd7^='' or vsreasnd7^='') and (vshr>.z or vshru^='') then put "ER" "ROR: update VS_build.sas to handle HR vars appropriately.";

	** catch cases where blood pressure units needs to be moved out of header **;
	if vsbpu not in ('','mmHg') then put "ER" "ROR: update vs_build.sas to handle VSBPU units correctly.";

	** ensure missing dates are sorted correctly **;
	if vsdat=. and subnum^='115-001' then put "ER" "ROR: update vs_build.sas to handle missing dates in sorting correctly." SUBNUM=;
run;

** for degree symbol **;
%let degr=%bquote(@{unicode 00B0});

data pp_final_vs(keep=subnum visitid visname vsnd_reas vsdat vsdat_c vspos vstimp_c vstim1_c hr hrn rr rrn temp tempn vstempl_dec bp1_sysn bp1_sys bp1_dian 
	bp1_dia vstim2 vstim2_c bp2_sysn bp2_sys bp2_dian bp2_dia vstim3_c bp3_sysn bp3_sys bp3_dian bp3_dia bp_avg_sysn bp_avg_sys bp_avg_dian bp_avg_dia vsnd
	vsreasnd1 tempn_std);
	set crf.vs(encoding=any where=(pagename='Vital Signs' and deleted='f'));

	length vsnd_reas $500;
	if vsnd^='' or vsreasnd1^='' then vsnd_reas='Not Done: '||strip(vsreasnd1);

	length vsdat_c $20;
	if vsdat>.z then vsdat_c=strip(put(vsdat,yymmdd10.));

	if vstimp>.z then vstimp_c=strip(put(vstimp,time5.));
	if vstim1>.z then vstim1_c=strip(put(vstim1,time5.));	 

	length times $40;
	if vstimp>.z or vstim1>.z then times=strip(put(vstimp,time5.))||' / '||strip(put(vstim1,time5.));

	if vstempu='F' then tempn_std=round(((vstemp-32)*(5/9)),.1);
		else if vstempu='C' then tempn_std=vstemp;

	%macro build_var(outvar=,nd=,reas=,val=,unit=);
		length &outvar. $200;
		if &nd.^='' or &reas.^='' then &outvar.='Not Done: '||strip(&reas.);
			else if &val.>.z or &unit.^='' then &outvar.=catx(' ',strip(put(&val.,best.)),strip(&unit.));

		if &val.>.z then &outvar.n=&val.;
		&outvar.=tranwrd(&outvar.,'beats per minute','bpm');
		&outvar.=tranwrd(&outvar.,'breaths per minute','brpm');
		&outvar.=tranwrd(&outvar.,'degrees Celsius',"&degr.C");
		&outvar.=tranwrd(&outvar.,'degrees Fahrenheit',"&degr.F");
	%mend build_var;
	%build_var(outvar=hr,  nd=vsnd7,reas=vsreasnd7,val=vshr,  unit=vshru);
	%build_var(outvar=rr,  nd=vsnd2,reas=vsreasnd, val=vsrr,  unit=vsrru);
	%build_var(outvar=temp,nd=vsnd3,reas=vsreasnd3,val=vstemp,unit=vstempu_dec);

	%macro sys_dia(readnum=,ndnum=);
		%if &readnum.^=1 %then %do;
			length vstim&readnum._c $10;
			if vstim&readnum.>.z then vstim&readnum._c=strip(put(vstim&readnum.,time5.));
		%end;

		length bp&readnum._sys bp&readnum._dia $200;
		if vsnd&ndnum.^='' or vsreasnd&ndnum.^='' then bp&readnum._sys='Not Done: '||strip(vsreasnd&ndnum.);
			else if vssysbp&readnum.>.z then bp&readnum._sys=strip(put(vssysbp&readnum.,best.));
		if vsdiabp&readnum.>.z then bp&readnum._dia=strip(put(vsdiabp&readnum.,best.));
		bp&readnum._sysn=vssysbp&readnum.;
		bp&readnum._dian=vsdiabp&readnum.;
	%mend sys_dia;
	%sys_dia(readnum=1,ndnum=4);
	%sys_dia(readnum=2,ndnum=5);
	%sys_dia(readnum=3,ndnum=6);

	length bp_avg_sys bp_avg_dia $200;
	if vssbpavg>.z then bp_avg_sys=strip(put(vssbpavg,best.));
	if vsdbpavg>.z then bp_avg_dia=strip(put(vsdbpavg,best.));
	bp_avg_sysn=vssbpavg;
	bp_avg_dian=vsdbpavg;

	proc sort;
		by subnum vsdat;
run;
