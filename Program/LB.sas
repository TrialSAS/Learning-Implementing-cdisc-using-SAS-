/*LB.sas*/
%make_empty_dataset(metadatafile=D:\SASShare\Data\github\Learning-Implementing-cdisc-using-SAS-\Program\SDTM_METADATA.xlsx,dataset=LB)

/* MISSING=<'>character<'> */
/*当遇到缺失值时打印空格。*/
options missing='';
data lb;
	set EMPTY_LB
		source.labs;

		studyid='XYZ123';
		domain='LB';
		usubjid=left(uniqueid);
		lbcat=put(labcat,$lbcat_labs_labcat.);
		/*$表示字符， lbcat_labs_labcat. 表示格式format。格式保存在WORK.EMPTY_LB下。
		语法：PUT(source, format.) */
		lbtest=put(labtest,$lbtest_labs_labtest.);
		lbtestcd=put(labtest,$lbtestcd_labs_labtest.);
		lborres=left(put(nresult,best.));
		lborresu=left(colunits);
		lbornrlo=left(put(lownorm,best.));
		lbornrhi=left(put(highnorm,best.)); /*左对齐一个字符串*/

		lbstresc=lborres;
		lbstresn=nresult;
		lbstresu=lborresu;
		lbstnrlo=lownorm;
		lbstnrhi=highnorm;

		if lbtest='Glucose' and lbcat='URINALYSIS' then
			do;
				lborres=left(put(nresult,uringluc_labs_labtest.));
				lbornrlo=left(put(lownorm,uringluc_labs_labtest.));
				lbornrhi=left(put(highnorm,uringluc_labs_labtest.));
				lbstresc=lborres;
				lbstresn=.;
				lbstnrlo=.;
				lbstnrhi=.;
			end;

		if lbtestcd='GLUC' and lbcat='URINALYSIS' and 
			lborres='POSITIVE' then
				lbnrind='HIGH';
		else if lbtestcd='GLUC' and lbcat='URINALSYS' and 
				lborres='NEGATIVE' then
					lbnrind='NORMAL';
		else if lbstnrlo ne . and lbstresn ne . and 
			round(lbstresn,.0000001)<round(lbstnrlo,.0000001) then
				lbnrind='LOW';
		else if lbstnrhi ne . and lbstresn ne . and 
			round(lbstresn,.0000001) > round (lbstnrhi,.0000001) then
				lbnrind='HIGH';
		else if lbstnrhi ne . and lbstresn ne . then 
			lbnrind = 'NORMAL';

		visitnum=month;
		visit=put(month,visit_labs_month.);

		if visit='Baseline' then
			lbblfl='Y';
		else
			lbblfl='';
		if visitnum<0 then 
			epoch='SCREENING';
		else 
			epoch='TREATMENT';
run;

proc sort
	data = lb;
		by usubjid;
run;

data lib;
	merge lb(in = inlb) target.dm(keep = usubjid rfstdtc);
		by usubjid;

		if inlb;
		%make_sdtm_dy(date=lbdtc)
run;

proc sort	
	data = lb;
		by studyid usubjid lbcat lbtestcd visitnum;
run;

data lb;
	retain &LBKEEPSTRING;
	set lb(drop = lbseq);
		by studyid usubjid lbcat lbtestcd visitnum;

	if not (first.visitnum and last.visitnum) then
		put "WARN" "ING:key variables do not define an 	unique record."
			usubjid=;
	retain lbseq 0;
	lbseq=lbseq+1;

	label lbseq="Sequence Number";
run;

