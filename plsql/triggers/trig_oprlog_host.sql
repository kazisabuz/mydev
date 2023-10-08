CREATE OR REPLACE TRIGGER TRIG_OPRLOG_HOST
   BEFORE INSERT
   ON OPRLOG
   FOR EACH ROW
DECLARE
   V_LOGIN_USER          VARCHAR2 (1000);
   V_INSTANCE_NUM        VARCHAR2 (1000);
   V_CLIENT_IP_ADDRESS   VARCHAR2 (1000);
   V_CURRENT_SCN         VARCHAR2 (1000);
   V_OS_USER             VARCHAR2 (1000);
   V_TERMINAL            VARCHAR2 (1000);
   V_IP_ADDRESS          VARCHAR2 (1000);
   V_SID                 VARCHAR2 (1000);
   V_SERIAL              VARCHAR2 (1000);
   V_LOGON_TIME          DATE;
BEGIN
   V_LOGIN_USER := ORA_LOGIN_USER;
   V_INSTANCE_NUM := ORA_INSTANCE_NUM;
   V_OS_USER := SYS_CONTEXT ('USERENV', 'OS_USER');
   V_IP_ADDRESS := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
   V_SID := SYS_CONTEXT ('USERENV', 'SID');

   SELECT SERIAL#, LOGON_TIME, MACHINE
     INTO V_SERIAL, V_LOGON_TIME, V_TERMINAL
     FROM GV$SESSION
    WHERE SID = SYS_CONTEXT ('USERENV', 'SID') AND INST_ID = ORA_INSTANCE_NUM;

   INSERT INTO OPRLOG_HOST (CT_LOGIN_USER,
                            CT_INSTANCE_NUM,
                            CT_OS_USER,
                            CT_TERMINAL,
                            CT_IP_ADDRESS,
                            CT_SID,
                            CT_SERIAL,
                            CT_SYSTIMESTAMP,
                            CT_LOGON_TIME,
                            OPRLOG_ENTITY_NUM,
                            OPRLOG_BRN_CODE,
                            OPRLOG_USER_ID,
                            OPRLOG_FORM_NAME,
                            OPRLOG_OPR_SL,
                            OPRLOG_IN_TIME,
                            OPRLOG_IP_ADDRESS)
        VALUES (V_LOGIN_USER,
                V_INSTANCE_NUM,
                V_OS_USER,
                V_TERMINAL,
                V_IP_ADDRESS,
                V_SID,
                V_SERIAL,
                SYSTIMESTAMP,
                V_LOGON_TIME,
                :NEW.OPRLOG_ENTITY_NUM,
                :NEW.OPRLOG_BRN_CODE,
                :NEW.OPRLOG_USER_ID,
                :NEW.OPRLOG_FORM_NAME,
                :NEW.OPRLOG_OPR_SL,
                :NEW.OPRLOG_IN_TIME,
                :NEW.OPRLOG_IP_ADDRESS);
  EXCEPTION
        WHEN OTHERS THEN
        NULL;
END;
/
