data lb;
	merge lb(in = inlb) target.dm(keep = usubjid rfstdtc);
		by usubjid;
			if inlb;
		%make_sdtm_dy(date=lbdtc)
run;