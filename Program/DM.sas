/*DM.sas*/
/*第一步：创建一个空的DM数据集*/
%make_empty_dataset(metadatafile=D:\SASShare\Data\github\Learning-Implementing-cdisc-using-SAS-\Program\SDTM_METADATA.xlsx,dataset=DM)

/*dosing记录了受试者编号，给药剂量，给药日期时间。*/

/*GET FIRST AND LAST DOSE DATE FOR RFSTDTC AND RFENDTC; */
proc sort 
	data =source.dosing(keep = subject startdt enddt) out = dosing;
		by subject startdt;
run;

/**/
data dosing;
	set dosing;
	by subject;
	
	retain firstdose lastdose;
	/*在DATA步中，SAS会创建两个临时变量FIRST.variable 和  LAST.variable，来鉴别每个BY group的开始和结束。*/
	/*比如，这里by后面的变量是subject，所以SAS会自动生成两个临时变量：FIRST.subject，LAST.subject*/
	/*当一个观测是一个BY GROUP中的第一个观测时，FIRST.subject值为1*/
	if first.subject then 
		do;
			firstdose=.;
			lastdose=.;
		end;
	firstdose=min(firstdose,startdt,enddt);
	lastdose=max(lastdose,startdt,enddt);
	/*startdt表示"Dosing start date"，enddt="Dosing end date"*/

	if last.subject;
run;

/*demographic中包含的变量有：subject,trt,gender,race,orace,dob,uniqueid,randdt,icdate,lastdoc*/
proc sort	
	data = source.demographic 
	out = demographic;
		by subject;
run;

/*合并后，demog_dose的变量为：subject,trt,gender,race,orace,dob,uniqueid,randdt,icdate,lastdoc,startdt,
enddt,firstdose,lastdose*/
data demog_dose;
	merge 	demographic
			dosing;
		by subject;
run;


****derive the majority of sdtm dm variables.;
/*衍生出主要的SDTM DM 的变量。 新建变量STUDYID,DOMAIN,USUBJID...etc.*/
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


PROC SORT	
	data = dm(keep = &DMKEEPSTRING)
	out =target.dm;
		by &DMSORTSTRING;
run;

			
