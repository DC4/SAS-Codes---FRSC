
OPTIONS COMPRESS=YES;

LIBNAME NM "C:\Users\1510806\Desktop\JACK_Data";

LIBNAME MJ "C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\Aug21";

LIBNAME OLD "C:\Users\1510806\Desktop\Jhilam\Consolidated Last 3 Months Data\Aug21_Original_Backup_Dont_Delete";


DATA rule_hit_CR;
SET NM.Rl_hit_3_mth_cr_Non_Mjr
MJ.Rl_hit_3_mth_cr_mjr_no_hk
OLD.rule_hit_last_3_months_cr;
RUN;

DATA rule_hit_DB;
SET NM.Rl_hit_3_mth_db_Non_Mjr
MJ.Rl_hit_3_mth_db_HK
MJ.Rl_hit_3_mth_db_mjr_no_hk
OLD.rule_hit_last_3_months_db;
RUN;


DATA last_3_months_CR;
SET NM.lst_3_mth_data_cr_NoMjr_No_HK
MJ.lst_3_mth_data_cr_mjr_no_hk
OLD.last_3_months_data_cr
MJ.hk_last_1_month_data_cr;
RUN;

DATA last_3_months_DB;
SET NM.lst_3_mth_data_db_NoMjr_No_HK
MJ.lst_3_mnth_data_db_mjr_no_hk
OLD.last_3_months_data_db
MJ.lst_3_mth_data_db_HK;
RUN;
