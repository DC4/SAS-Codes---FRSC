DATA NN;
INFILE "Z:\Saravana\Sparrow\Card_File_List_403745.txt" FIRSTOBS=7 TRUNCOVER;
INPUT CARDNO $1-17 Seq $22-23 Account_1 $24-44 Account_2 $46-60 Account_3 $68-82 Account_4 $90-104 
Customer_Name $111-136 Expiry $139-143 Status $148-151;
filename = "Card_File_List_403745";
IF CARDNO = "" then delete;
IF SUBSTR(CARDNO,1,4) = "Card" OR SUBSTR(CARDNO,1,5) = "Stan" then delete;
IF SUBSTR(CARDNO,7,1) NE "/" then CARDNO = TRIM(substr(filename,length(filename)-5,6)) || STRIP(CARDNO) ;
CARDNO = COMPRESS(CARDNO,"/");
RUN;


/*DATA NN1;*/
/*SET NN;*/
/*CARDNO = COMPRESS(CARDNO,"/");*/
/*RUN;*/
/**/

/*4567890800001030*/