/* Formatted on 27/01/2019 3:40:38 PM (QP5 v5.227.12220.39754) */
SELECT :P_BRANCH_CODE COL1,
       'BRN' COL2,
       'COL3' "COL3",
       'COL4' COL4,
       'COL5' COL5,
       'COL6' COL6,
       'COL7' COL7,
         (SELECT SUM (RPT_HEAD_BAL)
            FROM STATMENTOFAFFAIRS
           WHERE     RPT_BRN_CODE = :P_BRANCH_CODE
                 AND RPT_ENTRY_DATE = :P_ASON_DATE
                 AND RPT_HEAD_CODE LIKE 'A0%')
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0506',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0601',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0602',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0604',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0605',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0701',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0702',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0703',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0704',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A1001',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0905',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0943',
                                  'F12'),
              0)
          COL8,
         NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A1001',
                                  'F12'),
              0)
       - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'L2701',
                                  'F12'),
              0)
          VALUE_OF_I,
         (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0905',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0943',
                                     'F12'),
                 0))
       - (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2608',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2605',
                                     'F12'),
                 0))
          VALUE_OF_J,
         NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0801 ',
                                  'F12'),
              0)
       + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0802  ',
                                  'F12'),
              0)
       + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                  :P_ASON_DATE,
                                  'A0803   ',
                                  'F12'),
              0)
          COL9,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0506   ',
                                   'F12'),
               0)
        - (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                      :P_ASON_DATE,
                                      'L2301   ',
                                      'F12'),
                  0)
           + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                      :P_ASON_DATE,
                                      'L2304   ',
                                      'F12'),
                  0)))
          COL10,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0901',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0902',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0903',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0904',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A1001',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0906',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0907',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0908',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0909',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0910',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0911',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0913',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0926',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0927',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0928',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0931',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0938',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0939',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0940',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0941',
                                   'F12'),
               0))
          COL11,
         (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0905',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0943',
                                     'F12'),
                 0))
       - (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2608',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2605',
                                     'F12'),
                 0))
          DECODE_COL11,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0910',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0913',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0940',
                                   'F12'),
               0))
          COL12,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0904',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0941',
                                   'F12'),
               0))
          COL13,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0903',
                                'F12'),
            0)
          COL14,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0908',
                                'F12'),
            0)
          COL15,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0901 ',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0902',
                                   'F12'),
               0))
          COL16,
       0 COL17,
       'COL8' COL18,
       0 COL19,
       (SELECT SUM (RPT_HEAD_BAL)
          FROM STATMENTOFAFFAIRS
         WHERE     RPT_BRN_CODE = :P_BRANCH_CODE
               AND RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_HEAD_CODE LIKE 'L20%')
          COL20,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2101',
                                'F12'),
            0)
          COL21,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2005',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2017',
                                   'F12'),
               0))
          COL22,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2002',
                                'F12'),
            0)
          COL23,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2001',
                                'F12'),
            0)
          COL24,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2003',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2004',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2008',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2009',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2010',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2011',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2012',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2013',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2014',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2016',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2018',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2019',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2020',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2021',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2022',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2023',
                                   'F12'),
               0))
          COL25,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2110',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2111',
                                   'F12'),
               0))
          COL26,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2110',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2111',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2112',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2113',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2114',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2012',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2115',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2116',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2117',
                                   'F12'),
               0))
          COL27,
       (SELECT NVL (SUM (FN_GET_ASON_ACBAL (1,
                                            ACNTS_INTERNAL_ACNUM,
                                            ACNTS_CURR_CODE,
                                            :P_ASON_DATE,
                                            :P_ASON_DATE)),
                    0)
          FROM ACNTS, CLIENTS
         WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND CLIENTS_SEGMENT_CODE NOT IN
                      ('901009',
                       '903009',
                       '910500',
                       '911000',
                       '910000',
                       '915001',
                       '915002',
                       '915003',
                       '915004',
                       '915005',
                       '915006',
                       '915059',
                       '909051'))
          COL28,
       0 COL29,
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM PRODUCTS, ACNTS
         WHERE     PRODUCT_FOR_DEPOSITS = 1
               AND ACNTS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND PRODUCT_FOR_RUN_ACS = 1)
          COL30,
       (SELECT COUNT (A.ACNTS_INTERNAL_ACNUM)
          FROM ACNTS A
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_PROD_CODE IN (1000)
               AND ACNTS_AC_TYPE = 'SBSS'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL31,
       (SELECT COUNT (A.ACNTS_INTERNAL_ACNUM)
          FROM ACNTS A
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_PROD_CODE IN (1000)
               AND ACNTS_AC_TYPE = 'SBSS'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND (ACNTS_INOP_ACNT = '1' OR ACNTS_DORMANT_ACNT = '1')
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL32,
       0 COL33,
       0 COL34,
       0 COL35,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0501',
                                   'F12'),
               0)
        - NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2304',
                                   'F12'),
               0))
          COL36,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2106',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2115',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2116',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2609',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2610',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2611',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2613',
                                   'F12'),
               0))
          COL37,
         (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2608',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'L2605',
                                     'F12'),
                 0))
       - (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0905',
                                     'F12'),
                 0)
          + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                     :P_ASON_DATE,
                                     'A0943',
                                     'F12'),
                 0))
          DECODE_OF_COL37,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2201',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2202',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2203',
                                   'F12'),
               0))
          COL38,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2204',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2205',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2206',
                                   'F12'),
               0))
          COL39,
       'COL142COL143' COL40,
       'COL144' COL41,
       0 COL42,
       0 COL43,
       0 COL44,
       0 COL45,
       'Sum of 48 to 54' COL46,
       0 COL47,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2502',
                                'F12'),
            0)
          LETTERS_OF_GUARANTEE,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2501',
                                'F12'),
            0)
          COL48,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2501',
                                'F12'),
            0)
          COL49,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0601',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0602',
                                   'F12'),
               0))
          COL50,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0603',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0605',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0704',
                                   'F12'),
               0))
          COL51,
       0 COL52,
       0 COL53,
       0 COL54,
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM PRODUCTS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_PROD_CODE = PRODUCT_CODE
               AND PRODUCT_FOR_LOANS = '1'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL55,
       (SELECT SUM (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM PRODUCTS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_PROD_CODE = PRODUCT_CODE
               AND PRODUCT_FOR_LOANS = '1'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL56,
       0 COL57,
       (SELECT SUM (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL58,
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL59,
       (SELECT SUM (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL60,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL61,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SM')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL62,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL63,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('DF')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL64,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('BL')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL65,
       (SELECT SUM (GET_SECURED_VALUE (ACNTS_INTERNAL_ACNUM,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE,
                                       ACNTS_CURR_CODE))
          FROM PRODUCTS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND PRODUCT_FOR_LOANS = '1')
          COL66,
       (SELECT SUM (GET_SECURED_VALUE (ACNTS_INTERNAL_ACNUM,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE,
                                       ACNTS_CURR_CODE))
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          COL67,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2609',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2610',
                                   'F12'),
               0))
          COL68,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2609',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'L2610',
                                   'F12'),
               0))
          COL69,
       0 COL70,
       (SELECT SUM (BC_PROV_AMT)
          FROM CL_TMP_DATA
         WHERE     ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND ASON_DATE = :P_ASON_DATE)
          COL71,
       0 COL72,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0301',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0312',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0317',
                                   'F12'),
               0))
          COL73,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0302',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0313',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0318',
                                   'F12'),
               0))
          COL74,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0304',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0350',
                                   'F12'),
               0))
          COL75,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0324',
                                'F12'),
            0)
          COL76,
       0 COL77,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0403',
                                'F12'),
            0)
          COL78,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0405',
                                'F12'),
            0)
          COL79,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0322',
                                'F12'),
            0)
          COL80,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0321',
                                'F12'),
            0)
          COL81,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0326',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0404',
                                   'F12'),
               0))
          COL82,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0401',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0402',
                                   'F12'),
               0))
          COL83,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0323',
                                'F12'),
            0)
          COL84,
       0 COL85,
       0 COL86,
       0 COL87,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS, PRODUCTS
         WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND PRODUCT_FOR_RUN_ACS = 0)
          COL88,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0332',
                                'F12'),
            0)
          COL89,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0335',
                                'F12'),
            0)
          COL90,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0330',
                                'F12'),
            0)
          COL91,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0320',
                                'F12'),
            0)
          COL92,
       0 COL93,
       0 COL94,
       (SELECT NVL (SUM (FN_GET_ASON_ACBAL (1,
                                            ACNTS_INTERNAL_ACNUM,
                                            ACNTS_CURR_CODE,
                                            :P_ASON_DATE,
                                            :P_ASON_DATE)),
                    0)
          FROM ACNTS, CLIENTS
         WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND CLIENTS_SEGMENT_CODE IN ('902401', '902499'))
          COL95,
       0 COL96,
       0 COL97,
       0 COL98,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS, LNPRODPM
         WHERE     ACNTS_PROD_CODE = LNPRD_PROD_CODE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND LNPRD_SHORT_TERM_LOAN = '1')
          COL99,
       0 COL100,
       0 COL101,
       0 COL102,
       0 COL103,
       0 COL104,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0319',
                                'F12'),
            0)
          COL105,
       0 COL106,
       0 COL107,
       0 COL108,
       0 COL109,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0307 ',
                                   'F12'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'A0308 ',
                                   'F12'),
               0))
          COL110,
       0 COL111,
       0 COL112,
       (SELECT SUM (AMOUNT)
          FROM (  SELECT ACNTS_INTERNAL_ACNUM, AMOUNT
                    FROM (SELECT ACNTS_INTERNAL_ACNUM,
                                 FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                    ACNTS_INTERNAL_ACNUM,
                                                    ACNTS_CURR_CODE,
                                                    :P_ASON_DATE,
                                                    :P_ASON_DATE)
                                    AMOUNT
                            FROM ACNTS, PRODUCTS
                           WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
                                 AND ACNTS_BRN_CODE = :P_BRANCH_CODE
                                 AND ACNTS_CLOSURE_DATE IS NULL
                                 AND PRODUCT_FOR_LOANS = '1')
                ORDER BY ABS (AMOUNT) DESC)
         WHERE ROWNUM <= 50)
          COL113,
       0 COL114,
       0 COL115,
       0 COL116,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM LNPRODIR, ACNTS
         WHERE     ACNTS_PROD_CODE = LNPRODIR_PROD_CODE
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND LNPRODIR_ENTITY_NUM = 1
               AND LNPRODIR_AC_TYPE = ACNTS_AC_TYPE
               AND LNPRODIR_AC_SUB_TYPE = ACNTS_AC_SUB_TYPE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND LNPRODIR_APPL_INT_RATE = 0)
          COL117,
       0 COL118,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS
         WHERE     ACNTS_PROD_CODE = 2029
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL)
          COL119,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS
         WHERE     ACNTS_PROD_CODE = 2029
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL)
          COL120,
       0 COL121,
       (SELECT SUM (LLACNTOS_LIMIT_CURR_DISB_MADE + LMTLINE_SANCTION_AMT)
          FROM ACASLLDTL,
               LIMITLINE,
               LLACNTOS,
               ACNTS
         WHERE     ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LLACNTOS_ENTITY_NUM = 1
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_INTERNAL_ACNUM = LLACNTOS_CLIENT_ACNUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LLACNTOS_CLIENT_ACNUM = ACASLLDTL_INTERNAL_ACNUM)
          COL122,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS, LNACRS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND LNACRS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LNACRS_ENTITY_NUM = 1
               AND LNACRS_ENTITY_NUM = 1
               AND LNACRS_PURPOSE = 'R'
               AND ACNTS_CLOSURE_DATE IS NULL)
          COL123,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS, LNACRS, ASSETCLS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               AND ASSETCLS_ENTITY_NUM = 1
               AND LNACRS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LNACRS_ENTITY_NUM = 1
               AND LNACRS_ENTITY_NUM = 1
               AND LNACRS_PURPOSE = 'R'
               AND ACNTS_CLOSURE_DATE IS NULL)
          COL124,
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS, LNACRS, ASSETCLS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ASSETCLS_ENTITY_NUM = 1
               AND LNACRS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LNACRS_ENTITY_NUM = 1
               AND LNACRS_REPHASEMENT_ENTRY = 1
               AND LNACRS_PURPOSE = 'R'
               AND ACNTS_CLOSURE_DATE IS NULL)
          COL125,
       0 COL126,
       0 COL127,
       (SELECT NVL (SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                            ACNTS_INTERNAL_ACNUM,
                                            ACNTS_CURR_CODE,
                                            :P_ASON_DATE,
                                            :P_ASON_DATE)),
                    0)
          FROM ACNTS, PRODUCTS
         WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND PRODUCT_FOR_LOANS = '1'
               AND UPPER (PRODUCT_NAME) LIKE '%BLOCK%')
          COL128,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0703',
                                'F12'),
            0)
          COL129,
       0 COL130,
       0 COL131,
       0 COL132,
       0 COL133,
       (SELECT NVL (SUM (LNWRTOFF_WRTOFF_AMT), 0)
          FROM LNWRTOFF, ACNTS
         WHERE     LNWRTOFF_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND LNWRTOFF_ENTITY_NUM = 1
               AND TO_CHAR (LNWRTOFF_WRTOFF_DATE, 'RRRR') =
                      TO_CHAR (:P_ASON_DATE, 'RRRR'))
          COL134,
       (SELECT NVL (SUM (LNWRTOFFREC_RECOV_AMT), 0)
          FROM LNWRTOFFRECOV, ACNTS
         WHERE     LNWRTOFFREC_LN_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND LNWRTOFFREC_ENTITY_NUM = 1
               AND LNWRTOFFREC_ENTRY_DATE = :P_ASON_DATE)
          COL135,
       (SELECT NVL (SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                            ACNTS_INTERNAL_ACNUM,
                                            ACNTS_CURR_CODE,
                                            :P_ASON_DATE,
                                            :P_ASON_DATE)),
                    0)
          FROM ASSETCLSHIST, ACNTS
         WHERE     ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ASSETCLSH_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ACNTS_ENTITY_NUM = 1
               AND ASSETCLSH_ENTITY_NUM = 1
               AND ASSETCLSH_EFF_DATE < :P_ASON_DATE)
          COL136,
       0 COL137,
       0 COL138,
       0 COL139,
       0 COL140,
       0 COL141,
       0 COL142,
       0 COL143,
       0 COL144,
       0 COL145,
       0 COL146,
       0 COL147,
       0 COL148,
       0 COL149,
       0 COL150,
       0 COL151,
       0 COL152,
       0 COL153,
       0 COL154,
       0 COL155,
       0 COL156,
       0 COL157,
       0 COL158,
       0 COL159,
       0 COL160,
       0 COL161,
       0 COL162,
       0 COL163,
       0 COL164,
       0 COL165,
       0 COL166,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0104',
                                'F12'),
            0)
          COL167,
       0 COL168,
       0 COL169,
       (SELECT NVL (SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                            ACNTS_INTERNAL_ACNUM,
                                            ACNTS_CURR_CODE,
                                            :P_ASON_DATE,
                                            :P_ASON_DATE)),
                    0)
          FROM ACNTS
         WHERE     ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CURR_CODE <> 'BDT')
          COL170,
       0 COL171,
       0 COL172,
       0 COL173,
       0 COL174,
       0 COL175,
       0 COL176,
       0 COL177,
       0 COL178,
       0 COL179,
       0 COL180,
       0 COL181,
       0 COL182,
       0 COL183,
       0 COL184,
       0 COL185,
       0 COL186,
       0 COL187,
       0 COL188,
       0 COL189,
       0 COL190,
       0 COL191,
       0 COL192,
       0 COL193,
       0 COL194,
       0 COL195,
       0 COL196,
       0 COL197,
       (SELECT SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                  TOTAL_INCOME_EXPENSE
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE)
          COL198,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'I0127',
                                'F42B'),
            0)
          COL199,
       0 COL200,
       0 COL201,
       (SELECT CASE SIGN (
                       SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL))
                  WHEN 0
                  THEN
                     'NO INCOME EXPENSE'
                  WHEN 1
                  THEN
                     'Profit'
                  WHEN -1
                  THEN
                     'Loss'
               END
                  PROFIT_LOASS
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE)
          COL202,
       (  NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1101',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1102',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1103',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1104',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1104',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1106',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1107',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1108',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1109',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1110',
                                   'F42B'),
               0)
        + NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                   :P_ASON_DATE,
                                   'E1111',
                                   'F42B'),
               0))
          COL203,
       (SELECT NVL (SUM (RPT_HEAD_BAL), 0)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE
               AND RPT_HEAD_CODE IN
                      ('E1112',
                       'E1113',
                       'E1114',
                       'E1115',
                       'E1116',
                       'E1117',
                       'E1208'))
          COL204,
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE
               AND RPT_HEAD_CODE IN
                      ('E1112',
                       'E1113',
                       'E1114',
                       'E1115',
                       'E1116',
                       'E1117',
                       'E1118',
                       'E1119',
                       'E1159',
                       'E1194',
                       'E1195',
                       'E1197'))
          COL205,
       (SELECT NVL (SUM (RPT_HEAD_BAL), 0)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE
               AND RPT_HEAD_CODE IN
                      ('E1148',
                       'E1149',
                       'E1151',
                       'E1153',
                       'E1154',
                       'E1155',
                       'E1156',
                       'E1157',
                       'E1158',
                       'E1199',
                       'E1211'))
          COL206,
       0 COL207,
       0 COL208,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'E1163',
                                'F42B'),
            0)
          COL209,
       0 COL210,
       0 COL211,
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND VAULTBAL_YEAR = TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND VAULTBAL_MONTH = TO_CHAR (:P_ASON_DATE, 'MM'))
          COL212,
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND VAULTBAL_CURR_CODE = 'BDT'
               AND VAULTBAL_YEAR = TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND VAULTBAL_MONTH = TO_CHAR (:P_ASON_DATE, 'MM'))
          COL213,
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND VAULTBAL_CURR_CODE <> 'BDT'
               AND VAULTBAL_YEAR = TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND VAULTBAL_MONTH = TO_CHAR (:P_ASON_DATE, 'MM'))
          COL214,
       0 COL215,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0106',
                                'F12'),
            0)
          COL216,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0102',
                                'F12'),
            0)
          COL217,
       0 COL218,
       0 COL219,
       0 COL220,
       0 COL221,
       0 COL222,
       0 COL223,
       0 COL224,
       0 COL225,
       0 COL226,
       0 COL227,
       0 COL228,
       0 COL229,
       0 COL230,
       0 COL231,
       0 COL232,
       0 COL233,
       0 COL234,
       0 COL235,
       0 COL236
  FROM DUAL