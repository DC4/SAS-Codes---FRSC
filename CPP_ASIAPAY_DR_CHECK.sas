libname dec "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Dec21_Non_Major\Dragon";
libname jan "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Jan22\Dragon";
libname bfr6 "Z:\Falcon june 2017\Falcon 6.4 falcon download\DR";
libname exist "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Falcon 6.4 Monthly Data";

PROC SORT DATA=EXIST.FRD15 OUT=FRD15 NODUPKEY; 
BY PAN FITRANSACTIONIDREFERENCE; 
RUN;

DATA DR_6MNTH_1;
SET dec.last_3_months_data_cr
jan.last_3_months_data_cr;
RUN;

DATA DR_6MNTH_2;
SET
bfr6.falt002_dr_cr_jan2021
bfr6.falt002_dr_cr_feb2021
bfr6.falt002_dr_cr_mar2021
bfr6.falt002_dr_cr_apr2021
bfr6.falt002_dr_cr_may2021
bfr6.falt002_dr_cr_jun2021;
RUN;

PROC SORT DATA=DR_6MNTH_2; BY FI_TRANSACTION_ID DESCENDING FRD_IND; RUN;
PROC SORT DATA=DR_6MNTH_2 NODUPKEY; BY FI_TRANSACTION_ID; RUN;

proc sql;
create table DR_6MNTH_Tagged
as select a.*,
             b.fraudflag,
             case 
                when strip(upcase(a.frd_ind)) in ("Y" "D") or b.fraudflag="1" then 1 
             end as FRAUD
from DR_6MNTH_2 as a left join exist.frd15 as b on 
a.acct_nbr = b.pan and
a.fi_transaction_id=b.fiTransactionIdReference;
quit;

DATA DR_6MNTH_Final;
SET DR_6MNTH_1
DR_6MNTH_Tagged;
WHERE FRAUD = 1;
RUN;

PROC IMPORT DATAFILE="C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Required\Hotlist\CPP_ASIAPAY.XLSX"
OUT=CPP_ASIAPAY DBMS=XLSX REPLACE;RUN;

PROC SQL;
CREATE TABLE CPP_FRAUD AS
SELECT A.*, B.INDICATOR FROM
DR_6MNTH_Final A LEFT JOIN CPP_ASIAPAY B
ON STRIP(A.ACCT_NBR)=STRIP(B.HOTLIST_VALUE_NAME);
QUIT;
