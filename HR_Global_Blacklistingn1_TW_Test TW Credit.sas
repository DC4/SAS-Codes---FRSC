
*************************************************************

			HR_Global_Blacklistingn1_TW_Test TW Credit

**************************************************************;

LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

PROC IMPORT DATAFILE="Z:\Sumeet\R_Simulation\Hotlist\Hotlist_160921.XLSX"
OUT=BLACKLISTED_MERCHANTS_DEBIT DBMS=XLSX REPLACE;
RUN;


DATA FALT002;
     SET INC.falt002_CR_15sep ;    
WHERE CRD_CLNT_ID="SC_CCMSTW_CR"  AND MER_CNTY_CD NE "158" and TRN_AUTH_POST = "A" and TRN_POS_ENT_CD NOT IN ("V" "D") and
(AUTH_DECISION_XCD = "A" or (AUTH_DECISION_XCD="" and DECI_CD_ORIG = "A"));
FORMAT TRAN_DATE DATE9.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
RUN;

PROC SORT DATA=FALT002 NODUPKEY;BY FI_TRANSACTION_ID;RUN;

PROC SQL;
CREATE TABLE TXN_DATA AS
SELECT * FROM FALT002 
WHERE 
(
MER_CNTY_CD NE "158" and
TRN_AUTH_POST = "A" and
TRN_POS_ENT_CD NOT IN ("V" "D") and
(
AUTH_DECISION_XCD = "A" or
(AUTH_DECISION_XCD="" and DECI_CD_ORIG = "A")
) and
TRN_TYP IN ("C" "M" "P") and
SUBSTR(USR_DAT_2,9,1) NOT IN ("L" "E" "N" "S" "F") and
(
COMPRESS(MER_ID) IN (SELECT DISTINCT NAME FROM BLACKLISTED_MERCHANTS_DEBIT) or
MER_ID IN ("4445090874552"  "4445091120618") or
(
MER_ID IN ("000812770010915"  "000812770010917"  "000812770010918"  "000812770010919" 
"000812770010920 ") and
TRN_AMT >=5000
)
)
);
QUIT;



     DATA RULE_DATA;
     SET INC.falt003_CR_15sep ;
     WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_BLACKLISTINGN1_TW')  ;
     RUN;

     PROC SORT DATA = RULE_DATA NODUPKEY ;BY FI_TRANSACTION_ID; RUN;


     PROC FREQ DATA=TXN_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test SAS"; 
     TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;

     PROC FREQ DATA=RULE_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test FALCON HITS"; 
     TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;



/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "HR_Global_Blacklistingn1_TW_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "HR_Global_Blacklistingn1_TW_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Blacklistingn1_TW_Test TW Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;



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


/* 1 - Getting txns in Falcon not in SAS */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT SCORE_CUSTOMER_ACCOUNT_XID, FI_TRANSACTION_ID, CLIENT_XID FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
TXN_DATA);
QUIT;


DATA TXN_CHECK;
SET 
FALT002;
WHERE FI_TRANSACTION_ID IN 
(
'0061416d0b005008'
'0361416d3100109a'
'0361416d310011e7'
'1e614193ba00257d'
'1f6141a34400298b'
'1f6141a3440029a8'
'216141918c000593'
'216141a370001674'
'216141a370008645'
);
RUN;


/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_cr_15sep;
WHERE FI_TRANSACTION_ID IN 
(
'0061416d0b005008'
'0361416d3100109a'
'0361416d310011e7'
'1e614193ba00257d'
'1f6141a34400298b'
'1f6141a3440029a8'
'216141918c000593'
'216141a370001674'
'216141a370008645'
) and
UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_BLACKLISTINGN1_TW_TEST');
RUN;


/* 3 - Genuine list check */

DATA CASACTN;
SET
INC.casactn_cr_15SEP;
WHERE ACCT_NBR IN 
(
"4377229545366470"
"4688147294739917"
"5436775723449368"
"4377229543847503"
"4377229544035637"
"4377229544016389"
"4377229544428558"
"4377229543623778"
"4377229543102827"
) and date1 ge "15SEP2021"d;
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

/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE NOT_IN_FALCON AS*/
/*SELECT * FROM HR_GLOBAL_BLACKLISTINGN1_TW */
/*WHERE FI_TRANSACTION_ID not IN (SELECT DISTINCT FI_TRANSACTION_ID FROM RULE_DATA);*/
/*QUIT;*/
/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE NOT_IN_SAS AS*/
/*SELECT * FROM FALT002_1 WHERE FI_TRANSACTION_ID IN*/
/*(SELECT FI_TRANSACTION_ID FROM RULE_DATA */
/*WHERE FI_TRANSACTION_ID not IN (SELECT DISTINCT FI_TRANSACTION_ID FROM HR_GLOBAL_BLACKLISTINGN1_TW));*/
/*QUIT;*/
/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE OTHER_RULE AS*/
/*SELECT * FROM INC.FALT003_CR_15Sep*/
/*WHERE FI_TRANSACTION_ID IN (SELECT DISTINCT FI_TRANSACTION_ID FROM NOT_IN_FALCON) AND*/
/*SUBSTR(UPCASE(RULE_NAME_STRG),1,2) IN ('VH' 'HR');*/
/*QUIT;*/
/**/
/*PROC SQL;*/
/*CREATE TABLE MISMATCH AS*/
/*SELECT * FROM NOT_IN_FALCON*/
/*WHERE FI_TRANSACTION_ID NOT IN (SELECT DISTINCT FI_TRANSACTION_ID FROM OTHER_RULE);*/
/*QUIT;*/
/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE GENUINE AS*/
/*SELECT * FROM INC.casactn_tw_cr_sep2021*/
/*WHERE ACCT_NBR IN (SELECT DISTINCT ACCT_NBR FROM MISMATCH);*/
/*QUIT;*/
/**/

