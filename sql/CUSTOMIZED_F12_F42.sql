/* Formatted on 11/25/2021 2:27:41 PM (QP5 v5.252.13127.32867) */
SELECT RPT_HEAD_CODE,
       RPTHEAD_DESCN1 || RPTHEAD_DESCN2 || RPTHEAD_DESCN3 head_name,
       RPT_ENTRY_DATE,
       RPT_HEAD_BAL,
       RPT_BRN_CODE,
       rpthead.RPTHEAD_CLASSIFICATION,
       NUM_OF_ACCOUNT
  FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA ('F12',
                                                              26,
                                                              '23-mar-2017',
                                                              1)),
       rpthead
 WHERE RPT_HEAD_CODE = RPTHEAD_CODE;