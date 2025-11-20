
***************************************************************************
		 HR_Mcc_Score_non_major_Test Global Debit
				
***************************************************************************;

LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

DATA  FALT002;
SET
/*INC.falt002_db_23may*/
/*INC.falt002_db_24may;*/
INC.falt002_db_29may
INC.falt002_db_30may;
WHERE  (TRN_AUTH_POST = "A" and AUTH_DECISION_XCD = "A" and TRN_TYP IN ("C"  "M"  "P")
AND (
(
CRD_CLNT_ID NOT IN ("SC_EURONETIN_DB"  "SC_EURONETMY_DB"  "SC_EURONETSG_DB" "SC_EURONETAE_DB"
"SC_HOGANHK_DB" "SC_TANDEMTW_DB" "SC_EURONETID_DB") and
(
(SIC_CD ="2741" and FRD_SCOR > 800) or
(SIC_CD ="3695" and FRD_SCOR > 0) or
(SIC_CD ="4112" and FRD_SCOR > 960) or
(SIC_CD ="4722" and FRD_SCOR > 900) or
(SIC_CD ="4784" and FRD_SCOR > 200) or
(SIC_CD ="5046" and FRD_SCOR > 930) or
(SIC_CD ="5311" and FRD_SCOR > 930) or
(SIC_CD ="5533" and FRD_SCOR > 960) or
(SIC_CD ="5631" and FRD_SCOR > 990) or
(SIC_CD ="5661" and FRD_SCOR > 980) or
(SIC_CD ="5691" and FRD_SCOR > 980) or
(SIC_CD ="5698" and FRD_SCOR > 500) or
(SIC_CD ="5814" and FRD_SCOR > 940) or
(SIC_CD ="5818" and FRD_SCOR > 910) or
(SIC_CD ="7311" and FRD_SCOR > 930)
)
)
OR
(
CRD_CLNT_ID = "SC_SPARROWKE_DB" and
(
(SIC_CD ="4121" and FRD_SCOR > 850) or
(SIC_CD ="5734" and FRD_SCOR > 910 and MER_CNTY_CD IN ("344" "826" "840" "276" "724")) or
(SIC_CD ="5735" and FRD_SCOR > 700) or
(SIC_CD ="5812" and FRD_SCOR > 800) or
(SIC_CD ="5816" and FRD_SCOR > 700 and MER_CNTY_CD IN ("442" "196" "840" "702"))
)
)
OR
(
CRD_CLNT_ID = "SC_SPARROWBW_DB" and (SIC_CD ="5815" and FRD_SCOR > 850)
)
));
RUN;

PROC SORT DATA=FALT002 OUT=HR_Mcc_Score_non_major_Test NODUPKEY; BY FI_TRANSACTION_ID; RUN;


DATA HR_Mcc_Score_non_major_Test_RL;
SET
/*INC.falt003_db_23may*/
/*INC.falt003_db_24may;*/
INC.falt003_db_29MAY
INC.falt003_db_30MAY;
       WHERE UPCASE(RULE_NAME_STRG) IN ('HR_MCC_SCORE_NON_MAJOR_TEST') and date1 GE "29MAY2021"D;
RUN;

PROC SORT DATA=HR_Mcc_Score_non_major_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=HR_Mcc_Score_non_major_Test;TITLE "HR_Mcc_Score_non_major_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=HR_Mcc_Score_non_major_Test_RL; TITLE "HR_Mcc_Score_non_major_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 




/*CROSS CHECK* - 5 STEPS */

/********************** cross check 4 STEPS ***********************/

/* 1 - Getting txns in SAS not in Falcon */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT ACCT_NBR, FI_TRANSACTION_ID, MER_ID FROM HR_Mcc_Score_non_major_Test where 
FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
HR_Mcc_Score_non_major_Test_RL);
QUIT;


/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_db_29MAY
INC.falt003_db_30MAY;
WHERE FI_TRANSACTION_ID IN 
(
'0060b103ba03d789'
'0060b103ba03d828'
'1e60b102eb03bbd3'
'2160b1031900a715'
) and
UPCASE(RULE_NAME_STRG) not IN ('HR_MCC_SCORE_NON_MAJOR_TEST');
RUN;


/* 3 - Genuine list check */

DATA CASACTN;
SET INC.casactn_db_29may
INC.casactn_db_30may;
WHERE ACCT_NBR IN 
(
"4783932298520866"
"4935410000004450"
) and date1 ge "29may2021"d;
RUN;

/* 4 - If not solved in previous steps chec those ACCT_NBRs here*/
/* MER_ID or Name extraction for ACCT_NBS in SAS not in Falcon*/

PROC SQL;
CREATE TABLE VIP AS 
SELECT distinct(MER_ID), FI_TRANSACTION_ID FROM Txn_Data where ACCT_NBR in
(
'4783932298520866'
'4935410000004450'
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

/********************** cross check 5 STEPS ***********************/



/*PROC SQL;*/
/*CREATE TABLE CHK AS*/
/*SELECT * FROM */
/*HR_Mcc_Score_non_major_Test A LEFT JOIN HR_Mcc_Score_non_major_Test_RL B*/
/*ON A.FI_TRANSACTION_ID = B.FI_TRANSACTION_ID*/
/*WHERE CLIENT_XID="";*/
/*QUIT;*/
/**/
/*DATA CASACTN;*/
/*SET INC.CASACTN_DB_30JAN INC.CASACTN_DB_31JAN;*/
/*WHERE ACCT_NBR IN ("4592440200018418");*/
/*RUN;*/