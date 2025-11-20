
			*******************************************************************
					 MR_CC_Global_RN_Int_CNP_Test Global Credit

			*******************************************************************;

LIBNAME INC "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Daily Data\CR";

DATA  FALT002;
SET 
INC.falt002_cr_01nov
INC.falt002_cr_02nov
INC.falt002_cr_03nov
INC.falt002_cr_04nov;   

WHERE  CRD_CLNT_ID NOT IN ("SC_CCMSHK_CR" "SC_PMTHK_CR" "SC_CCMSTW_CR" "SC_C400BD_CR") and 
TRN_AUTH_POST = "A" and AUTH_DECISION_XCD = "A";
FORMAT TRAN_DATE DATE9.;
 TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
 ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
 AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
 MCC = INPUT(SIC_CD,BEST.);

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
	ELSE IF CRD_CLNT_ID IN ("SC_PMTHK_CR") THEN USD = TRN_AMT/7.8;
	ELSE IF CRD_CLNT_ID IN ("SC_C400BD_CR") THEN USD = TRN_AMT_LOCAL/83.60;

RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;



PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 OUT=FALT002; BY ACCT_NBR AUTH_DTTM; RUN;

%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);
DATA FALT002;
SET FALT002;
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

%UDV
(
CUM_INTERVAL = 86400,                                          
CUMULATIVE_CONDITION = %STR(
 TRN_AUTH_POST  = "A" AND
 AUTH_DECISION_XCD  = "A" AND
 TRN_TYP IN ("C" "M" "P") AND
 TRN_POS_ENT_CD  IN ("E" "K" "G") AND
 TRN_AMT > 0
),
VAR_NAME = CNP_DAILY
);



DATA MR_CC_Global_RN_Int_CNP_TestSAS;
SET FALT002;
IF
(
(
 TRN_AUTH_POST  = "A" AND
 AUTH_DECISION_XCD  = "A" AND
SUBSTR(USR_IND_4,1,2) NE "Y2" AND
TRN_POS_ENT_CD  IN ("E" "K" "G")
)
and
(
(
 CRD_CLNT_ID  = "SC_C400AE_CR" AND  MER_CNTY_CD  NE "784" AND  TRN_TYP  IN ("C" "M" "P") AND AA_SCOR  >= 850
)

OR
(
 CRD_CLNT_ID  = "SC_C400BH_CR" AND  MER_CNTY_CD  NE "048" AND  TRN_TYP  IN ("C" "M" "P") and FRD_SCOR  >= 850
)

OR
(
 CRD_CLNT_ID  = "SC_C400GH_CR" AND  MER_CNTY_CD  NE "288" AND  TRN_TYP  IN ("C" "M" "P") and  FRD_SCOR  >= 650
)

OR

(
 CRD_CLNT_ID  = "SC_C400KE_CR" AND
 MER_CNTY_CD  NE "404" AND
 TRN_TYP  IN ("C" "M" "P" "U") and
 (
(
 MER_CNTY_CD  IN ("840" "233" "826" "372" "124" "566" "710" "292" ) AND
 FRD_SCOR  > 550 AND  TRN_AMT  > 500
) OR
(
NOT( MER_CNTY_CD  IN ("840" "233" "826" "372" "124" "566" "710" "292" )) AND
 FRD_SCOR  > 850
) OR
(
 FRD_SCOR  >= 980
)
)
)

OR

(
 CRD_CLNT_ID  = "SC_C400LK_CR" AND  MER_CNTY_CD  NE "144" AND  TRN_TYP  IN ("C" "M" "P") AND
(
( MER_CNTY_CD  IN ("840" "372" ) AND
 TRN_AMT  > 4000 AND  FRD_SCOR  >850) OR
( MER_CNTY_CD  = "826" AND
 TRN_AMT  > 4000 AND  FRD_SCOR  > 940) OR
( MER_CNTY_CD  NOT IN ("840"  "372"  "826") AND
 CUM_AMOUNT_CNP_DAILY > 30000 AND  FRD_SCOR  >960)
)
)

OR

(
 CRD_CLNT_ID  = "SC_C400NG_CR" AND  MER_CNTY_CD  NE "566" AND  TRN_TYP  IN ("C" "M" "P") and FRD_SCOR  >= 850
)

OR

(
 CRD_CLNT_ID  = "SC_C400ZM_CR" AND  MER_CNTY_CD  NE "894" AND  TRN_TYP  IN ("C" "M" "P") and  FRD_SCOR  >= 850
)
)
)
THEN MR_CC_Global_RN_Int_CNP_Test = "Y";
RUN;

DATA TXN_DATA;
SET MR_CC_Global_RN_Int_CNP_TestSAS;
WHERE MR_CC_Global_RN_Int_CNP_Test = "Y" and date1 GE "03NOV2021"D;
RUN;


DATA RULE_DATA;
SET 
INC.falt003_cr_03nov
INC.falt003_cr_04nov;
WHERE UPCASE(RULE_NAME_STRG) IN ('MR_CC_GLOBAL_RN_INT_CNP_TEST') and CLIENT_XID NOT IN ("SC_CCMSHK_CR" "SC_PMTHK_CR" "SC_CCMSTW_CR" "SC_C400BD_CR") 
and date1 GE "03NOV2021"D;
RUN;

PROC SORT DATA=RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA;TITLE "MR_CC_Global_RN_Int_CNP_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=RULE_DATA; TITLE "MR_CC_Global_RN_Int_CNP_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 



/* Writing Output to Excel - For Audit*/

ods listing;
ods excel file='C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\MR_CC_Global_RN_Int_CNP_Test Global Credit.xlsx'
 options(sheet_interval="NONE");
 ods excel options(sheet_name="OUTPUT");
 PROC FREQ DATA = TXN_DATA;TITLE "MR_CC_Global_RN_Int_CNP_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA = RULE_DATA; TITLE "MR_CC_Global_RN_Int_CNP_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;
ods excel close;
ods listing close;

PROC EXPORT DATA= TXN_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\MR_CC_Global_RN_Int_CNP_Test Global Credit.xlsx"
dbms=xlsx replace;
sheet="TXN_DATA";
run;

PROC EXPORT DATA= RULE_DATA
outfile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\SAS\Outputs\MR_CC_Global_RN_Int_CNP_Test Global Credit.xlsx"
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
'0060cca6d402f4ee',
'1e60cca61502dc17',
'2060cca6140444cf'
);
RUN;


/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_cr_03nov
INC.falt003_cr_04nov;
WHERE FI_TRANSACTION_ID IN 
(
'2161811c5400d7a3'
) and
UPCASE(RULE_NAME_STRG) not IN ('MR_CC_GLOBAL_RN_INT_CNP_TEST');
RUN;


/* 3 - Genuine list check */

DATA CASACTN;
SET INC.casactn_cr_03nov
INC.casactn_cr_04nov;
WHERE ACCT_NBR IN 
(
"4860560009684220"
) and date1 ge "03NOV2021"d;
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
SET FALT002;
WHERE FI_TRANSACTION_ID IN 
(
'2161811c5400d7a3'
);
RUN;

PROC EXPORT DATA= UDV_Mismatch
outfile= "C:\Users\1510806\Desktop\SAS\Outputs\MR_Country_CNP_Google_Facebook_Test BD Credi.xlsx"
dbms=xlsx replace;
sheet="UDV_Mismatch";
run;

/********************** cross check 6 STEPS ***********************/