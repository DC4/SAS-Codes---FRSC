
**********************************************************
		HR_BIN_Attack_CNP_AMAZON_SG_Test Global Credit
				
**********************************************************;

PROC DELETE DATA=_ALL_;RUN;
OPTIONS COMPRESS=YES;


proc delete data = hotlist; run;

%macro ch( start, end);

%do SHEET = &START. %to &END. %by 1;

proc import datafile="C:\Users\1586087\Downloads\data (&SHEET.).xls" out=x_&SHEET. dbms=xls replace; 
namerow=2;
startrow=3;
run;

data x_&SHEET.;
set x_&SHEET.;
run;

proc append data=x_&SHEET. base=hotlist force; run;

%end;

%mend;

%ch(7, 10);


proc delete data = hotlist2; run;

%macro ch( start, end);

%do SHEET = &START. %to &END. %by 1;

proc import datafile="C:\Users\1586087\Downloads\data (&SHEET.).xls" out=x_&SHEET. dbms=xls replace; 
namerow=2;
startrow=3;
run;

data x_&SHEET.;
set x_&SHEET.;
run;

proc append data=x_&SHEET. base=hotlist2 force; run;

%end;

%mend;

%ch(11, 13);

LIBNAME INC "C:\Users\1586087\Documents\Daily_datasets\Credit";


DATA  FALT002;
SET INC.falt002_cr_01aug INC.falt002_cr_02aug INC.falt002_cr_03aug
	INC.falt002_cr_04aug;   
WHERE  (TRN_AUTH_POST = "A" and  TRN_TYP IN ("C"  "M"  "P")
and TRN_POS_ENT_CD IN ("E"  "K"  "G" "") and CRD_CLNT_ID ="SC_CCMSSG_CR" );
FORMAT TRAN_DATE DATE9.;
 TRAN_DATE = INPUT(SUBSTR(TRN_DT,1,2) || SUBSTR(TRN_DT,4,3) || '20' || SUBSTR(TRN_DT,8,2),DATE9.);
 ATTRIB AUTH_DTTM FORMAT=DATETIME19.;
 AUTH_DTTM=DHMS(TRAN_DATE,SUBSTR(TRN_DT,11,2),SUBSTR(TRN_DT,14,2),SUBSTR(TRN_DT,17,2)); 
 MCC = INPUT(SIC_CD,BEST.);
MERCHANTBIN=COMPRESS(MER_ID)||SUBSTR(ACCT_NBR,1,6);
RUN;

PROC SORT DATA=FALT002 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

PROC SQL;
CREATE TABLE FALT002_1 AS
SELECT * FROM FALT002
WHERE STRIP(MER_ID) NOT IN (SELECT DISTINCT NAME FROM HOTLIST);
QUIT;


PROC SQL;
CREATE TABLE FALT002_2 AS SELECT * from FALT002_1
WHERE STRIP(MER_ID) NOT IN (SELECT DISTINCT NAME FROM HOTLIST2 WHERE INDEX(VALUE,"SG"));
QUIT;


PROC SORT DATA=FALT002_2; BY MERCHANTBIN AUTH_DTTM; RUN;

%MACRO UDV(CUM_INTERVAL=, CUMULATIVE_CONDITION =, VAR_NAME=);

DATA FALT002_2;
     SET FALT002_2;
     BY MERCHANTBIN AUTH_DTTM;

     FORMAT TIME_RESET_&VAR_NAME. DATETIME19.;

     RETAIN CUM_COUNT_&VAR_NAME. TIME_RESET_&VAR_NAME. CUM_AMOUNT_&VAR_NAME. DAILY_PREV;

     IF FIRST.MERCHANTBIN THEN DO;
           TIME_RESET_&VAR_NAME. = 0;
           CUM_COUNT_&VAR_NAME. = 0;
           CUM_AMOUNT_&VAR_NAME. = 0;
		   DAILY_PREV = 0;
     END;

     IF &CUMULATIVE_CONDITION. THEN DO;
           IF AUTH_DTTM LE (TIME_RESET_&VAR_NAME. + &CUM_INTERVAL.) THEN DO;
                CUM_COUNT_&VAR_NAME. + 1;
                CUM_AMOUNT_&VAR_NAME. + TRN_AMT;
           END;
           ELSE DO;
		   		DAILY_PREV = FLOOR(TIME_RESET_&VAR_NAME.);
                TIME_RESET_&VAR_NAME. = AUTH_DTTM;
                CUM_COUNT_&VAR_NAME. = 1;
                CUM_AMOUNT_&VAR_NAME. = TRN_AMT;
           END;
     END;

RUN;
%MEND; 

%UDV(CUM_INTERVAL        = 86400,                                          
     CUMULATIVE_CONDITION= %STR(TRN_AUTH_POST = "A" and TRN_POS_ENT_CD IN ("E"  "K"  "G" "") and 
	TRN_TYP IN ("C"  "M"  "P") AND MER_ID NE ""),
     VAR_NAME            = BIN_DAILY);


DATA CNP_AMAZON_SG_TestSAS;
    SET FALT002_2;
    IF ((
TRN_AUTH_POST = "A" and AUTH_DECISION_XCD IN ("A" "") and
TRN_TYP IN ("C" "M" "P") and TRN_POS_ENT_CD IN ("E"  "K"  "G") and
TRN_AMT > 0 and (AUTH_DTTM - TIME_RESET_BIN_DAILY < 86400)
)
AND
(
CRD_CLNT_ID = "SC_CCMSSG_CR" and
(
INDEX(UPCASE(MER_NM),"AMZN MKTP FR") OR
INDEX(UPCASE(MER_NM),"AMZN MKTP CA") OR
INDEX(UPCASE(MER_NM),"AMAZON.FR") OR
INDEX(UPCASE(MER_NM),"AMAZON.CA")
) and
CUM_COUNT_BIN_DAILY >= 25
)
)
       THEN CNP_AMAZON_SG_Test = "Y";
RUN;

DATA CNP_AMAZON_SG_Test;
SET CNP_AMAZON_SG_TestSAS;
WHERE CNP_AMAZON_SG_Test = "Y" and date1 GE "03AUG2021"D;
RUN;


DATA CNP_AMAZON_SG_Test_RL;
     SET INC.falt003_cr_03aug INC.falt003_cr_04aug;
       WHERE UPCASE(RULE_NAME_STRG) IN ('HR_BIN_ATTACK_CNP_AMAZON_SG_TEST') and date1 GE "03AUG2021"D;
RUN;

PROC SORT DATA=CNP_AMAZON_SG_Test_RL NODUPKEY; BY RULE_NAME_STRG FI_TRANSACTION_ID; RUN;

PROC FREQ DATA=CNP_AMAZON_SG_Test;TITLE "CNP_AMAZON_SG_Test SAS";
TABLE CRD_CLNT_ID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
PROC FREQ DATA=CNP_AMAZON_SG_Test_RL; TITLE "CNP_AMAZON_SG_Test FALCON";
TABLE CLIENT_XID*DATE1/NOCOL NOROW NOPERCENT NOCUM; RUN; 
