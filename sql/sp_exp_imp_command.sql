CREATE OR REPLACE PROCEDURE SP_EXP_IMP_COMMAND(P_schema_number_start number,
                                               P_schema_number_end   number,
                                               v_version_number        number,
																							 P_ENV VARCHAR) IS
  V_COUNT    NUMBER;
  V_SQL      VARCHAR2(100);
  v_export   clob;
  v_brn_name varchar2(100);
  v_test     number;
BEGIN
  FOR LCNTR IN P_schema_number_start .. P_schema_number_end LOOP
    V_SQL := 'SELECT distinct ACNTS_BRN_CODE FROM SONALI_MIG_' || LCNTR ||
             '.MIG_ACNTS ';
    --DBMS_OUTPUT.PUT_LINE (V_SQL ); 
    EXECUTE IMMEDIATE V_SQL
      INTO V_COUNT;
    select mbrn_name
      into v_brn_name
      from sonali_mig_1.mbrn
     where mbrn_code = V_COUNT;
  
    select instr(v_brn_name, ' ') into v_test from dual;
  
    if v_test <> 0 then
      select substr(v_brn_name, 1, instr(v_brn_name, ' ') - 1)
        into v_brn_name
        from dual;
    enD if;
    v_brn_name := upper(trim(v_brn_name));
    --DBMS_OUTPUT.PUT_LINE(v_brn_name);
    v_export := 'expdp SONALI_MIG_' || LCNTR || '/SONALI_MIG_' || LCNTR ||
                ' tables=ACASLL,ACASLLDTL,ACNTBAL,ACNTBBAL,ACNTCBAL,ACNTCBBAL,ACNTCONTRACT,ACNTCVDBBAL,ACNTFRZ,ACNTLINK,ACNTMAIL,temp_sec,ACNTOTN,ACNTS,ACNTLIEN,ACNTSTATUS,ACNTVDBBAL,ADVBAL,ADVBBAL,ADVVDBBAL,ASSETCLS,ASSETCLSHIST,BATCHCOUNTER,CBISS,CLIENTNUM,CLIENTOTN,CLIENTOTNDTL,CLIENTS,CLIENTSBKDTL,CONNPINFO,CORPCLIENTS,DDPOISS,DDPOISSDTL,DDPOISSDTLANX,DDPOPAYDB,DENOMBAL,DENOMDBAL,DEPACCLIEN,depcls,DEPINTPAYMENT,DEPINTPAYMENTDTL,GLBBAL,GLSUM2010,GLSUM2011,GLSUM2012,IACLINK,INDCLIENTS,JOINTCLIENTS,JOINTCLIENTSDTL,LADACNTDTL,lngsacnts,lngsacntdtl,LADACNTS,LIMITLINE,limitlinehist,LIMITSERIAL,LLACNTOS,LLPROD,LNACAODHIST,LNACDISB,LNACDSDTL,LNACDSDTLHIST,LNACGUAR,LNACIR,LNACIRHIST,LNACIRS,LNACIRSHIST,LNACMIS,LNACMISHIST,LNACRS,LNACRSDTL,LNACRSHDTL,LNACRSHIST,LNSUSPBAL,LNSUSPLED,LOANACNTOTN,LOANACNTS,MARGINREC,NOMENTRY,NOMREG,PBCOUNT,PBDCONTDSA,PBDCONTDSAHIST,PBDCONTRACT,PIDDOCS,PROVLED,RDINS,STOPCHQ,STOPLEAF,TDSPI,TDSPIDTL,TRAN2010,TRANADV2010,TRANBAT2010,tranadvaddn2010,TRAN2011,TRANADV2011,TRANBAT2011,tranadvaddn2011,TRAN2012,TRANADV2012,TRANBAT2012,tranadvaddn2012,VAULTBAL,VAULTDBAL,TBILLSERIAL,INVSPDOCIMG,CLAMIMAGE,spdocimage,SECRCPT,SECASSIGNMENTS,SECASSIGNMTDTL,SECASSIGNMTBAL,SECASSIGNMTDBAL,SECMORTGAGE,SECMORTEC,SECINVEST,SECVEHICLE,SECCLIENT,SECSHARES,SECSHARESDTL,SECINSUR,SECSTKBKDB,SECSTKBKDBDTL,SECSTKBKDT,SECSTKBKDTDTL,LNDP,LNDPHIST,LIMFACCURR,LIMITLINEAUX,LOANACHIST,LOANACHISTDTL,LOANACDTL,LIMITLINECTREQ,LNSUBVENRECV,LNACSUBSIDY,LNACIRDTL,LNACIRHDTL,addrdtls,PBDCONTTRFOD,TDSREMITGOV,HOVERING,HOVERRECBRK,amlacturnover,hoverseq,ecsacmap,LADDEPLINK,LADDEPLINKHIST,LADDEPLINKHISTDTL,LNGOVTSEC,SECVAL,LOCKERAVL,LOCKERAVLHIST,LOCKERAM,LOCKERCHGSHIST,LOCKERACCHIST,LOCKERACC,LOCKERKEYHIST,LOCKERKEY,LOCKERDTLS,LOCKERRENT,LOCKERSTAT,LOCKERSTATHIST,ACSEQGEN,DEPRCPTPRNT,LEGALNOTICE,LEGALSTAT,LEGALACTION,LNACINTCTL,LNACINTCTLHIST,ITFORMS,CLIENTMEM,MEMNUM,DEPCLIENTNOMMEM,NOMINALMEMNUM,LNNOMINALMEM,LNNOMINALMEMDTL,ACNTOTN,ACNTOTNNEW,LNACCHGS,LNACCHGSQBAL,LNACCHGSQLED,VAULTDBAL,DENOMDBAL,LNACINTARHIST,LNACINTARDTL,LNACINTARHDTL,LNACINTAR,LNTOTINTDBMIG,SMSBREG,SMSBREGDTL,SMSBREGSVC,ivracnts,,IBS_AC_BAL,MIG_LDR,MIG_TDS,MIG_FWD,MIG_RD,IBS_GL_BAL,IBS_NOMENTRY,MIG_DP,MIG_PDISB,MIG_FWDCFINT,MIG_SBACCR,MIG_CLIENT_ACCESS,MIG_ACNTS_ACCESS,MIG_DEP_ACCESS,MIG_CLIENTSBKDTL_ACCESS,MIG_CLNT_KYCACC,MIG_JOINTCLIENTSDTL_ACCESS,MIG_JOINTCLIENTS_ACCESS,MIG_OVERDUE_DETAILS,MIG_CP,MIG_OBC,MIG_IBC,MIG_SCH_MAST,MIG_TL_MAST,MIG_INT_MAST,MIG_CHEQ_BK,MIG_CHEQSTOP,MIG_CUMUSUB,MIG_NPARPT,MIG_BANK,MIG_BR_PARA,MIG_AC_MAST_NEW,MIG_D_MAST_NEW,MIG_LNRPST,TEMP_CLIENT,DEPIA,LOANIA,SBCAIA,LOANIADTL,SBCAIABRK,ACBALASONHIST,GLSUM2013,TRAN2013,TRANADV2013,TRANBAT2013,tranadvaddn2013,TRANADV2015,GLSUM2015,TRAN2015,TRANADV2015,TRANBAT2015,tranadvaddn2015,ACBALASONHIST_MAX,ACBALASONHIST_AVGBAL,NOMREGDTL,ACBALASONHIST_MIN,SNDPROD,MMB_ACNTS,ddadvpart,ddadvpartdtl,loaniamrr,loaniamrrdtl,blloania,LNWRTOFF,lnwrtoffrecov directory=DUMPDIR_MIG dumpfile=SONALI_MIG_' ||
                LCNTR || '_' || V_COUNT || '_' || v_brn_name || '_v' ||
                v_version_number || '.DMP logfile=EXP_SONALI_MIG_' || LCNTR || '_' ||
                V_COUNT || '_' || v_brn_name || '_v' || v_version_number ||
                '.log';
  
	  --host(v_export) ;
    DBMS_OUTPUT.PUT_LINE(v_export);
    DBMS_OUTPUT.PUT_LINE(chr(13));
  
  -- scp SONALI_MIG_9_23218_MONIRUMPUR_JESSORE_V3.DMP oracle@10.40.40.33:/rman/sblcbs/dumpdir/
  
  /*V_SQL :=
         'SELECT COUNT(*) FROM SONALI_MIG_' || LCNTR || '.MIG_SIGNATURE ';
      EXECUTE IMMEDIATE V_SQL INTO V_COUNT;
      DBMS_OUTPUT.PUT_LINE ('SONALI_MIG_'||LCNTR||'='|| V_COUNT);*/
  END LOOP;

  FOR LCNTR IN P_schema_number_start .. P_schema_number_end LOOP
    V_SQL := 'SELECT distinct ACNTS_BRN_CODE FROM SONALI_MIG_' || LCNTR ||
             '.MIG_ACNTS ';
    --DBMS_OUTPUT.PUT_LINE (V_SQL ); 
    EXECUTE IMMEDIATE V_SQL
      INTO V_COUNT;
    select mbrn_name
      into v_brn_name
      from sonali_mig_1.mbrn
     where mbrn_code = V_COUNT;
  
    select instr(v_brn_name, ' ') into v_test from dual;
  
    if v_test <> 0 then
      select substr(v_brn_name, 1, instr(v_brn_name, ' ') - 1)
        into v_brn_name
        from dual;
    enD if;
    v_brn_name := upper(trim(v_brn_name));
    --DBMS_OUTPUT.PUT_LINE(v_brn_name);
  
    v_export := 'scp SONALI_MIG_' || LCNTR || '_' || V_COUNT || '_' ||
                v_brn_name || '_v' || v_version_number || '.DMP' ||
                ' oracle@10.40.40.33:/rman/sblcbs/dumpdir/';
    DBMS_OUTPUT.PUT_LINE(v_export);
  
  -- scp SONALI_MIG_9_23218_MONIRUMPUR_JESSORE_V3.DMP oracle@10.40.40.33:/rman/sblcbs/dumpdir/
  
  /*V_SQL :=
         'SELECT COUNT(*) FROM SONALI_MIG_' || LCNTR || '.MIG_SIGNATURE ';
      EXECUTE IMMEDIATE V_SQL INTO V_COUNT;
      DBMS_OUTPUT.PUT_LINE ('SONALI_MIG_'||LCNTR||'='|| V_COUNT);*/
  END LOOP;

  FOR LCNTR IN P_schema_number_start .. P_schema_number_end LOOP
    V_SQL := 'SELECT distinct ACNTS_BRN_CODE FROM SONALI_MIG_' || LCNTR ||
             '.MIG_ACNTS ';
    EXECUTE IMMEDIATE V_SQL
      INTO V_COUNT;
    select mbrn_name
      into v_brn_name
      from sonali_mig_1.mbrn
     where mbrn_code = V_COUNT;
  
    select instr(v_brn_name, ' ') into v_test from dual;
  
    if v_test <> 0 then
      select substr(v_brn_name, 1, instr(v_brn_name, ' ') - 1)
        into v_brn_name
        from dual;
    enD if;
    v_brn_name := upper(trim(v_brn_name));
  
    -- host(impdp SBLPROD/*password* directory=DUMPDIR dumpfile=SONALI_MIG_9_23218_MONIRUMPUR_JESSORE_V3.DMP logfile=IMP_SONALI_MIG_9_23218_MONIRUMPUR_JESSORE_
    --V3.LOG remap_schema=SONALI_MIG_9:SBLPROD transform=oid:n IGNORE='Y')
   DBMS_OUTPUT.PUT_LINE(chr(10));
	 
	 IF P_ENV = 'P' THEN 
    v_export := 'host(impdp SBLPROD/*password* directory=DUMPDIR dumpfile=SONALI_MIG_' ||
                LCNTR || '_' || V_COUNT || '_' || v_brn_name || '_v' ||
                v_version_number || '.DMP logfile=IMP_SONALI_MIG_' || LCNTR|| '_' || V_COUNT || '_' || v_brn_name || '_v' ||
                v_version_number || '.LOG remap_schema=SONALI_MIG_' || LCNTR ||':SBLPROD transform=oid:n IGNORE=''Y'')';
    DBMS_OUTPUT.PUT_LINE(v_export);
   END IF ;
	 
	 IF P_ENV = 'U' THEN 
    v_export := 'host(impdp SBL010715AFTHE/SBL010715AFTHE directory=DUMPDIR_MIG dumpfile=SONALI_MIG_' ||
                LCNTR || '_' || V_COUNT || '_' || v_brn_name || '_v' ||
                v_version_number || '.DMP logfile=IMP_SONALI_MIG_' || LCNTR|| '_' || V_COUNT || '_' || v_brn_name || '_v' ||
                v_version_number || '.LOG remap_schema=SONALI_MIG_' || LCNTR ||':SBL010715AFTHE transform=oid:n IGNORE=''Y'')';
    DBMS_OUTPUT.PUT_LINE(v_export);
   END IF ;
  
  END LOOP;

END;
