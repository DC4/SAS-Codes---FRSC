
****************************************************
Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT
****************************************************;

LIBNAME DC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA FALT002;
SET

DC.FALT002_CR_16JUL;

where
CRD_CLNT_ID IN ("SC_CCMSHK_CR");
FORMAT TRAN_DATE DATE9.;
TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2));
MCC = INPUT(SIC_CD,BEST.);


	IF CRD_CLNT_ID IN ("SC_CCMSSG_CR" "SC_CCMSBN_CR") THEN USD = TRN_AMT/1.255698;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSMY_CR") THEN USD = TRN_AMT/3.221743;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSPH_CR") THEN USD = TRN_AMT/43.88082;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSTH_CR") THEN USD = TRN_AMT/32.675467;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSID_CR") THEN USD = TRN_AMT/11627.906977;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSIN_CR") THEN USD = TRN_AMT/63.75;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSTW_CR") THEN USD = TRN_AMT/30.116853;
	ELSE IF CRD_CLNT_ID IN ("SC_C400AE_CR") THEN USD = TRN_AMT/3.67;
	ELSE IF CRD_CLNT_ID IN ("SC_C400BH_CR") THEN USD = TRN_AMT/0.377132;
	ELSE IF CRD_CLNT_ID IN ("SC_C400BW_CR") THEN USD = TRN_AMT/10.2587;
	ELSE IF CRD_CLNT_ID IN ("SC_C400GH_CR") THEN USD = TRN_AMT/4.42718;
	ELSE IF CRD_CLNT_ID IN ("SC_C400JO_CR") THEN USD = TRN_AMT/0.708893;
	ELSE IF CRD_CLNT_ID IN ("SC_C400JE_CR") THEN USD = TRN_AMT/0.75;
	ELSE IF CRD_CLNT_ID IN ("SC_C400KE_CR") THEN USD = TRN_AMT/103.824;
	ELSE IF CRD_CLNT_ID IN ("SC_C400LK_CR") THEN USD = TRN_AMT/153.05;
	ELSE IF CRD_CLNT_ID IN ("SC_C400NG_CR") THEN USD = TRN_AMT/365.467;
	ELSE IF CRD_CLNT_ID IN ("SC_C400NP_CR") THEN USD = TRN_AMT/102.69;
	ELSE IF CRD_CLNT_ID IN ("SC_C400VN_CR") THEN USD = TRN_AMT/22727.50;
	ELSE IF CRD_CLNT_ID IN ("SC_C400ZM_CR") THEN USD = TRN_AMT/8.98193;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSHK_CR") THEN USD = TRN_AMT/7.8;
	ELSE IF CRD_CLNT_ID IN ("SC_C400BD_CR") THEN USD = TRN_AMT_LOCAL/83.60;

RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 OUT=FALT002_2; BY ACCT_NBR AUTH_DTTM; RUN;

%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002_2;
     SET FALT002_2;
     BY ACCT_NBR AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;

     RETAIN CUM_COUNT_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME.;

     IF FIRST.ACCT_NBR THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + USD;
           END;
           ELSE DO;
                TIME_RESET_&VAR_NAME. = AUTH_DTTM;
                CUM_COUNT_&VAR_NAME. = 1;
                CUM_AMOUNT_&VAR_NAME. = USD;
           END;
     END;


RUN;
%MEND; 

%UDV(CUM_INTERVAL        = 86400,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND 
								TRN_TYP IN ("C" "M" "P") AND 
	 						TRN_POS_ENT_CD IN ("E" "K" "G") AND
							TRN_AMT > 0),
     VAR_NAME            = CNP_DAILY);


%UDV(CUM_INTERVAL        = 86400,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND 
								TRN_TYP IN ("C" "M" "P") AND 
	 						TRN_POS_ENT_CD NOT IN ("E" "K" "G")),
     VAR_NAME            = CP_DAILY);


PROC IMPORT DATAFILE='C:\Users\1510806\Desktop\Jhilam\Hotlist\LIMIT_BASED_WHITELIST_HK.XLS'
DBMS = XLS
OUT = LOOKUP_DATA
REPLACE;
RUN;


PROC SQL;
CREATE TABLE FALT002_2 AS
SELECT * FROM FALT002_2
WHERE 
/* Base tenant hotlist */
(
CRD_CLNT_ID IN ("SC_CCMSHK_CR") AND
 TRN_AUTH_POST ="A" AND
( AUTH_DECISION_XCD  = "A" OR  DECI_CD_ORIG  = "A") AND
 TRN_TYP IN ("C" "M" "P")  AND
/*GETLOOKUPLISTVALUE("LIMIT_BASED_WHITELIST", PAN, HOTLISTVALUE) = 1 AND*/
/*IS_NUMERIC(HOTLISTVALUE) = 1 AND*/
 (trim(ACCT_NBR) in (Select distinct(Name) from LOOKUP_DATA)) AND
(
(TRN_POS_ENT_CD IN ("E" "K" "G") AND CUM_AMOUNT_CNP_DAILY <= 1500) OR
((TRN_POS_ENT_CD NOT IN ("E" "K" "G")) AND CUM_AMOUNT_CP_DAILY <= 1500)
)
);

QUIT;

PROC SORT DATA=FALT002_2 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002_2 OUT=FALT003; BY ACCT_NBR AUTH_DTTM; RUN;


DATA TXN_DATA;
SET FALT003;
WHERE DATE1 GE "16JUL2021"D;
RUN;

DATA RULE_DATA;
SET
DC.FALT003_CR_16JUL;
WHERE UPCASE(RULE_NAME_STRG) IN ('BYPASS_LIMIT_BASED_WHITELIST_HK') AND
CLIENT_XID IN ("SC_CCMSHK_CR") AND
DATE1 GE "16JUL2021"D;
RUN;

PROC SORT DATA=RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA;TITLE "TXN_DATA SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA=RULE_DATA; TITLE "RULE_DATA FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;


/* Writing Output to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "Bypass_LIMIT_BASED_WHITELIST_HK SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "Bypass_LIMIT_BASED_WHITELIST_HK FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;


/**/
/*PROC EXPORT DATA= VIP_LIST*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="VIP_LIST";*/
/*run;*/




/**/
/*/*CROSS CHECK* - 5 STEPS */*/
/**/
/**/
/*PROC EXPORT DATA= CASACTN*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="CASACTN";*/
/*run;*/
/**/
/*PROC EXPORT DATA= OTHER_RULE*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="OTHER_RULE";*/
/*run;*/
/**/
/**/
/*/********************** cross check 6 STEPS ***********************/*/
/**/
/*/* 1 - Getting txns in SAS not in Falcon */*/
/*/* MER_ID is Name in VIP list Case manager */*/
/**/
/*PROC SQL;*/
/*CREATE TABLE txn_in_sas_not_in_rule AS */
/*SELECT ACCT_NBR, FI_TRANSACTION_ID, MER_ID, CRD_CLNT_ID FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM */
/*RULE_DATA);*/
/*QUIT;*/
/**/
/**/
/*/* 1 - Getting txns in Falcon not in SAS */*/
/*/* MER_ID is Name in VIP list Case manager */*/
/**/
/*PROC SQL;*/
/*CREATE TABLE txn_in_sas_not_in_rule AS */
/*SELECT SCORE_CUSTOMER_ACCOUNT_XID, FI_TRANSACTION_ID, CLIENT_XID FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM */
/*TXN_DATA);*/
/*QUIT;*/
/**/
/**/
/*DATA TXN_CHECK;*/
/*SET */
/*FALT002;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0060cca6d402f4ee',*/
/*'1e60cca61502dc17',*/
/*'2060cca6140444cf'*/
/*);*/
/*RUN;*/
/**/
/**/
/*/* 2 - High priority rule check */*/
/**/
/*DATA OTHER_RULE;*/
/*SET */
/*DC.falt003_cr_10jul*/
/*DC.falt003_cr_11jul;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'1e60e9fbd8000c88'*/
/*'0060e9f9bf0042c5'*/
/*'1e60e9fbd8022c28'*/
/*) and*/
/*UPCASE(RULE_NAME_STRG) not IN ('BYPASS_LIMIT_BASED_WHITELIST_HK');*/
/*RUN;*/
/**/
/**/
/*/* 3 - Genuine list check */*/
/**/
/*DATA CASACTN;*/
/*SET*/
/*DC.casactn_cr_11jul;*/
/*WHERE ACCT_NBR IN */
/*(*/
/*"5523438412897745"*/
/*) and date1 ge "16JUL2021"d;*/
/*RUN;*/
/**/
/*/* 4 - If not solved in previous steps chec those ACCT_NBRs here*/*/
/*/* MER_ID or Name extraction for ACCT_NBS in SAS not in Falcon*/*/
/**/
/*PROC SQL;*/
/*CREATE TABLE VIP AS */
/*SELECT distinct(MER_ID), FI_TRANSACTION_ID FROM Txn_Data where ACCT_NBR in*/
/*(*/
/*'5523438412897745'*/
/*);*/
/*RUN;*/
/**/
/*/* 5 - Check if the ACCT_NBR is present in VIP list (Case manager)*/*/
/**/
/*DATA VIP_LIST;*/
/*SET LOOKUP_DATA;*/
/*WHERE*/
/*NAME IN(*/
/*'000445473801998'*/
/*'000445473801998'*/
/*'235251000762203'*/
/*'5523438412897745'*/
/*);*/
/*RUN;*/
/**/
/**/
/*DATA UDV_Mismatch;*/
/*SET TEMP_TXN_DATA;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'000445473801998'*/
/*'000445473801998'*/
/*'235251000762203'*/
/*'5523438412897745'*/
/*);*/
/*RUN;*/
/**/
/*PROC EXPORT DATA= UDV_Mismatch*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\Bypass_LIMIT_BASED_WHITELIST_HK HK CREDIT.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="UDV_Mismatch";*/
/*run;*/
/**/
/*/********************** cross check 6 STEPS ***********************/*/