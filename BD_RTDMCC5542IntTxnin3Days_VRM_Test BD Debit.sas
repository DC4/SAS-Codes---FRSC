
					**********************************************************
						   BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Debit
									
					**********************************************************;
 
/*PROC DELETE DATA=_ALL_;RUN;*/
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\DB";
LIBNAME INC "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\DB";

DATA FALT002;
SET  
INC.falt002_db_15DEC
INC.falt002_db_16DEC
INC.falt002_db_17DEC
INC.falt002_db_18DEC
INC.falt002_db_19DEC;

     WHERE TRN_AUTH_POST = "A"  AND DATE1 GE "14DEC2021"D AND
 CRD_CLNT_ID IN ("SC_SPARROWBD_DB");
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
								'470691') AND CRD_CLNT_ID = "SC_SPARROWBD_DB" THEN TRN_AMT_LOCAL = TRN_AMT * 83.60;
	ELSE TRN_AMT_LOCAL = TRN_AMT;

		IF CRD_CLNT_ID = "SC_EURONETAE_DB" THEN USD = TRN_AMT/3.67;
			ELSE IF CRD_CLNT_ID = "SC_EURONETMY_DB" THEN USD= TRN_AMT/3.221743;
		ELSE IF CRD_CLNT_ID = "SC_EURONETID_DB" THEN USD= TRN_AMT/13500;
		ELSE IF CRD_CLNT_ID = "SC_EURONETIN_DB" THEN USD= TRN_AMT/65;
		ELSE IF CRD_CLNT_ID = "SC_TANDEMTW_DB" THEN USD= TRN_AMT/30.116853; 
		ELSE IF CRD_CLNT_ID = "SC_EURONETBH_DB" THEN USD= TRN_AMT/0.377132; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWBW_DB" THEN USD= TRN_AMT/10.2587; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWGH_DB" THEN USD= TRN_AMT/4.42718; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWJO_DB" THEN USD= TRN_AMT/0.708893; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWKE_DB" THEN USD= TRN_AMT/103.824; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWLK_DB" THEN USD= TRN_AMT/153.05; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWNG_DB" THEN USD= TRN_AMT/365.467; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWNP_DB" THEN USD= TRN_AMT/102.69; 
		ELSE IF CRD_CLNT_ID = "SC_EURONETVN_DB" THEN USD= TRN_AMT/22700; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWZM_DB" THEN USD= TRN_AMT/8.98193; 
		ELSE IF CRD_CLNT_ID IN ("SC_EURONETBN_DB"  "SC_EURONETSG_DB") THEN USD= TRN_AMT/1.36370; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWBW_DB" THEN USD= TRN_AMT/10.3382; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWGM_DB" THEN USD= TRN_AMT/45.8258; 
		ELSE IF CRD_CLNT_ID = "SC_EURONETIN_DB" THEN USD= TRN_AMT/65; 
		ELSE IF CRD_CLNT_ID = "SC_EURONETQA_DB" THEN USD= TRN_AMT/3.64146; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWTZ_DB" THEN USD= TRN_AMT/2240.11; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWUG_DB" THEN USD= TRN_AMT/3603.55; 
		ELSE IF CRD_CLNT_ID = "SC_SPARROWZW_DB" THEN USD= TRN_AMT/361.900; 
		ELSE IF CRD_CLNT_ID = "SC_HOGANHK_DB" THEN USD= TRN_AMT/7.8;
		ELSE IF CRD_CLNT_ID = "SC_SPARROWBD_DB" THEN USD = TRN_AMT_LOCAL/83.60;
		ELSE IF CRD_CLNT_ID = "SC_SPARROWCI_DB" THEN USD = TRN_AMT/562.55;
		ELSE IF CRD_CLNT_ID = "SC_SPARROWCM_DB" THEN USD = TRN_AMT/570;
		ELSE IF CRD_CLNT_ID = "SC_SPARROWSL_DB" THEN USD = TRN_AMT/8300;
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
(CUM_COUNT_CNP_DAILY > 2 OR
USD < 2)
)

THEN FLAG="Y";
RUN;

DATA TXN_DATA;
SET TEMP_TXN_DATA;
WHERE FLAG = "Y" and date1 GE "18DEC2021"D;
RUN;

DATA RULE_DATA;
     SET 
INC.falt003_db_18DEC
INC.falt003_db_19DEC;
WHERE UPCASE(RULE_NAME_STRG) IN ('BD_RTDMCC5542INTTXNIN3DAYS_VRM_TEST') and CLIENT_XID IN  ("SC_SPARROWBD_DB")
and date1 GE "18DEC2021"D;
RUN;

PROC SORT DATA = RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA = TXN_DATA;TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA = RULE_DATA; TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Debit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "BD_RTDMCC5542IntTxnin3Days_VRM_Test  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Debit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Debit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;



/**/
/*/* 3 - Check UDV Mismatch */*/
/**/
/*DATA UDV_Mismatch;*/
/*SET TEMP_TXN_DATA;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0060df0d5a00840e'*/
/*'0060df0d5a038513'*/
/*'0060df0d5a03854d'*/
/*'0160df0d5a02e3fc'*/
/*'0160df0d5a0506dd'*/
/*'0260df0d5a031282'*/
/*'0260df0d5a04c0f7'*/
/*'0360df0d8401186b'*/
/*'0360df0d840292b4'*/
/*'1e60df0c9901229d'*/
/*'1e60df0c99020fd3'*/
/*'1f60df0c99036ea3'*/
/*'1f60df0c990403f1'*/
/*'1f60df0c99044cd8'*/
/*'1f60df0c9904a14b'*/
/*'2060df0c990076e0'*/
/*'2060df0c99010f7b'*/
/*'2160df0cc9012e64'*/
/*'2160df0cc9015247'*/
/*'2160df0cc90191ea'*/
/*'2160df0cc9019971'*/
/*'2160df0cc901c749'*/
/*);*/
/*RUN;*/
/**/
/*PROC EXPORT DATA= UDV_Mismatch*/
/*outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Debit.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="UDV_Mismatch";*/
/*run;*/
/**/
/**/
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
/*/* 2 - High priority rule check */*/
/**/
/*DATA OTHER_RULE;*/
/*SET */
/*INC.falt003_db_28jun*/
/*INC.falt003_db_29jun;*/
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
/*SET INC.casactn_db_28jun*/
/*INC.casactn_db_29jun;*/
/*WHERE ACCT_NBR IN */
/*(*/
/*"5447290210320252"*/
/*) and date1 ge "28JUN2021"d;*/
/*RUN;*/
/**/
/**/
/*/* 3 - Check UDV Mismatch */*/
/**/
/*DATA UDV_Mismatch;*/
/*SET TEMP_TXN_DATA;*/
/*WHERE FI_TRANSACTION_ID IN */
/*(*/
/*'0060df0d5a00840e'*/
/*'0060df0d5a038513'*/
/*'0060df0d5a03854d'*/
/*'0160df0d5a02e3fc'*/
/*'0160df0d5a0506dd'*/
/*'0260df0d5a031282'*/
/*'0260df0d5a04c0f7'*/
/*'0360df0d8401186b'*/
/*'0360df0d840292b4'*/
/*'1e60df0c9901229d'*/
/*'1e60df0c99020fd3'*/
/*'1f60df0c99036ea3'*/
/*'1f60df0c990403f1'*/
/*'1f60df0c99044cd8'*/
/*'1f60df0c9904a14b'*/
/*'2060df0c990076e0'*/
/*'2060df0c99010f7b'*/
/*'2160df0cc9012e64'*/
/*'2160df0cc9015247'*/
/*'2160df0cc90191ea'*/
/*'2160df0cc9019971'*/
/*'2160df0cc901c749'*/
/*);*/
/*RUN;*/
/**/
/*PROC EXPORT DATA= UDV_Mismatch*/
/*outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\BD_RTDMCC5542IntTxnin3Days_VRM_Test BD Credi.xlsx"*/
/*dbms=xlsx replace;*/
/*sheet="UDV_Mismatch";*/
/*run;*/