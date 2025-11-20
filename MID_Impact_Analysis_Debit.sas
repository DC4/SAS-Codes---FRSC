
LIBNAME EXIST "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data";

******* Impact analysis for UAE ************;

LIBNAME CR "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Previous_Run_Data\Debit_OLD";


****** Pulling FRD15 file ***********;

proc sort data=exist.frd15 out=frd15 nodupkey; 
by pan fiTransactionIdReference; 
run;

******* For Credit *********;

data FALT002;
     set CR.falt002_BD_db_mar2021
           CR.falt002_BD_db_apr2021
           CR.falt002_BD_db_may2021;
where strip(mer_id) in ('200000000000018', '505331201201000', '705331200511001') and
TRN_AUTH_POST = "A" and 
AUTH_DECISION_XCD = "A" and
TRN_TYP IN ("C" "M" "P");
run;


proc sql;
create table FALT002_1
as select a.*,
             tranwrd(mer_nm, mer_id, "") as Merchant,
             b.fraudflag,
             case 
                when strip(upcase(a.frd_ind)) in ("Y" "D") or b.fraudflag="1" then 1 
             end as FRAUD
from FALT002 as a left join frd15 as b on 
a.acct_nbr = b.pan and
a.fi_transaction_id=b.fiTransactionIdReference;
quit;


proc sort data=FALT002_1; where fi_transaction_id ne ""; by acct_nbr fi_transaction_id descending fraud; run;
proc sort data=FALT002_1 nodupkey; where fi_transaction_id ne ""; by acct_nbr fi_transaction_id ; run;

proc sql;
create table CR_Impact_Summary as 
select distinct mer_id,  MERCHANT,
           count(distinct fi_transaction_id) as Total_Txns, 
           count(distinct acct_nbr) as Total_Cards_Used, 
           sum(fraud) as No_of_Frauds, 
           count(distinct case when fraud=1 then acct_nbr end) as No_of_Cards_Fraud, 
           case 
            when sum(fraud) ne . then calculated Total_Txns/calculated No_of_Frauds
           else calculated Total_Txns
           end as TFPR,
           case 
            when sum(fraud) ne . then calculated Total_Cards_Used/calculated No_of_Cards_Fraud
           else calculated Total_Cards_Used
           end as AFPR
from FALT002_1
group by mer_id;
quit;
