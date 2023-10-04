/* Formatted on 6/28/2020 2:06:18 PM (QP5 v5.227.12220.39754) */
SELECT EXTGL_ACCESS_CODE from_gl_code,
       EXTGL_EXT_HEAD_DESCN from_gl_name,
       GLBALTRF_TRF_GLACC_CODE to_gl_code,
       (SELECT EXTGL_EXT_HEAD_DESCN
          FROM extgl
         WHERE EXTGL_ACCESS_CODE = GLBALTRF_TRF_GLACC_CODE)
          to_gl_name,
       CASE
          WHEN GLBALTRF_BALTRF_FREQ = 'D' THEN 'Daily'
          WHEN GLBALTRF_BALTRF_FREQ = 'M' THEN 'Monthly'
          WHEN GLBALTRF_BALTRF_FREQ = 'Y' THEN 'Yarly'
          ELSE NULL
       END
          trf_freq
  FROM extgl, GLBALTRF
 WHERE EXTGL_ACCESS_CODE = GLBALTRF_GLACC_CODE;