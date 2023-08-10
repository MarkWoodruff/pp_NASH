/*****************************************************************************************/
* Program Name  : QS_build.sas
* Project       : BOS-580-201
* Programmer    : Mark Woodruff
* Creation Date : 2021-10-19
* Description   : build temporary dataset for QS (Monthly Questionnaire) domain
*
* Revision History
* Date       By            Description of Change
* 2021-10-26 Mark Woodruff add flagging for dates not matching SV.
* 2021-11-09 Mark Woodruff move call to check_dates to report program from build program.
* 2022-01-18 Mark Woodruff edit sort order for missing dates.
* 2022-02-14 Mark Woodruff add VISITSEQ to missing dates call.
* 2023-04-20 Mark Woodruff add highlighting to increases in consumption.
* 2023-04-26 Mark Woodruff add highlighting for increases in 'rate your desire'.
******************************************************************************************;

data _null_;
	set crf.qs(encoding=utf8 where=(pagename='Monthly Visit Questionnaire'));

	** ensure DELETED var is being handled correctly **;
	if deleted^='f' then put "ER" "ROR: update QS_build.sas to handle QS.DELETED var appropriately.";

	*if qsdat=. then put "ER" "ROR: update QS_build.sas to handle missing dates in sorting.";
run;

data qs;
	set crf.qs(encoding=utf8 where=(pagename='Monthly Visit Questionnaire' and deleted='f'));

	length qsperf_reas $700;
	qsperf_reas=catx(': ',qsperf_dec,qsreasnd);

	length qsdat_c $12;
	if qsdat>.z then qsdat_c=strip(put(qsdat,yymmdd10.));

	format qs01-qs13;
	if qs01=7 then qs01=.;
	if qs02=7 then qs02=.;
	if qs03=7 then qs03=.;
	if qs04=7 then qs04=.;
	if qs06=7 then qs06=.;
	if qs07=7 then qs07=.;
	if qs08=7 then qs08=.;

	proc sort;
		by subnum qsdat visitid visitseq visname;
run;

%missing_dates(dsn=qs,date=qsdat,date2=,pgmname=QS_build);

proc sort data=qs;
	by subnum qsdat_sort visitid visitseq visname;
run;

** flag increases for Jose **;
data qs;
	set qs;
	by subnum qsdat_sort visitid visitseq visname;

	retain bl_01 bl_02 bl_03 bl_04 bl_05 bl_06 bl_07 bl_08 bl_09 bl_10 bl_11 bl_12 bl_13;
	if first.subnum then do;
		bl_01=.;
		bl_02=.;
		bl_03=.;
		bl_04=.;
		bl_05=.; ** desire **;

		bl_06=.;
		bl_07=.;
		bl_08=.;
		bl_09=.; ** desire **;

		bl_10=.;
		bl_11=.;
		bl_12=.;
		bl_13=.; ** desire **;
	end;

	if visname='Day 1' then do;
		bl_01=qs01;
		bl_02=qs02;
		bl_03=qs03;
		bl_04=qs04;
		bl_05=qs05;

		bl_06=qs06;
		bl_07=qs07;
		bl_08=qs08;
		bl_09=qs09;

		bl_10=qs10;
		bl_11=qs11;
		bl_12=qs12;
		bl_13=qs13;
	end;
		else if visname='Day 29' and (bl_01=. and bl_02=. and bl_06=.) then do;
			bl_01=qs01;
			bl_02=qs02;
			bl_03=qs03;
			bl_04=qs04;
			bl_05=qs05;

			bl_06=qs06;
			bl_07=qs07;
			bl_08=qs08;
			bl_09=qs09;

			bl_10=qs10;
			bl_11=qs11;
			bl_12=qs12;
			bl_13=qs13;
		end;

	%macro flag(qs=);
		length qs&qs._flag $10;
		if qs&qs.>.z and bl_&qs.>.z then do;
			if qs&qs.=bl_&qs.+1 and qs&qs.>.z and bl_&qs.>.z then qs&qs._flag='yellow';
				else if qs&qs.=bl_&qs.+2 and qs&qs.>.z and bl_&qs.>.z then qs&qs._flag='orange';
				else if qs&qs.>bl_&qs.+2 and qs&qs.>.z and bl_&qs.>.z then qs&qs._flag='red';
		end;
	%mend flag;
	** juice/pop **;
	%flag(qs=01);
	%flag(qs=02);
	%flag(qs=03);
	%flag(qs=04);
	%flag(qs=05);

	** alcohol **;
	%flag(qs=06);
	%flag(qs=07);
	%flag(qs=08);
	%flag(qs=09);

	** sweets/dessert **;
	%flag(qs=10);
	%flag(qs=11);
	%flag(qs=12);
	%flag(qs=13);
run;

data pp_final_qs(keep=subnum visitid visitseq visname qsperf_reas qsdat qsdat_c qsdat_sort c1 c2 flag);
	set qs;
	by subnum qsdat_sort visitid visname;

	length c1 c2 flag $200;
	c1="BLDJuice/Soda (pop)"; 
	c2=' '; 
	flag=' ';
	output;
	c1="Fruit juice, such as orange, apple, grape, cranberry, or others";       
	c2=strip(qs01_dec);
	flag=strip(qs01_flag);
	output;
	c1="Fruit drinks, such as cranberry cocktail, Hi-C, lemonade, or Kool-Aid"; 
	c2=strip(qs02_dec);
	flag=strip(qs02_flag);
	output;
	c1="Regular (not sugar free) soft drinks, soda (pop)"; 
	c2=strip(qs03_dec);
	flag=strip(qs03_flag);
	output;
	c1="Diet or sugar free drinks, soda (pop), or fruit drinks"; 
	c2=strip(qs04_dec);
	flag=strip(qs04_flag);
	output;
	c1="Rate your desire"; 
	c2=strip(qs05_dec);
	flag=strip(qs05_flag);
	output;
	c1="BLDAlcohol"; 
	c2=' ';
	flag=' ';
	output;
	c1="Beer (12 ounces or 355 mL)"; 
	c2=strip(qs06_dec);
	flag=strip(qs06_flag);
	output;
	c1="Wine/wine coolers (5 ounces or 150 mL)"; 
	c2=strip(qs07_dec);
	flag=strip(qs07_flag);
	output;
	c1="Hard alcohol (1.5 ounces or 50 mL)"; 
	c2=strip(qs08_dec);
	flag=strip(qs08_flag);
	output;
	c1="Rate your desire"; 
	c2=strip(qs09_dec);
	flag=strip(qs09_flag);
	output;
	c1="BLDSweet/Dessert"; 
	c2=' ';
	flag=' ';
	output;
	c1="Muffins, doughnuts, sweet rolls, danish, or poptarts"; 
	c2=strip(qs10_dec);
	flag=strip(qs10_flag);
	output;
	c1="Pies, ice cream, cakes, cookies, brownies, or other types of desserts"; 
	c2=strip(qs11_dec);
	flag=strip(qs11_flag);
	output;
	c1="Candy, candy bars, chocolates, or chocolate bars"; 
	c2=strip(qs12_dec);
	flag=strip(qs12_flag);
	output;
	c1="Rate your desire"; 
	c2=strip(qs13_dec);
	flag=strip(qs13_flag);
	output;
run;
