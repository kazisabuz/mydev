/* Formatted on 5/30/2021 4:47:21 PM (QP5 v5.252.13127.32867) */
SELECT ROWNUM Serial_No,
       MPGM_ID Program_ID,
       MPGM_DESCN description,
       CASE WHEN MPGMACTL_DBL_AUTH_REQD = 1 THEN 'DOUBLE' ELSE 'SINGLE' END
          Authorization_Status                          --(Single/Double/Risk)
  FROM MPGM, MPGMAUTHCTL
 WHERE MPGMACTL_PGM_ID = MPGM_ID