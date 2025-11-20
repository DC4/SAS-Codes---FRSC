libname a "\\10.132.5.78\wkgrps7\RAC_IN_MIS\PVB_MIS\pvb_fileverification\SAS_Data";

%let mm=0512;

proc delete data=NN_ALL; run;

%macro imp_brp003(file);

DATA NN;
INFILE "Z:\Saravana\Sparrow\&file..txt" FIRSTOBS=7 TRUNCOVER;
INPUT CARDNO1 $1-17 Seq $22-23 Account_1 $24-44 Account_2 $46-60 Account_3 $68-82 Account_4 $90-104 
Customer_Name $111-136 Expiry $139-143 Status $148-151;
filename = "&file.";
IF cardno1 = "" then delete;
IF SUBSTR(cardno1,1,4) = "Card" OR SUBSTR(cardno1,1,5) = "Stan" then delete;
if index(cardno1,"/") then cardno = compress(cardno1,"/");
if index(cardno1,"/") EQ 0 then CARDNO = TRIM(substr(filename,length(filename)-5,6)) || SUBSTR(CARDNO1,1,10);
RUN;

DATA NN1 (KEEP = cardno STATUS1 filename);
SET NN;
TMP = catx(TRIM(Account_1) , TRIM(Account_2) , TRIM(Account_3) , TRIM(Account_4) , TRIM(Customer_Name) , TRIM(Expiry) , TRIM(Status));
STATUS1 = TRIM(SUBSTR(TMP,length(TMP)-3,4));
if index(STATUS1,"-") then STATUS1 = compress(STATUS1,"-");
RUN;

PROC APPEND DATA=NN1 BASE=NN_ALL FORCE;RUN;

%MEND;

%imp_brp003(Card_File_listing_459278);
%imp_brp003(Card_File_listing_459279);
%imp_brp003(Card_File_listing_459280);
%imp_brp003(card_file_listing_480870);
%imp_brp003(card_file_listing_480953);
%imp_brp003(Card_file_listing_489161);
%imp_brp003(Card_file_listing_489162);
%imp_brp003(card_file_listing_499827);
%imp_brp003(card_file_listing_499830);
%imp_brp003(Card_File_List_403745);
%imp_brp003(card_file_list_406896);
%imp_brp003(Card_File_List_415675);
%imp_brp003(card_file_list_422127);
%imp_brp003(Card_File_list_426373);
%imp_brp003(Card_File_list_426374);
%imp_brp003(Card_File_list_426608);
%imp_brp003(card_file_list_427889);
%imp_brp003(card_file_list_430399);
%imp_brp003(card_file_list_440292);
%imp_brp003(Card_File_list_441128);
%imp_brp003(card_file_list_445598);
%imp_brp003(card_file_list_446094);
%imp_brp003(card_file_list_458587);
%imp_brp003(card_file_list_458588);
%imp_brp003(card_file_list_459243);
%imp_brp003(card_file_list_459244);
%imp_brp003(card_file_list_459245);
%imp_brp003(Card_File_List_462821);
%imp_brp003(card_file_list_464898);
%imp_brp003(card_file_list_464899);
%imp_brp003(card_file_list_471415);
%imp_brp003(card_file_list_471459);
%imp_brp003(Card_File_List_478393);
%imp_brp003(Card_File_List_478394);
%imp_brp003(card_file_list_RPT_457879);
%imp_brp003(card_file_list_RPT_478680);
%imp_brp003(card_file_list_RPT_478682);




/**/
/*DATA NN;*/
/*INFILE "Z:\Saravana\Sparrow\card_file_list_422127.txt" FIRSTOBS=7 TRUNCOVER;*/
/*INPUT CARDNO1 $1-17 Seq $22-23 Account_1 $24-44 Account_2 $46-60 Account_3 $68-82 Account_4 $90-104 */
/*Customer_Name $111-136 Expiry $139-143 Status $148-151;*/
/*filename = "Card_File_List_403745";*/
/*IF cardno1 = "" then delete;*/
/*IF SUBSTR(cardno1,1,4) = "Card" OR SUBSTR(cardno1,1,5) = "Stan" then delete;*/
/*if index(cardno1,"/") then cardno = compress(cardno1,"/");*/
/*if index(cardno1,"/") EQ 0 then CARDNO = TRIM(substr(filename,length(filename)-5,6)) || SUBSTR(CARDNO1,1,10);*/
/*RUN;*/
/**/
/**/
/*DATA NN1 (KEEP = cardno STATUS1 filename);*/
/*SET NN;*/
/*TMP = catx(TRIM(Account_1) , TRIM(Account_2) , TRIM(Account_3) , TRIM(Account_4) , TRIM(Customer_Name) , TRIM(Expiry) , TRIM(Status));*/
/*STATUS1 = TRIM(SUBSTR(TMP,length(TMP)-3,4));*/
/*if index(STATUS1,"-") then STATUS1 = compress(STATUS1,"-");*/
/*RUN;*/




/**/
/*IF CARDNO = "" then delete;*/
/*IF SUBSTR(CARDNO,1,4) = "Card" OR SUBSTR(CARDNO,1,5) = "Stan" then delete;*/
/*IF SUBSTR(CARDNO,7,1) NE "/" then CARDNO = TRIM(substr(filename,length(filename)-5,6)) || STRIP(CARDNO) ;*/
/*CARDNO = COMPRESS(CARDNO,"/");*/
/*RUN;*/