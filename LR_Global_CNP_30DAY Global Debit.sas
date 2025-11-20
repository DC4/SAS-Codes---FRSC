
PROC DELETE DATA=_ALL_;RUN;

**********************************************************
		LR_Global_CNP_30DAY Global Debit
				
**********************************************************;

OPTIONS COMPRESS=YES;

LIBNAME DB "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";
LIBNAME IND "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\DB";

%MACRO DR(CNTY,MTH);
DATA FALT002_A;
     SET  DB.falt002_&CNTY._db_&MTH.2021 ;
     WHERE TRN_AUTH_POST = "A"  AND CRD_CLNT_ID IN ("SC_EURONETSG_DB" "SC_EURONETMY_DB" "SC_EURONETAE_DB" ) AND
 DATE1 GE "23JUN2021"D;
     FORMAT TRAN_DATE DATE9. TIME TIME8.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
         ATMONUS=(COMPRESS(MER_ID)||COMPRESS(ACCT_NBR));
/*         IF AUTH_DTTM GE "26FEB2021:22:15:00"DT;*/
         TIME = TIMEPART(AUTH_DTTM);
		RUN;

PROC SORT DATA=FALT002_A NODUPKEY; BY FI_TRANSACTION_ID; RUN;
/*PROC SORT DATA=FALT002_A ; BY ATMONUS AUTH_DTTM; RUN;*/

PROC APPEND DATA=FALT002_A BASE=FALT002 FORCE;RUN;

PROC DELETE DATA=FALT002_A;RUN;
%MEND;

/*%DR(SG,JUN);*/
/*%DR(SG,JUL);*/
/*%DR(SG,AUG);*/
%DR(SG,SEP);
%DR(SG,OCT);


/*%DR(MY,JUN);*/
/*%DR(MY,JUL);*/
/*%DR(MY,AUG);*/
%DR(MY,SEP);
%DR(MY,OCT);

/*%DR(AE,JUN);*/
/*%DR(AE,JUL);*/
/*%DR(AE,AUG);*/
%DR(AE,SEP);
%DR(AE,OCT);


/*Wed 6/23/2021 3:19 PM*/

PROC SORT DATA=FALT002 ; BY ATMONUS AUTH_DTTM;
WHERE AUTH_DTTM GE '23JUN2021:17:49:00'DT;
RUN;


DATA FALT002;
     SET FALT002;
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
           IF ATMONUS_FIRST_APPROVAL_DATE = 0 AND TRN_TYP IN ("C" "M" "P") AND (AUTH_DECISION_XCD = "A" OR DECI_CD_ORIG="A") 
		   AND TRN_AMT GT 0 THEN DO;
                ATMONUS_FIRST_APPROVAL_DATE = AUTH_DTTM;
           END;
     END;


RUN;

%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002;
     SET FALT002;
     BY ATMONUS AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATE9.;

     RETAIN CUM_COUNT_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. ATMONUS_30DAY_MAX_CNT;

     IF FIRST.ATMONUS THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
		   ATMONUS_30DAY_MAX_CNT = 0;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF TRAN_DATE LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + TRN_AMT;
           END;
           ELSE DO;
		   		ATMONUS_30DAY_MAX_CNT = MAX(ATMONUS_30DAY_MAX_CNT,CUM_COUNT_&VAR_NAME.);
                TIME_RESET_&VAR_NAME. = TRAN_DATE;
                CUM_COUNT_&VAR_NAME. = 1;
                CUM_AMOUNT_&VAR_NAME. = TRN_AMT;
           END;
     END;


RUN;
%MEND; 

%UDV(CUM_INTERVAL        = 30,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" and MER_ID ne '' and TRN_TYP IN ("C" "M" "P") and
(AUTH_DECISION_XCD = "A" or DECI_CD_ORIG = "A") and TRN_AMT > 0),
     VAR_NAME            = ATMONUS_30DAY);


DATA FALT002_1;
SET FALT002;
BY ATMONUS AUTH_DTTM;
where date1 GE "14OCT2021"D;
RETAIN ATMONUS_30DAY_TRIGGERED;
IF FIRST.ATMONUS THEN ATMONUS_30DAY_TRIGGERED=0;
IF
((TRN_AUTH_POST = "A" and AUTH_DECISION_XCD = "A"  and
TRN_TYP IN ("C" "M" "P") and TRN_POS_ENT_CD IN ("E" "K" "G" "") and
SUBSTR(USR_IND_4,1,2) NE "Y2" and TRN_AMT > 0 and ATMONUS_30DAY_TRIGGERED = 0 AND
(AUTH_DTTM - ATMONUS_FIRST_APPROVAL_DATE) <= (30*86400) AND
SIC_CD NOT IN ("6011" "4121"))  
AND 
(
(CRD_CLNT_ID = "SC_EURONETSG_DB"  and
 MER_CNTY_CD NE "702" and  CUM_COUNT_ATMONUS_30DAY >= 15 ) or
(CRD_CLNT_ID = "SC_EURONETMY_DB"  and
 MER_CNTY_CD NE "458" and  CUM_COUNT_ATMONUS_30DAY >= 15 ) or
 (CRD_CLNT_ID = "SC_EURONETAE_DB"  and
 MER_CNTY_CD NE "784" and  CUM_COUNT_ATMONUS_30DAY >= 15 )
)) then do;
LR_GLOBAL_CNP_30DAY="Y";
ATMONUS_30DAY_TRIGGERED = 1;
end;
RUN;


DATA TXN_DATA;
SET FALT002_1;
WHERE (LR_GLOBAL_CNP_30DAY="Y" and date1 EQ "17OCT2021"D);
RUN;


DATA RULE_DATA;
     SET IND.FALT003_DB_17OCT ;
       WHERE UPCASE(RULE_NAME_STRG) IN ('LR_GLOBAL_CNP_30DAY') and date1 GE "17OCT2021"D and
CLIENT_XID IN ("SC_EURONETSG_DB" "SC_EURONETMY_DB" "SC_EURONETAE_DB" );
RUN;

PROC SORT DATA=RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA;TITLE "LR_GLOBAL_CNP_30DAY SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=RULE_DATA; TITLE "LR_GLOBAL_CNP_30DAY FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 



/* Writing Outout to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\LR_GLOBAL_CNP_30DAY Global Debit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "LR_GLOBAL_CNP_30DAY  SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "LR_GLOBAL_CNP_30DAY  FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\LR_GLOBAL_CNP_30DAY Global Debit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\LR_GLOBAL_CNP_30DAY Global Debit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
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
'0061683b6b05c55b'
'0061683b6b064deb'
'0161683b6b05c5df'
'0261683b6b05d882'
'0261683b6b065633'
'1f61683aab05bd5a'
'2161683adc05fc83'
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