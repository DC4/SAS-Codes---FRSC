
******************************************************************************************
					COPYING DATASETS FROM SERVER TO LOCAL DRIVE
******************************************************************************************;


****COMMENTS: Place the Monthly Dataset in below folder***********************;

LIBNAME LOCAL "C:\Users\1510806\Desktop\Jhilam\Falcon 6.4 Monthly Data\Credit";

%LET MNTH = NOV2020;


***************** CREDIT COUNTRIES ********************;

%MACRO COP(CNTY);

LIBNAME SERVER "\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Falcon june 2017\SCMAC\&CNTY.";
LIBNAME SERVER1 "\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Falcon june 2017\Falcon 6.4 falcon download\&CNTY.";

***** TRANSACTION DATA *****;

PROC COPY IN=SERVER OUT=LOCAL;
SELECT FALT002_&CNTY._CR_&MNTH.;
RUN;

***** RULE HIT DATA *****;

PROC COPY IN=SERVER1 OUT=LOCAL;
SELECT FALT003_&CNTY._CR_&MNTH.;
RUN;


%MEND;

%COP(AE);
%COP(BD);
%COP(BH);
%COP(BN);
%COP(BW);
%COP(GH);
%COP(HK);
%COP(ID);
%COP(IN);
%COP(JE);
%COP(JO);
%COP(KE);
%COP(LK);
%COP(MY);
%COP(NG);
%COP(NP);
%COP(SG);
%COP(TW);
%COP(VN);
%COP(ZM);



%MACRO COP(CNTY);

LIBNAME SERVER1 "\\inhadfil101.in.standardchartered.com\wkgrps7\RAC_IN_MIS\Falcon june 2017\Falcon 6.4 falcon download\&CNTY.";

***** TRANSACTION DATA *****;

PROC COPY IN=SERVER1 OUT=LOCAL;
SELECT FALT002_&CNTY._CR_&MNTH.;
RUN;

***** RULE HIT DATA *****;

PROC COPY IN=SERVER1 OUT=LOCAL;
SELECT FALT003_&CNTY._CR_&MNTH.;
RUN;


%MEND;

%COP(DR);