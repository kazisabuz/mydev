/*This script will take the dump backup for some particular tables of a particular schema. Again, the impdp command will import the dump file to a schema.*/

expdp SONALI_21DEC/###password### tables = MIG_CLIENTS, MIG_CONNPINFO, MIG_PIDDOCS, MIG_ACNTS, MIG_ACNTLIEN, MIG_PBDCONTRACT, MIG_DEPIA, MIG_RDINS, MIG_ASSETCLS, MIG_LNACDSDTL, MIG_LNACGUAR, MIG_LNACIRS, MIG_LNACNT, MIG_LNACRSDTL, MIG_LNSUSP, MIG_ACOP_BAL, MIG_GLOP_BAL, MIG_MAXBAL, MIG_MINBAL, MIG_AVGBAL, MIG_CHEQUE, MIG_STOPCHQ, MIG_DDPO, TEMP_LOANIA, TEMP_SBCAIA, MIG_NOMREG, MIG_LNTOTINTDBMIG directory=DUMPDIR dumpfile=SONALI_21DEC_MIG.dmp logfile=EXP_SONALI_21DEC_MIG.log



host(impdp SONALI_MIG_1/###password### directory=DUMPDIR_MIG dumpfile=SONALI_21DEC_MIG.DMP logfile=IMP_SONALI_21DEC_MIG.LOG remap_schema=SONALI_21DEC:SONALI_MIG_1 transform=oid:n IGNORE='Y')