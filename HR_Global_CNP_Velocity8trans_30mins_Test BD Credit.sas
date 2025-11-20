


***********************************************************************

		HR_Global_CNP_Velocity8trans_30mins_Test BD Credit 

***********************************************************************;



LIBNAME INC "C:\Users\1510806\Desktop\Jhilam\Daily Data\CR";

DATA  FALT002;
SET 
/*INC.falt002_cr_23may*/
/*INC.falt002_cr_24may;*/
INC.falt002_cr_28may
INC.falt002_cr_29may
INC.falt002_cr_30may; 
     WHERE TRN_AUTH_POST = "A" AND AUTH_DECISION_XCD = "A" AND TRN_TYP IN ("C" "M" "P") AND 
TRN_POS_ENT_CD IN ("E" "K" "G") and
CLIENT_XID = "SC_C400BD_CR";	
     FORMAT TRAN_DATE DATE9.;
     TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
     ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
     AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
     MCC = INPUT(SIC_CD,BEST.);

	 IF SUBSTR(ACCT_NBR,1,6) IN ('411144'
								'421451'
								'469626'
								'470691') THEN TRN_AMT_LOCAL = TRN_AMT * 83.60;
	ELSE TRN_AMT_LOCAL = TRN_AMT;

	USD = TRN_AMT_LOCAL/83.60;

RUN;


PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SORT DATA=FALT002 OUT=FALT002_2; BY ACCT_NBR AUTH_DTTM; RUN;


%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002_2;
     SET FALT002_2;
     BY ACCT_NBR AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;

     RETAIN CUM_COUNT_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. m;

     IF FIRST.ACCT_NBR THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + USD;
           END;
           ELSE DO;
                TIME_RESET_&VAR_NAME. = AUTH_DTTM;
                CUM_COUNT_&VAR_NAME. = 1;
                CUM_AMOUNT_&VAR_NAME. = USD;
           END;
     END;


RUN;
%MEND; 

%UDV(CUM_INTERVAL        = 1800,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" and AUTH_DECISION_XCD = "A" and TRN_TYP IN ("C" "M" "P")
                            AND TRN_POS_ENT_CD IN ("E" "K" "G") AND TRN_AMT > 0),
     VAR_NAME            = CNP_30MINS);



DATA Velocity8trans_30mins_TestSAS;
    SET FALT002_2;

    IF TRN_AUTH_POST = "A" and AUTH_DECISION_XCD = "A" and 
	MCC NOT IN (5964 4900 5960 6300 4112 4814 4899 5968 9399) AND
	   NOT(3000 LE MCC LE 3999) AND SUBSTR(USR_DAT_2,1,9) NOT IN ("L" "E" "N" "S" "F") AND
       TRN_TYP IN ("C" "M" "P") AND TRN_POS_ENT_CD IN ("E" "K" "G") AND SUBSTR(USR_IND_4,1,2) NE "Y2" AND 
	   (
		CUM_COUNT_CNP_30MINS GE 8 AND CUM_AMOUNT_CNP_30MINS GE 400 AND
		FRD_SCOR GT 50
	   )
	    AND CRD_CLNT_ID = "SC_C400BD_CR"

       THEN Velocity8trans_30mins_Test = "Y";
RUN;

DATA Velocity8trans_30mins_Test;
SET Velocity8trans_30mins_TestSAS;
WHERE Velocity8trans_30mins_Test = "Y" AND DATE1 GE "29MAY2021"D;
RUN;


DATA Velocity8trans_30mins_Test_RL;
     SET 
/*INC.falt003_cr_23may*/
/*INC.falt003_cr_24may;*/
INC.falt003_cr_29MAY
INC.falt003_cr_30MAY;
       WHERE UPCASE(RULE_NAME_STRG) IN ('HR_GLOBAL_CNP_VELOCITY8TRANS_30MINS_TEST') AND 
	   CLIENT_XID = "SC_C400BD_CR" AND DATE1 GE "29MAY2021"D;
RUN;

PROC SORT DATA=Velocity8trans_30mins_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=Velocity8trans_30mins_Test; TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

PROC FREQ DATA=Velocity8trans_30mins_Test_RL; TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 

