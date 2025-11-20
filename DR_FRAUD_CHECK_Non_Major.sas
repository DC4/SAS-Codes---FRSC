
LIBNAME DS1 "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Dec21_Non_Major";
/*LIBNAME DS2 "C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\Sep21_All_Cnty_Frd_Tagged\MAJOR_COUNTRIES_DATA";*/

 %LET TOD = %SYSFUNC(TODAY());
 %LET MNTH0 = %SYSFUNC(INTNX(MONTH,&TOD.,0),MONYY7.);

DATA DR_FRAUD;
SET DS1.last_3_months_data_db;
if (SUBSTR(ACCT_NBR,1,1)="5" and SUBSTR(USR_IND_4,9,2) IN ("kG"  "kA"  "kJ"  "kC"  "kE"  "kL")) then
Challenge_Type = 2;
else if (SUBSTR(ACCT_NBR,1,1)="4" and SUBSTR(USR_IND_4,5,1) IN ("D"  "F")) then
Challenge_Type = 2;
else if (SUBSTR(USR_IND_4,1,2) = "Y2") then
Challenge_Type = 1;
else
Challenge_Type = 0;
RUN;


DATA DR_FRAUD_3DS1;
SET DR_FRAUD;
WHERE Challenge_Type = 1 AND FRAUD=1;
RUN; 

DATA DR_FRAUD_3DS2;
SET DR_FRAUD;
WHERE Challenge_Type = 2 AND FRAUD=1;
RUN;

PROC EXPORT DATA=DR_FRAUD_3DS1
 OUTFILE="C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Dec21_Non_Major\Non_Major_3DS\DR_FRAUD_3DS1_Non_Major_&MNTH0..XLSX"
DBMS=XLSX REPLACE;RUN;

PROC EXPORT DATA=DR_FRAUD_3DS2
 OUTFILE="C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Dec21_Non_Major\Non_Major_3DS\DR_FRAUD_3DS2_Non_Major_&MNTH0..XLSX"
DBMS=XLSX REPLACE;RUN;