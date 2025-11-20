
**************************************************************************************

				HR_Global_Magstripe_Nonmajor_Test BD Credit

**************************************************************************************;


LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";


*********************************************************;

DATA FALT002;
     SET
	  INC.falt002_CR_24SEP
		INC.falt002_CR_25SEP
		INC.falt002_CR_26SEP;
     WHERE TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD IN ("A" "") AND TRN_TYP IN ("C" "M" "P") AND 
	 		CRD_CLNT_ID IN ("SC_C400BD_CR");
     FORMAT TRAN_DATE DATE9.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);
	IF CRD_CLNT_ID IN ("SC_CCMSSG_CR") THEN USD = TRN_AMT/1.255698;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSMY_CR") THEN USD = TRN_AMT/3.221743;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSIN_CR") THEN USD = TRN_AMT/63.75;
	ELSE IF CRD_CLNT_ID IN ("SC_CCMSHK_CR") THEN USD = TRN_AMT/7.8;
	ELSE IF CRD_CLNT_ID IN ("SC_C400AE_CR") THEN USD = TRN_AMT/3.67;
	ELSE IF CRD_CLNT_ID IN ("SC_C400BD_CR") THEN USD = TRN_AMT/83.60;
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
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND TRN_TYP IN ("C" "M" "P") AND 
								TRN_POS_ENT_CD NOT IN ("E" "K" "G")),
     VAR_NAME            = CNP_DAILY);


DATA After_Test_CNP_Test_SAS;

	SET FALT002_2;

	**************** Decision Rule HR_Global_Magstripe_Nonmajor_Test *****************; 
IF	

(
 CRD_CLNT_ID IN ("SC_C400BD_CR") AND
 TRN_AUTH_POST  = "A" AND
 AUTH_DECISION_XCD  = "A" AND
 TRN_TYP  IN ("C" "M" "P") AND
 TRN_POS_ENT_CD  IN ("U" "S" "F" "T") AND
 TRN_AMT  > 0 AND
 MER_CNTY_CD  NE "050" AND
 FRD_SCOR  > 800 AND
 CUM_AMOUNT_CNP_DAILY >= 500 AND
 CUM_COUNT_CNP_DAILY >=1
)

THEN After_Test_CNP_Test = "Y";

RUN;

DATA TXN_DATA;
	SET After_Test_CNP_Test_SAS;
	WHERE After_Test_CNP_Test = "Y" AND DATE1 GE "25SEP2021"D;
RUN;

DATA RULE_DATA;
     SET 
	 	INC.falt003_CR_25SEP
		INC.falt003_CR_26SEP;
WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_MAGSTRIPE_NONMAJOR_TEST') AND DATE1 GE "25SEP2021"D
	AND CLIENT_XID IN ("SC_C400BD_CR");
RUN;

PROC SORT DATA = RULE_DATA NODUPKEY ;BY FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA; TITLE "HR_Global_Magstripe_Nonmajor_Test SAS"; 
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;

PROC FREQ DATA=RULE_DATA; TITLE "HR_Global_Magstripe_Nonmajor_Test FALCON HITS"; 
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;


/* Writing output to excel */

ods listing;
ods excel file='C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Magstripe_Nonmajor_Test BD Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
PROC FREQ DATA = TXN_DATA;TITLE "HR_Country_TAP_PIE_BH SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "HR_Country_TAP_PIE_BH FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Magstripe_Nonmajor_Test BD Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\HR_Global_Magstripe_Nonmajor_Test BD Credit.xlsx"
dbms=xlsx replace;
sheet="RULE_DATA";
run;


/**/
/*PROC SQL;*/
/*CREATE TABLE MISMATCHED AS */
/*SELECT * FROM After_Test_CNP_Test A LEFT JOIN After_Test_CNP_Test_RL B*/
/*ON A.FI_TRANSACTION_ID = B.FI_TRANSACTION_ID;*/
/*QUIT;*/
/**/
/**/
/*proc sql;*/
/*create table chk as select * from INC.FALT003_CR_31JAN */
/*where fi_transaction_id in (select distinct fi_transaction_id from After_Test_CNP_Test WHERE UPCASE(DECI_CD) = "DECLINE");*/
/*quit;*/
/**/
/*DATA GENUINE_LIST;*/
/*SET INC.casactn_cr_30JAN*/
/*	INC.casactn_cr_31JAN;*/
/*WHERE ACCT_NBR IN */
/*('5523438411407231'*/
/*'5523438414618784');*/
/*RUN;*/
/**/
/**/
