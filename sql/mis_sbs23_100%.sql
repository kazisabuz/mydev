select  round((count(*)/20018231)*100)     DATE_OF_BIRTH
from SBS2_ALL_BRANCH_NEW,iaclink,indclients
where trim(DATE_OF_BIRTH)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/1843593)*100)     DATE_OF_BIRTH
from SBS3_ALL_BRANCH_NEW,iaclink,indclients
where trim(DATE_OF_BIRTH)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/20018231)*100)     GENDER_CODE
from SBS2_ALL_BRANCH_NEW,iaclink,indclients
where trim(GENDER_CODE)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/1843593)*100)     GENDER_CODE
from SBS3_ALL_BRANCH_NEW,iaclink,indclients
where trim(GENDER_CODE)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/20018231)*100)     UNIQUE_ID
from SBS2_ALL_BRANCH_NEW,iaclink,indclients
where trim(UNIQUE_ID)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/1843593)*100)     UNIQUE_ID
from SBS3_ALL_BRANCH_NEW,iaclink,indclients
where trim(UNIQUE_ID)  is not null
and IACLINK_ACTUAL_ACNUM=ACCOUT_ID
and INDCLIENT_CODE=IACLINK_CIF_NUMBER
and IACLINK_ENTITY_NUM=1;

select  round((count(*)/20018231)*100)     E_TIN
from SBS2_ALL_BRANCH_NEW
where trim(E_TIN) is not null;

select  round((count(*)/1843593)*100)     E_TIN
from SBS3_ALL_BRANCH_NEW
where trim(E_TIN) is not null;


select  round((count(*)/20018231)*100)     INTEREST_RATE
from SBS2_ALL_BRANCH_NEW
where nvl(INTEREST_RATE,0) <>0;

select  round((count(*)/1843593)*100)     INTEREST_RATE
from SBS3_ALL_BRANCH_NEW
where nvl(INTEREST_RATE,0) <>0;

select  round((count(*)/20018231)*100)     DEPOSIT_TYPE
from SBS2_ALL_BRANCH_NEW
where nvl(DEPOSIT_TYPE,0) <>0;

select  round((count(*)/20018231)*100)     DEPOSIT_STATUS
from SBS2_ALL_BRANCH_NEW
where nvl(DEPOSIT_STATUS,0) <>0;


select  round((count(*)/20018231)*100)     ACCRUED_INTEREST
from SBS2_ALL_BRANCH_NEW
where nvl(ACCRUED_INTEREST,0) <>0;

select  round((count(*)/20018231)*100)     AMOUNT
from SBS2_ALL_BRANCH_NEW
where nvl(AMOUNT,0) <>0;

select  round((count(*)/20018231)*100) E_SECTOR_ID
from SBS2_ALL_BRANCH_NEW
where trim(ECO_SECTOR_ID) is not  null ;

select  round((count(*)/1843593)*100) E_SECTOR_ID
from SBS3_ALL_BRANCH_NEW
where trim(ECO_SECTOR_ID) is not  null ;


select  round((count(*)/1843593)*100) E_SECTOR_ID
from SBS3_ALL_BRANCH_NEW
where trim(ECO_SECTOR_ID) is not  null ;

select  round((count(*)/1843593)*100) INDUSTRY_SCALE_ID
from SBS3_ALL_BRANCH_NEW
where trim(INDUSTRY_SCALE_ID) is not  null ;

select  round((count(*)/20018231)*100) NATURE_OF_LOAN
from SBS2_ALL_BRANCH_NEW
where trim(NATURE_OF_LOAN) is not  null ;


select  round((count(*)/1843593)*100) ECO_PURPOSE_ID
from SBS3_ALL_BRANCH_NEW
where trim(ECO_PURPOSE_ID) is not  null ;

select  round((count(*)/1843593)*100) COLLATERAL_ID
from SBS3_ALL_BRANCH_NEW
where trim(COLLATERAL_ID) is not  null ;

select  round((count(*)/1843593)*100) COLLATERAL_VALUE   
from SBS3_ALL_BRANCH_NEW
where nvl(COLLATERAL_VALUE,0)<>0;

select  round((count(*)/1843593)*100)     LOAN_CLASS_ID
from SBS3_ALL_BRANCH_NEW
where trim(LOAN_CLASS_ID) is not  null;


select  round((count(*)/1843593)*100)     PRODUCT_TYPE_ID
from SBS3_ALL_BRANCH_NEW
where trim(PRODUCT_TYPE_ID) is not  null;

select  round((count(*)/1843593)*100)     SANCTION_LIMIT
from SBS3_ALL_BRANCH_NEW
where nvl(SANCTION_LIMIT,0) is not  null;

select  round((count(*)/1843593)*100)     DISBURSEMENT_DATE
from SBS3_ALL_BRANCH_NEW
where trim(DISBURSEMENT_DATE) is not  null;

select  round((count(*)/1843593)*100)     EXPIRY_DATE
from SBS3_ALL_BRANCH_NEW
where trim(EXPIRY_DATE) is not  null;


select  round((count(*)/1843593)*100)     CHARGED_INTEREST
from SBS3_ALL_BRANCH_NEW
where nvl(CHARGED_INTEREST,0)<>0;

select  round((count(*)/1843593)*100)     ACCRUED_INTEREST
from SBS3_ALL_BRANCH_NEW
where nvl(ACCRUED_INTEREST,0) <>0;

select  round((count(*)/1843593)*100)     OTHERS_BAL
from SBS3_ALL_BRANCH_NEW
where nvl(OTHERS_BAL,0)<>0;


select  round((count(*)/1843593)*100)     RECOVERY_AMOUNT
from SBS3_ALL_BRANCH_NEW
where nvl(RECOVERY_AMOUNT,0) <>0;

select  round((count(*)/1843593)*100)     WAIVER_AMOUNT
from SBS3_ALL_BRANCH_NEW
where nvl(WAIVER_AMOUNT,0) <>0;

select  round((count(*)/1843593)*100)     WRITE_OFF_AMOUNT
from SBS3_ALL_BRANCH_NEW
where nvl(WRITE_OFF_AMOUNT,0) <>0;


select  round((count(*)/1843593)*100)     OUTSTANDING_AMOUNT
from SBS3_ALL_BRANCH_NEW
where nvl(OUTSTANDING_AMOUNT,0) <>0;


select  round((count(*)/1843593)*100)     OVERDUE_AMOUNT
from SBS3_ALL_BRANCH_NEW
where nvl(OVERDUE_AMOUNT,0) <>0;

select  count(*) 
from SBS2_ALL_BRANCH_NEW;
 
select  sum(tran_amount) ACCR_INT_AMT_covid  ---2535099896.56
from tran2021
where TRAN_ENTITY_NUM = 1
AND TRAN_INTERNAL_ACNUM <> 0
AND TRAN_NARR_DTL1 = 'Covid rectification'
 AND TRAN_DATE_OF_TRAN = '30-jun-2021'
AND TRAN_DB_CR_FLG = 'D'
AND TRAN_AUTH_BY is not null;



select sum(LNINTAPPL_ACCR_INT_AMT)  ACCR_INT_AMT ---6950644805.72
from lnintappl
where LNINTAPPL_APPL_DATE>='01-apr-2021'
and LNINTAPPL_ENTITY_NUM=1;