/*****************************************************************************************/
* Program Name  : VS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : build temporary dataset for VS (Vital Signs) domain
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

data _null_;
	set crf.vs(encoding=any where=(pagename='Vital Signs'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update VS_build.sas to handle VS.DELETED var appropriately.";

	** ensure HR vars entered correctly **;
	if (vsnd7^='' or vsreasnd7^='') and (vshr>.z or vshru^='') then put "ER" "ROR: update VS_build.sas to handle HR vars appropriately.";

	** catch cases where blood pressure units needs to be moved out of header **;
	if vsbpu not in ('','mmHg') then put "ER" "ROR: update vs_build.sas to handle VSBPU units correctly.";
run;

data pp_final_vs(keep=subnum visname vsnd_reas vsdat vsdat_c vspos vstimp_c vstim1_c hr rr temp vstempl_dec bp1 vstim2 vstim2_c bp2 vstim3_c bp3 bp_avg);
	set crf.vs(encoding=any where=(pagename='Vital Signs' and deleted='f'));

	length vsnd_reas $500;
	if vsnd^='' or vsreasnd1^='' then vsnd_reas='Not Done: '||strip(vsreasnd1);

	length vsdat_c $20;
	if vsdat>.z then vsdat_c=strip(put(vsdat,yymmdd10.));

	if vstimp>.z then vstimp_c=strip(put(vstimp,time5.));
	if vstim1>.z then vstim1_c=strip(put(vstim1,time5.));	 

	length times $40;
	if vstimp>.z or vstim1>.z then times=strip(put(vstimp,time5.))||' / '||strip(put(vstim1,time5.));

	%macro build_var(outvar=,nd=,reas=,val=,unit=);
		length hr $200;
		if &nd.^='' or &reas.^='' then &outvar.='Not Done: '||strip(&reas.);
			else if &val.>.z or &unit.^='' then &outvar.=catx(' ',strip(put(&val.,best.)),strip(&unit.));
		&outvar.=tranwrd(&outvar.,'beats per minute','bpm');
		&outvar.=tranwrd(&outvar.,'breaths per minute','brpm');
		&outvar.=tranwrd(&outvar.,'degrees Celsius','°C');
		&outvar.=tranwrd(&outvar.,'degrees Fahrenheit','°F');
	%mend build_var;
	%build_var(outvar=hr,  nd=vsnd7,reas=vsreasnd7,val=vshr,  unit=vshru);
	%build_var(outvar=rr,  nd=vsnd2,reas=vsreasnd, val=vsrr,  unit=vsrru);
	%build_var(outvar=temp,nd=vsnd3,reas=vsreasnd3,val=vstemp,unit=vstempu_dec);

	length bp1 $200;
	if vsnd4^='' or vsreasnd4^='' then bp1='Not Done: '||strip(vsreasnd4);
		else if vssysbp1>.z or vsdiabp1>.z then bp1=strip(put(vssysbp1,best.))||"/"||strip(put(vsdiabp1,best.));

	length vstim2_c $10;
	if vstim2>.z then vstim2_c=strip(put(vstim2,time5.));

	length bp2 $200;
	if vsnd5^='' or vsreasnd5^='' then bp2='Not Done: '||strip(vsreasnd5);
		else if vssysbp2>.z or vsdiabp2>.z then bp2=strip(put(vssysbp2,best.))||"/"||strip(put(vsdiabp2,best.));

	length vstim3_c $10;
	if vstim3>.z then vstim3_c=strip(put(vstim3,time5.));

	length bp3 $200;
	if vsnd6^='' or vsreasnd6^='' then bp3='Not Done: '||strip(vsreasnd6);
		else if vssysbp3>.z or vsdiabp3>.z then bp3=strip(put(vssysbp3,best.))||"/"||strip(put(vsdiabp3,best.));

	length bp_avg $200;
	if vssbpavg>.z or vsdbpavg>.z then bp_avg=strip(put(vssbpavg,best.))||"/"||strip(put(vsdbpavg,best.));

	proc sort;
		by subnum vsdat;
run;
