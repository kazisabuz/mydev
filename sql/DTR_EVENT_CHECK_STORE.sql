/*Triger to control the unwanted occurances in the production server even in UAT server. Someone might commit development script in deployment script which has some truncate or drop statement which might distroy the production/UAT server. This triger will protect the database from any unwanted truncate or drop.*/
CREATE OR REPLACE TRIGGER DTR_EVENT_CHECK_STORE
   BEFORE DROP OR TRUNCATE ON SCHEMA
DECLARE
   V_OBJNAME   VARCHAR2 (50);
   V_OBJECT_TYPE VARCHAR2(30);
   V_EVENT     VARCHAR2 (30);
   V_OBJECT_COUNT NUMBER(5);
BEGIN
   SELECT ORA_DICT_OBJ_NAME, ORA_DICT_OBJ_TYPE, ORA_SYSEVENT
     INTO V_OBJNAME, V_OBJECT_TYPE, V_EVENT
     FROM DUAL;
     
     IF V_EVENT IN ('DROP','TRUNCATE') AND V_OBJECT_TYPE IN ('TABLE') THEN 
        IF V_EVENT='DROP' THEN 
            BEGIN
                SELECT COUNT(OBJECT_NAME) 
                INTO V_OBJECT_COUNT
                FROM OBJECT_EVENT_ALLOWED
                WHERE UPPER(OBJECT_NAME)=UPPER(V_OBJNAME)
                AND DROP_ALLOWED='Y';
            END;
        END IF;

        IF V_EVENT='TRUNCATE' THEN 
            BEGIN
                SELECT COUNT(OBJECT_NAME) 
                INTO V_OBJECT_COUNT
                FROM OBJECT_EVENT_ALLOWED
                WHERE UPPER(OBJECT_NAME)=UPPER(V_OBJNAME)
                AND TRUNCATE_ALLOWED='Y';
            END;
        END IF;
        
         IF V_OBJECT_COUNT=0 THEN
                RAISE_APPLICATION_ERROR(-20099, V_EVENT||' Not allowed in '||V_OBJNAME|| ' '||V_OBJECT_TYPE);
           ELSE
                BEGIN
                    INSERT INTO ORA_EVENT_LOG( OBJECT_NAME, EVENT, OWNER) VALUES (V_OBJNAME, ORA_SYSEVENT, USER);
                  EXCEPTION
                        WHEN OTHERS THEN 
                        NULL;
                END;
         END IF; 
        
     END IF;

END DTR_EVENT_CHECK_STORE;