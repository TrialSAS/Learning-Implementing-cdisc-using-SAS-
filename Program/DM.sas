/*DM.sas*/
%make_empty_dataset(metadatafile=D:\SASShare\Data\github\Learning-Implementing-cdisc-using-SAS-\Program\SDTM_METADATA.xlsx,dataset=DM)

proc sort 
	data =source.dosing(keep = subject startdt enddt) out = dosing;
		by subject startdt;
run;

data dosing;
	set dosing;
	by subject;
	
	retain firstdose lastdose;

	if first.subject then 
		do;
			firstdose=.;
			lastdose=.;
		end;
	firstdose=min(firstdose,startdt,enddt);
	lastdose=max(lastdose,startdt,enddt);

	if last.subject;
run;

proc sort	
	data = source.demographic 
	out = demographic;
		by subject;
run;

data demog_dose;
	merge 	demographic
			dosing;
		by subject;
run;

options missing = "";
data dm;
	set EMPTY_DM demog_dose(rename = (race=_race));

	studyid="XYZ123";
	domain='DM';
	usubjid=left(uniqueid);
	subject=put(subject,3.);
	rfstdtc=put(subject,3.);
	rfendtc=put(lastdose,yymmdd10.);
	rfxstdtc=put(firstdose,yymmdd10.);
	rfxendtc=put(lastdose,yymmdd10.);
	rficdtc=put(lastdoc,yymmdd10.);
	rfpendtc=put(lastdoc,yymmdd10.);
	dthf1="N";
	siteid=substr(subjid,1,1)||"00";
	brthdtc=put(dob,yymmdd10.);
	age=floor((intck('month',dob,firstdose)-(day(firstdose)<day(dob)))/12);

	if age ne . then
		ageu="YEARS";
	sex=put(gender,sex_demographic_gender.);
	race=put(_race,race_demographic_race.);
	armcd=put(trt,arm_demographic_trt.);
	actarmcd=put(trt,armcd_demographic_trt.);
	actarm=put(trt,arm_demographic_trt.);
	country="USA";
run;



			