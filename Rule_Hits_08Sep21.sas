

								/********* CREDIT *********/


OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Credit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA RULE_DATA_CR_1;
SET 
INC.falt003_cr_28AUG;
WHERE UPCASE(RULE_NAME_STRG) IN 
(
'BYPASS_LOW_RISK_CNP_HK'
) and 
/*CLIENT_XID NOT IN ("SC_C400BD_CR" "SC_PMTHK_CR" "SC_CCMSHK_CR" "SC_CCMSTW_CR")*/
CLIENT_XID = "SC_CCMSHK_CR"
and date1 GE "28AUG2021"D;
RUN;


DATA RULE_DATA_CR_2;
SET 
INC.falt003_cr_28AUG;
WHERE UPCASE(RULE_NAME_STRG) IN 
(
'XCNI_BYPASS_LOW_RISK_CNP_HK'
) and 
/*CLIENT_XID NOT IN ("SC_C400BD_CR" "SC_PMTHK_CR" "SC_CCMSHK_CR" "SC_CCMSTW_CR")*/
CLIENT_XID = "SC_PMTHK_CR"
and date1 GE "28AUG2021"D;
RUN;


DATA RULE_DATA_CR;
SET RULE_DATA_CR_1 RULE_DATA_CR_2;
RUN;

PROC SORT DATA = RULE_DATA_CR NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = RULE_DATA_CR; TITLE "DATA FOR FALCON CREDIT";
TABLE RULE_NAME_STRG*CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 



								/********* DEBIT *********/


OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

DATA RULE_DATA_DB;
SET 
INC.falt003_db_28AUG;
WHERE UPCASE(RULE_NAME_STRG) IN 
(
'BYPASS_LOW_RISK_CNP_HK'
) and 
/*CLIENT_XID NOT IN ("SC_SPARROWBD_DB" "SC_HOGANHK_DB" "SC_TANDEMTW_DB" "SC_EURONETID_DB")*/
CLIENT_XID = "SC_HOGANHK_DB"
and date1 GE "28AUG2021"D;
RUN;

PROC SORT DATA = RULE_DATA_DB NODUPKEY; 
BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = RULE_DATA_DB; 
TITLE "DATA FOR FALCON DEBIT";
TABLE RULE_NAME_STRG*CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; 
RUN; 

/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_CR_DR_29AUG_Type_1.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
ods excel close;
ods listing close;

PROC EXPORT DATA= RULE_DATA_DB
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_CR_DR_29AUG_Type_1.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA_DB";
run;

PROC EXPORT DATA= RULE_DATA_CR
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_CR_DR_29AUG_Type_1.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA_CR";
run;


/***********************************************************/
