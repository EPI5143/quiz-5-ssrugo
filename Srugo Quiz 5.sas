libname in "/folders/myfolders/LargeData";
libname out "/folders/myfolders/LargeData/WorkFolder/Data";

/*Copy sorted datasets into work folder*/
proc sort data=in.NhrAbstracts  out=out.NhrAbstracts nodupkey;
	by hraEncWID;
run;

proc sort data=in.NhrDiagnosis  out=out.NhrDiagnosis;
	by hdghraencwid;
run;

/*Creating spine dataset*/
data out.spine (keep=hraAdmDtm hraEncWID);
	set out.NhrAbstracts;
	if hraAdmDtm ne .;
	if year(datepart(hraAdmDtm)) in (2003, 2004);
	by hraEncWID;
run;

/*Flat filing*/
data out.diabetes (keep=hdghraencwid hdgcd dm);
	set in.NhrDiagnosis;
	by hdghraencwid;
	if first.hdghraencwid then dm=0;
	if hdgcd in:('250' 'E10' 'E11') then dm=1;
	if last.hdghraencwid then output; 
	retain dm;
run;

/*merging*/
data out.merge;
	merge 	out.spine (in=a rename=(hraEncWID=id))
			out.diabetes (rename=(hdghraencwid=id));
			by id;
	if a;
run;

/*frequency table*/
proc freq data=out.merge;
	tables dm;
run;

/*
dm	Frequency	Percent	Cumulative Frequency	Cumulative	Percent
0	1898		95.81	1898					95.81
1	83			4.19	1981					100.00
Frequency Missing = 249