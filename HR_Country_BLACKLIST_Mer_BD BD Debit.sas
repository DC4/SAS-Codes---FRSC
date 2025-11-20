
*******************************************************************
			HR_Country_BLACKLIST_Mer_BD BD Debit

*******************************************************************;

LIBNAME IND "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

PROC DELETE DATA = BD_BLACKLISTED_MERCHANTS; RUN;

%MACRO HOTLIST();

%do i=27 %to 30;

PROC IMPORT DATAFILE="Z:\Sumeet\R_Simulation\Hotlist\data (&i.).XLS"
OUT=data&i. DBMS=XLS REPLACE;namerow=2;
startrow=3;RUN;

PROC APPEND BASE=BD_BLACKLISTED_MERCHANTS DATA=data&i. FORCE;RUN;

%end;
%MEND;

%HOTLIST();

/*PROC IMPORT DATAFILE="C:\Users\1586087\Downloads\BD_BLACKLISTED_MERCHANTS (2).xls"*/
/*OUT=BD_BLACKLISTED_MERCHANTS DBMS=XLS REPLACE;RUN;*/

/*LIBNAME IND "C:\Users\1586087\Documents\Daily_datasets\debit";*/

DATA  FALT002;
SET IND.falt002_db_15SEP;   
WHERE  (CRD_CLNT_ID = "SC_SPARROWBD_DB" and TRN_AUTH_POST = "A" and
(AUTH_DECISION_XCD = "A" or ((AUTH_DECISION_XCD)= "" and DECI_CD_ORIG = "A")) and
TRN_TYP IN ("C"  "M"  "P") AND TRN_POS_ENT_CD NOT IN ("V" "D"));
RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SQL;
CREATE TABLE FALT002_2 AS
SELECT * FROM FALT002 WHERE
STRIP(MER_ID) IN (SELECT DISTINCT NAME FROM BD_BLACKLISTED_MERCHANTS);
QUIT;



DATA HR_Cntry_BLACKLIST_Mer_BDSAS;
    SET FALT002_2;
    IF (CRD_CLNT_ID = "SC_SPARROWBD_DB" and TRN_AUTH_POST = "A" and
(AUTH_DECISION_XCD = "A" or (AUTH_DECISION_XCD= "" and DECI_CD_ORIG = "A")) and
TRN_TYP IN ("C"  "M"  "P") and SUBSTR(USR_IND_4,1,2) NE "Y2" and
TRN_POS_ENT_CD NE "V" )
       THEN HR_Cntry_BLACKLIST_Mer_BD = "Y";
RUN;

DATA HR_Cntry_BLACKLIST_Mer_BD;
SET HR_Cntry_BLACKLIST_Mer_BDSAS;
WHERE HR_Cntry_BLACKLIST_Mer_BD = "Y" and date1 GE "15SEP2021"D;
RUN;

DATA HR_Cntry_BLACKLIST_Mer_BD_RL;
     SET IND.falt003_db_15SEP ;
       WHERE UPCASE(RULE_NAME_STRG) IN ('HR_COUNTRY_BLACKLIST_MER_BD') and date1 GE "15SEP2021"D;
RUN;

PROC SORT DATA=HR_Cntry_BLACKLIST_Mer_BD_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=HR_Cntry_BLACKLIST_Mer_BD;TITLE "HR_Cntry_BLACKLIST_Mer_BD SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=HR_Cntry_BLACKLIST_Mer_BD_RL; TITLE "HR_Cntry_BLACKLIST_Mer_BD FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 


/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\HR_Country_BLACKLIST_Mer_BD BD Debit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = HR_Cntry_BLACKLIST_Mer_BD;TITLE "HR_Country_BLACKLIST_Mer_BD  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = HR_Cntry_BLACKLIST_Mer_BD_RL; TITLE "HR_Country_BLACKLIST_Mer_BD  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= HR_Cntry_BLACKLIST_Mer_BD
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Country_BLACKLIST_Mer_BD BD Debit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= HR_Cntry_BLACKLIST_Mer_BD_RL
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Country_BLACKLIST_Mer_BD BD Debit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;