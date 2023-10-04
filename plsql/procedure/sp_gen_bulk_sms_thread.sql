CREATE OR REPLACE PROCEDURE  SP_GEN_BULK_SMS_THREAD(p_ason_date DATE) is 
  LN_DUMMY NUMBER;
BEGIN
   
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',1,100 ); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',101,200); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',201,300); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',301,400); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',401,500); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',501,600); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',601,700); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',701,800); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',801,900); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',901,1000); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',1001,1100); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',1101,1200); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',1201,1300); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_BULK_SMS_DATA(1,'''||p_ason_date||''',1301,1400); end;',instance=>2);
  COMMIT;
END SP_GEN_BULK_SMS_THREAD;
/
