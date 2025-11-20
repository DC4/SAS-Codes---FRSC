
***************************************************************************
		 MR_Country_Amazon_KE_Test Global Debit
				
***************************************************************************;

LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

DATA  FALT002;
SET
/*INC.falt002_db_23may*/
/*INC.falt002_db_24may;*/
INC.falt002_db_29may
INC.falt002_db_30may;

WHERE  

(
CRD_CLNT_ID = "SC_SPARROWKE_DB" and
TRN_AUTH_POST = "A" and
(AUTH_DECISION_XCD = "A" or (AUTH_DECISION_XCD="" and DECI_CD_ORIG = "A")) and
TRN_TYP IN ("C"  "M"  "P") and
COMPRESS(MER_ID) = "160146000762203" AND
INDEX(UPCASE(MER_NM),"AMZN") AND
(TRN_AMT >= 1000 and TRN_AMT <= 1200) AND
FRD_SCOR > 500
);
RUN;

PROC SORT DATA=FALT002 OUT=MR_Country_Amazon_KE_Test NODUPKEY; BY FI_TRANSACTION_ID; RUN;


DATA MR_Country_Amazon_KE_Test_RL;
SET
/*INC.falt003_db_23may*/
/*INC.falt003_db_24may;*/
INC.falt003_db_29MAY
INC.falt003_db_30MAY;
WHERE UPCASE(RULE_NAME_STRG) IN ('MR_COUNTRY_AMAZON_KE_TEST') and date1 GE "29MAY2021"D;
RUN;

PROC SORT DATA=MR_Country_Amazon_KE_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=MR_Country_Amazon_KE_Test;TITLE "MR_Country_Amazon_KE_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=MR_Country_Amazon_KE_Test_RL; TITLE "MR_Country_Amazon_KE_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 




/*PROC SQL;*/
/*CREATE TABLE CHK AS*/
/*SELECT * FROM */
/*MR_Country_Amazon_KE_Test A LEFT JOIN MR_Country_Amazon_KE_Test_RL B*/
/*ON A.FI_TRANSACTION_ID = B.FI_TRANSACTION_ID*/
/*WHERE CLIENT_XID="";*/
/*QUIT;*/
/**/
/*DATA CASACTN;*/
/*SET INC.CASACTN_DB_30JAN INC.CASACTN_DB_31JAN;*/
/*WHERE ACCT_NBR IN ("4592440200018418");*/
/*RUN;*/