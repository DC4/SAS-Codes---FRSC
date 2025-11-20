/* Remoe password and run - Saravana gets this file from Mox*/

Proc import datafile = 'C:\Users\1510806\Desktop\SAS\Monthly Rule Review - Jul\Copy of Non Falcon 2021[1].xlsx'
out=Dragon_dispute
dbms= xlsx replace; sheet="June 2021";
run;

Data Dragon_dispute;
set Dragon_dispute;
if 'product*'n = "" then delete;
run;

/*LIBNAME DC 'Y:\Falcon june 2017\Falcon 6.4 falcon download\DR';*/
/*Run from local after copying dataset from above path as shared drive might take time*/
LIBNAME DC 'C:\Users\1510806\Desktop\New folder';

Data FALT002;
SET
DC.falt002_dr_cr_may2021
DC.falt002_dr_cr_jun2021;
run;


PROC SQL;
CREATE TABLE FALT002_A AS
Select * from FALT002 A LEFT JOIN DRAGON_DISPUTE B
ON A.ACCT_NBR=B.'Card Number*'n AND
INPUT(A.SIC_CD,BEST.)=B.'MCC*'n and
A.DATE1=INPUT(B.'Trans date*'n, mmddyy10.)
/*A.TRN_AMT=B.'Trans Amount*'n*/
WHERE B.'Card Number*'n NE '';
QUIT;


PROC SORT DATA=FALT002_A NODUPKEY; BY FI_TRANSACTION_ID; RUN;