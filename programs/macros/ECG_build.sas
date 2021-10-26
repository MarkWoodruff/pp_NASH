/*****************************************************************************************/
* Program Name  : ECG_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-30
* Description   : build temporary dataset for ECG domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-21 Mark Woodruff add EGQTCF.
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
******************************************************************************************;

data _null_;
	set crf.eg(encoding=any);

	** ensure only ECG records are present in crf.eg **;
	if ^(pagename='ECG') then put "ER" "ROR: update ECG_build.sas to read in only ECG records from crf.EG.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update ECG_build.sas to handle ECG.DELETED var appropriately.";
run;

data pp_final_ecg(keep=subnum visitid visname egnd_reas egdat egdat_c egtims_c egtim_c eghr_c egqt_c egpr_c egqrs_c egrr_c egqtcf egqtcf_c egorres_c);
	set crf.eg(encoding=any where=(pagename='ECG' and deleted='f'));

	length egnd_reas $500;
	if egnd^='' or egreasnd^='' then egnd_reas='Not Done: '||strip(egreasnd);

	length egdat_c $20;
	if egdat>.z then egdat_c=strip(put(egdat,yymmdd10.));

	%macro times(in=,out=,unk=);
		length &out. $20;
		if &in.>.z then &out.=strip(put(&in.,time5.));
			else if &unk.^='' then &out.='Unknown';
	%mend times;
	%times(in=egtims,out=egtims_c,unk=egtimsun);
	%times(in=egtim,out=egtim_c,unk=egtimun);

	%macro ecg(in=,unit=);
		length &in._c $30;
		if &in.>.z then &in._c=strip(put(&in.,best.))||' '||strip(&unit.);
		&in._c=tranwrd(&in._c,'beats per minute','bpm');
		&in._c=tranwrd(&in._c,'milliseconds','ms');
		if &unit. not in ('','beats per minute','milliseconds') then put "ER" "ROR: update ECG_build.sas for new &unit. values.";
	%mend ecg;
	%ecg(in=eghr,unit=eghru);
	%ecg(in=egqt,unit=egqtu);
	%ecg(in=egpr,unit=egpru);
	%ecg(in=egqrs,unit=egqrsu);
	%ecg(in=egrr,unit=egrru);
	%ecg(in=egqtcf,unit=egqtcu);

	length egorres_c $700;
	if egorres_dec^='' or egspec^='' then egorres_c=catx(': ',egorres_dec,egspec);

	proc sort;
		by subnum egdat;
run;

%check_dates(dsn=pp_final_ecg,date=egdat_c);
