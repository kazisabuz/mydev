CREATE OR REPLACE PROCEDURE SP_START_BRANCH_CLEAR 
IS
BEGIN
SP_DATA_CLEAR_BRANCH('BOPAUTHQ','BOPAUTHQ_TRAN_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LOANIAMRRDTL','LOANIAMRRDTL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LOANIADTL','LOANIADTL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SBMMBCALC','SBMMBCALC_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LOANIADLY','RTMPLNIA_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SMSALERTQ','SMSALERTQ_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SBCAIABRK','SBCAIBRK_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SBMMBCALCBRK','SBMMBCALC_BRN_CODE');
SP_DATA_CLEAR_BRANCH('GLBALASONHIST','GLBALH_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LOANIA','LOANIA_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LOANIAMRR','LOANIAMRR_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DDPOPAY','DDPOPAY_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DDPOISSDTL','DDPOISSDTL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('IACLINK','IACLINK_BRN_CODE');
SP_DATA_CLEAR_BRANCH('STATMENTOFAFFAIRS','RPT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DEPIA','DEPIA_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CASHRP','CASHRP_BRN_CODE');
SP_DATA_CLEAR_BRANCH('ACNTTRANPROFAMT','ACNTTRANPAMT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANSTLMNT','TRANSTL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('INCOMEEXPENSE','RPT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('INWARD_CLEARING_ITEM','BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('SBCAIA','SBCAIA_BRN_CODE');
SP_DATA_CLEAR_BRANCH('ACNTCHARGEAMT','ACNTCHGAMT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DEPIANA','DEPIANA_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TDSPIDTL','TDSPIDT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TELDENOMDBAL','TDDB_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2014','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2015','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2016','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2017','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2018','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2019','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2020','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2021','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('AUDITLOG2022','ATLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('RDCALC','RDCALC_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CLIENTOTNDTL','CLOTNDTL_OLD_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DENOMDBAL','DENOMDBAL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SODEOD_PROCESS_INFO','SODEOD_PROCESS_BRN_CODE');
SP_DATA_CLEAR_BRANCH('EODSODBATCHNUMBER','EODSOD_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2014','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2015','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2016','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2017','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2018','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2019','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2020','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2021','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('GLSUM2022','GLSUM_BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('LNINTAPPLDTLS','LNINTAPPLD_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LNINTAPPL','LNINTAPPL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('LIMITLINE','LMTLINE_HOME_BRANCH');
SP_DATA_CLEAR_BRANCH('OPRLOG2014','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2015','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2016','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2017','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2018','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2019','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2020','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2021','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OPRLOG2022','OPRLOG_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2014','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2015','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2016','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2017','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2018','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2019','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2020','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2021','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TRANBAT2022','TRANBAT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('ECSACMAP','ECSACMAP_SM_BRN_CODE');
SP_DATA_CLEAR_BRANCH('NROSBTDS','NRO_BRN_CODE');
SP_DATA_CLEAR_BRANCH('OCLGINST','OCLGINST_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DDPOISSDTLANX','DDPOANX_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SIGTRANDTL','POST_TRAN_BRN');
SP_DATA_CLEAR_BRANCH('SMS_ACCOUNT','BRANCH_CODE');
SP_DATA_CLEAR_BRANCH('DDPOISS','DDPOISS_BRN_CODE');
SP_DATA_CLEAR_BRANCH('MMB_ACNTS','MMB_ACNTS_BRN_CODE');
SP_DATA_CLEAR_BRANCH('EODSODPROCBRN','PROC_BRN_CODE');
SP_DATA_CLEAR_BRANCH('TDSPI','TDSPI_BRN_CODE');
SP_DATA_CLEAR_BRANCH('DDPOPAYDB','DDPOPAYDB_ISSUED_BRN');
SP_DATA_CLEAR_BRANCH('TELDBAL','TELDBAL_BRN_CODE');
SP_DATA_CLEAR_BRANCH('SMSCHARGE','SMSCHARGE_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CBREQ','CBREQ_BRN_CODE');
SP_DATA_CLEAR_ACC('ACNTVDBBAL','ACNTVBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTBBAL','ACNTBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACBALASONHIST','ACBALH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACBALASONHIST_AVGBAL','ACBALH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACBALASONHIST_MAX','ACBALH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACBALASONHIST_MAX_TRAN','ACBALH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACBALASONHIST_MIN','ACBALH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTBAL','ACNTBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('BPUPLDATADTL','BPUPLDDTL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('SBCACALCBRK','SBCACBRK_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('RDINS','RDINS_RD_AC_NUM');
SP_DATA_CLEAR_ACC('ACNTOTNNEW','ACNTOTN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('CBISS','CBISS_CLIENT_ACNUM');
SP_DATA_CLEAR_ACC('ACNTOTNNEW','ACNTOTN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTOTN','ACNTOTN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('CLAMIMAGE','CLAMIMAGE_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('INVSPDOCIMG','SPDOCIMG_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ADVVDBBAL','ADVVDBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ADVBBAL','ADVBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTLINK','ACNTLINK_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('NOMREGDTL','NOMREGDTL_AC_NUM');
SP_DATA_CLEAR_ACC('LOANACNTS','LNACNT_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ASSETCLSHIST','ASSETCLSH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ASSETCLS','ASSETCLS_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNOD','LNOD_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACIRHIST','LNACIRH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACRSDTL','LNACRSDTL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACRS','LNACRS_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACRSHDTL','LNACRSHDTL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACRSHIST','LNACRSH_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('LNACRSMAXTLPMHIST','LNACRSMAXTLH_ACC_NO');
SP_DATA_CLEAR_ACC('ACNTCVDBBAL','ACNTCVBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTCBBAL','ACNTCBBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('DEPCALCBRK','DEPCBRK_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('DEPCALCAC','DEPCAC_INTERNAL_AC_NUM');
SP_DATA_CLEAR_ACC('PROVLED','PROVLED_ACNT_NUM');
SP_DATA_CLEAR_ACC('ACNTEXCISEAMT','ACNTEXCAMT_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('PROVCALC','PROVC_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTSTATUS','ACNTSTATUS_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('ACNTMAIL','ACNTMAIL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('DEPTDSIA','DEPTDSIA_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('MAINTCHAVGBAL','MAINTCHAVGBAL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('PBDCONTRACT','PBDCONT_DEP_AC_NUM');
SP_DATA_CLEAR_ACC('NOMREG','NOMREG_AC_NUM');
SP_DATA_CLEAR_ACC('NOMREGDTL','NOMREGDTL_AC_NUM');
SP_DATA_CLEAR_ACC('LNREPAY','LNREPAY_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('EODRAMINBALNM','EODRAMBNM_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('CHQUSG','CHQUSG_INTERNAL_AC_NUM');
SP_DATA_CLEAR_ACC('ACNTRNPRHIST','ACTPH_ACNT_NUM');
SP_DATA_CLEAR_ACC('ACNTS_STATUS','ACNTS_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('AMLACNTCL','AMLACNTCL_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('MV_LOAN_ACCOUNT_BAL_OD','TRAN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('MV_LOAN_ACCOUNT_BAL','TRAN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('MV_DAY_ACCOUNT_BAL','TRAN_INTERNAL_ACNUM');
SP_DATA_CLEAR_ACC('MV_MMB_WEEK_TRANSACTION_TEMP','TRAN_INTERNAL_ACNUM');

SP_DATA_CLEAR_BRANCH('CTRAN2014','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2015','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2016','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2017','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2018','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2019','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2020','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2021','CT_BRN_CODE');
SP_DATA_CLEAR_BRANCH('CTRAN2022','CT_BRN_CODE');
SP_TRAN_BRANCH_CLEAR('TRAN2014');
SP_TRAN_BRANCH_CLEAR('TRAN2015');
SP_TRAN_BRANCH_CLEAR('TRAN2016');
SP_TRAN_BRANCH_CLEAR('TRAN2017');
SP_TRAN_BRANCH_CLEAR('TRAN2018');
SP_TRAN_BRANCH_CLEAR('TRAN2019');
SP_TRAN_BRANCH_CLEAR('TRAN2020');
SP_TRAN_BRANCH_CLEAR('TRAN2021');
SP_TRAN_BRANCH_CLEAR('TRAN2022');


COMMIT;
END;
/
