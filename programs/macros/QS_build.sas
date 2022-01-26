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

	proc sort;
		by subnum qsdat visitid visname;
run;

%missing_dates(dsn=qs,date=qsdat,date2=,pgmname=QS_build);

proc sort data=qs;
	by subnum qsdat_sort visitid visname;
run;

data pp_final_qs(keep=subnum visitid visname qsperf_reas qsdat qsdat_c qsdat_sort c1 c2);
	set qs;
	by subnum qsdat_sort visitid visname;

	length c1 c2 $200;
	c1="BLDJuice/Soda (pop)"; c2=' ';
	output;
	c1="Fruit juice, such as orange, apple, grape, cranberry, or others";       c2=strip(qs01_dec);
	output;
	c1="Fruit drinks, such as cranberry cocktail, Hi-C, lemonade, or Kool-Aid"; c2=strip(qs02_dec);
	output;
	c1="Regular (not sugar free) soft drinks, soda (pop)"; c2=strip(qs03_dec);
	output;
	c1="Diet or sugar free drinks, soda (pop), or fruit drinks"; c2=strip(qs04_dec);
	output;
	c1="Rate your desire"; c2=strip(qs05_dec);
	output;
	c1="BLDAlcohol"; c2=' ';
	output;
	c1="Beer (12 ounces or 355 mL)"; c2=strip(qs06_dec);
	output;
	c1="Wine/wine coolers (5 ounces or 150 mL)"; c2=strip(qs07_dec);
	output;
	c1="Hard alcohol (1.5 ounces or 50 mL)"; c2=strip(qs08_dec);
	output;
	c1="Rate your desire"; c2=strip(qs09_dec);
	output;
	c1="BLDSweet/Dessert"; c2=' ';
	output;
	c1="Muffins, doughnuts, sweet rolls, danish, or poptarts"; c2=strip(qs10_dec);
	output;
	c1="Pies, ice cream, cakes, cookies, brownies, or other types of desserts"; c2=strip(qs11_dec);
	output;
	c1="Candy, candy bars, chocolates, or chocolate bars"; c2=strip(qs12_dec);
	output;
	c1="Rate your desire"; c2=strip(qs13_dec);
	output;
run;

