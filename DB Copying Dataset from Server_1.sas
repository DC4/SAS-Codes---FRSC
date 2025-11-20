
***************** DEBIT COUNTRIES ********************;


****COMMENTS: Place the Monthly Dataset in below folder***********************;

LIBNAME LOCAL "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Falcon 6.4 Monthly Data\Debit";

%LET MNTH = SEP2021;


%MACRO COP1(CNTY);

LIBNAME SERVER "\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Falcon june 2017\Falcon 6.4 Debit download\&CNTY.";

***** TRANSACTION DATA *****;

PROC COPY IN=SERVER OUT=LOCAL;
SELECT FALT002_&CNTY._DB_&MNTH.;
RUN;

***** RULE HIT DATA *****;

PROC COPY IN=SERVER OUT=LOCAL;
SELECT FALT003_&CNTY._DB_&MNTH.;
RUN;


%MEND;

%COP1(AE);
%COP1(BD);
%COP1(BH);
%COP1(BN);
%COP1(BW);
%COP1(CI);
%COP1(CM);
%COP1(GH);
%COP1(GM);
%COP1(HK);
%COP1(ID);
%COP1(IN);
%COP1(JO);
%COP1(KE);
%COP1(LK);
%COP1(MY);
%COP1(NG);
%COP1(NP);
%COP1(QA);
%COP1(SG);
%COP1(SL);
%COP1(TW);
%COP1(TZ);
%COP1(UG);
%COP1(VN);
%COP1(ZM);
%COP1(ZW);