proc import 
	datafile = "D:\SASShare\Data\github\Learning-Implementing-cdisc-using-SAS-\Program\SDTM_METADATA.xlsx"
	/*datafile的值为：“文件完整路径和文件名”或“libref”*/
	out = formatdata
	dbms = excelcs
	replace;
	sheet = "CODELISTS";
RUN;

/* 创建永久数据集formatdata*/
data data.formatdata;
	set formatdata(drop = type);
		where sourcedataset ne  "" and sourcevalue ne "" ;
		keep fmtname start end label type;
		length fmtname $ 32 start end $ 16 label $200 type $ 1;
		fmtname=compress(codelistname || "_" || sourcedataset || "_" || sourcevariable);
		start=left(sourcevalue);
		end = left(sourcevalue);
		label = left(codedvalue);
		if upcase(sourcetype)="NUMBER" then 
			type ="N";
		ELSE IF upcase(sourcetype)="CHARACTER" then
			type="C";
run;

proc format
	library = library 
	/*library指定一个包含了informats 或 formats的SAS library或目录，之后的cntlin会用到。*/
	cntlin = source.formatdata
	/*CNTLIN 表示：Input control SAS data set*/
	/*cntlin  指定一个SAS数据集，该数据集用来构建informats 或 formats    */
	fmtlib;
	/*打印使用LIBRARY= 功能指定的目录中的informats或formats的信息。*/
run;
