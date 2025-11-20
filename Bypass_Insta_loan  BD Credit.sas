**********************************************************
		Bypass_Insta_loan  Bypass_Insta_loan
				
**********************************************************;
 
/*PROC DELETE DATA=_ALL_;RUN;*/
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Credit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA TXN_DATA;
SET  
INC.falt002_cr_01JUL;
where
mer_id = '00100000024';
run;


DATA RULE_DATA;
     SET 
INC.falt003_cr_01JUL;
       WHERE CLIENT_XID = ("SC_C400BD_CR")
and date1 GE "01JUL2021"D;
RUN;

/* Checking if the transactions fetched by FALT002 are present in FALT003 */

Proc sql;
create table analysis as
Select * from FALT002 T, RULE_DATA R where T.FI_TRANSACTION_ID = R.FI_TRANSACTION_ID;
quit;


PROC FREQ DATA = TXN_DATA;TITLE "Bypass_Insta_loan  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA = RULE_DATA; TITLE "Bypass_Insta_loan  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\Bypass_Insta_loan BD Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "Bypass_Insta_loan  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "Bypass_Insta_loan  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_Insta_loan BD Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_Insta_loan BD Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;


PROC EXPORT DATA= ANALYSIS
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_Insta_loan BD Credit.xlsx"
dbms=xlsx replace;
sheet="ANALYSIS";
run;

