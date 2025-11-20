
/* Writing Output to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_Google_CNP_VN_Test VN Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "MR_Country_Google_CNP_VN_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "MR_Country_Google_CNP_VN_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_Google_CNP_VN_Test VN Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_Google_CNP_VN_Test VN Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;

/*

proc printto log="C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_CRYPTO_Merchants1 Global Credit.txt";
run; 

PROC IMPORT DATAFILE= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_CRYPTO_Merchants1 Global Credit.txt"
OUT= outdata
DBMS=dlm
REPLACE;
delimiter=',';
GETNAMES=YES;
RUN;

DATA LOG_DATA;
SET mydata;
RUN;

PROC EXPORT DATA= outdata
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_CRYPTO_Merchants1 Global Credit.xlsx "
dbms=xlsx replace;
sheet="LOG";
run;

*/