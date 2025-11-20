libname a "\\10.132.5.78\wkgrps7\RAC_IN_MIS\PVB_MIS\pvb_fileverification\SAS_Data";

%let mm=0512;
%macro imp_brp003(file);
proc import datafile="Z:\Saravana\Sparrow\test\Card_File_List_403745.txt" out=fl;
run; 

data fl;
set fl;
filename = "&file.";
bin = TRIM(substr(filename,length(filename)-5,6));
RUN;
%MEND;

run;
%mend; 

%imp_brp003(file=Card_File_List_403745);


proc import datafile="Z:\Saravana\Sparrow\test\Card_File_List_403745.txt" out=fl
replace;
run;