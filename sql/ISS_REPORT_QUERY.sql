/* Formatted on 24/01/2019 5:44:25 PM (QP5 v5.227.12220.39754) */
SELECT 'BRCODE' "BRCODE",
       'BRN' BRN_NAME,
       'COL3' "INTER BRN UNRECONCILED DR NO",
       'COL4' INTER_BRN_UNRECONCILED_DR_AMNT,
       'COL5' INTER_BRAN_UNRECONCILED_CR_NO,
       'COL6' INTER_BRN_UNRECONCILED_CR_AMNT,
       'COL7' LAST_DATE_INTER_BRN_RECON_COMP,
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
          TOTAL_ASSET,
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
          TOTAL_FIXED_ASSET,
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
          HO_SBG_LEDGER_POSITIVE,
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
          TOTAL_OTHER_ASSET,
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
          DECODE_TOTAL_OTHER_ASSET,
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
          ACCRUED_INCOME,
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
          PREPAID_EXPENSES_OTHER_TAX,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0903',
                                'F12'),
            0)
          SUSPENSE_ACCOUNT,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0908',
                                'F12'),
            0)
          TOTAL_AMOUNT_OF_PROTESTED_BILL,
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
          STATIONARY_AND_STAMP,
       0 "Other Receivables",
       'Total Liability' TOTAL_LIABILITY,
       0 "Yearly Deposit Target",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM STATMENTOFAFFAIRS
         WHERE     RPT_BRN_CODE = :P_BRANCH_CODE
               AND RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_HEAD_CODE LIKE 'L20%')
          TOTAL_DEPOSIT,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2101',
                                'F12'),
            0)
          TOTAL_CURRENT_DEPOSIT,
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
          TOTAL_SAVINGS_DEPOSIT,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2002',
                                'F12'),
            0)
          TOTAL_STD,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'L2001',
                                'F12'),
            0)
          TOTAL_TERM_DEPOSIT,
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
          TOTAL_SAVINGS_SCHEME_DEPOSIT,
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
          TOTAL_MARGIN_DEPOSIT,
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
          TOTAL_SUNDRY_DEPOSIT,
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
          TOTAL_INSTITUTIONAL_DEPOSIT,
       0 "Total Crore above Deposit",
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM PRODUCTS, ACNTS
         WHERE     PRODUCT_FOR_DEPOSITS = 1
               AND ACNTS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL
               AND PRODUCT_FOR_RUN_ACS = 1)
          TOTAL_NUM_OF_DEPOSIT_ACCOUNT,
       (SELECT COUNT (A.ACNTS_INTERNAL_ACNUM)
          FROM ACNTS A
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_PROD_CODE IN (1000)
               AND ACNTS_AC_TYPE = 'SBSS'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          TOTAL_NUMBER_OF_10TK_ACCOUNT,
       (SELECT COUNT (A.ACNTS_INTERNAL_ACNUM)
          FROM ACNTS A
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_PROD_CODE IN (1000)
               AND ACNTS_AC_TYPE = 'SBSS'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND (ACNTS_INOP_ACNT = '1' OR ACNTS_DORMANT_ACNT = '1')
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          NON_OPERATIVE_OF_10TK_ACCOUNT,
       0 "Total Number of Unclaimed Deposit Accoun",
       0 "Total amount of Unclaimed Deposit",
       0 "Deposit with Insurance Coverage",
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
          HO_GL_AFTER_NETTING_OFF,
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
          TOTAL_OTHER_LIABILITY,
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
          DECODE_OF_37,
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
          LOCAL_DDTTMTPO_PAYABLE,
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
          FOREIGN_DDTTMTPO_PAYABLE,
       'Accepted Bills Payable Local' ACCEPTED_BILLS_PAYABLE_LOCAL,
       'Accepted Bills Payable foreign' ACCEPTED_BILLS_PAYABLE_FOREIGN,
       'Other Bills Payable' OTHER_BILLS_PAYABLE,
       'Sundry Creditors' SUNDRY_CREDITORS,
       'Total Off Balance Sheet Exposure 48 to54'
          TOTAL_OF_BALANCE_SHEET_EXPOSUR,
       'Acceptance and Endorsement' ACCEPTANCE_AND_ENDORSEMENT,
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
          IRREVOCABLE_LETTERS_OF_CREDIT,
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
          BILLS_FOR_COLLECTION,
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
          OTHER_CONTINGENT_LIABILITIES,
       0 "Other Commitments",
       0 "Short Term Trade-related Transactions",
       0 "Forward Assets Purchased",
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM PRODUCTS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_PROD_CODE = PRODUCT_CODE
               AND PRODUCT_FOR_LOANS = '1'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          TOTAL_NUMBER_OF_LOAN_ACCOUNT,
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
          TOTAL_LOAN_OUTSTANDING,
       0 "Yearly Loan Target",
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
          "Overdue Loan Amount",
       (SELECT COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ASSETCLS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE)
          TOTAL_NUMBER_OF_NPL_ACCOUNT,
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
          TOTAL_NPL_OUTSTANDING,
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
          TOTAL_STANDARD_LOAN,
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
          TOTAL_SMA_LOAN,
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
          TOTAL_SUBSTANDARD_LOAN,
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
          TOTAL_DOUBTFUL_LOAN,
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
          TOTAL_BAD_LOAN,
       (SELECT SUM (GET_SECURED_VALUE (ACNTS_INTERNAL_ACNUM,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE,
                                       ACNTS_CURR_CODE))
          FROM PRODUCTS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND PRODUCT_FOR_LOANS = '1')
          TOTAL_SEC_VALUE_AGAINST_LOAN,
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
          TOTAL_SEC_VAL_AGAINST_CLS_LOAN,
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
          TOTAL_INTEREST_SUSP_AGAINST_LOAN,
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
          TOTAL_INTEREST_SUSPENSE_BALANC,
       0 "Total Base for Provision",
       (SELECT SUM (BC_PROV_AMT)
          FROM CL_TMP_DATA
         WHERE     ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND ASON_DATE = :P_ASON_DATE)
          TOTAL_PROVISION_REQUIRED,
       0 "Total Provision Kept",
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
          TOTAL_CASH_CREDIT_HYPO_LOAN,
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
          TOTAL_CASH_CREDIT_PLEDGE_LOAN,
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
          TOTAL_OD_SOD_LOAN,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0324',
                                'F12'),
            0)
          TOTAL_PC_PSC,
       'Total ECC' TOTAL_ECC,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0403',
                                'F12'),
            0)
          TOTAL_PAD_GENERAL,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0405',
                                'F12'),
            0)
          TOTAL_PAD_EDF,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0322',
                                'F12'),
            0)
          TOTAL_LTR_MPI,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0321',
                                'F12'),
            0)
          TOTAL_LIM,
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
          TOTAL_LOAN_OUT_AGNST_IBP_LDBP,
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
          TOTAL_LOAN_OUT_AGNST_IBP_FDBP,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0323',
                                'F12'),
            0)
          OTHER_FORCED_LOAN_OUTSTANDING,
       0 "Total Buyers Credit Outstanding",
       0 "Total Suppliers Credit Outstanding",
       0 "Other Loans Outstanding",
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
          TOTAL_TERM_LOAN,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0332',
                                'F12'),
            0)
          TOTAL_LEASE_FINANCING,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0335',
                                'F12'),
            0)
          TOTAL_RETAIL_CREDIT,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0330',
                                'F12'),
            0)
          TOTAL_LOAN_AGAINST_CREDIT_CARD,
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0320',
                                'F12'),
            0)
          TOTAL_MICRO_CREDIT_OUTSTANDING,
       0 "Total Outstanding of Loans extended to NGOs",
       0 "Total Manufacturing and Industrial Loan Outstanding",
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
          "Total Service_Loan Outstanding",
       0 "Total Non-Manufacturing and Trade Loan Outstanding",
       0 "Total Asset backed Loan Outstanding",
       0 "Total Guarantee Backed(and Unsecured)Loan Outstanding",
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
          "Short Term Loan Outstanding",
       0 "Medium Term Loan Outstanding",
       0 "Long Term Loan Outstanding",
       0 "Total SME Loan Outstanding",
       0 "Total Women Entrepreneur Loan Outstanding",
       0 "Total Agro(Industrial) Loan Outstanding",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0319',
                                'F12'),
            0)
          "Total Agri(Pure) Loan Outstanding",
       0 "Total Green Financing",
       0 "Total Refinanced Loan Outstanding",
       0 "Director's Loan",
       0 "Director's Commitment/Undertaking",
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
          "Total Staff Loan",
       0 "Total Loan to Other Bank/FI Directors",
       0 "Large Loan Exposure as per BB Circular",
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
          "Total  Outstanding Amount of Top 50 Loans",
       0 "Total Loan Disbursed and Settled within this Month",
       0 "Total Loan purchased/acquisition from Other Bank/FIs",
       0 "Total EOL(Excess over limit) against loans",
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
          "Total Interest Free loan",
       0 "Total Loan Against NRB Owner's FDR ",
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS
         WHERE     ACNTS_PROD_CODE = 2029
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL)
          "Total Temporary Over Draft(TOD) Outstanding",
       (SELECT SUM (FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                       ACNTS_INTERNAL_ACNUM,
                                       ACNTS_CURR_CODE,
                                       :P_ASON_DATE,
                                       :P_ASON_DATE))
          FROM ACNTS
         WHERE     ACNTS_PROD_CODE = 2029
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_CLOSURE_DATE IS NULL)
          "Total TOD Against Cash Incentive",
       0 "Total New Loan Disbursed",
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
          "Unused Part of Commitment",
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
          "Total Rescheduled Loan Outstanding",
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
          "Total Rescheduled Loan Outstanding Presently UC",
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
               AND LNACRS_REPHASEMENT_ENTRY=1
               AND LNACRS_PURPOSE = 'R'
               AND ACNTS_CLOSURE_DATE IS NULL)
          "Total Rescheduled Loan Outstanding Presently NP",
       0 "Total Declassified Loan Outstanding",
       0 "Total Interest Waived  Loan Outstanding",
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
          "Total Blocked Loan Outstanding",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,:P_ASON_DATE,'A0703','F12'),0) "Total Write-off Loan Outstanding",
       0 "Total Irregular Staff Loan Outstanding",
       0 "Total  Recoverable Loan for this month",
       0 "Total Loan Recovered  in this month",
       0 "Early Settled Loan amount",
       (SELECT NVL (SUM (LNWRTOFF_WRTOFF_AMT), 0)
          FROM LNWRTOFF, ACNTS
         WHERE     LNWRTOFF_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND LNWRTOFF_ENTITY_NUM = 1
               AND TO_CHAR (LNWRTOFF_WRTOFF_DATE, 'RRRR') =TO_CHAR (:P_ASON_DATE, 'RRRR')) "Total Amount of Written-off Loan (current year)",
       (SELECT NVL (SUM (LNWRTOFFREC_RECOV_AMT), 0)
          FROM LNWRTOFFRECOV, ACNTS
         WHERE     LNWRTOFFREC_LN_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = :P_BRANCH_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND LNWRTOFFREC_ENTITY_NUM = 1
               AND LNWRTOFFREC_ENTRY_DATE = :P_ASON_DATE) "Total Recovery of Written-off Loan",
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
               AND ASSETCLSH_EFF_DATE < :P_ASON_DATE) "Total Recovery of Classified Loan",
       0 "Total Outstanding of Term Loan Converted from Continuous, Demand and Time Loan",
       0 "Total Amount of LTR Converted to Term Loan",
       0 "Total Amount of STL (Except LTR) Converted to Term loan",
       0 "Total Amount of Demand Loan Converted to Term loan",
       0 "Total Amount of Time Loan Converted to Term loan",
       0 "Total Acceptance provided Against Inland Bill Related to Export LC",
       0 "Total Acceptance Provided Against Inland Bill not Related to Export LC",
       0 "Total Acceptance Provided Against Foreign Bill",
       0 "Total Outstanding of Acceptance Issued Against  FB/IB/AB",
       0 "Total Acceptance Matured Against  FB/IB/AB",
       0 "Total Payment Made Against  FB/IB/AB",
       0 "Total Outstanding of Acceptance Received from Other Bank/branch Against  FBP/IBP/ABP",
       0 "Total Acceptance Matured to Other Bank/branch Against  FBP/IBP/ABP",
       0 "Unrealized Acceptance Receivable from Other Bank/branch Against  FBP/IBP/ABP",
       0 "Total Outstanding Balance of Issued Bank Guarantee",
       0 "Total Performance Guarantee Local",
       0 "Total Other Guarantee Local",
       0 "Total Performance Guarantee Foreign",
       0 "Total Other Guarantee Foreign",
       0 "Total Issued Bank Guarantee Against Foreign Loan",
       0 "Total Value of Other Bank's Bank Guarantee in Hand",
       0 "Total Export Executed",
       0 "Advance Export Payment Received",
       0 "Total Amount of Export Bill Discounted",
       0 "Total Import Executed",
       0 "Total Advance Payment Made Against Import",
       0 "Total Payment Against Contract",
       0 "Total Foreign Exchange Inflow",
       0 "Total Foreign Exchange Outflow",
       0 "Total Foreign Currency Purchased",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0104',
                                'F12'),
            0)
          "Total Foreign Currency in Hand",
       0 "Total Foreign Currency in Transit",
       0 "Total Foreign Exchange Holding",
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
          "Total Customer Balance in the Foreign Currency A/C",
       0 "Total Commitment Provided Against LC Foreign",
       0 "Total Commitment Provided Against LC Local",
       0 "Total L/C Opened under L/C Code-1",
       0 "Total L/C Opened under L/C Code-2",
       0 "Total L/C Opened under L/C Code-3",
       0 "Total L/C Opened under L/C Code-4",
       0 "Total L/C Opened under L/C Code-5",
       0 "Total L/C Opened under L/C Code-6",
       0 "Total L/C Opened under L/C Code-9",
       0 "Total L/C Opened under L/C Code-10",
       0 "Total L/C Opened under L/C Code-11",
       0 "Total L/C Opened under L/C Code-12",
       0 "Total L/C Opened under L/C Code-99",
       0 "Total L/C Retired under L/C Code-1",
       0 "Total L/C Retired under L/C Code-2",
       0 "Total L/C Retired under L/C Code-3",
       0 "Total L/C Retired under L/C Code-4",
       0 "Total L/C Retired under L/C Code-5",
       0 "Total L/C Retired under L/C Code-6",
       0 "Total L/C Retired under L/C Code-9",
       0 "Total L/C Retired under L/C Code-10",
       0 "Total L/C Retired under L/C Code-11",
       0 "Total L/C Retired under L/C Code-12",
       0 "Total L/C Retired under L/C Code-99",
       0 "Cumulative value of Cash LC Retired (F)",
       0 "Cumulative value of BB LC Retired (F)",
       0 "Cumulative value of BB LC Retired (L)",
       (SELECT SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                  TOTAL_INCOME_EXPENSE
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_ASON_DATE
               AND RPT_BRN_CODE = :P_BRANCH_CODE)
          "Total Income",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'I0127',
                                'F42B'),
            0)
          "Total Interest Income",
       0 "Total Non-interest Income",
       0 "Total Non-interest Income",
       0 "Net Interest Income",
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
          "Gross Profit(+/-)",
      (NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1101','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1102','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1103','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1104','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1104','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1106','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1107','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1108','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1109','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1110','F42B'),0)+
NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE, :P_ASON_DATE, 'E1111','F42B'),0))
          "Total Interest Expenses",
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
          "Total Operating Expenditure",
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
          "Administrative Cost",
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
          "Total Other Expenditure",
       0 "Office Maintenance Expenses",
       0 "Branch Renovation Cost",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'E1163',
                                'F42B'),
            0)
          "Total Business Development Expenses",
       0 "Cash-Vault Limit",
       0 "Cash-Vault Insurance Coverage",
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND TO_CHAR (VAULTBAL_YEAR, 'RRRR') =
                      TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND TO_CHAR (VAULTBAL_MONTH, 'MM') =
                      TO_CHAR (:P_ASON_DATE, 'MM'))
          "Cash in Vault",
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND VAULTBAL_CURR_CODE = 'BDT'
               AND TO_CHAR (VAULTBAL_YEAR, 'RRRR') =
                      TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND TO_CHAR (VAULTBAL_MONTH, 'MM') =
                      TO_CHAR (:P_ASON_DATE, 'MM'))
          "Local Currency in Vault",
       (SELECT SUM (VAULTBAL_CUR_GOOD_BAL)
          FROM VAULTBAL
         WHERE     VAULTBAL_ENTITY_NUM = 1
               AND VAULTBAL_BRN_CODE = :P_BRANCH_CODE
               AND VAULTBAL_CURR_CODE <> 'BDT'
               AND TO_CHAR (VAULTBAL_YEAR, 'RRRR') =
                      TO_CHAR (:P_ASON_DATE, 'RRRR')
               AND TO_CHAR (VAULTBAL_MONTH, 'MM') =
                      TO_CHAR (:P_ASON_DATE, 'MM'))
          "Foreign Currency in Vault",
       0 "Prize Bond in Vault",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0106',
                                'F12'),
            0)
          "Cash Balance in ATM",
       NVL (SP_FN_ISS_HEAD_BAL (:P_BRANCH_CODE,
                                :P_ASON_DATE,
                                'A0102',
                                'F12'),
            0)
          "Balance with BB/BB Representative",
       0 "Cash Transit Limit",
       0 "Total Fund Received from the Feeding Br/ BB in this month",
       0 "Total Fund Remit to the Feeding Br/BB in this month",
       0 "Highest Fund Received from Feeding Br/BB in this month",
       0 "Highest Fund Remit to Feeding Br/BB in this month",
       0 "No.ofdays exceeding cash vault limit in this month",
       0 "Highest amount of cash vault exceeding limit in this month",
       0 "Total Number Reported in STR",
       0 "Total Amount Reported in STR",
       0 "Total Number Reported in CTR",
       0 "Total Amount Reported in CTR",
       0 "Total Amount Reported in CTR",
       0 "Total Number of Suit Filed",
       0 "Total Outstanding of Loans under Suit",
       0 "Amount of Suit Value Recovered in this Year",
       0 "Total Expense against Suit filed in this year",
       0 "Total Number of Mutual Suit Vacant",
       0 "Total Amount Realized against Mutual Suit Vacant",
       0 "Total Number of Employee of the Branch",
       0 "Number of Branch Employee Trained in Credit Operation "
  FROM DUAL