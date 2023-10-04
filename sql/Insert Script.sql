DELETE FROM DATACTRCONF WHERE DATACTRCONF_ID = 'LNREPAYUPD';
COMMIT;




insert into DATACTRCONF (DATACTRCONF_ID, DATACTRCONF_DESC, DATACTRCONF_COND, DATACTRCONF_C_DTYP, DATACTRCONF_RLVDATA, DATACTRCONF_RLVQRY, DATACTRCONF_UPDDATA, DATACTRCONF_UPDQRY, DATACTRCONF_DTTYPE, DATACTRCONF_MANDOPT, DATACTRCONF_BRN_QRY, DATACTRCONF_BRNQ_DTP, DATACTRCONF_ACTIVE)
values ('LNREPAYUPD', 'Repayment Schedule Update', 'Account Number', 'S', 'First Installment Date |Number of Instamment|Repay Frequency|Installment Amount|Expiry Date', 'SELECT
       TO_CHAR(LNACRSDTL_REPAY_FROM_DATE,''DD/MM/YYYY'') || ''|'' ||
       LNACRSDTL_NUM_OF_INSTALLMENT || ''|'' ||
       LNACRSDTL_REPAY_FREQ || ''|'' ||
       LNACRSDTL_REPAY_AMT || ''|'' || 
       TO_CHAR(L1.LMTLINE_LIMIT_EXPIRY_DATE,''DD/MM/YYYY'')
  FROM LNACRSDTL L, IACLINK I,ACASLLDTL A,LIMITLINE L1
 WHERE L.LNACRSDTL_ENTITY_NUM = 1
   AND A.ACASLLDTL_ENTITY_NUM = 1
   AND I.IACLINK_ENTITY_NUM = 1
   AND L1.LMTLINE_ENTITY_NUM = 1
   AND L1.LMTLINE_CLIENT_CODE = A.ACASLLDTL_CLIENT_NUM
   AND L1.LMTLINE_NUM = A.ACASLLDTL_LIMIT_LINE_NUM
   AND L.LNACRSDTL_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND A.ACASLLDTL_INTERNAL_ACNUM = L.LNACRSDTL_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'First Installment Date |Number of Instamment|Repay Frequency|Installment Amount', 'SELECT
       TO_CHAR(LNACRSDTL_REPAY_FROM_DATE,''DD/MM/YYYY'') || ''|'' ||
       LNACRSDTL_NUM_OF_INSTALLMENT || ''|'' ||
       L.LNACRSDTL_REPAY_FREQ || ''|'' ||
       LNACRSDTL_REPAY_AMT
  FROM LNACRSDTL L, IACLINK I
 WHERE L.LNACRSDTL_ENTITY_NUM = 1
   AND I.IACLINK_ENTITY_NUM = 1
   AND L.LNACRSDTL_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'D|N|S|N', '1|1|1|1', 'SELECT ACNTS_BRN_CODE
  FROM ACNTS A, IACLINK I
 WHERE I.IACLINK_ENTITY_NUM = 1
   AND A.ACNTS_ENTITY_NUM = 1
   AND A.ACNTS_BRN_CODE = I.IACLINK_BRN_CODE
   AND A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'S', '1');
   
   
insert into DATACTRCONF (DATACTRCONF_ID, DATACTRCONF_DESC, DATACTRCONF_COND, DATACTRCONF_C_DTYP, DATACTRCONF_RLVDATA, DATACTRCONF_RLVQRY, DATACTRCONF_UPDDATA, DATACTRCONF_UPDQRY, DATACTRCONF_DTTYPE, DATACTRCONF_MANDOPT, DATACTRCONF_BRN_QRY, DATACTRCONF_BRNQ_DTP, DATACTRCONF_ACTIVE)
values ('LNLMTEXPDT', 'Expiry Date Correction', 'Account Number', 'S', 'Limit Line Number |Sanction Date|Expiry Date|Sanction Amount', 'SELECT A.ACASLLDTL_LIMIT_LINE_NUM || ''|'' ||
       TO_CHAR(L1.LMTLINE_DATE_OF_SANCTION, ''DD/MM/YYYY'') || ''|'' ||
       TO_CHAR(L1.LMTLINE_LIMIT_EXPIRY_DATE, ''DD/MM/YYYY'') || ''|'' ||
       L1.LMTLINE_SANCTION_AMT
  FROM IACLINK I, ACASLLDTL A, LIMITLINE L1
 WHERE A.ACASLLDTL_ENTITY_NUM = 1
   AND I.IACLINK_ENTITY_NUM = 1
   AND L1.LMTLINE_ENTITY_NUM = 1
   AND L1.LMTLINE_CLIENT_CODE = A.ACASLLDTL_CLIENT_NUM
   AND L1.LMTLINE_NUM = A.ACASLLDTL_LIMIT_LINE_NUM
   AND A.ACASLLDTL_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'Expiry Date', 'SELECT TO_CHAR(L1.LMTLINE_LIMIT_EXPIRY_DATE, ''DD/MM/YYYY'')
  FROM IACLINK I, ACASLLDTL A, LIMITLINE L1
 WHERE A.ACASLLDTL_ENTITY_NUM = 1
   AND I.IACLINK_ENTITY_NUM = 1
   AND L1.LMTLINE_ENTITY_NUM = 1
   AND L1.LMTLINE_CLIENT_CODE = A.ACASLLDTL_CLIENT_NUM
   AND L1.LMTLINE_NUM = A.ACASLLDTL_LIMIT_LINE_NUM
   AND A.ACASLLDTL_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'D', '1', 'SELECT ACNTS_BRN_CODE
  FROM ACNTS A, IACLINK I
 WHERE I.IACLINK_ENTITY_NUM = 1
   AND A.ACNTS_ENTITY_NUM = 1
   AND A.ACNTS_BRN_CODE = I.IACLINK_BRN_CODE
   AND A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND I.IACLINK_ACTUAL_ACNUM = ?', 'S', '1');
   

COMMIT;