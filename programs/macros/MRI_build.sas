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
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2021-12-06 Mark Woodruff remove sort by dates (some are missing), add circuit breaker for unscheduleds.
* 2022-01-10 Mark Woodruff handle post-Screening visits that are labeled differently than CRF (Week 6).
* 2022-02-01 Mark Woodruff handle post-Screening visits that are labeled differently than CRF (Week 12).
* 2022-03-14 Mark Woodruff add warn!ng note to log if average record is not on MOSEQ=10,20,30,etc. record.
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

	if visitid=777 or index(visname,'Uns')>0 then put "ER" "ROR: update MRI_build.sas for unscheduled ordering.";

	proc sort;
		by subnum visitid visname;
run;

** get latest external MRI file **;
%get_latest_file(fnstr=%str(bos_580_201_mri),macvarnm=latest_mri,onlyfn=2);
%put latest_mri=&latest_mri.;

data mri_external_(drop=usubjid);
	set crf.&latest_mri.;

	** standardize subnum to CRF **;
	length subnum $100;
	subnum=strip(usubjid);

	moseqn=input(strip(moseq),best.);

	if moseq in ('10','20','30','40','50','60','70','80','90') and moloc^='LIVER' then put "ER" "ROR: update MRI_build.sas for location of average record." SUBNUM=;

	proc sort;
		by subnum moseqn;
run;

proc sort data=crf.ds out=cohort(keep=subnum cohort);
	by subnum;
	where pagename='Randomization' and cohort>.z;
run;

data mri_external_;
	merge cohort
		  mri_external_(in=ine);
	by subnum;
	if ine;
run;

data mri_external(drop=visitnum visit cohort);
	set mri_external_;
	by subnum moseqn;

	** standardize visitid and visname to CRF **;
	length visname $100;
	if visitnum=1 and visit='Screening' then do;
		visitid=1;
		visname='Screening';
	end;
		else if visit='Week 6' then do;
			if cohort in (1,4,5) then do; ** Q4W (monthly) **;
				visitid=8;
				visname='Day 43 monthly';
			end;
				else if cohort in (2,3) then do; ** Q2W (bi-weekly) **;
					visitid=7;
					visname='Day 43 bi-weekly';
				end;
		end;
		else if visit='Week 12' then do;
			visitid=12;
			visname='Day 85';
		end;
		else put "ER" "ROR: update MRI_build.sas for new BioTel visits that need standardizing." cohort= visit=;
run;

proc sort data=mri_external;
	by subnum visitid visname;* moseqn;
run;

data mri_external(drop=evalcom:);
	set mri_external(rename=(moseq=moseq_));
	by subnum visitid visname;* moseqn;

	length first_comm $5000;
	retain first_comm;
	if first.visitid then first_comm=strip(evalcom1);
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

	if moseq_^='' then moseq_n=input(strip(moseq_),best.);
	if 1<=moseq_n<=10 then moseq=moseq_n;
		else if 11<=moseq_n<=20 then moseq=moseq_n-10;
		else if 21<=moseq_n<=30 then moseq=moseq_n-20;
		else if 31<=moseq_n<=40 then moseq=moseq_n-30;
		else put "ER" "ROR: update MRI_build.sas for more reads." SUBNUM=;

	length moseqc $2;
	if moseq>.z then moseqc=strip(put(moseq,best.));

	proc sort;
		by subnum visitid visname modtc moseq;
run;

proc transpose data=mri_external out=mri_external_x(drop=_:) prefix=meas_;
	by subnum visitid visname modtc;
	id moseqc;
	var mostresn;
run;

proc transpose data=mri_external out=mri_external_cx(drop=_:) prefix=measc_;
	by subnum visitid visname modtc;
	id moseqc;
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
	if nmiss(meas_2-meas_10)=0 then meas_avg=round(((meas_2*1.77)+(meas_3*4.91)+(meas_4*4.91)+(meas_5*4.91)+(meas_6*4.91)
		+(meas_7*4.91)+(meas_8*4.91)+(meas_9*4.91)+(meas_10*4.91))/41.05,.01);

	length measc_avg $20;
	if meas_avg>.z then measc_avg=strip(put(round(meas_avg,.01),8.2));

	if meas_avg^=meas_1 then meas_flag=1;

	measc_avg='in progressSUPER2';
run;

proc print data=mri_external_x (obs=20) width=min;
	where subnum='110-008x';
	var subnum visitid visname meas_avg meas_2 meas_3 meas_4 meas_5 meas_6 meas_7 meas_8 meas_9 meas_10 meas_1 meas_flag;
	title'ext';
run;
proc print data=mri_crf (obs=20) width=min;
	where subnum='110-008x';
	title'crf';
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
