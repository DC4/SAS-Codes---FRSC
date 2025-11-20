
*************************************************************

			HR_Global_Blacklistingn1_TW TW Debit

**************************************************************;

LIBNAME IND "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

PROC IMPORT DATAFILE="Z:\Sumeet\R_Simulation\Hotlist\Hotlist_160921.XLSX"
OUT=BLACKLISTED_MERCHANTS_DEBIT DBMS=XLSX REPLACE;
RUN;

DATA FALT002;
     SET IND.falt002_DB_15sep;
     WHERE (CRD_CLNT_ID IN ("SC_TANDEMTW_DB") AND TRN_AUTH_POST = "A" AND 
	 MER_CNTY_CD NE "158" AND SUBSTR(USR_DAT_2,9,1) NOT IN ("L" "E" "N" "S" "F") AND
     (AUTH_DECISION_XCD = "A" OR (AUTH_DECISION_XCD = "" AND DECI_CD_ORIG = "A")) AND TRN_TYP IN ("C"  "M"  "P")
	 AND TRN_POS_ENT_CD NOT IN ("V" "D")) ;
     FORMAT TRAN_DATE DATE9.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
RUN;

PROC SORT DATA=FALT002 OUT=FALT002_1 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SQL;
CREATE TABLE TXN_DATA AS
SELECT * FROM FALT002_1 
WHERE COMPRESS(MER_ID) IN (SELECT DISTINCT NAME FROM BLACKLISTED_MERCHANTS_DEBIT) OR
MER_ID IN ("4445091120618" "4445090874552") OR 
(MER_ID IN ("000812770010915" "000812770010917" "000812770010918" "000812770010919" "000812770010920") AND TRN_AMT GE 5000);
QUIT;

     DATA RULE_DATA;
     SET IND.falt003_DB_15sep ;
     WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_BLACKLISTINGN1_TW') ;
     RUN;

     PROC SORT DATA = RULE_DATA NODUPKEY ;BY FI_TRANSACTION_ID; RUN;


     PROC FREQ DATA=TXN_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test SAS"; 
     TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;

     PROC FREQ DATA=RULE_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test FALCON HITS"; 
     TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;


	 
/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Debit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "HR_Global_Blacklistingn1_TW_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Debit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Debit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;