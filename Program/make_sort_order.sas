%macro make_sort_order(metadatafile=,dataset=);
	
	/*从Excel文件SDTM_METADATA中导入“VARIABLE_METADATA”,数据存放到_temp*/
	proc import 
		datafile = "&metadatafile"
		out = _temp
		dbms = excelcs
		replace;
		sheet = "VARIABLE_METADATA";
	run;
	/*排序*/
	proc sort
		data = _temp;
		where keysequence ne . and domain="&dataset";
		by keysequence;
	run;
	/*创建全局宏变量DM.sortstring*/
	%global &dataset.sortstring;
	data test;
		set _temp end =  eof;
		length domainkeys $200;
		retain domainkeys '';

		domainkeys=trim(domainkeys)||''||trim(put(variable,8.));
		/*语法：TRIM('expression') 移除结尾空格*/
		if eof then 
			call symputx(compress("&dataset"||"SORTSTRING"),domainkeys);
			/*语法：CALL SYMPUTX(macro-variable, value <, symbol-table>);*/
			/*分配值到一个宏变量，同时移除首尾空格。*/
	run;
%mend make_sort_order;
	
