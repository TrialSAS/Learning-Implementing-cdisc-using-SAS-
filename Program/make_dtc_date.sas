/*make_dtc_date.sas*/
%macro make_dtc_date(dtcdate=,year=.,month=.,day=.,
					hour=.,minute=.,second=.);
	if (&second ne .) then            
	/*second不为空，含有秒。则处理*/
		&dtcdate = put(&year,z4.)||"-"||put(&month,z2.)||"-"
			||put(&day,z2.)||"T"||put(&hour,z2.)||":"
			||put(&minute,z2.)||":"||put(&second,z2.);
	else if (&minute ne .) then
		&dtcdate=put(&year,z4.)||"-"||put(&month,z2.)||"-"
			||put(&day,z2.)||"T"||put(&hour,z2.)||":"
			||put(&minute,z2.);
	else if (&hour ne .) then
		&dtcdate=put(&year,z4.)||"-"||put(&month,z2.)||"-"
			||put(&day,z2.)||"T"||put(&hour,z2.);
	else if (&day ne .) then
		&dtcdate=put(&year,z4.)||"-"||put(&month,z2.)||"-"
			||put(&day,z2.);
	else if (&month ne .) then
		&dtcdate=put(&year,z4.)||"-"||put(&month,z2.);
	else if (&year ne .) then
		&dtcdate=put(&year,z4.);
	else if (&year = .) then
		&dtcdate="";
%mend make_dtc_date;

/*生成 2000-02-02T05:30:09 格式的日期时间*/
		