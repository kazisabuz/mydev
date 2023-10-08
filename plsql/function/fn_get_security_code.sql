CREATE OR REPLACE FUNCTION FN_GET_SECURITY_CODE (P_ENTITY_NUM      NUMBER,
                                                 P_CLIENTS_CODE    NUMBER,
                                                 P_BRN_CODE        NUMBER,
                                                 P_AC_NUM          NUMBER,
                                                 P_PROD_CODE       NUMBER)
   RETURN VARCHAR2
IS
   V_SEC_CODE     SECRCPT.SECRCPT_SEC_TYPE%TYPE;
   V_EXIST_FLAG   VARCHAR2 (1);
BEGIN
   BEGIN
      SELECT 1
        INTO V_EXIST_FLAG
        FROM LNPRODPM
       WHERE     NVL (LNPRD_DEPOSIT_LOAN, '0') = '1'
             AND LNPRD_PROD_CODE = P_PROD_CODE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_EXIST_FLAG := 0;
   END;

   BEGIN
      IF V_EXIST_FLAG = '1'
      THEN
         SELECT SECTYPE_CODE_FOR_RETURN18
           INTO V_SEC_CODE
           FROM SECTYPES
          WHERE SECTYPE_TYPE_FLG = '1' AND SECTYPE_AUTH_ON IS NOT NULL;
      ELSE
         SELECT SECTYPE_CODE_FOR_RETURN18
           INTO V_SEC_CODE
           FROM SECRCPT,
                SECTYPES,
                SECASSIGNMTBAL,
                ACASLLDTL
          WHERE     SECRCPT_SEC_TYPE = SECTYPE_CODE
                AND SECRCPT_ENTITY_NUM = P_ENTITY_NUM
                AND SECRCPT_CREATED_BY_BRN = P_BRN_CODE
                AND SECRCPT_CLIENT_NUM = P_CLIENTS_CODE
                AND SECRCPT_AUTH_ON IS NOT NULL
                AND ACASLLDTL_ENTITY_NUM = P_ENTITY_NUM
                AND ACASLLDTL_CLIENT_NUM = SECAGMTBAL_CLIENT_NUM
                AND ACASLLDTL_LIMIT_LINE_NUM = SECAGMTBAL_LIMIT_LINE_NUM
                AND ACASLLDTL_INTERNAL_ACNUM = P_AC_NUM
                AND SECAGMTBAL_ENTITY_NUM = P_ENTITY_NUM
                AND SECAGMTBAL_SEC_NUM = SECRCPT_SECURITY_NUM;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_SEC_CODE := NULL;
         RETURN V_SEC_CODE;
   END;

   RETURN V_SEC_CODE;
END;

/
