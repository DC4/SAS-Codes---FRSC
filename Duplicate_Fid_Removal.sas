LIBNAME DC "C:\Users\1510806\OneDrive - Standard Chartered Bank\Desktop\Jhilam\Consolidated Last 3 Months Data\Nov21";

DATA CHECK_CR_DR;
SET 
DC.last_3_months_data_cr (Keep = FI_TRANSACTION_ID ACCT_NBR FRAUD)
DC.last_3_months_data_db (Keep = FI_TRANSACTION_ID ACCT_NBR FRAUD);
WHERE FRAUD = 1;
RUN;
