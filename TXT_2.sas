DATA NN;
INFILE "Z:\Saravana\Sparrow\Card_File_list_426374.txt" FIRSTOBS=7 TRUNCOVER;
INPUT CARDNO $1-17 Seq $22-23 Account_1 $24-44 Account_2 $46-60 Account_3 $68-82 Account_4 $90-104 
Customer_Name $111-136 Expiry $139-143 Status $148-151;
filename = "Card_File_list_426374";
RUN;
