/*make_sdtm_dy.sas宏程序使用两个SDTM --DTC日期 计算出一个SDTM study day（--DY）变量。*/
/*该宏程序必须使用在：date步，在变量REFDATE和DATE被指定之后才使用。*/
/*refdate 基线日期，类似reference date，*/

%macro make_sdtm_dy(refdate=RESTDTC,date=);
	if length(&date)>=10 and length(&refdate)>=10 then
		do;
			if input(substr(%substr("&date",2,%length(&date)-
				3)dtc,1,10),yymmdd10.) >=
				input(substr(%substr("&refdate",2,%length(&refdate)-3)dtc,1,10),yymmdd10.) then
				/*SUBSTR(matrix, position <, length> ); 表示从matrix中从position开始，截取length长度的字段形成新的string。*/
				
					%upcase(%substr("&date",2,%length(&date)-3))DY =	
					input(substr(%substr("&date",2,%length(&date)-3)dtc,1,10),yymmdd10.)-
					input(substr(%substr("&refdate",2,%length(&refdate)-3)dtc,1,10),yymmdd10.)+1;
			
			else
				%upcase(%substr("&date",2,%length(&date)-3))DY =	
				input(substr(%substr("&date",2,%length(&date)-3)dtc,1,10),yymmdd10.)-
				input(substr(%substr("refdate",2,%length(&refdate)-3)dtc,1,10),yymmdd10.);
		end;
%mend make_sdtm_dy;
