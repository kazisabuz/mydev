update acnts a set A.ACNTS_CLOSURE_DATE='18-mar-2021'
where ACNTS_ENTITY_NUM=1
and  A.ACNTS_INTERNAL_ACNUM in 
(select I.IACLINK_INTERNAL_ACNUM 
from iaclink i,acntbal
 where  IACLINK_INTERNAL_ACNUM=ACNTBAL_INTERNAL_ACNUM
 and IACLINK_ENTITY_NUM=1
 and ACNTBAL_ENTITY_NUM=1
 and ACNTBAL_BC_CUR_DB_SUM=0
 and ACNTBAL_BC_CUR_CR_SUM=0
 and I.IACLINK_ACTUAL_ACNUM in ('3021348000048',
'3021366000008',
'3021362004246',
'3021362004366',
'3021362004104',
'3021362003958',
'3021362003680',
'3021362003456',
'3021362003474',
'3021362003269',
'3021362003666',
'3021362003294',
'3021362003141',
'3021362003201',
'3021362003126',
'3021362003105',
'3021343000001',
'3021362002822',
'3021362002589',
'3021343000120',
'3021362002505',
'3021362002411',
'3021363001469',
'3021362002271',
'3021362002363',
'3021362002124',
'3021362001939',
'3021362001910',
'3021362001889'

))