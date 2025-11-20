
**************************************************************************************

				MR_CC_Country_Dom_CNP_ID_Test ID DEBIT

**************************************************************************************;


LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";


*********************************************************;
DATA  FALT002;
SET
/*INC.falt002_db_23may*/
/*INC.falt002_db_24may;*/
INC.falt002_db_29may
INC.falt002_db_30may;

WHERE  

(
CRD_CLNT_ID = "SC_EURONETID_DB" and
MER_CNTY_CD = "360" and
TRN_AUTH_POST = "A" and
AUTH_DECISION_XCD = "A" and
TRN_TYP IN ("C" "M") and
TRN_POS_ENT_CD IN ("E" "K") and
FRD_SCOR > 750
);
RUN;

PROC SORT DATA=FALT002 OUT=MR_CC_Country_Dom_CNP_ID_Test NODUPKEY; BY FI_TRANSACTION_ID; RUN;


DATA MR_CC_Country_Dom_CNP_ID_Test_RL;
SET
/*INC.falt003_db_23may*/
/*INC.falt003_db_24may;*/
INC.falt003_db_29MAY
INC.falt003_db_30MAY;
WHERE UPCASE(RULE_NAME_STRG) IN ('MR_CC_COUNTRY_DOM_CNP_ID_TEST') and date1 GE "29MAY2021"D;
RUN;

PROC SORT DATA=MR_CC_Country_Dom_CNP_ID_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=MR_CC_Country_Dom_CNP_ID_Test;TITLE "MR_CC_Country_Dom_CNP_ID_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=MR_CC_Country_Dom_CNP_ID_Test_RL; TITLE "MR_CC_Country_Dom_CNP_ID_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 



