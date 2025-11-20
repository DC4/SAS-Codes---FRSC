
/*CROSS CHECK* - 5 STEPS */


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


/********************** cross check 6 STEPS ***********************/

/* 1 - Getting txns in SAS not in Falcon */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT ACCT_NBR, FI_TRANSACTION_ID, MER_ID, CRD_CLNT_ID FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
RULE_DATA);
QUIT;

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT * FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
RULE_DATA);
QUIT;


/* 1 - Getting txns in Falcon not in SAS */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT SCORE_CUSTOMER_ACCOUNT_XID, FI_TRANSACTION_ID, CLIENT_XID FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
TXN_DATA);
QUIT;

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT * FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
TXN_DATA);
QUIT;


DATA TXN_CHECK;
SET 
FALT002;
WHERE FI_TRANSACTION_ID IN 
(
'0060cca6d402f4ee',
'1e60cca61502dc17',
'2060cca6140444cf'
);
RUN;


/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_cr_05jun
INC.falt003_cr_06jun;
WHERE FI_TRANSACTION_ID IN 
(
'0160ba4fce04a3b0'  /*GBL - Caseaction*/
'1f60ba4ef6048fd4'   /*GBL - Caseaction*/
'2060ba4ef604027c' /*High priority rule HK*/
'2160ba4f2804239b' /* VIP Genuine */
) and
UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_MID_MERCHANTNAME');
RUN;


/* 3 - Genuine list check */
/*
1. Check for USER_ID as "fal" and LAST_UPDATED_DTTM as before TXN time and ACT_DETAIL as "NOT_FRAUD"
2. Check for USER_ID as some number other than "fal" and check if ACT_DETAIL as "NOT_FRAUD" then check in HOTLIST
*/

DATA CASACTN;
SET 
INC.casactn_cr_13dec;
WHERE INDEX(USER_ID,"fal") > 0 and INDEX(UPCASE(ACT_DETAIL),"NOT_FRAUD")> 0;
RUN;


DATA CASACTN_CHK;
SET 
INC.casactn_cr_13dec;
WHERE ACCT_NBR in(
/*"4058038018985898"*/
/*"4509360650948611"*/
/*"5523438414807809"*/
/*"5523438413017798"*/

"4028743400520388"
"4028743400531138"

);
RUN;

DATA CASACTN;
SET INC.casactn_cr_05jun
INC.casactn_cr_06jun;
WHERE ACCT_NBR IN 
(
"5523024972177197" /*GBL - Caseaction*/
"5523024972177197" /*GBL - Caseaction*/
"4509360641073065" /*High priority rule HK*/
"5523438412256975" /* VIP Genuine */
) and date1 ge "05JUN2021"d;
RUN;

/* 4 - If not solved in previous steps chec those ACCT_NBRs here*/
/* MER_ID or Name extraction for ACCT_NBS in SAS not in Falcon*/

PROC SQL;
CREATE TABLE VIP AS 
SELECT distinct(MER_ID), FI_TRANSACTION_ID FROM Txn_Data where ACCT_NBR in
(
'5523438412256975'
);
RUN;

/* 5 - Check if the ACCT_NBR is present in VIP list (Case manager)*/

DATA VIP_LIST;
SET LOOKUP_DATA;
WHERE
NAME IN(
'484767000200403'
'EP86CJLWQYAQGJM'
);
RUN;


DATA UDV_Mismatch;
SET TEMP_TXN_DATA;
WHERE FI_TRANSACTION_ID IN 
(
'0060df0d5a00840e'
'0060df0d5a038513'
'0060df0d5a03854d'
);
RUN;

PROC EXPORT DATA= UDV_Mismatch
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_CNP_Google_Facebook_Test BD Credi.xlsx"
dbms=xlsx replace;
sheet="UDV_Mismatch";
run;

/********************** cross check 6 STEPS ***********************/