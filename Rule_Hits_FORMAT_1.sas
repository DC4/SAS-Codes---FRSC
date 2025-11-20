/*CREDIT*/
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Credit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA RULE_DATA_CR;
SET 
INC.falt003_cr_14AUG
INC.falt003_cr_15AUG;
WHERE UPCASE(RULE_NAME_STRG) IN 
(
'MR_Merchant_ACQID_Loc_JEE_MCC_CP',
'MR_Merchant_ACQID_Loc_JEE_MCC_CP_Test'
) and 
/*CLIENT_XID NOT IN ("SC_C400BD_CR" "SC_PMTHK_CR" "SC_CCMSHK_CR" "SC_CCMSTW_CR")*/
CLIENT_XID = "SC_C400BD_CR"
and date1 GE "14AUG2021"D;
RUN;

PROC SORT DATA = RULE_DATA_CR NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = RULE_DATA_CR; TITLE "DATA FOR FALCON CREDIT";
TABLE RULE_NAME_STRG*CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 


/*DEBIT*/
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

DATA RULE_DATA_DB;
SET 
INC.falt003_db_14AUG
INC.falt003_db_15AUG;
WHERE UPCASE(RULE_NAME_STRG) IN 
(
'HR_Country_Blacklist_MER_ID ',
'HR_Country_Blacklist_MER_ID_Test ',
'HR_Global_Blacklist_Decline_All_Txn ',
'HR_Global_Blacklist_Decline_All_Txn_Test ',
'HR_Merchant_ACQID_Int_CNP ',
'HR_Merchant_ACQID_Int_CNP_Test ',
'MR_BIN_Attack_Int_CNP ',
'MR_BIN_Attack_Int_CNP_Test ',
'MR_BIN_Attack_Int_CP ',
'MR_BIN_Attack_Int_CP_Test ',
'MR_BIN_Attack_Loc_CNP',
'MR_BIN_Attack_Loc_CNP_Test'
) and 
/*CLIENT_XID NOT IN ("SC_SPARROWBD_DB" "SC_HOGANHK_DB" "SC_TANDEMTW_DB" "SC_EURONETID_DB")*/
CLIENT_XID = "SC_SPARROWBD_DB"
and date1 GE "14AUG2021"D;
RUN;

PROC SORT DATA = RULE_DATA_DB NODUPKEY; 
BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = RULE_DATA_DB; 
TITLE "DATA FOR FALCON DEBIT";
TABLE RULE_NAME_STRG*CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; 
RUN; 

/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_BD_CR_DR_16AUG.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
ods excel close;
ods listing close;

PROC EXPORT DATA= RULE_DATA_DB
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_BD_CR_DR_16AUG.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA_DB";
run;

PROC EXPORT DATA= RULE_DATA_CR
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Rule_Hits_BD_CR_DR_16AUG.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA_CR";
run;


/***********************************************************/
