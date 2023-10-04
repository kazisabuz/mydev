BEGIN
   FOR IDX IN (SELECT ACC_NO,
                      CONT_PHASE,
                      CONT_STATUS,
                      SANC_DATE,
                      REQ_DATE,
                      PLAN_END_DATE,
                      AC_END_DATE,
                      DEFAULTER,
                      LAST_PMT_DATE,
                      REORGANIZE_CR,
                      SANCTION_LIMIT,
                      TOTAL_DISBURSE,
                      OUTSTANDING,
                      NOINSTALMENT,
                      INSTALLAMT,
                      NXT_INST_EXP_DATE,
                      NXT_EX_INST_AMT,
                      REMAIN_INST_NO,
                      REMAIN_AMT,
                      NOOVERDUE,
                      OVERDUE,
                      PAYMENT_DELAYNO,
                      DUERECOVERY,
                      RECOVERY,
                      CUMRECOVERY,
                      LAWSUIT_DATE,
                      CL_DATE,
                      RESCHEDULE_NO,
                      LAST_RESCH_DATE
                 FROM CIB_CONTRACT)
   LOOP
      UPDATE CIB_CONTRACT_BAK
         SET CONT_PHASE = IDX.CONT_PHASE,
             CONT_STATUS = IDX.CONT_STATUS,
             SANC_DATE = IDX.SANC_DATE,
             REQ_DATE = IDX.REQ_DATE,
             PLAN_END_DATE = IDX.PLAN_END_DATE,
             AC_END_DATE = IDX.AC_END_DATE,
             DEFAULTER = IDX.DEFAULTER,
             LAST_PMT_DATE = IDX.LAST_PMT_DATE,
             REORGANIZE_CR = IDX.REORGANIZE_CR,
             SANCTION_LIMIT = IDX.SANCTION_LIMIT,
             TOTAL_DISBURSE = IDX.TOTAL_DISBURSE,
             OUTSTANDING = IDX.OUTSTANDING,
             NOINSTALMENT = IDX.NOINSTALMENT,
             INSTALLAMT = IDX.INSTALLAMT,
             NXT_INST_EXP_DATE = IDX.NXT_INST_EXP_DATE,
             NXT_EX_INST_AMT = IDX.NXT_EX_INST_AMT,
             REMAIN_INST_NO = IDX.REMAIN_INST_NO   ,
                 REMAIN_AMT             =    IDX.REMAIN_AMT,
       NOOVERDUE                  =IDX.NOOVERDUE,
       OVERDUE                    =IDX.OVERDUE,
       PAYMENT_DELAYNO            =IDX.PAYMENT_DELAYNO,
       DUERECOVERY                =IDX.DUERECOVERY,
       RECOVERY                   =IDX.RECOVERY,
       CUMRECOVERY                =IDX.CUMRECOVERY,
       LAWSUIT_DATE               =IDX.LAWSUIT_DATE,
       CL_DATE                    =IDX.CL_DATE,
       RESCHEDULE_NO              =IDX.RESCHEDULE_NO,
       LAST_RESCH_DATE            =IDX.LAST_RESCH_DATE
       WHERE  ACC_NO=IDX.ACC_NO;

  END LOOP;
  END;