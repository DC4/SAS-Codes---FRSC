
proc delete data = _all_; run;

%MACRO RULEDETAILS(CNTY);

FILENAME RAW "C:\Users\1586087\Documents\Falcon\Falcon Rules\Text_File\&CNTY.16Jul21 Tenant Rule Report.TXT"; 

DATA FST ;

INFILE RAW LRECL=136 TRUNCOVER IGNOREDOSEOF LRECL = 800 ;
input tmp $800.;
format product $200. rule_name $200. mode $100. content $20000. Description $200.;
retain product rule_name rule_name1 mode  content Description rule_set QAV rule_type ALERT_NO_SMS;
if  tmp = "" then delete;
TMP1 = LAG(TMP);
rownum = _n_;


** QAV **;

if index(tmp,"CreateQueueAttributeString")>0 then QAV=scan(tranwrd(compress(tmp,')";'),"return",""),2,",");

** ALERT_NO_SMS **;

if index(tmp,"CreateQueueAttributeString")>0 and index(upcase(tmp),"ALERT_NO_SMS")>0 then  ALERT_NO_SMS = "Y"; 

** Decision **;

if index(tmp,"DECLINE")>0 then rule_type='RTD';
IF index(tmp,"TriggerCase(SERVICE)")>0 AND index(tmp1,"DECLINE")>0 then rule_type='RTD';
IF index(tmp,"ForceCase(SERVICE)")>0 AND index(tmp1,"DECLINE")=0 then rule_type='CC';
else if index(tmp,"TriggerCase(SERVICE)")>0 then rule_type='CC';


** Rule Name **;

if index(tmp,"Rule Name:")>0 then do; rule_name=substr(tmp,12,200); content="";
 end;
if index(tmp1,"Rule Name:")>0 then rule_name1=substr(tmp1,12,200);

** Description: **;

if index(tmp,"Description:")>0 then Description=substr(tmp,13,200);

** Mode **;

if rule_name1 = rule_name and index(tmp1,"Mode:")>0 then mode=compress(substr(tmp1,6,50));


** Rule Set **;

if index(tmp,"Rule Set:")>0 then do; rule_set=substr(tmp,11,50); rule_name = ""; mode = ""; QAV = "";rule_type = ""; 
ALERT_NO_SMS = "";end;

** Content **;
if index(tmp,"Content:")>0 then do;
/*do;content=substr(tmp,9,200);*/
content=substr(tmp,9,200); end;
else IF index(tmp,"Rule Name:")=0 and index(tmp,"Rule Set: Decision Ruleset")=0 AND
index(tmp,"Rule Set: Udv Calculation Ruleset")=0 THEN 
/*content=strip(content)||'0a'x||strip(tmp) ;*/
content=strip(content)||BYTE(10)||strip(tmp) ;
** Product **;

if index(tmp,"Credit 25 Authorization-Posting")>0 or index(tmp,"Debit 25 Authorization-Posting")>0 
or index(tmp,"Account Information Summary 20")>0 or index(tmp,"Business Information Summary (BIS) 21")>0
or index(tmp,"PAN Information Summary 12")>0 or index(tmp,"Retail Banking Transactions 21")>0
or index(tmp,"Nonmonetary 20")>0 or index(tmp,"Customer Information Summary (CIS) 20")>0
or index(tmp,"Fraud Dispositions 15")>0 or index(tmp,"External Message 10")>0
then do; product=strip(tmp);  rule_name = ""; mode = ""; content="";
Description="";
end;

rownum = _n_;
run;

proc sort data=FST; by product rule_name rownum; run;

data &CNTY.(DROP=rownum rule_name1 QAV rule_type ALERT_NO_SMS);
set FST(DROP=tmp TMP1);
by product rule_name rownum;
IF rule_name="" THEN DELETE;
if last.rule_name;
run;

/*DATA &CNTY.1;*/
/*SET &CNTY.;*/
/*IF INDEX(UPCASE(content),"SRVC_UDV")=0 THEN OUTPUT;*/
/*DROP QAV rule_type ALERT_NO_SMS;*/
/*RUN;*/

proc export data=&CNTY. outfile="C:\Users\1586087\Desktop\Rule_Details_16JUL.xlsx"
dbms=xlsx replace;SHEET="&CNTY.";run;


/*proc export data=&CNTY. outfile="C:\Users\1586087\Desktop\&CNTY._Rule_Details1.xlsx"*/
/*dbms=xlsx replace;run;*/

%MEND;

%RULEDETAILS(GBL);
%RULEDETAILS(BD);
%RULEDETAILS(HK);
%RULEDETAILS(ID_DEBIT);
%RULEDETAILS(TW);
%RULEDETAILS(DR);