/*****************************************************************************************/
* Program Name  : SV_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-24
* Description   : build temporary dataset for SV (Subject Visit) domain
*
* Revision History
* Date       By            Description of Change
* 2021-12-09 Mark Woodruff update comment.
* 2022-03-16 Mark Woodruff add visit day flagging against protocol specified window.
******************************************************************************************;

data _null_;
	set crf.sv(encoding=any);

	** ensure only informed consent records are present in crf.sv **;
	if ^(pagename='Visit Date') then put "ER" "ROR: update SV_build.sas to read in only Visit Date records from crf.SV.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update SV_build.sas to handle SV.DELETED var appropriately.";
run;

data sv(keep=subnum visitid visname svnd_c svreasnd svstdt_c svstdt);
	set crf.sv(encoding=any where=(pagename='Visit Date' and deleted='f' and visname^='Unscheduled'));

	length svnd_c $3;
	if svnd^='' then svnd_c='Yes';

	length svstdt_c $20;
	if svstdt>.z then svstdt_c=strip(put(svstdt,yymmdd10.));

	proc sort;
		by subnum visitid;
run;

** flag visits outside of protocol specified window **;
data sv_d1(keep=subnum d1dt);
	set sv(where=(visname='Day 1'));
	format d1dt yymmdd10.;
	d1dt=svstdt;
run;

data eos(keep=subnum dscomp_dec);
	set crf.ds(encoding=any where=(pagename='End of Study' and deleted='f'));

	proc sort;
		by subnum;
run;

data sv;
	merge sv_d1
		  eos
		  sv;
	by subnum;
run;

data sv;
	set sv;
	by subnum;

	if .z<svstdt<d1dt then diff=(svstdt-d1dt);
		else if .z<d1dt<=svstdt then diff=(svstdt-d1dt)+1;

	if visname not in ('Screening','Unscheduled') then visday=input(strip(scan(scan(visname,1,'/'),2,' ')),best.);
	if visday>.z then do;
		visday_m3=(visday-3);
		visday_p3=(visday+3);
	end;
	
	length vistext $200;
	if d1dt>.z then do;
		if visname='Screening' then do;
			if ^(-35<=diff<=-10) then do;
				visflag=1;
				vistext='Ocurred on day '||strip(put(diff,best.))||', outside protocol window of day -35 to day -10.';
			end;
				else if (-35<=diff<=-10) then do;
					visflag=0;
					vistext='In window';
				end;
		end;
			else if visname not in ('Screening','Day 113/Early Termination','Day 1') then do;
				if ^(visday_m3<=diff<=visday_p3) then do;
					visflag=1;
					vistext='Ocurred on day '||strip(put(diff,best.))||', outside window of day '||strip(put(visday,best.))||' +/- 3 days (day '||strip(put(visday_m3,best.))||' to '||strip(put(visday_p3,best.))||').';
				end;
					else if (visday_m3<=diff<=visday_p3) then do;
						visflag=0;
						vistext='In window';
					end;
			end;
			else if visname='Day 113/Early Termination' then do;
				if dscomp_dec='Yes' then do;
					if ^(visday_m3<=diff<=visday_p3) then do;
						visflag=1;
						vistext='Ocurred on day '||strip(put(diff,best.))||', outside window of day '||strip(put(visday,best.))||' +/- 3 days (day '||strip(put(visday_m3,best.))||' to '||strip(put(visday_p3,best.))||').';
					end;
						else if (visday_m3<=diff<=visday_p3) then do;
							visflag=0;
							vistext='In window';
						end;
				end;
					else if dscomp_dec='No' then do;
						visflag=0;
						vistext='Not compared due to early termination.';
					end;
			end;
	end;
run;

data pp_final_sv(keep=subnum visitid visname svnd_c svreasnd svstdt_c svstdt visflag vistext);
	set sv;
run;
