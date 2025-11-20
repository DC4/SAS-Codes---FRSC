
PROC EXPORT DATA= CASACTN
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname Global Credit.xlsx"
dbms=xlsx replace;
sheet="CASACTN";
run;

PROC EXPORT DATA= OTHER_RULE
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname Global Credit.xlsx"
dbms=xlsx replace;
sheet="OTHER_RULE";
run;

/*CROSS CHECK* - 5 STEPS */

/********************** cross check 4 STEPS ***********************/

/* 1 - Getting txns in SAS not in Falcon */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT ACCT_NBR, FI_TRANSACTION_ID, MER_ID, CRD_CLNT_ID FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
RULE_DATA);
QUIT;


/* 1 - Getting txns in Falcon not in SAS */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT SCORE_CUSTOMER_ACCOUNT_XID, FI_TRANSACTION_ID, CLIENT_XID FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
TXN_DATA);
QUIT;

/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_cr_28jun
INC.falt003_cr_29jun;
WHERE FI_TRANSACTION_ID IN 
(
'0060db305f0020d8'
'0060db305f00215b'
'0060db305f0021f0'
'0060db305f0022cf'
'0060db305f00240d'
) and
UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_MID_MERCHANTNAME');
RUN;


/* 3 - Genuine list check */

DATA CASACTN;
SET INC.casactn_cr_28jun
INC.casactn_cr_29jun;
WHERE ACCT_NBR IN 
(
"5447290210320252"
) and date1 ge "28JUN2021"d;
RUN;