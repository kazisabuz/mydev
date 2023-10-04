/* Formatted on 10/26/2022 10:31:47 AM (QP5 v5.388) */
  SELECT *
    FROM TABLE (PKG_CAD_REPORT.FN_GET_DATA ( :ENTITYNUM,
                                            18,
                                            :FROM_DATE,
                                            :TO_DATE,
                                            :RPT_TYPE,
                                            'F42B',
                                            :GL_CODE,
                                            :DEPT_CODE,
                                            :HEAD_CODE))
                                            where RPTHEAD_CODE in ('E1112','E1119')
ORDER BY DEPTS_DEPT_NAME, RPTHEAD_CODE, EXTGL_EXT_HEAD_DESCN