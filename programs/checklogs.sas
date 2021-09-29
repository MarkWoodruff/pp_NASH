/*****************************************************************************************/
* Program Name  : checklogs.sas
* Project       :  
* Programmer    : Mark Woodruff
* Creation Date : 2021-09-29
* Description   : check logs of profile runs
*
* Revision History
* Date       By            Description of Change
******************************************************************************************;

%macro checklogs(seq=,study=,pipe=,progdir=,prog=);
	filename pdir pipe &pipe. lrecl=32727;

	data names&seq.(keep=date time);
		infile pdir truncover scanover;
 		input filename $char1000.;

		length date time $10;
 		if index(filename,"&prog..log");

 		date=put(input(scan(filename,1," "),mmddyy10.),yymmdd10.);
 		time=catx(" ",scan(filename,2," "),scan(filename,3," "));
	run;

	%global logdate logtime;
	data null;
		set names&seq.;
		call symput('logdate',strip(date));
		call symput('logtime',strip(time));
	run;

	data logs&seq.(keep=study date time line);
		infile "&progdir.\&prog..log" missover pad ignoredoseof;
 		input line $1000.;

		** keep only the records that had an undesirable message **;
 		if (index(upcase(line), "WARNING") or
 	   	    index(upcase(line), "ERROR:") or
 	   	    index(upcase(line), "UNINITIALIZED") or
 	   	    index(upcase(line), "NOTE: MERGE") or
 	   	    index(upcase(line), "MORE THAN ONE DATA SET WITH REPEATS OF BY") or
 	   	    index(upcase(line), "VALUES HAVE BEEN CONVERTED") or
 	   	    index(upcase(line), "MISSING VALUES WERE GENERATED AS A RESULT") or
 	   	    index(upcase(line), "INVALID DATA") or
 	   	    index(upcase(line), "INVALID NUMERIC DATA") or
 	   	    index(upcase(line), "AT LEAST ONE W.D FORMAT TOO SMALL") or
 	   	    index(upcase(line), "ORDERING BY AN ITEM THAT DOESN'T APPEAR IN") or
 	   	    index(upcase(line), "OUTSIDE THE AXIS RANGE") or
 	   	    index(upcase(line), "RETURNING PREMATURELY") or
 	   	    index(upcase(line), "UNKNOWN MONTH FOR") or
 	   	    index(upcase(line), "QUERY DATA") or
 	   	    index(upcase(line), "??") or
 	   	    index(upcase(line), "QUESTIONABLE"))

		AND

		index(upcase(line),"WARNING: UNABLE TO COPY SASUSER REGISTRY TO WORK REGISTRY. BECAUSE OF THIS, YOU WILL NOT SEE REGISTRY CUSTOMIZATIONS")=0;

		length study date time $100;
		study="&study.";
		date="&logdate.";
		time="&logtime.";
	run;

	data dummy;
		length study date time $100 line $1000;
		study="&study.";
		date="&logdate.";
		time="&logtime.";
		line="Log clean";
	run;

	data logs_&seq.;
		merge dummy 
			  logs&seq.;
		by study date time;
	run;

	proc sort data=logs_&seq. nodupkey;
		by study date time line;
	run;

	proc print data=logs_&seq. width=min;
		var study date time line;
		title"Log Check for &study. &prog.";
	run;

	title;
%mend checklogs;

%checklogs(seq=1,
		   study=%str(BOS-580-201 Profiles),
		   pipe=%str('dir "C:\Users\markw.consultant\_projects\BOS-580-201\profiles\programs"'),
		   progdir=%str(C:\Users\markw.consultant\_projects\BOS-580-201\profiles\programs),
		   prog=%str(RunProfiles));