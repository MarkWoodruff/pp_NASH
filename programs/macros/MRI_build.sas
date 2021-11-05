/*****************************************************************************************/
* Program Name  : MRI_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for MRI domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-04 Mark Woodruff add external data
* 2021-11-05 Mark Woodruff use mri_nobs instead of nobs.
******************************************************************************************;

data _null_;
	set crf.mo(encoding=any where=(pagename='MRI-PDFF'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update MRI_build.sas to handle MRI.DELETED var appropriately.";
run;

data mri_crf(keep=subnum mriperf_reas mofastyn_dec mofastn_c mostdat visitid visname mostdat_c);
	set crf.mo(encoding=any where=(pagename='MRI-PDFF' and deleted='f'));

	length mriperf_reas $700;
	mriperf_reas=catx(': ',moperf_dec,moreasnd);

	length mofastn_c $10;
	if mofastn>.z then mofastn_c=strip(put(mofastn,best.));

	length mostdat_c $20;
	if mostdat>.z then mostdat_c=strip(put(mostdat,yymmdd10.));

	proc sort;
		by subnum mostdat visitid visname;
run;

** get latest external MRI file **;
%get_latest_file(fnstr=%str(bos_580_201_mri),macvarnm=latest_mri,onlyfn=2);
%put latest_mri=&latest_mri.;

data mri_external_;
	set crf.&latest_mri.;

	moseqn=input(strip(moseq),best.);

	proc sort;
		by usubjid moseqn;
run;

data mri_external(drop=usubjid visitnum visit evalcom:);
	set mri_external_;
	by usubjid moseqn;

	** standardize subnum to CRF **;
	length subnum $100;
	subnum=strip(usubjid);

	** standardize visitid and visname to CRF **;
	length visname $100;
	if visitnum=1 and visit='Screening' then do;
		visitid=1;
		visname='Screening';
	end;
		else put "ER" "ROR: update MRI_build.sas for new BioTel visits that need standardizing.";

	length first_comm $5000;
	retain first_comm;
	if first.usubjid then first_comm=strip(evalcom1);
	if first_comm^=strip(evalcom1) then put "ER" "ROR: update MRI_build.sas for inconsistent comments.";
	if evalcom2^='' then put "ER" "ROR: update MRI_build.sas for second comment field populated.";
	if evalcom3^='' then put "ER" "ROR: update MRI_build.sas for third comment field populated.";

	if domain^='MO' then put "ER" "ROR: update MRI_build.sas for inconsistent DOMAIN values.";
	if motestcd^='MEANHFF' then put "ER" "ROR: update MRI_build.sas for inconsistent MOTESTCD values.";
	if motest^='Mean Hepatic Fat Fraction' then put "ER" "ROR: update MRI_build.sas for inconsistent MOTEST values.";
	if mostat^='' then put "ER" "ROR: update MRI_build.sas for inconsistent MOSTAT values.";
	if moreasnd^='' then put "ER" "ROR: update MRI_build.sas for inconsistent MOREASND values.";
	if monam^='BioTel Research' then put "ER" "ROR: update MRI_build.sas for inconsistent MONAM values.";
	if momethod^='MRI' then put "ER" "ROR: update MRI_build.sas for inconsistent MOMETHOD values.";
	if moeval^='RADIOLOGIST' then put "ER" "ROR: update MRI_build.sas for inconsistent MOEVAL values.";
	if mostresu^='%' then put "ER" "ROR: update MRI_build.sas for new units.";

	length comments $5000;
	comments=catx(' ',evalcom1,evalcom2,evalcom3);

	proc sort;
		by subnum visitid visname modtc moseq;
run;

proc transpose data=mri_external out=mri_external_x(drop=_:) prefix=meas_;
	by subnum visitid visname modtc;
	id moseq;
	var mostresn;
run;

proc transpose data=mri_external out=mri_external_cx(drop=_:) prefix=measc_;
	by subnum visitid visname modtc;
	id moseq;
	var mostresc;
run;

data mri_external_x;
	merge mri_external_x
		  mri_external_cx;
	by subnum visitid visname modtc;
run;

data mri_external_x(keep=subnum visitid visname mosttim_c meas_: measc_:);
	set mri_external_x;
	by subnum visitid visname modtc;

	length mosttim_c $10;
	if modtc^='' then mosttim_c=scan(modtc,2,'T');

	if nmiss(meas_2-meas_10)>0 then put "ER" "ROR: update MRI_build.sas for average calculation.";
	if nmiss(meas_2-meas_10)=0 then meas_avg=mean(of meas_2-meas_10);
	if nmiss(meas_1-meas_9)=0 then meas_avg2=mean(of meas_1-meas_9);

	length measc_avg $20;
	if meas_avg>.z then measc_avg=strip(put(round(meas_avg,.01),8.2));

	if meas_avg^=meas_1 then meas_flag=1;

	measc_avg='in progressSUPER2';
run;

%macro mri_nobs(dsn);
	%symdel nobs / nowarn;
	%global nobs nobs_&dsn.;
	%let dsid=%sysfunc(open(&dsn.));
	%let nobs=%sysfunc(attrn(&dsid.,nlobs));
	%let nobs_&dsn.=%sysfunc(attrn(&dsid.,nlobs));
	%let rc=%sysfunc(close(&dsid.));
%mend mri_nobs;
%mri_nobs(mri_crf);

data pp_final_mri;
	merge mri_crf(in=inm)
		  mri_external_x(in=ine);
	by subnum visitid visname;
	if inm;
run;

%mri_nobs(pp_final_mri);

data _null_;
	%if &nobs_mri_crf.^=&nobs_pp_final_mri. %then %do;
		put "ER" "ROR: update MRI_build.sas for merge with external data.";
	%end;
run;

%check_dates(dsn=pp_final_mri,date=mostdat_c);
