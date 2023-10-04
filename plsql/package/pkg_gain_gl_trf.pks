DROP PACKAGE SBLPROD_AME_AUG.PKG_GAIN_GL_TRF;

CREATE OR REPLACE PACKAGE SBLPROD_AME_AUG.PKG_GAIN_GL_TRF
  /*

   Author :Kazi Sabuj
   Created : 09/30/2019 4:19:11 PM
   Purpose : Gain loss GL adjustment

   */
IS
   TYPE TY_TRANRECDTL IS RECORD
   (
      VV_BRN_CODE    MBRN.MBRN_CODE%TYPE,
      VV_DB_CR_FLG    TRAN2019.TRAN_DB_CR_FLG%TYPE,
       VV_GLACC_CODE   TRAN2019.TRAN_GLACC_CODE%TYPE,
      VV_CURR_CODE    TRAN2019.TRAN_CURR_CODE%TYPE,
      VV_AC_AMOUNT    TRAN2019.TRAN_AMOUNT%TYPE,
      VV_BC_AMT       TRAN2019.TRAN_BASE_CURR_EQ_AMT%TYPE
   );


   TYPE TY_TY_TRANREC IS TABLE OF TY_TRANRECDTL;


   PROCEDURE START_BRNWISE (
      P_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      P_BRN_CODE     IN MBRN.MBRN_CODE%TYPE DEFAULT 0);
END;
/
