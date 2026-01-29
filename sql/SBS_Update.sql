/*Reporting code update after migration.*/

select t.br_code,
       t.sector,
       c.clients_code,
       (SELECT OCCUPATIONS_CODE
          FROM OCCUPATIONS
         WHERE OCCUPATIONS_DESCN = NVL(t.OCCUPATION, 'OTHER')) OCCUPTION
  from temp_deposit t, iaclink i, clients c
 where i.iaclink_actual_acnum = t.ac_number
   and c.clients_code = i.iaclink_cif_number
   
   
   

BEGIN
  FOR I IN (select t.br_code,
                   t.sector,
                   c.clients_code,
                   (SELECT OCCUPATIONS_CODE
                      FROM OCCUPATIONS
                     WHERE OCCUPATIONS_DESCN = NVL(t.OCCUPATION, 'OTHER')) OCCUPTION
              from temp_deposit t, iaclink i, clients c
             where i.iaclink_actual_acnum = t.ac_number
               and c.clients_code = i.iaclink_cif_number) LOOP
  
    UPDATE CLIENTS
       SET CLIENTS_SEGMENT_CODE = I.SECTOR
     WHERE CLIENTS_CODE = I.CLIENTS_CODE;
  
    UPDATE INDCLIENTS
       SET INDCLIENT_OCCUPN_CODE = I.OCCUPTION
     WHERE INDCLIENT_CODE = I.CLIENTS_CODE;
  
  END LOOP;
END;



SELECT IA.IACLINK_INTERNAL_ACNUM, AC.ACNTS_CLIENT_NUM, SECTOR,
(SELECT OCCUPATIONS_CODE FROM OCCUPATIONS
WHERE OCCUPATIONS_DESCN=NVL(DA.OCCUPATION,'OTHER')) OCCUPTION,SME,PURPOSE,SECURITY,SUBINDUS_CODE
FROM DEPOSIT_DATA_UPDATE_ADV DA, IACLINK IA, ACNTS AC, SUBINDUSTRIES SI
WHERE IA.IACLINK_ACTUAL_ACNUM= DA.AC_NUMBER
AND IA.IACLINK_INTERNAL_ACNUM=AC.ACNTS_INTERNAL_ACNUM
AND SI.SUBINDUS_SUB_CODE=DA.PURPOSE;

-- Update statement for Advance data

BEGIN
  FOR I IN (SELECT IA.IACLINK_INTERNAL_ACNUM,
                   AC.ACNTS_CLIENT_NUM,
                   SECTOR,
                   (SELECT OCCUPATIONS_CODE
                      FROM OCCUPATIONS
                     WHERE OCCUPATIONS_DESCN = NVL(DA.OCCUPATION, 'OTHER')) OCCUPTION,
                   SME,
                   PURPOSE,
                   SECURITY,
                   SUBINDUS_CODE
              FROM DEPOSIT_DATA_UPDATE_ADV DA,
                   IACLINK                 IA,
                   ACNTS                   AC,
                   SUBINDUSTRIES           SI
             WHERE  IA.IACLINK_ACTUAL_ACNUM  = lpad(DA.AC_NUMBER,13,'0')
               AND IA.IACLINK_INTERNAL_ACNUM = AC.ACNTS_INTERNAL_ACNUM
               AND SI.SUBINDUS_SUB_CODE = DA.PURPOSE) LOOP
  
    UPDATE INDCLIENTS
       SET INDCLIENT_OCCUPN_CODE = I.OCCUPTION
     WHERE INDCLIENT_CODE = I.ACNTS_CLIENT_NUM;
  
    UPDATE CLIENTS
       SET CLIENTS_SEGMENT_CODE = I.SECTOR
     WHERE CLIENTS_CODE = I.ACNTS_CLIENT_NUM;
  
    UPDATE LNACMISHIST
       SET LNACMISH_SEGMENT_CODE       = I.SECTOR,
           LNACMISH_NATURE_BORROWAL_AC = I.SME,
           LNACMISH_SUB_INDUS_CODE     = I.PURPOSE,
           LNACMISH_INDUS_CODE         = I.SUBINDUS_CODE
     WHERE LNACMISH_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM;
  
    UPDATE LNACMIS
       SET LNACMIS_SEGMENT_CODE       = I.SECTOR,
           LNACMIS_NATURE_BORROWAL_AC = I.SME,
           LNACMIS_SUB_INDUS_CODE     = I.PURPOSE,
           LNACMIS_INDUS_CODE         = I.SUBINDUS_CODE
     WHERE LNACMIS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM;
  
  END LOOP;
END;
