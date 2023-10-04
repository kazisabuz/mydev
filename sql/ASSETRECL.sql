

delete from assetrecldtlhist where ASSETRECLDH_PRD_CODE in (select LNPRD_PROD_CODE from lnprodpm p ,assetrecl where LNPRD_PROD_CODE =ASSETRECL_PRD_CODE and LNPRD_SHORT_TERM_LOAN <> 1) ;
delete from assetrecldtl where ASSETRECLD_PRD_CODE in (select LNPRD_PROD_CODE from lnprodpm p ,assetrecl where LNPRD_PROD_CODE =ASSETRECL_PRD_CODE and LNPRD_SHORT_TERM_LOAN <> 1) ;
delete from assetrecl where ASSETRECL_PRD_CODE in (select LNPRD_PROD_CODE from lnprodpm p ,assetrecl where LNPRD_PROD_CODE =ASSETRECL_PRD_CODE and LNPRD_SHORT_TERM_LOAN <> 1) ;
