proc delete data=_all_;run;

 %LET TOD = %SYSFUNC(TODAY());
 %LET MNTH0 = %SYSFUNC(INTNX(MONTH,&TOD.,0),MONYY7.);
 %LET MNTH1 = %SYSFUNC(INTNX(MONTH,&TOD.,-1),MONYY7.);
 %LET MNTH11 = %SYSFUNC(CATX(,%SYSFUNC(SUBSTR(&MNTH1.,1,3)),%SYSFUNC(SUBSTR(&MNTH1.,6,2)) ));
 %LET MNTH00 = %SYSFUNC(CATX(,%SYSFUNC(SUBSTR(&MNTH0.,1,3)),%SYSFUNC(SUBSTR(&MNTH0.,6,2)) ));
 %PUT &MNTH1. &MNTH0. &MNTH11. &MNTH00.;



**** COMMENTS: Change the Path ******;


libname a "C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&MNTH00.\Dragon";


**** COMMENTS: Increase these below month by one ******;

/* Changed on June 8th for June month - READY TO RUN */

%let prv_m = JUN21;
%let curr_mth = JUL21;
%let rmth = 202106;
%let prev_mth = 202105;
%let prev_mth1 = 202104;
%let prev_mth2 = 202103;
%let rule_segment = a.RULE_SEGMENT;
%let disputefile = a.dispute_JUL_2021_CR;
%let portfolio = "CREDIT";
%let frd_table = a.FRAUD_CR_APR21_TO_JUN21;
%let tran_tab = a.LAST_3_MONTHS_DATA_CR;
%let rule_hit_tab = a.RULE_HIT_LAST_3_MONTHS_CR;
%let rule_perf = a.RULE_PERFORMANCE_CR_JUL2021;

proc import datafile=
"\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Saravana\Monthly Reviews\Falcon\Rule_Segment_GBL_new.xls"
out=a.rule_segment dbms=xls replace;run;

proc sql;
create table t as 
select distinct rule_name_strg as rule_name_strg,
CASE WHEN STRIP(CLIENT_XID) IN ("SC_PMTHK_CR") THEN "DR" END AS TENANT
from &rule_hit_tab. ;
quit;

/*COMMENTS: if new_rule dataset contains any rule please go to the below path 
\\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Saravana\Monthly Reviews\Falcon
and update the file Rule_Segment_GBL_new.xls*/

proc sql;
create table new_rule as 
select distinct TENANT, RULE_NAME_STRG 
from T
where RULE_NAME_STRG not in (select Rule_Name from a.rule_segment);
quit;


/*COMMENTS: once you recieved the dispute file, take the variable fi_transaction_id as fitxn and 
create a new file named dispute_transaction_sep2019_gbl.xlsx in the below path
\\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Saravana\Monthly Reviews\Falcon\oct2019\*/

proc import datafile=
"\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Saravana\Monthly Reviews\Falcon\&MNTH0.\dispute_transaction_&MNTH1._gbl.xlsx"
out=fitxn dbms=xlsx replace;run;

proc sql;
create table &disputefile. as 
select distinct(acct_nbr ) as dispute_card from a.LAST_3_MONTHS_DATA_CR
where compress(trim(fi_transaction_id)) in (select compress(trim(fitxn)) from fitxn);
quit;




data &frd_table.;
set &frd_table.;
country="DR";
/*country=compress(tranwrd(tranwrd(scan(crd_clnt_id,2,"_"),"C400",""),"CCMS",""));*/

	IF CRD_CLNT_ID IN ("SC_PMTHK_CR") THEN USD = TRN_AMT/7.8;

run;

proc sql;
create table frd_mth as 
select crd_clnt_id,acct_nbr,
input(put(max(date1),yymmn6.),6.) as frd_month
from &frd_table.
group by crd_clnt_id,acct_nbr;
quit;

data disp;
set &disputefile.;
frd_month1 =&rmth.;
run;


data disp_all;
set disp ;
run;

proc sql;
create table frd_mth1 as 
select a.*,b.frd_month1 from
frd_mth a
left join disp_all b
on a.acct_nbr = b.dispute_card;
quit;

data frd_mth1;
set frd_mth1;
if frd_month1 <> . then frd_month = frd_month1;
run;

proc sql;
create table &frd_table.1 as 
select a.*,b.frd_month
from &frd_table. a
left join frd_mth1 b
on a.acct_nbr = b.acct_nbr;
quit;

proc sql;
create table tab1 as 
select crd_clnt_id,frd_month,
count(distinct acct_nbr)  as value
from &frd_table.1  
group by crd_clnt_id,frd_month;
quit;

data tab1(drop=value);
set tab1;
format var_name $50.;
value1 = compress(put(value,$20.));
var_name = "num_accts";
run;

proc sql;
create table tab2 as 
select crd_clnt_id,frd_month,
count(*)  as value
from &frd_table.1
group by crd_clnt_id,frd_month;
quit;

data tab2(drop=value);
set tab2;
format var_name $50.;
value1 = compress(put(value,$20.));
var_name = "num_txns";
run;

proc sort data=&frd_table.1;by acct_nbr frd_month;run;

data &frd_table.1;
set &frd_table.1;
by acct_nbr frd_month;
if first.acct_nbr then acct_cnt = 1;
run;

data &frd_table.1;
set &frd_table.1;
format rule_hit $2.;
run;

proc sql;
update &frd_table.1 
set rule_hit = "Y" 
where fi_transaction_id in (select fi_transaction_id from &rule_hit_tab.);
quit;

proc sql;
select count(distinct(acct_nbr)) from &frd_table.1;
quit;

proc sql;
create table tab2x as 
select crd_clnt_id,frd_month,
acct_nbr,
sum(case when frd_ind = "Y" or fraudFlag = "1" or rule_hit = 'Y' then 1 else 0 end ) as detect,
sum(case when fraudFlag ne '1' and frd_ind = 'D' and rule_hit ne "Y" then 1 else 0 end ) as undetect,
max(date1)-min(date1) as run_days
from &frd_table.1
group by 
crd_clnt_id,frd_month,
acct_nbr;
quit;

data tab2x;
set tab2x;
Detection = "N";
if detect > 0 then Detection = "Y";
run;

proc sql;
create table undetect_summary as 
select country,acct_nbr,
sum(usd ) as frd_tot_amt_usd,
count(*) as frd_tot_cnt,
sum(case when TRN_POS_ENT_CD not in ('E','K','G') then 1 else 0 end ) as cp_cnt ,
sum(case when TRN_POS_ENT_CD in ('E','K','G') then 1 else 0 end ) as cnp_cnt ,
sum(case when AUTH_DECISION_XCD = "A" then usd else 0 end) as frd_appr_amt_usd,
sum(case when AUTH_DECISION_XCD = "A" then 1 else 0 end) as frd_appr_cnt
from &frd_table.1 where acct_nbr in (select acct_nbr from tab2x where Detection = "N" and frd_month = &rmth.) 
group by country, acct_nbr
order by country , frd_tot_amt_usd desc;
quit;


data undetect_summary(drop=cp_cnt cnp_cnt);
set undetect_summary;
fraud_type = 'CNP';
if cp_cnt > 0 then fraud_type = 'CP';
run;

proc sql;
create table undetect_cases as 
select *
from &frd_table.1 where acct_nbr in (select acct_nbr from undetect_summary)
;
quit;

proc sql;
create table tab3 as 
select crd_clnt_id,frd_month,
sum(case when detect > 0  then 1 else 0 end) / count(*) as value 
format =percent10.2 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab3(drop=value);
set tab3;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "Acct_detection_rate";
run;

/*remove single txn frauds*/
proc sql;
create table tab4 as 
select crd_clnt_id,frd_month,
sum(case when detect > 0 then 1 else 0 end) / 
(count(*) - sum( case when undetect = 1 and Detection = 'N' then 1 else 0 end )) as value 
format =percent10.2 
from tab2x
/*where detect+undetect > 1*/
group by crd_clnt_id,frd_month;
quit;

data tab4(drop=value);
set tab4;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "excl single frd Acct_detection_rate";
run;
/*End remove single txn frauds*/


proc sql;
create table tab5 as 
select crd_clnt_id,frd_month,
sum(case when detect > 0 then 1 else 0 end) as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab5(drop=value);
set tab5;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "detect fraud accts";
run;


%macro det(n,tabnum);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
sum(case when detect = &n. then 1 else 0 end) / 
sum(case when detect > 0  then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum(drop=value);
set tab&tabnum;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "Fraud"||compress(put(&n.,$10.))||" txns";
run;
%mend;

%det(1,6);
%det(2,7);
%det(3,8);

proc sql;
create table tab9 as 
select crd_clnt_id,frd_month,
sum(case when  detect >= 4 then 1 else 0 end) / 
sum(case when  detect > 0  then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab9(drop=value);
set tab9;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "Fraud >=4 txns";
run;


/*undetected metrics*/


proc sql;
create table tab10 as 
select crd_clnt_id,frd_month,
sum(case when undetect > 0 and detect = 0 then 1 else 0 end) as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab10(drop=value);
set tab10;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "undetect fraud accts";
run;


%macro det(n,tabnum);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
sum(case when detect = 0 and undetect = &n. then 1 else 0 end) / 
sum(case when detect = 0 and undetect > 0  then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum(drop=value);
set tab&tabnum;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "undetected Fraud"||compress(put(&n.,$10.))||" txns";
run;
%mend;

%det(1,11);
%det(2,12);
%det(3,13);

proc sql;
create table tab14 as 
select crd_clnt_id,frd_month,
sum(case when detect = 0 and undetect >= 4 then 1 else 0 end) / 
sum(case when detect = 0 and undetect > 0  then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab14(drop=value);
set tab14;
format var_name $50.;
value1 = compress(put(value,percent10.2));
var_name = "undetected Fraud >=4 txns";
run;


%macro det(n,tabnum);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
sum(case when Detection='Y' and run_days = &n. then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum(drop=value);
set tab&tabnum;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "detected run day"||compress(put(&n.,$10.));
run;
%mend;

%det(0,15);
%det(1,16);
%det(2,17);


proc sql;
create table tab18 as 
select crd_clnt_id,frd_month,
sum(case when Detection='Y' and run_days >= 3 then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab18(drop=value);
set tab18;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "detected run day 3+";
run;

%macro det(n,tabnum);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
sum(case when Detection='N' and run_days = &n. then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum(drop=value);
set tab&tabnum;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "undetected run day"||compress(put(&n.,$10.));
run;
%mend;

%det(0,19);
%det(1,20);
%det(2,21);


proc sql;
create table tab22 as 
select crd_clnt_id,frd_month,
sum(case when Detection='N' and run_days >= 3 then 1 else 0 end) 
as value 
from tab2x
group by crd_clnt_id,frd_month;
quit;

data tab22(drop=value);
set tab22;
format var_name $50.;
value1 = compress(put(value,$10.));
var_name = "undetected run day 3+";
run;

proc sql;
create table tab23 as 
select crd_clnt_id,frd_month,
sum(case when AUTH_DECISION_XCD = "A" then usd else 0 end) as value
from &frd_table.1
group by crd_clnt_id,frd_month;
quit;


data tab23(drop=value);
set tab23;
format var_name $50.;
value1 = compress(put(input(value,18.2),$20.));
var_name = "Acct fraud amt";
run;

proc sql;
create table tab24 as 
select crd_clnt_id,frd_month,
sum(case when AUTH_DECISION_XCD = "A" and upcase(DECI_CD) = 'DECLINE' then usd else 0 end) as value
from &frd_table.1
group by crd_clnt_id,frd_month;
quit;

data tab24(drop=value);
set tab24;
format var_name $50.;
value1 = compress(put(input(value,18.2),$20.));
var_name = "Decline fraud amt";
run;

data &RULE_SEGMENT.1(drop=tenant portfolio rule_segment);
set &RULE_SEGMENT.;
run;
proc sort nodupkey data=&RULE_SEGMENT.1;by _all_;run;
proc sql;
create table cr_rule_hit as 
select * from 
 &rule_perf. as a
 left join 
 (select * from &RULE_SEGMENT.1 ) b 
 on a.rule_name_strg=b.rule_name
where upcase(rule_name_strg) not like "%_TEST" and rule_name_strg not like "%ModelUPgrade_INSG%"
and upcase(Category) ne 'TEST';
quit;
data cr_rule_hit;
set cr_rule_hit;
frd_month = input(put(date1,yymmn6.),6.);
run;
data blank_seg;
set cr_rule_hit;
where Strategy='';
run;


%macro mc(strtype,tabnum,varname);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
count(*) as value
from cr_rule_hit
where strategy = &strtype.
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum.(drop=value);
set tab&tabnum.;
format var_name $50.;
value1 = compress(put(input(value,20.),$20.));
var_name = &strtype.||&varname.;
run;
%mend;

%mc("RTD",25,"number of alerts");
%mc("Case Creation",26,"number of alerts");
%mc("SMS Only",27,"number of alerts");


%macro mc(strtype,tabnum,varname);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
count(*) as alerts,
sum(case when strategy = &strtype. and fraud=1 then 1 else 0 end ) as frd
from cr_rule_hit
where strategy = &strtype. 
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum.(drop=value alerts frd);
set tab&tabnum.;
format var_name $50.;

if frd = 0 then value = alerts;
if frd > 0 then value = alerts/frd;
value1 = compress(put(input(value,20.),$20.));
var_name = &strtype.||&varname.;
run;

%mend;

%mc("RTD",28,"fpr");
%mc("Case Creation",29,"fpr");
%mc("SMS Only",30,"fpr");


%macro mc1(strtype,category,tabnum,varname);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
count(*) as alerts,
sum(case when strategy = &strtype. and category=&category. and  fraud=1 then 1 else 0 end ) as frd
from cr_rule_hit
where strategy = &strtype. and category=&category. 
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum.(drop=value alerts frd);
set tab&tabnum.;
format var_name $50.;
value = alerts;
value1 = compress(put(input(value,20.),$20.));
var_name = &strtype.||&category.||&varname.;
run;

%mend;

%mc1("RTD","CNP",31,"alerts");
%mc1("RTD","CP",32,"alerts");
%mc1("RTD","CPP",33,"alerts");
%mc1("RTD","Other",34,"alerts");
%mc1("RTD","Score based",35,"alerts");
%mc1("RTD","blacklist",36,"alerts");
%mc1("RTD","compliance",37,"alerts");
%mc1("RTD","fallback",38,"alerts");
%mc1("RTD","UDP",38a,"alerts");
%mc1("RTD","TokenRules",38b,"alerts");
%mc1("Case Creation","CNP",39,"alerts");
%mc1("Case Creation","CP",40,"alerts");
%mc1("Case Creation","CPP",41,"alerts");
%mc1("Case Creation","Other",42,"alerts");
%mc1("Case Creation","Score based",43,"alerts");
%mc1("Case Creation","blacklist",44,"alerts");
%mc1("Case Creation","compliance",45,"alerts");
%mc1("Case Creation","fallback",46,"alerts");
%mc1("Case Creation","UDP",46a,"alerts");
%mc1("Case Creation","TokenRules",46b,"alerts");
%mc1("SMS Only","CNP",47,"alerts");
%mc1("SMS Only","CP",48,"alerts");
%mc1("SMS Only","CPP",49,"alerts");
%mc1("SMS Only","Other",50,"alerts");
%mc1("SMS Only","Score based",51,"alerts");
%mc1("SMS Only","blacklist",52,"alerts");
%mc1("SMS Only","compliance",53,"alerts");
%mc1("SMS Only","fallback",54,"alerts");
%mc1("SMS Only","UDP",54a,"alerts");
%mc1("SMS Only","TokenRules",54b,"alerts");

%macro mc2(strtype,category,tabnum,varname);
proc sql;
create table tab&tabnum. as 
select crd_clnt_id,frd_month,
count(*) as alerts,
sum(case when strategy = &strtype. and category=&category. and  fraud=1 then 1 else 0 end ) as frd
from cr_rule_hit
where strategy = &strtype. and category=&category. 
group by crd_clnt_id,frd_month;
quit;

data tab&tabnum.(drop=value alerts frd);
set tab&tabnum.;
format var_name $50.;
value = frd;
value1 = compress(put(input(value,20.),$20.));
var_name = &strtype.||&category.||&varname.;
run;

%mend;
%mc2("RTD","CNP",55,"frauds");
%mc2("RTD","CP",56,"frauds");
%mc2("RTD","CPP",57,"frauds");
%mc2("RTD","Other",58,"frauds");
%mc2("RTD","Score based",59,"frauds");
%mc2("RTD","blacklist",60,"frauds");
%mc2("RTD","compliance",61,"frauds");
%mc2("RTD","fallback",62,"frauds");
%mc2("RTD","Business",79,"frauds");
%mc2("RTD","UDP",79a,"frauds");
%mc2("RTD","TokenRules",79b,"frauds");
%mc2("Case Creation","CNP",63,"frauds");
%mc2("Case Creation","CP",64,"frauds");
%mc2("Case Creation","CPP",65,"frauds");
%mc2("Case Creation","Other",66,"frauds");
%mc2("Case Creation","Score based",67,"frauds");
%mc2("Case Creation","blacklist",68,"frauds");
%mc2("Case Creation","compliance",69,"frauds");
%mc2("Case Creation","Business",80,"frauds");
%mc2("Case Creation","UDP",80a,"frauds");
%mc2("Case Creation","TokenRules",80b,"frauds");
%mc2("Case Creation","fallback",70,"frauds");
%mc2("SMS Only","CNP",71,"frauds");
%mc2("SMS Only","CP",72,"frauds");
%mc2("SMS Only","CPP",73,"frauds");
%mc2("SMS Only","Other",74,"frauds");
%mc2("SMS Only","Score based",75,"frauds");
%mc2("SMS Only","blacklist",76,"frauds");
%mc2("SMS Only","compliance",77,"frauds");
%mc2("SMS Only","fallback",78,"frauds");
%mc2("SMS Only","Business",81,"frauds");
%mc2("SMS Only","UDP",81a,"frauds");
%mc2("SMS Only","TokenRules",81b,"frauds");

data all;
set 
tab1 tab2 tab3 tab4 tab5 tab6 tab7 tab8 tab9
tab10 tab11 tab12 tab13 tab14 tab15 tab16 tab17 tab18
tab19 tab20 tab21 tab22 tab23 tab24 tab25 tab26 tab27
tab28 tab29 tab30 tab31 tab32 tab33 tab34 tab35 tab36 tab37
tab38 tab39 tab40 tab41 tab42 tab43 tab44 tab45 tab46 tab47
tab48 tab49 tab50 tab51 tab52 tab53 tab54 tab55 tab56 tab57
tab58 tab59 tab60 tab61 tab62 tab63 tab64 tab65 tab66 tab67
tab68 tab69 tab70 tab71 tab72 tab73 tab74 tab75 tab76 tab77
tab78 tab79 tab80 tab81 
tab38a tab46a tab54a tab79a tab80a tab81a
tab38b tab46b tab54b tab79b tab80b tab81b
;
run;

data all1;
set all;
country=compress(tranwrd(tranwrd(scan(crd_clnt_id,2,"_"),"C400",""),"CCMS",""));
keyfld=compress(tranwrd(tranwrd(scan(crd_clnt_id,2,"_"),"C400",""),"CCMS",""))||put(frd_month,$6.)||var_name;
run;

proc sql;
create table all2 as 
select keyfld,Country,	CRD_CLNT_ID	,frd_month	,var_name	,value1
from all1
;
quit;

proc sql;
create table rule_summary as 
select crd_clnt_id,strategy,category,RULE_NAME_STRG,frd_month,
count(*) as num_alerts,
sum(case when fraud=1 then 1 else 0 end ) as frd
from CR_RULE_HIT
where 
upcase(rule_name_strg) not like '%_TEST' and rule_name_strg not like '%ModelUPgrade_INSG%'
group by crd_clnt_id,strategy,category,RULE_NAME_STRG,frd_month;
quit;
data rule_summary;
set rule_summary;
fpr = num_alerts;
if frd >= 1 then fpr = num_alerts / frd;
run;

data review_data;
set rule_summary;
where frd_month = &rmth. and 
( (Strategy = 'Case Creation' and fpr > 50 ) or 
(Strategy = 'RTD' and fpr > 10 ) or 
(Strategy = 'SMS Only' and fpr > 100 )
)
;
run;

proc sql;
create table t as 
select distinct(RULE_NAME_STRG) from review_data;
quit;


/*MID analysis*/

proc sql;
create table mid_base as 
select distinct(MER_ID) from &tran_tab. where acct_nbr in (select acct_nbr from tab2x where Detection ="N") and 
FRAUD = 1;
quit;

proc sql;
create table a.CR_MID_Impact_Summary as 
select distinct mer_id,  
				count(distinct fi_transaction_id) as Total_Txns, 
				count(distinct acct_nbr) as Total_cards_Txns, 
				sum(fraud) as No_of_Frauds,
				count(distinct case when fraud=1 then acct_nbr end) as No_of_cards_Frauds,
              case 
               when sum(fraud) ne . then calculated Total_Txns/calculated No_of_Frauds
              else calculated Total_Txns
              end as TFPR,
			  case 
               when sum(fraud) ne . then calculated Total_cards_Txns/calculated No_of_cards_Frauds
              else calculated Total_cards_Txns
              end as AFPR
from &tran_tab. where mer_id in (select mer_id from mid_base)
group by mer_id;
quit;


proc sql;
create table a.rules_to_review_CR as 
select distinct(RULE_NAME_STRG) from REVIEW_DATA;
quit;

proc sql;
create table rule_analysis_data_CR1 as 
select * from &rule_perf.
where rule_name_strg in (select rule_name_strg from a.rules_to_review_CR);
quit;

data rule_analysis_data_CR1;
set rule_analysis_data_CR1;
IF CRD_CLNT_ID IN ("SC_PMTHK_CR") THEN USD = TRN_AMT/7.8;
run;




proc import datafile="\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Saravana\Monthly Reviews\Falcon\&MNTH1.\Data from fraudbase_CR_GBL_new.xlsx"
out= previous_month_cr
dbms=xlsx replace;run;

data previous_month_cr;
set previous_month_cr;
if substr(var_name,1,3) in ( 'RTD','SMS','Cas') then delete;
if frd_month = &prev_mth2. then delete;
run;

data all3;
set all2;
if substr(var_name,1,3) not in ( 'RTD','SMS','Cas') and 
frd_month in (&prev_mth.,&prev_mth1.) then delete;
run;

data all4;
set previous_month_cr all3;
run;


proc sql;
CREATE TABLE BLACKLIST_ANALYSIS AS 
select DISTINCT(FI_TRANSACTION_ID) AS TXNID from &rule_hit_tab. where RULE_NAME_STRG in ('HR_Country_MID_Blacklist_HK');
quit;

PROC SQL;
CREATE TABLE BLACKLIST_ANALYSIS1 AS 
SELECT * FROM &tran_tab. WHERE FI_TRANSACTION_ID IN (
SELECT TXNID FROM BLACKLIST_ANALYSIS);
QUIT;

PROC SQL;
CREATE TABLE BLACKLIST_ANALYSIS2 AS 
SELECT DISTINCT(MER_ID) FROM BLACKLIST_ANALYSIS1;
QUIT;

PROC SQL;
CREATE TABLE BLACKLIST_ANALYSIS3 AS 
SELECT * FROM &tran_tab. WHERE MER_ID IN (SELECT MER_ID FROM BLACKLIST_ANALYSIS2);
QUIT;


PROC SQL;
CREATE TABLE DISPUTE_MER_TXN AS 
SELECT * FROM &TRAN_TAB. WHERE MER_ID IN (SELECT DISTINCT MER_ID FROM undetect_cases);
QUIT;

DATA DISPUTE_MER_TXN1;
SET DISPUTE_MER_TXN;
	IF CRD_CLNT_ID IN ("SC_PMTHK_CR") THEN USD = TRN_AMT/7.8;
RUN;


/*proc export data=DISPUTE_MER_TXN1*/
/* outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\DISPUTE_MER_TXN_CR_GBL_new.xlsx"*/
/*dbms=xlsx replace;run;*/

DATA DISPUTE_MER_TXN1; 
SET DISPUTE_MER_TXN1(OBS=578829); 
RUN; 
DATA DISPUTE_MER_TXN1_2; 
SET DISPUTE_MER_TXN1(FIRSTOBS=578830); 
RUN; 

proc export data=DISPUTE_MER_TXN1 
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\DISPUTE_MER_TXN_CR_GBL_new.xlsx" 
dbms=xlsx replace;SHEET="DISPUTE_MER_TXN1";run; 
proc export data=DISPUTE_MER_TXN1_2 
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\DISPUTE_MER_TXN_CR_GBL_new.xlsx" 
dbms=xlsx replace;SHEET="DISPUTE_MER_TXN1_2";run; 



proc export data=all4 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\Data from fraudbase_CR_GBL_new.xlsx"
dbms=xlsx replace;run;
proc export data=RULE_SUMMARY outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\Overall rule analysis_CR_GBL_new.xlsx"
dbms=xlsx replace;run;
proc export data=UNDETECT_SUMMARY outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\Undetected case review_CR_GBL_new.xlsx"
dbms=xlsx replace;run;
proc export data=review_data outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\RUle review data_CR_GBL_new.xlsx"
dbms=xlsx replace;run;
proc export data=undetect_cases
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months data\&curr_mth.\Dragon\undetect_cases_CR_GBL_new.xlsx"
dbms=xlsx replace;run;

proc export data=rule_analysis_data_CR1
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\rule_analysis_data_CR_GBL_new.xlsx"
dbms=xlsx replace;run;

proc export data=a.CR_MID_Impact_Summary
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth\Dragon\CR_MID_Impact_Summary_CR_GBL_new.xlsx"
dbms=xlsx replace;run;
proc export data=tab2x
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\tab2x_cr.xlsx"
dbms=xlsx replace;run;
proc export data=BLACKLIST_ANALYSIS3
 outfile="C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\&curr_mth.\Dragon\BLACKLIST_ANALYSIS3_CR.xlsx"
dbms=xlsx replace;run;