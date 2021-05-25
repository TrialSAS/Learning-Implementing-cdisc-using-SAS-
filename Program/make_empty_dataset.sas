%macro make_empty_dataset(metadatafile=,dataset=);
proc import
	datafile="&metadatafile"
	out=_temp
	dbms=excelcs;
	sheet="VARIABLE_METADATA";
run;

proc sort
	data=_temp;
	where domain="&dataset";
	/*如，只选取DM */
	by varnum;
run;

%global &dataset.KEEPSTRING;


/*This DATA step loads the domain metadata that we need into VAR*, LABEL*, LENGTH*,
and TYPE* macro parameters for each variable in the domain to be used in the next step.*/
data _null_;
	set _temp nobs=nobs end=eof;
	/*nobs=变量，   nobs=创建一个临时变量，值为观测的总数。*/
	/*end= 创建一个临时变量eof，表示“end-of-file”到了文件尾部。*/
	/*变量eof的初始值为0，当达到文件尾时，值为1 .*/
	
	if _n_=1 then 
	/* _n_ 的值 表示读取数据时的迭代次数。*/
	
		call symput("vars",compress(put(nobs,3.)));
		/*语法： CALL SYMPUT(macro-variable, value); 将值value赋值给宏变量。*/
		/*表示在第一次读取数据时，将被读取数据的总观测数赋值给宏变量vars。*/
		
	call symputx('var'||compress(put(_n_,3.)),variable);
	/*语法： CALL SYMPUTX(macro-variable, value <, symbol-table>); */
	/*将值赋值给宏变量，同时移除首尾的空格。*/
	
	/*compress()表示从原始字符串中删除指定的字符后返回一个新的字符串。*/
	/*语法： COMPRESS(character-expression<, character-list-expression>) */
	
	call symputx('label'||compress(put(_n_,3.)),label);
	call symputx('length'||compress(put(_n_,3.)),put(length,3.));
	
	
	if upcase(type) in ("INTEGER","FLOAT") then 
		call symputx('type' || compress(put(_n_,3.)),"");
	else if upcase(type) in ("TEXT","DATE","DATETIME","TIME") then
		call symputx('type' || compress(put(_n_,3.)),"$");
	else 
		put "ERR" "OR:not using a valid ODM type." type=;

	/*This section is responsible for defining the **KEEPSTRING global macro variable, which
will be used in the actual domain creation code later.*/
	length keepstring $32767;
	retain keepstring;
	keepstring=compress(keepstring)||"|" ||left(variable);
	/*一直将keepstring的值拼接。*/
	
	if eof then   /*读取到文件尾*/
		call symputx(upcase(compress("&dataset"||'KEEPSTRING')),   
			left(trim(translate(keepstring," ","|"))));
		/*大写*/   /*translate()替换字符串中指定的character。这里换成"|"*/
run;

/*This DATA step defines the SAS work EMPTY_** dataset, which is the shell of the domain
that we will populate later.*/
/*此数据步骤将需要的域元数据加载到域中每个变量的VAR*、LABEL*、LENGTH*和TYPE*宏参数中，
以便在下一步中使用*/
data EMPTY_&dataset;
	%do i=1 %to &vars;
		attrib &&var&i label = "&&label&i"
			length = &&type&i.&&length&i...
		;
		%if &&type&i=$ %then
			retain &&var&i '';
		%else
			retain &&var&i .;
		;
	%end;
	if 0;
run;

%mend make_empty_dataset;

