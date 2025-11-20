

options firstobs = 2;

/*proc import Datafile= "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\31Dec2021_2.0\3DS2.0_ID_CR_01-15Dec21.TSV" */
/*OUT=VCAS DBMS=TAB REPLACE; delimiter='09'x; getnames = "yes"; RUN;*/

/*proc import Datafile= "Y:\VCAS\31Dec2021_2.0\3DS2.0_ID_CR_01-15Dec21.TSV" */
/*OUT=outdata DBMS=TAB REPLACE; delimiter='09'x; GETNAMES = YES; RUN;*/

proc import Datafile= "Y:\VCAS\31Dec2021_2.0\*.TSV" 
OUT=outdata DBMS=TAB REPLACE; delimiter='09'x; GETNAMES = YES; RUN;