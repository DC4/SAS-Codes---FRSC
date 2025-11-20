
LIBNAME CH1 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Falcon 6.4 Monthly Data";
/*LIBNAME CH1 "Z:\Falcon 6.4 data download\FRD15";*/
LIBNAME CH2 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\CR";
LIBNAME CH3 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\DB";

PROC SORT DATA = CH1.FRD15 NODUPKEY OUT=FRD15;
BY fiTransactionIdReference;
WHERE  clientIdFromHeader  IN ("SC_EURONETIN_DB" "SC_CCMSIN_CR") AND DATE="25NOV2021"D;
RUN;

libname ch2 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\CR";

PROC SQL;
CREATE TABLE CR AS 
SELECT * FROM 
ch2.falt002_cr_25nov
where substr(usr_ind_4,1,2) = "Y2"  AND DATE1="25NOV2021"D and 
(
(frd_ind in ("Y" "D") and crd_clnt_id = "SC_CCMSIN_CR") OR
FI_TRANSACTION_ID IN (SELECT DISTINCT fiTransactionIdReference FROM FRD15)
);
run;

proc sort data=CR nodupkey; by fi_transaction_id; run;


libname ch3 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\DB";

PROC SQL;
CREATE TABLE DB AS 
SELECT * FROM 
ch3.falt002_db_25nov
where substr(usr_ind_4,1,2) = "Y2"  AND DATE1="25NOV2021"D and 
(
(frd_ind in ("Y" "D") and crd_clnt_id = "SC_EURONETIN_DB") OR
FI_TRANSACTION_ID IN (SELECT DISTINCT fiTransactionIdReference FROM FRD15)
);
run;

proc sort data=DB nodupkey; by fi_transaction_id; run;



/* Writing Output to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\IN_3D_Secured_25NOV2021.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");

ods excel close;
ods listing close;

PROC EXPORT DATA= FRD15
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\IN_3D_Secured_25NOV2021.xlsx"
dbms=xlsx replace;
sheet="FRD15";
run;


PROC EXPORT DATA= CR
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\IN_3D_Secured_25NOV2021.xlsx"
dbms=xlsx replace;
sheet="CR";
run;

PROC EXPORT DATA= DB
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\IN_3D_Secured_25NOV2021.xlsx"
dbms=xlsx replace;
sheet="DB";
run;
