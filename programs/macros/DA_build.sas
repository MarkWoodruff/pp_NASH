/*****************************************************************************************/
* Program Name  : DA_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-06
* Description   : build temporary dataset for DA (Kit Assignment) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-05-16 Mark Woodruff avoid ops on miss!ng values.
******************************************************************************************;

data _null_;
	set crf.da(encoding=any);

	if pagename^='Kit Assignment' then put "ER" "ROR: update DA_build.sas to read in only Kit Assignment records.";

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update DA_build.sas to handle DA.DELETED var appropriately.";
run;

data pp_final_da(keep=subnum visitid visname dareplac_dec dadisdat_c dadistim_c dakitno1-dakitno3 dadisdat2_c dadistim2_c 
					  dst_strt dst_stop dst dadisdat dadistim dadisdattim newdttm newtm dadisdattim2 dadistim2 diff newdt newtm dstc convfoot diffc diff);
	set crf.da(encoding=any where=(pagename='Kit Assignment' and deleted='f'));

	length dadisdat_c $12;
	if dadisdat>.z then dadisdat_c=strip(put(dadisdat,yymmdd10.));

	length dadistim_c $12;
	if dadistim>.z then dadistim_c=strip(put(dadistim,time5.));

	format dadisdattim datetime20.;
	if dadisdat>.z and dadistim>.z then dadisdattim=dhms(dadisdat,0,0,dadistim);

	length dadisdat2_c $12;
	if dadisdat2>.z then dadisdat2_c=strip(put(dadisdat2,yymmdd10.));

	length dadistim2_c $12;
	if dadistim2>.z then dadistim2_c=strip(put(dadistim2,time5.));

	format dadisdattim2 datetime20.;
	if dadisdat2>.z and dadistim2>.z then dadisdattim2=dhms(dadisdat2,0,0,dadistim2);

	format dst_strt dst_stop yymmdd10.;
	if dadisdat>.z then do;
		dst_year=year(dadisdat);
		dst_strt = nwkdom(2, 1, 3, dst_year);/*DST begins 2nd Sun in March */
		dst_stop = nwkdom(1, 1,11, dst_year);/*DST ends 1st Sun in Nov */
		if dst_strt<=dadisdat<=dst_stop then dst=1;
			else if dadisdat>.z then dst=0;
	end;

	format newdttm datetime20. newdt yymmdd10. newtm time5.;
	if sitenum in (106,110,113,118) then do;
		adjust_dst=-4;
		adjust=-5;
	end;
		else if sitenum in (104,105) then do;
			adjust_dst=-6;
			adjust=-7;
		end;
		else if sitenum in (108,117) then do;
			adjust_dst=-7;
			adjust=-8;
		end;
		else if sitenum in (111,112,115) then do;
			adjust_dst=-5;
			adjust=-6;
		end;
		else if sitenum=101 then do;
			adjust_dst=-7;
			adjust=-7;
		end;
		else if sitenum>.z then put "ER" "ROR: add site.";

	if dst=1 then newdttm=(dadisdattim+(adjust_dst*60*60));
		else if dst=0 then newdttm=(dadisdattim+(adjust*60*60));
	if newdttm>.z then newdt=datepart(newdttm);
	if newdttm>.z then newtm=timepart(newdttm);

	length dstc $3;
	if dst=1 then dstc='Yes';
		else if dst=0 then dstc='No';

	*format diff time5.;
	if dadisdattim2>.z and newdttm>.z then diff=floor((dadisdattim2-newdttm)/60);

	length diffc $10;
	if diff>.z then diffc=strip(put(diff,best.));

	length convfoot $200;
	if sitenum=101 then convfoot="Site "||strip(put(sitenum,best.))||' is in Mountain Time during standard time (converted using GMT-7), and Pacific Time Zone during daylight saving time (converted using GMT-7).';
		else if sitenum in (106,110,113,118) then convfoot="Site "||strip(put(sitenum,best.))||' is in Eastern Time Zone.  Converted using GMT-5 during standard time, and GMT-4 during daylight saving time.';
		else if sitenum in (104,105) then convfoot="Site "||strip(put(sitenum,best.))||' is in Mountain Time Zone.  Converted using GMT-7 during standard time, and GMT-6 during daylight saving time.';
		else if sitenum in (108,117) then convfoot="Site "||strip(put(sitenum,best.))||' is in Pacific Time Zone.  Converted using GMT-8 during standard time, and GMT-7 during daylight saving time.';
		else if sitenum in (111,112,115) then convfoot="Site "||strip(put(sitenum,best.))||' is in Central Time Zone.  Converted using GMT-6 during standard time, and GMT-5 during daylight saving time.';

	proc sort;
		by subnum visitid visname;
run;
