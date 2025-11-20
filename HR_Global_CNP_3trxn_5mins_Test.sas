
**************************************************************************************

				HR_Global_CNP_3trxn_5mins_Test 

**************************************************************************************;


LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";


*********************************************************;

DATA FALT002;
     SET 
		INC.FALT002_CR_02AUG
	 	INC.FALT002_CR_03AUG
	 	INC.FALT002_CR_04AUG
		INC.FALT002_CR_05AUG;
     WHERE TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND TRN_TYP IN ("C" "M" "P") AND
			TRN_POS_ENT_CD IN ("E" "K" "G") AND TRN_AMT GT 0 AND 
			CRD_CLNT_ID IN ("SC_C400NG_CR" "SC_CCMSIN_CR" "SC_C400NP_CR" "SC_C400ZM_CR");
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

%UDV(CUM_INTERVAL        = 300,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND TRN_TYP IN ("C" "M" "P") AND
							TRN_POS_ENT_CD IN ("E" "K") AND TRN_AMT GT 0),
     VAR_NAME            = CNP_5MINS);


DATA CNP_3trxn_5mins_Test_SAS;

	SET FALT002_2;

	**************** Decision Rule HR_Global_CNP_3trxn_5mins_Test  *****************; 

	IF TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND TRN_TYP IN ("C" "M" "P") AND SUBSTR(USR_IND_4,1,2) NOT IN ("Y2") AND 
	TRN_POS_ENT_CD IN ("E" "K" "G") AND MCC NOT IN (5964 4900 5960 6300) AND SUBSTR(USR_DAT_2,9,1) NOT IN ("L" "E" "N" "S" "F") AND 
	(
	(CRD_CLNT_ID IN ("SC_CCMSIN_CR") AND COMPRESS(MER_ID) NOT IN ("200000017500" "200000017502" "222967682229676") AND 
	((CUM_COUNT_CNP_5MINS > 5 AND CUM_AMOUNT_CNP_5MINS/63.75 GT 500) OR CUM_COUNT_CNP_5MINS > 9)) OR
	(CRD_CLNT_ID IN ("SC_C400NG_CR") AND CUM_COUNT_CNP_5MINS GE 3 AND CUM_AMOUNT_CNP_5MINS GT 9140) OR 
	(CRD_CLNT_ID IN ("SC_C400NP_CR") AND CUM_COUNT_CNP_5MINS GE 4 AND CUM_AMOUNT_CNP_5MINS GE 2000) OR 
	(CRD_CLNT_ID IN ("SC_C400ZM_CR") AND CUM_COUNT_CNP_5MINS GE 3 AND CUM_AMOUNT_CNP_5MINS GT 0)  
	)
	THEN CNP_3trxn_5mins_Test = "Y";

RUN;

DATA TXN_DATA;
	SET CNP_3trxn_5mins_Test_SAS;
	WHERE CNP_3trxn_5mins_Test = "Y" AND DATE1 GE "04AUG2021"D;
RUN;

DATA RULE_DATA;
     SET INC.FALT003_CR_04AUG
	 	INC.FALT003_CR_05AUG;
WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_CNP_3TRXN_5MINS_TEST') AND DATE1 GE "04AUG2021"D;
RUN;

PROC SORT DATA = CNP_3trxn_5mins_Test_RL NODUPKEY ;BY FI_TRANSACTION_ID; RUN;


PROC FREQ DATA=CNP_3trxn_5mins_Test; TITLE "HR_Global_CNP_3trxn_5mins_Test SAS"; 
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;

PROC FREQ DATA=CNP_3trxn_5mins_Test_RL; TITLE "HR_Global_CNP_3trxn_5mins_Test FALCON HITS"; 
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;



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