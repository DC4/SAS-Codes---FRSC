
**********************************************************
		HR_Global_MID_Merchantname DR Credit
				
**********************************************************;
 
/*PROC DELETE DATA=_ALL_;RUN;*/

OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Credit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA FALT002;
     SET  
CR.falt002_HK_cr_apr2021 
CR.falt002_HK_cr_may2021 
CR.falt002_HK_cr_jun2021 
INC.falt002_cr_01JUL
INC.falt002_cr_02JUL
INC.falt002_cr_03JUL
INC.falt002_cr_04JUL
INC.falt002_cr_05JUL
INC.falt002_cr_06JUL
INC.falt002_cr_07JUL
INC.falt002_cr_08JUL
INC.falt002_cr_09JUL
INC.falt002_cr_10JUL
INC.falt002_cr_11JUL
INC.falt002_cr_12JUL
INC.falt002_cr_13JUL
INC.falt002_cr_14JUL
INC.falt002_cr_15JUL
INC.falt002_cr_16JUL
INC.falt002_cr_17JUL
INC.falt002_cr_18JUL
INC.falt002_cr_19JUL
INC.falt002_cr_20JUL
INC.falt002_cr_21JUL
INC.falt002_cr_22JUL
INC.falt002_cr_23JUL
INC.falt002_cr_24JUL
INC.falt002_cr_25JUL
INC.falt002_cr_26JUL
INC.falt002_cr_27JUL;

     WHERE TRN_AUTH_POST = "A"  AND DATE1 GE "01APR2021"D AND
 CRD_CLNT_ID IN ("SC_PMTHK_CR");
     FORMAT TRAN_DATE DATE9. TIME TIME8.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
         ATMONUS=(COMPRESS(MER_ID)||COMPRESS(ACCT_NBR));
/*         IF AUTH_DTTM GE "26FEB2021:22:15:00"DT;*/
         TIME = TIMEPART(AUTH_DTTM);
/*		 USD=TRN_AMT/63.75;*/
RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 ; BY ATMONUS AUTH_DTTM; RUN;

PROC SORT DATA=FALT002 OUT = FALT002_BACKUP NODUPKEY; BY FI_TRANSACTION_ID; RUN;


DATA FALT002_1;
     SET FALT002;
/*	 WHERE ACCT_NBR = "5447290100000220";*/
     BY ATMONUS AUTH_DTTM;

     FORMAT ATMONUS_FIRST_TXN_DATE DATETIME19. ATMONUS_FIRST_APPROVAL_DATE DATETIME19.;
         RETAIN ATMONUS_FIRST_TXN_DATE ATMONUS_FIRST_APPROVAL_DATE;

     IF FIRST.ATMONUS THEN DO;
           ATMONUS_FIRST_TXN_DATE = 0;
                    ATMONUS_FIRST_APPROVAL_DATE = 0;
     END;

     IF TRN_AUTH_POST = "A" and MER_ID NE "" THEN DO;
           IF ATMONUS_FIRST_TXN_DATE = 0 THEN DO;
                ATMONUS_FIRST_TXN_DATE = AUTH_DTTM;
           END;
           IF ATMONUS_FIRST_APPROVAL_DATE = 0 AND TRN_TYP IN ("C" "M" "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG = "A") 
                    AND TRN_AMT GT 0 THEN DO;
                ATMONUS_FIRST_APPROVAL_DATE = AUTH_DTTM;
           END;
     END;

RUN;

/*DATA NNN;*/
/*SET FALT002_1;*/
/*where ACCT_NBR = "5447290100000246";*/
/*RUN;*/
/**/
/*PROC SQL;*/
/*CREATE TABLE Analysis AS*/
/*Select distinct ACCT_NBR, count(*) as Count from FALT002_1 group by ACCT_NBR having Count > 1;*/
/*RUN;*/

PROC SORT DATA=FALT002 NODUPKEY; BY ACCT_NBR; RUN;


%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002;
     SET FALT002;
     BY ATMONUS AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;

     RETAIN CUM_COUNT_&VAR_NAME. CUM_COUNT_MAX_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. CUM_AMOUNT_MAX_&VAR_NAME.
                          &VAR_NAME._AA_SCORE &VAR_NAME._BASE_SCORE 
                          CUM_COUNT_APPR_&VAR_NAME. CUM_AMOUNT_APPR_&VAR_NAME. &VAR_NAME._PREV;

     IF FIRST.ATMONUS THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
                    CUM_COUNT_APPR_&VAR_NAME. = 0;
                    CUM_AMOUNT_APPR_&VAR_NAME. = 0;
                    &VAR_NAME._BASE_SCORE=0;
                    &VAR_NAME._AA_SCORE=0;
                    CUM_COUNT_MAX_&VAR_NAME.=0;
                    CUM_AMOUNT_MAX_&VAR_NAME.=0;
                    ATMONUS_FIRST_TXN_DATE=AUTH_DTTM;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + TRN_AMT;
                                  IF (TRN_TYP IN ("C"  "M"  "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG="A") AND
                                           TRN_AMT GT 0) THEN DO;
                                           CUM_COUNT_APPR_&VAR_NAME. + 1 ;
                                           CUM_AMOUNT_APPR_&VAR_NAME. + TRN_AMT;
                                  END;
                                  &VAR_NAME._BASE_SCORE=MAX(&VAR_NAME._BASE_SCORE,FRD_SCOR);
                                  &VAR_NAME._AA_SCORE=MAX(&VAR_NAME._AA_SCORE,AA_SCOR);
           END;
           ELSE DO;
                                  CUM_COUNT_MAX_&VAR_NAME. = max(CUM_COUNT_MAX_&VAR_NAME., CUM_COUNT_APPR_&VAR_NAME.);
                                  CUM_AMOUNT_MAX_&VAR_NAME. = max(CUM_AMOUNT_MAX_&VAR_NAME., CUM_AMOUNT_APPR_&VAR_NAME.);
                                  ATMONUS_DAILY_DAYS + 1;
                                  CUM_COUNT_&VAR_NAME. = 1;
                          CUM_AMOUNT_&VAR_NAME. = TRN_AMT;
                		  CUM_COUNT_APPR_&VAR_NAME. = 0;
                                  CUM_AMOUNT_APPR_&VAR_NAME. = 0;
                                  IF (TRN_TYP IN ("C"  "M"  "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG="A") AND
                                           TRN_AMT GT 0) THEN DO;
                                           CUM_COUNT_APPR_&VAR_NAME. = 1 ;
                                           CUM_AMOUNT_APPR_&VAR_NAME. = TRN_AMT;
                                  END;
                                  &VAR_NAME._PREV = TIME_RESET_&VAR_NAME.;
                                  TIME_RESET_&VAR_NAME. = AUTH_DTTM;
                                  &VAR_NAME._BASE_SCORE = FRD_SCOR;
                                  &VAR_NAME._AA_SCORE = AA_SCOR;
           END;
     END;

RUN;
%MEND; 

%UDV(CUM_INTERVAL        = 86400,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" and MER_ID NE "") ,
     VAR_NAME            = ATMONUS_DAILY);


DATA HR_Global_MID_Merchantname;
    SET FALT002;
	WHERE DATE1 GE "25JUL2021"D;
IF (
(
 TRN_AUTH_POST  = "A" AND
( AUTH_DECISION_XCD  = "A" OR (AUTH_DECISION_XCD = "" AND  DECI_CD_ORIG  = "A")) AND
 TRN_TYP  IN ("C" "M" "P")
)
and
(
 CRD_CLNT_ID  = ("SC_PMTHK_CR") AND
(
(COMPRESS(MER_ID) = "3057FLI300000I3" AND INDEX(UPCASE(MER_NM), "FW.SHOP*")) OR
(COMPRESS(MER_ID) = "500100000187" AND INDEX(UPCASE(MER_NM), "ABADYSTORES")) OR
(COMPRESS(MER_ID) = "000000000204560" AND INDEX(UPCASE(MER_NM), "REVOLUT*")) OR
(COMPRESS(MER_ID) = "000174030075991" AND INDEX(UPCASE(MER_NM), "GRUBHUB TEMPVALIDATE")
 AND CUM_COUNT_ATMONUS_DAILY > 2) OR
(COMPRESS(MER_ID) = "XXCR5EE3UVI7PJV" AND INDEX(UPCASE(MER_NM), "REAP PAYMENTS"))
)
)
)
	THEN FLAG ="Y";
RUN;

DATA TXN_DATA;
SET HR_Global_MID_Merchantname;
WHERE FLAG = "Y" and date1 GE "25JUL2021"D;
RUN;

DATA RULE_DATA;
     SET INC.falt003_cr_23JUL;
       WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_MID_MERCHANTNAME') and CLIENT_XID = "SC_PMTHK_CR" and date1 GE "25JUL2021"D;
RUN;

PROC SORT DATA=RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA;TITLE "HR_Global_MID_Merchantname SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA=RULE_DATA; TITLE "HR_Global_MID_Merchantname FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

/* Writing Output to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname DR Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "HR_Global_MID_Merchantname SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "HR_Global_MID_Merchantname FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname DR Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname DR Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;

/**/
/**/
/*PROC EXPORT DATA= CASACTN*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname DR Credit.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="CASACTN";*/
/*run;*/
/**/
/*PROC EXPORT DATA= OTHER_RULE*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_MID_Merchantname DR Credit.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="OTHER_RULE";*/
/*run;*/
/**/
/*/*CROSS CHECK* - 5 STEPS */*/
/**/
/*/********************** cross check 4 STEPS ***********************/*/
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
/*'0360db027b0079c0',*/
/*'0360db027b007a09',*/
/*'2160db2fbc000807'*/
/*);*/
/*RUN;*/
/**/
/**/
/*/* 2 - High priority rule check */*/
/**/
/*DATA OTHER_RULE;*/
/*SET */
/*INC.falt003_cr_28jun*/
/*INC.falt003_cr_29jun;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0060db305f0020d8'*/
/*'0060db305f00215b'*/
/*'0060db305f0021f0'*/
/*'0060db305f0022cf'*/
/*'0060db305f00240d'*/
/*) and*/
/*UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_MID_MERCHANTNAME');*/
/*RUN;*/
/**/
/**/
/*/* 3 - Genuine list check */*/
/**/
/*DATA CASACTN;*/
/*SET INC.casactn_cr_28jun*/
/*INC.casactn_cr_29jun;*/
/*WHERE ACCT_NBR IN */
/*(*/
/*"5447290210320252"*/
/*) and date1 ge "28JUN2021"d;*/
/*RUN;*/
/**/
/*/* 4 - If not solved in previous steps chec those ACCT_NBRs here*/*/
/*/* MER_ID or Name extraction for ACCT_NBS in SAS not in Falcon*/*/
/**/
/*PROC SQL;*/
/*CREATE TABLE VIP AS */
/*SELECT distinct(MER_ID), FI_TRANSACTION_ID FROM Txn_Data where ACCT_NBR in*/
/*(*/
/*'5523438412256975'*/
/*);*/
/*RUN;*/
/**/
/*/* 5 - Check if the ACCT_NBR is present in VIP list (Case manager)*/*/
/**/
/*DATA VIP_LIST;*/
/*SET LOOKUP_DATA;*/
/*WHERE*/
/*NAME IN(*/
/*'484767000200403'*/
/*'EP86CJLWQYAQGJM'*/
/*);*/
/*RUN;*/

/********************** cross check 5 STEPS ***********************/



/**/
/*PROC SQL;*/
/*CREATE TABLE CHK AS*/
/*SELECT * FROM*/
/*HR_Global_MID_Merchantname A LEFT JOIN HR_Global_MID_Merchantname_RL B*/
/*ON A.FI_TRANSACTION_ID=B.FI_TRANSACTION_ID*/
/*WHERE CLIENT_XID="";*/
/*QUIT;*/
/**/
/*PROC SQL;*/
/*CREATE TABLE OTHER_RULE AS*/
/*SELECT * FROM INC.falt003_cr_02JUN*/
/*WHERE FI_TRANSACTION_ID IN (SELECT DISTINCT FI_TRANSACTION_ID FROM CHK) AND*/
/*UPCASE(SUBSTR(RULE_NAME_STRG,1,2)) IN ("HR" "VH");*/
/*QUIT;*/
/**/
/*PROC SQL;*/
/*CREATE TABLE MISMATCH AS*/
/*SELECT * FROM CHK*/
/*WHERE FI_TRANSACTION_ID NOT IN (SELECT DISTINCT FI_TRANSACTION_ID FROM OTHER_RULE);*/
/*QUIT;*/
/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE CHK2 AS*/
/*SELECT * FROM*/
/*HR_Global_MID_Merchantname_RL A LEFT JOIN HR_Global_MID_Merchantname B*/
/*ON A.FI_TRANSACTION_ID=B.FI_TRANSACTION_ID*/
/*WHERE CRD_CLNT_ID="";*/
/*QUIT;*/
/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE MISMATCH_2 AS*/
/*SELECT * FROM FALT002*/
/*WHERE FI_TRANSACTION_ID IN (SELECT DISTINCT FI_TRANSACTION_ID FROM CHK2);*/
/*QUIT;*/
