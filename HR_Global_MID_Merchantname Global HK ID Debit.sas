

**************************************************************************************

				HR_Global_MID_Merchantname Global HK ID Debit

**************************************************************************************;

*********************************************************
DATA LOCATION
*********************************************************;
LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";


*********************************************************
SAS HITS
*********************************************************;

DATA FALT002;
SET
/*INC.falt002_db_02jun*/
/*INC.falt002_db_01jun;*/
INC.falt002_db_05jun
INC.falt002_db_06jun;

WHERE 
(DATE1 GE "06JUN2021"D and
(
 TRN_AUTH_POST  = "A" AND
( AUTH_DECISION_XCD  = "A" OR (AUTH_DECISION_XCD = "" AND  DECI_CD_ORIG  = "A")) AND
 TRN_TYP  IN ("C" "M" "P")
)
AND
(
(
 CRD_CLNT_ID  IN ("SC_HOGANHK_DB" "SC_EURONETID_DB" "SC_EURONETAE_DB" "SC_EURONETBH_DB" "SC_EURONETBN_DB" "SC_SPARROWBW_DB" 
"SC_SPARROWCI_DB" "SC_SPARROWCM_DB" "SC_SPARROWGH_DB" "SC_SPARROWGM_DB" "SC_EURONETIN_DB" "SC_SPARROWJO_DB" 
"SC_SPARROWKE_DB" "SC_SPARROWLK_DB" "SC_EURONETMY_DB" "SC_SPARROWNP_DB" "SC_EURONETQA_DB" "SC_EURONETSG_DB" 
"SC_SPARROWSL_DB" "SC_SPARROWTZ_DB" "SC_SPARROWUG_DB" "SC_EURONETVN_DB" "SC_SPARROWZM_DB" "SC_SPARROWZW_DB") AND
(COMPRESS(MER_ID) = "3057FLI300000I3" AND INDEX(UPCASE(MER_NM), "FW.SHOP*"))
)
OR
(
 CRD_CLNT_ID  IN ("SC_HOGANHK_DB" "SC_EURONETID_DB" "SC_EURONETAE_DB" "SC_EURONETBH_DB" "SC_EURONETBN_DB" "SC_SPARROWBW_DB"  "SC_SPARROWCI_DB""SC_SPARROWCM_DB" "SC_SPARROWGH_DB" "SC_SPARROWGM_DB" "SC_EURONETIN_DB" "SC_SPARROWJO_DB" "SC_SPARROWKE_DB" 
"SC_SPARROWLK_DB" "SC_EURONETMY_DB" "SC_SPARROWNP_DB" "SC_EURONETQA_DB" "SC_EURONETSG_DB" "SC_SPARROWSL_DB" 
"SC_SPARROWTZ_DB" "SC_SPARROWUG_DB" "SC_EURONETVN_DB" "SC_SPARROWZM_DB" "SC_SPARROWZW_DB" "SC_SPARROWNG_DB") AND
(
(COMPRESS(MER_ID) = "500100000187" AND INDEX(UPCASE(MER_NM), "ABADYSTORES")) OR
(COMPRESS(MER_ID) = "000000000204560" AND INDEX(UPCASE(MER_NM), "REVOLUT*"))
)
)
)
);

IF CRD_CLNT_ID NOT IN ("SC_TANDEMTW_DB" "SC_HOGANHK_DB" "SC_SPARROWBD_DB" "SC_EURONETID_DB" "") THEN TENANT = "GBL";
ELSE IF CRD_CLNT_ID IN ("SC_HOGANHK_DB") THEN TENANT = "HK";
ELSE IF CRD_CLNT_ID IN ("SC_EURONETID_DB") THEN TENANT = "ID";

RUN;

PROC SORT DATA=FALT002 OUT=TXN_DATA NODUPKEY; BY FI_TRANSACTION_ID; RUN;


*********************************************************
FALCON HITS
*********************************************************;

DATA RULE_DATA;
SET
/*INC.falt003_db_02jun*/
/*INC.falt003_db_01jun;*/
INC.falt003_db_05jun
INC.falt003_db_06jun;

WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_MID_MERCHANTNAME') and DATE1 GE "06JUN2021"D;

IF CLIENT_XID NOT IN ("SC_TANDEMTW_DB" "SC_HOGANHK_DB" "SC_SPARROWBD_DB" "SC_EURONETID_DB" "") THEN TENANT = "GBL";
ELSE IF CLIENT_XID IN ("SC_HOGANHK_DB") THEN TENANT = "HK";
ELSE IF CLIENT_XID IN ("SC_EURONETID_DB") THEN TENANT = "ID";

RUN;

PROC SORT DATA = RULE_DATA NODUPKEY ;BY FI_TRANSACTION_ID; RUN;


*********************************************************
COUNT COMPARISON
*********************************************************;

PROC FREQ DATA=TXN_DATA; TITLE "TXN_DATA SAS HITS"; 
TABLE TENANT*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;

PROC FREQ DATA=RULE_DATA; TITLE "TXN_DATA FALCON HITS"; 
TABLE TENANT*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN;




/*DATA GENUINE;*/
/*SET INC.CASACTN_DB_21FEB;*/
/*WHERE ACCT_NBR IN */
/*('4455980202232844');*/
/*RUN;*/


/*CROSS CHECK* - 5 STEPS */

/********************** cross check 4 STEPS ***********************/

/* 1 - Getting txns in SAS not in Falcon */
/* MER_ID is Name in VIP list Case manager */

PROC SQL;
CREATE TABLE txn_in_sas_not_in_rule AS 
SELECT ACCT_NBR, FI_TRANSACTION_ID, MER_ID, CRD_CLNT_ID FROM TXN_DATA where FI_TRANSACTION_ID not in (SELECT distinct(FI_TRANSACTION_ID) FROM 
RULE_DATA);
QUIT;


/* 2 - High priority rule check */

DATA OTHER_RULE;
SET 
INC.falt003_db_05jun
INC.falt003_db_06jun;
WHERE FI_TRANSACTION_ID IN 
(
'1f60ba4ef602bb32' /*GBL */
/*'0160ba4fce04a3b0'  /*GBL - Caseaction*/
/*'1f60ba4ef6048fd4'   /*GBL - Caseaction*/
/*'2060ba4ef604027c' /*High priority rule HK*/
/*'2160ba4f2804239b' /* VIP Genuine */
) and
UPCASE(RULE_NAME_STRG) not IN ('HR_GLOBAL_MID_MERCHANTNAME');
RUN;


/* 3 - Genuine list check */

DATA CASACTN;
SET INC.casactn_db_05jun
INC.casactn_db_06jun;
WHERE ACCT_NBR IN 
(
"4783947600025065" /*GBL */
/*"5523024972177197" /*GBL - Caseaction*/
/*"5523024972177197" /*GBL - Caseaction*/
/*"4509360641073065" /*High priority rule HK*/
/*"5523438412256975" /* VIP Genuine */
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

/********************** cross check 5 STEPS ***********************/