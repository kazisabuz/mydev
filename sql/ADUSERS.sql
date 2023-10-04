SELECT   U.USER_ID "Sam-Account-Name", 
                 'sonali@123' "Password",
                 'OU=User, OU= '||MBRN_NAME||' ('||MBRN_CODE|| '),'
                 || ', OU=ALL_Branches,OU=SONALI BANK LTD (SBL),DC=SBL,DC=LOCAL'  "OrganizationalUnit", 
                E.MEMP_NAME||'|'||TRIM(D.DESIG_CONC_NAME)||'|'
                 ||( SELECT  MBRN_NAME  FROM MBRN WHERE  MBRN_CODE = U.USER_BRANCH_CODE)||'('||U.USER_BRANCH_CODE
                 || ')|SBL' "Display-Name",
                substr(E.MEMP_NAME, 1,  instr(E.MEMP_NAME, ' ', -1 )-1) "Given Name",  
                substr(E.MEMP_NAME, instr(E.MEMP_NAME, ' ', -1 )+1 )  "Initials",
                E.MEMP_GSM_NUM "MOBILE-NO", E.MEMP_EMAIL_ID_1  EMAIL    
    FROM USERS U, MEMP E, MBRN B, DESIGNATIONS D
 WHERE    E.MEMP_NUM = U.USER_ID
       AND U.USER_BRANCH_CODE = B.MBRN_CODE
       AND E.MEMP_DESIG_CODE = D.DESIG_CODE
       AND TRIM (U.USER_SUSP_REL_FLAG) IS NULL
       AND U.USER_ID not in ( 'INTELECT', '69178' )
       AND U.USER_BRANCH_CODE IN ( 
39008
)
ORDER BY  U.USER_BRANCH_CODE, U.USER_ID  