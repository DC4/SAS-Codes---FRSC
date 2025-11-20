
					**********************************************************
						   BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Credit
									
					**********************************************************;
 
/*PROC DELETE DATA=_ALL_;RUN;*/
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\CR";
LIBNAME INC "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\CR";

DATA FALT002;
SET  
INC.falt002_cr_15DEC
INC.falt002_cr_16DEC
INC.falt002_cr_17DEC
INC.falt002_cr_18DEC
INC.falt002_cr_19DEC;

     WHERE TRN_AUTH_POST = "A"  AND DATE1 GE "14DEC2021"D AND
 CRD_CLNT_ID IN ("SC_C400BD_CR");
     FORMAT TRAN_DATE DATE9. TIME TIME8.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
         ATMONUS=(COMPRESS(MER_ID)||COMPRESS(ACCT_NBR));
/*         IF AUTH_DTTM GE "26FEB2021:22:15:00"DT;*/
         TIME = TIMEPART(AUTH_DTTM);

		     	IF SUBSTR(ACCT_NBR,1,6) IN ('411144'
								'421451'
								'469626'
								'470691') AND CRD_CLNT_ID = "SC_C400BD_CR" THEN TRN_AMT_LOCAL = TRN_AMT * 83.60;
	ELSE TRN_AMT_LOCAL = TRN_AMT;
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
	 ELSE IF CRD_CLNT_ID IN ("SC_PMTHK_CR") THEN USD = TRN_AMT_LOCAL/7.8;

RUN;
/**/
/*PROC SORT DATA=FALT002 OUT=FALT002_1 NODUPKEY; BY FI_TRANSACTION_ID; RUN;*/
/**/
/*PROC SORT DATA=FALT002_1 OUT=FALT002_2 ; BY ATMONUS AUTH_DTTM; RUN;*/
/**/
/**/
/*DATA FALT002_2;*/
/*     SET FALT002_2;*/
/*     BY ATMONUS AUTH_DTTM;*/
/**/
/*     FORMAT ATMONUS_FIRST_TXN_DATE DATETIME19. ATMONUS_FIRST_APPROVAL_DATE DATETIME19.;*/
/*	 RETAIN ATMONUS_FIRST_TXN_DATE ATMONUS_FIRST_APPROVAL_DATE;*/
/**/
/*     IF FIRST.ATMONUS THEN DO;*/
/*           ATMONUS_FIRST_TXN_DATE = 0;*/
/*		   ATMONUS_FIRST_APPROVAL_DATE = 0;*/
/*     END;*/
/**/
/*     IF TRN_AUTH_POST = "A" and MER_ID NE "" THEN DO;*/
/*           IF ATMONUS_FIRST_TXN_DATE = 0 THEN DO;*/
/*                ATMONUS_FIRST_TXN_DATE = AUTH_DTTM;*/
/*           END;*/
/*           IF ATMONUS_FIRST_APPROVAL_DATE = 0 AND TRN_TYP IN ("C" "M" "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG = "A") */
/*		   AND TRN_AMT GT 0 THEN DO;*/
/*                ATMONUS_FIRST_APPROVAL_DATE = AUTH_DTTM;*/
/*           END;*/
/*     END;*/
/**/
/**/
/*RUN;*/
/**/
/**/
/*%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);*/
/**/
/*DATA FALT002_2;*/
/*     SET FALT002_2;*/
/*     BY ATMONUS AUTH_DTTM;*/
/**/
/*     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;*/
/**/
/*     RETAIN CUM_COUNT_&VAR_NAME. CUM_COUNT_MAX_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. CUM_AMOUNT_MAX_&VAR_NAME.*/
/*			&VAR_NAME._AA_SCORE &VAR_NAME._BASE_SCORE */
/*			CUM_COUNT_APPR_&VAR_NAME. CUM_AMOUNT_APPR_&VAR_NAME. &VAR_NAME._PREV;*/
/**/
/*     IF FIRST.ATMONUS THEN DO;*/
/*           TIME_RESET_&VAR_NAME. = 0;*/
/*           CUM_COUNT_&VAR_NAME. = 0;*/
/*           CUM_AMOUNT_&VAR_NAME. = 0;*/
/*		   CUM_COUNT_APPR_&VAR_NAME. = 0;*/
/*		   CUM_AMOUNT_APPR_&VAR_NAME. = 0;*/
/*		   &VAR_NAME._BASE_SCORE=0;*/
/*		   &VAR_NAME._AA_SCORE=0;*/
/*		   CUM_COUNT_MAX_&VAR_NAME.=0;*/
/*		   CUM_AMOUNT_MAX_&VAR_NAME.=0;*/
/*		   ATMONUS_FIRST_TXN_DATE=AUTH_DTTM;*/
/*     END;*/
/**/
/*     IF &CUMULATIVE_CONDITION. THEN DO;*/
/*           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;*/
/*                CUM_COUNT_&VAR_NAME. + 1;*/
/*                CUM_AMOUNT_&VAR_NAME. + TRN_AMT;*/
/*				IF (TRN_TYP IN ("C"  "M"  "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG="A") AND*/
/*					TRN_AMT GT 0) THEN DO;*/
/*					CUM_COUNT_APPR_&VAR_NAME. + 1 ;*/
/*					CUM_AMOUNT_APPR_&VAR_NAME. + TRN_AMT;*/
/*				END;*/
/*				&VAR_NAME._BASE_SCORE=MAX(&VAR_NAME._BASE_SCORE,FRD_SCOR);*/
/*				&VAR_NAME._AA_SCORE=MAX(&VAR_NAME._AA_SCORE,AA_SCOR);*/
/*           END;*/
/*           ELSE DO;*/
/*		   		CUM_COUNT_MAX_&VAR_NAME. = max(CUM_COUNT_MAX_&VAR_NAME., CUM_COUNT_APPR_&VAR_NAME.);*/
/*				CUM_AMOUNT_MAX_&VAR_NAME. = max(CUM_AMOUNT_MAX_&VAR_NAME., CUM_AMOUNT_APPR_&VAR_NAME.);*/
/*				ATMONUS_DAILY_DAYS + 1;*/
/*				CUM_COUNT_&VAR_NAME. = 1;*/
/*           		CUM_AMOUNT_&VAR_NAME. = TRN_AMT;*/
/*                CUM_COUNT_APPR_&VAR_NAME. = 0;*/
/*		   		CUM_AMOUNT_APPR_&VAR_NAME. = 0;*/
/*				IF (TRN_TYP IN ("C"  "M"  "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG="A") AND*/
/*					TRN_AMT GT 0) THEN DO;*/
/*					CUM_COUNT_APPR_&VAR_NAME. = 1 ;*/
/*					CUM_AMOUNT_APPR_&VAR_NAME. = TRN_AMT;*/
/*				END;*/
/*				&VAR_NAME._PREV = TIME_RESET_&VAR_NAME.;*/
/*				TIME_RESET_&VAR_NAME. = AUTH_DTTM;*/
/*				&VAR_NAME._BASE_SCORE = FRD_SCOR;*/
/*				&VAR_NAME._AA_SCORE = AA_SCOR;*/
/*           END;*/
/*     END;*/
/**/
/*RUN;*/
/*%MEND; */
/**/
/*%UDV(CUM_INTERVAL        = 86400,                                          */
/*     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" and MER_ID NE "") ,*/
/*     VAR_NAME            = ATMONUS_DAILY);*/


PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 OUT=FALT002_2; BY ACCT_NBR AUTH_DTTM; RUN;


%MACRO UDV_DAILY(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);
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
           IF AUTH_DTTM LT (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
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

%UDV_DAILY
(
CUM_INTERVAL = 86400,                                          
CUMULATIVE_CONDITION = %STR
(
     TRN_AUTH_POST = "A" AND 
     AUTH_DECISION_XCD = "A" AND 
     TRN_TYP IN ("C" "M" "P") AND 
     SIC_CD in ("5542" "5552") AND 
     MER_CNTY_CD  NE "050"
),
VAR_NAME = CNP_DAILY
);


DATA TEMP_TXN_DATA;
    SET FALT002_2;
	WHERE DATE1 GE "18DEC2021"D;
IF 

(
 TRN_AUTH_POST  = "A" AND
 AUTH_DECISION_XCD  = "A" AND
 TRN_TYP  in ("C" "M" "P") AND
SUBSTR(ACCT_NBR,1,1) = "4" AND
/*LOOKUPLIST("GENUINE",PAN) = 0 AND*/
/*LOOKUPLIST("VIP_LIST",PAN) = 0 AND*/
/*//SIC_CD NE ("6010" AND "6011" AND "6012") AND*/
SIC_CD in ("5542" "5552") AND
 MER_CNTY_CD  NE "050" AND
(CUM_COUNT_CNP_DAILY > 2 OR USD < 2)
)

THEN FLAG="Y";
RUN;

DATA TXN_DATA;
SET TEMP_TXN_DATA;
WHERE FLAG = "Y" and date1 GE "18DEC2021"D;
RUN;

DATA RULE_DATA;
     SET 
INC.falt003_cr_18DEC
INC.falt003_cr_19DEC;
WHERE UPCASE(RULE_NAME_STRG) IN ('BD_RTDMCC5542INTTXNIN3DAYS_VRM_TEST') and CLIENT_XID IN  ("SC_C400BD_CR")
and date1 GE "18DEC2021"D;
RUN;

PROC SORT DATA = RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = TXN_DATA;TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA = RULE_DATA; TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;



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
/*PROC SQL;*/
/*CREATE TABLE txn_in_sas_not_in_rule AS */
/*SELECT * FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM */
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
/*PROC SQL;*/
/*CREATE TABLE txn_in_sas_not_in_rule AS */
/*SELECT * FROM RULE_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM */
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
/*INC.falt003_cr_05jun*/
/*INC.falt003_cr_06jun;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0160ba4fce04a3b0'  /*GBL - Caseaction*/*/
/*'1f60ba4ef6048fd4'   /*GBL - Caseaction*/*/
/*'2060ba4ef604027c' /*High priority rule HK*/*/
/*'2160ba4f2804239b' /* VIP Genuine */*/
/*) and*/
/*UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_MID_MERCHANTNAME');*/
/*RUN;*/
/**/
/**/
/*/* 3 - Genuine list check */*/
/*/**/
/*1. Check for USER_ID as "fal" and LAST_UPDATED_DTTM as before TXN time and ACT_DETAIL as "NOT_FRAUD"*/
/*2. Check for USER_ID as some number other than "fal" and check if ACT_DETAIL as "NOT_FRAUD" then check in HOTLIST*/
/**/*/
/**/
/*DATA CASACTN;*/
/*SET */
/*INC.casactn_cr_13dec;*/
/*WHERE INDEX(USER_ID,"fal") > 0 and INDEX(UPCASE(ACT_DETAIL),"NOT_FRAUD")> 0;*/
/*RUN;*/
/**/
/**/
/*DATA CASACTN_CHK;*/
/*SET */
/*INC.casactn_cr_13dec;*/
/*WHERE ACCT_NBR in(*/
/*/*"4058038018985898"*/*/
/*/*"4509360650948611"*/*/
/*/*"5523438414807809"*/*/
/*/*"5523438413017798"*/*/
/**/
/*"4028743400520388"*/
/*"4028743400531138"*/
/**/
/*);*/
/*RUN;*/
/**/
/*DATA CASACTN;*/
/*SET INC.casactn_cr_05jun*/
/*INC.casactn_cr_06jun;*/
/*WHERE ACCT_NBR IN */
/*(*/
/*"5523024972177197" /*GBL - Caseaction*/*/
/*"5523024972177197" /*GBL - Caseaction*/*/
/*"4509360641073065" /*High priority rule HK*/*/
/*"5523438412256975" /* VIP Genuine */*/
/*) and date1 ge "05JUN2021"d;*/
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
/**/
/**/
/*DATA UDV_Mismatch;*/
/*SET TEMP_TXN_DATA;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0161bc79eb044d8c'*/
/*'0361bc7a150693f7'*/
/*'0b61bc793c0141f4'*/
/*);*/
/*RUN;*/
/**/
/*PROC EXPORT DATA= UDV_Mismatch*/
/*outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_CNP_Google_Facebook_Test BD Credi.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="UDV_Mismatch";*/
/*run;*/
/**/
/*/********************** cross check 6 STEPS ***********************/*/