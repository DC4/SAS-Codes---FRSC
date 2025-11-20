
proc delete data = _all_; run;

%MACRO RULEDETAILS(CNTY);

FILENAME RAW "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Falcon Rules\Text Files\&CNTY. Tenant Rule Report.TXT"; 

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
mode = ""; QAV = "";rule_type = ""; ALERT_NO_SMS = "";
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

data &CNTY.(DROP=rownum rule_name1   );
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

DATA &CNTY._1;
SET &CNTY.;
if index (content,'SC_CCMSSG_CR') then SG = 'Yes';
if index (content,'SC_CCMSBN_CR') then BN = 'Yes';
if index (content,'SC_CCMSMY_CR') then MY = 'Yes';
if index (content,'SC_CCMSPH_CR') then PH = 'Yes';
if index (content,'SC_CCMSTH_CR') then TH = 'Yes';
if index (content,'SC_CCMSID_CR') then ID = 'Yes';
if index (content,'SC_CCMSIN_CR') then IN = 'Yes';
if index (content,'SC_CCMSTW_CR') then TW = 'Yes';
if index (content,'SC_C400AE_CR') then AE = 'Yes';
if index (content,'SC_C400BH_CR') then BH = 'Yes';
if index (content,'SC_C400BW_CR') then BW = 'Yes';
if index (content,'SC_C400GH_CR') then GH = 'Yes';
if index (content,'SC_C400JO_CR') then JO = 'Yes';
if index (content,'SC_C400JE_CR') then JE = 'Yes';
if index (content,'SC_C400KE_CR') then KE = 'Yes';
if index (content,'SC_C400LK_CR') then LK = 'Yes';
if index (content,'SC_C400NG_CR') then NG = 'Yes';
if index (content,'SC_C400NP_CR') then NP = 'Yes';
if index (content,'SC_C400VN_CR') then VN = 'Yes';
if index (content,'SC_C400ZM_CR') then ZM = 'Yes';
if index (content,'SC_CCMSHK_CR') then HK = 'Yes';
if index (content,'SC_PMTHK_CR') then DR = 'Yes';
if index (content,'SC_C400BD_CR') then BD = 'Yes';
if index (content,'SC_EURONETAE_DB') then AE = 'Yes';
if index (content,'SC_EURONETMY_DB') then MY = 'Yes';
if index (content,'SC_EURONETID_DB') then ID = 'Yes';
if index (content,'SC_EURONETIN_DB') then IN = 'Yes';
if index (content,'SC_TANDEMTW_DB') then TW = 'Yes';
if index (content,'SC_EURONETBH_DB') then BH = 'Yes';
if index (content,'SC_SPARROWBW_DB') then BW = 'Yes';
if index (content,'SC_SPARROWGH_DB') then GH = 'Yes';
if index (content,'SC_SPARROWJO_DB') then JO = 'Yes';
if index (content,'SC_SPARROWKE_DB') then KE = 'Yes';
if index (content,'SC_SPARROWLK_DB') then LK = 'Yes';
if index (content,'SC_SPARROWNG_DB') then NG = 'Yes';
if index (content,'SC_SPARROWNP_DB') then NP = 'Yes';
if index (content,'SC_EURONETVN_DB') then VN = 'Yes';
if index (content,'SC_SPARROWZM_DB') then ZM = 'Yes';
if index (content,'SC_EURONETBN_DB') then BN = 'Yes';
if index (content,'SC_EURONETSG_DB') then SG = 'Yes';
if index (content,'SC_SPARROWBW_DB') then BW = 'Yes';
if index (content,'SC_SPARROWGM_DB') then GM = 'Yes';
if index (content,'SC_EURONETIN_DB') then IN = 'Yes';
if index (content,'SC_EURONETQA_DB') then QA = 'Yes';
if index (content,'SC_SPARROWTZ_DB') then TZ = 'Yes';
if index (content,'SC_SPARROWUG_DB') then UG = 'Yes';
if index (content,'SC_SPARROWZW_DB') then ZW = 'Yes';
if index (content,'SC_HOGANHK_DB') then HK = 'Yes';
if index (content,'SC_SPARROWBD_DB') then BD = 'Yes';
if index (content,'SC_SPARROWCI_DB') then CI = 'Yes';
if index (content,'SC_SPARROWCM_DB') then CM = 'Yes';
if index (content,'SC_SPARROWSL_DB') then SL = 'Yes';

/*WHERE PRXMATCH("M/BLACKLISTED MERCHANTS|BLACKLIST_MIDS_COUNTRYWISE_CREDIT|BLACKLIST_MIDS_BINATTACK_CREDIT|*/
/*BLACKLIST_MIDS_BINATTACK_DEBIT|BLACKLIST_MIDS_COUNTRYWISE_DEBITBLACKLISTED_MERCHANTS_DEBIT|*/
/*BD_BLACKLISTED_MERCHANTS|BLACKLISTED_MIDS_ID_DEBIT/OI",CONTENT);*/
RUN;

proc export data=&CNTY._1 outfile="C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Rule_Details_21OCT.xlsx"
dbms=xlsx replace;SHEET="&CNTY.";run;


/*proc export data=&CNTY. outfile="C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\&CNTY._Rule_Details1.xlsx"*/
/*dbms=xlsx replace;run;*/

%MEND;

%RULEDETAILS(GBL);
%RULEDETAILS(BD);
%RULEDETAILS(HK);
%RULEDETAILS(ID_DEBIT);
%RULEDETAILS(TW);
%RULEDETAILS(DR);
/*%RULEDETAILS(RAC_IN);*/
/*%RULEDETAILS(RAC_SG);*/

