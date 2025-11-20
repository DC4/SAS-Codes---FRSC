***
TERMINAL_ENTRY_CAP  => terminalEntryCapability
PAN => ACCT_NBR
SIC_CD   =>  mcc 
TRN_AMT
TRN_TYP  => transactionType
TRN_AUTH_POST  =>  authPostFlag
TRN_POS_ENT_CD =>  posEntryMode
USR_DAT_2   =>  userData02
USER_DATA_4_STRG => userData04
MER_CTY
MER_ID
MER_NM
MER_CNTY_CD  =>  merchantCountryCode
SUBSTR(MER_NM,(LENGTH(MER_NM)-14)) IN 
AUTH_DECISION_XCD => authDecisionCode 
FRD_SCOR  => FRD_SCOR
USR_IND_4  =>  userIndicator04
CRD_CLNT_ID  =>  clientIdFromHeader
;

**************************************************************************************

                  MR_CC_Global_CNP_Non_Sec_2trans_1day_Test Global Debit

**************************************************************************************;

OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

*********************************************************;

DATA FALT002;
	SET  INC.falt002_db_28sep
		 INC.falt002_db_29sep
		 INC.falt002_db_30sep;
     WHERE  ( TRN_AUTH_POST = "A" and  AUTH_DECISION_XCD = "A" and TRN_POS_ENT_CD IN ("E"  "K"  "G" ""));
     FORMAT TRAN_DATE DATE9.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 OUT=FALT002_2; BY ACCT_NBR AUTH_DTTM; RUN;


%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002_2;
     SET FALT002_2;
     BY ACCT_NBR AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;

     RETAIN CUM_COUNT_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. ;

     IF FIRST.ACCT_NBR THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + TRN_AMT;
           END;
           ELSE DO;
                TIME_RESET_&VAR_NAME. = AUTH_DTTM;
                CUM_COUNT_&VAR_NAME. = 1;
                CUM_AMOUNT_&VAR_NAME. = TRN_AMT;
           END;
     END;


RUN;
%MEND; 


%UDV(CUM_INTERVAL        = 86400,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" AND TRN_POS_ENT_CD IN ("E"  "K" "G" "") AND SUBSTR(USR_IND_4,1,2) NOT IN ("Y2") AND 
								PRXMATCH("M/GOOGLE|FACEBK|PAYPAL|AMAZON|WALMART|ITUNES|GOURMONDO|MICROSOFT/OI",UPCASE(MER_NM))),
     VAR_NAME            = 2TRANS_1DAY);

DATA MR_CC_Gl_CNP_2tr_1day_TestSAS;
    SET FALT002_2;

    IF ((TRN_AUTH_POST = "A" and  TRN_TYP IN ("C"  "M" "P") and	TRN_POS_ENT_CD IN ("E"  "K" "G" "") and
		CUM_COUNT_2TRANS_1DAY > 2 and SUBSTR(USR_IND_4,1,2) NOT IN ("Y2"  "Y5") and
		(SUBSTR(MER_NM,1,6) IN ("Google"  "google"  "GOOGLE" "Facebk"  "facebk"  "FACEBK"  "FaceBk"  
		"Paypal"  "paypal"  "PAYPAL" "Amazon"  "amazon"  "AMAZON" "Itunes"  "itunes"  "ITUNES"  "ITunes" ) OR  
		 SUBSTR(MER_NM,1,7) IN ("WALMART"  "walmart"  "Walmart")  OR
		 SUBSTR(MER_NM,1,9) IN ("GOURMONDO"  "gourmondo"  "Gourmondo"  "Microsoft"  "MICROSOFT"  "microsoft")))
		AND (( CRD_CLNT_ID IN ("SC_EURONETBH_DB"  "SC_EURONETBN_DB"  "SC_EURONETID_DB"  "SC_EURONETIN_DB" 
		"SC_EURONETMY_DB"  "SC_EURONETQA_DB"  "SC_EURONETPH_DB"  "SC_EURONETSG_DB") and
		FRD_SCOR > 800 )  or
		 ( CRD_CLNT_ID = "SC_SPARROWBW_DB" and FRD_SCOR > 850 )  OR
		 ( CRD_CLNT_ID = "SC_EURONETAE_DB" and FRD_SCOR > 800 )  OR
		 ( CRD_CLNT_ID = "SC_SPARROWGH_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWGM_DB" and FRD_SCOR > 800 ) OR 
		 ( CRD_CLNT_ID = "SC_SPARROWJO_DB" and FRD_SCOR > 800 ) OR  
		 ( CRD_CLNT_ID = "SC_SPARROWKE_DB" and FRD_SCOR > 850 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWLK_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWNG_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWNP_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWTZ_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWUG_DB" and FRD_SCOR > 800 )  OR 
		 ( CRD_CLNT_ID = "SC_EURONETVN_DB" and FRD_SCOR > 800 ) OR 
		 ( CRD_CLNT_ID = "SC_SPARROWZM_DB" and TRN_AMT/8.98193 > 20 and FRD_SCOR > 920 )  OR 
		 ( CRD_CLNT_ID = "SC_SPARROWZW_DB" and FRD_SCOR > 800 )))
       THEN MR_CC_Gl_CNP_2tr_1day_Test = "Y";

RUN;

DATA MR_CC_Gl_CNP_2tr_1day_Test;
SET MR_CC_Gl_CNP_2tr_1day_TestSAS;
WHERE MR_CC_Gl_CNP_2tr_1day_Test = "Y" AND date1 GE "29SEP2021"D;
RUN;


DATA MR_CC_Gl_CNP_2tr_1day_Test_RL;
     SET INC.FALT003_DB_29SEP
		 INC.FALT003_DB_30SEP;
       WHERE UPCASE(RULE_NAME_STRG) IN ('MR_CC_GLOBAL_CNP_NON_SEC_2TRANS_1DAY_TEST') and date1 ge "29SEP2021"D;
RUN;

PROC SORT DATA=MR_CC_Gl_CNP_2tr_1day_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=MR_CC_Gl_CNP_2tr_1day_Test;TITLE "MR_CC_GLOBAL_CNP_NON_SEC_2TRANS_1DAY_TEST SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=MR_CC_Gl_CNP_2tr_1day_Test_RL; TITLE "MR_CC_GLOBAL_CNP_NON_SEC_2TRANS_1DAY_TEST FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 




/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\MR_CC_Global_CNP_Non_Sec_2trans_1day_Test GBL Debit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = MR_CC_Gl_CNP_2tr_1day_Test;TITLE "HR_Global_AirBNB_CNP  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = MR_CC_Gl_CNP_2tr_1day_Test_RL; TITLE "HR_Global_AirBNB_CNP  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= MR_CC_Gl_CNP_2tr_1day_Test
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_CC_Global_CNP_Non_Sec_2trans_1day_Test GBL Debit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= MR_CC_Gl_CNP_2tr_1day_Test_RL
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_CC_Global_CNP_Non_Sec_2trans_1day_Test GBL Debit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;




/**/
/**/
/*PROC SQL;*/
/*CREATE TABLE CHK AS */
/*SELECT * FROM*/
/*MR_CC_Gl_CNP_2tr_1day_Test A LEFT JOIN MR_CC_Gl_CNP_2tr_1day_Test_RL B*/
/*ON A.FI_TRANSACTION_ID=B.FI_TRANSACTION_ID;*/
/*QUIT;*/
/**/
/**/
/*DATA CHK2;*/
/*     SET INC.FALT003_DB_29JUN INC.FALT003_DB_30JUN ;*/
/*WHERE FI_TRANSACTION_ID IN ('025d162bf7060d5e');RUN;*/
/**/
/*DATA CHK3;*/
/*     SET INC.FALT003_DB_29JUN INC.FALT003_DB_30JUN ;*/
/*  WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_INT_CNP_NONSEC_SCORE_2_TEST');*/
/*  RUN;*/
/**/
/*PROC SORT DATA=CHK3 NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;*/
/**/
/*proc sql;*/
/*create table chk4 as*/
/*select *,sum(trn_amt) as a from FALT002*/
/*where FI_TRANSACTION_ID in (select distinct FI_TRANSACTION_ID from CHK3);*/
/*run;*/
