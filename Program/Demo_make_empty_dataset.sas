%make_empty_dataset(metadatafile=D:\SASShare\Data\github\Learning-Implementing-cdisc-using-SAS-\Program\SDTM_METADATA.xlsx,dataset=DM);

proc contents
	data = work.empty_dm;
run;
