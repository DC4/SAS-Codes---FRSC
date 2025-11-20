**************************************************************
		 XCNI_HR_Global_Contactless_Decline DR Credit
				
**************************************************************;
OPTIONS COMPRESS=YES;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";
LIBNAME IND "C:\Users\1510806\Desktop\Jhilam\Daily Data\DB";

LIBNAME DAT "Y:\Falcon june 2017\Falcon 6.4 falcon download\DR";

/**/
/*LIBNAME IND "C:\Users\1586087\Documents\Daily_datasets\debit";*/

DATA  FALT002;
SET DAT.falt002_dr_cr_sep2021;
WHERE  
(
 TRN_AUTH_POST  = "A" AND
 AUTH_DECISION_XCD  = "A" AND
 TRN_TYP  IN ("C" "M" "P") AND
TRN_POS_ENT_CD  = "C" AND
NOT(SUBSTR(USER_DATA_4_STRG,1,11) IN ("50110030273" "50120834693" "50139059239"))
) and date1 GE "05SEP2021"D;
RUN;

PROC SORT DATA=FALT002 OUT=TXN_DATA NODUPKEY; BY FI_TRANSACTION_ID; RUN;


DATA RULE_DATA;
     SET DAT.falt003_dr_cr_sep2021;
       WHERE UPCASE(RULE_NAME_STRG) IN ('XCNI_HR_GLOBAL_CONTACTLESS_DECLINE') and date1 GE "05SEP2021"D;
RUN;

PROC SORT DATA=RULE_DATA NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=TXN_DATA;TITLE "TXN_DATA SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=RULE_DATA; TITLE "RULE_DATA FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

