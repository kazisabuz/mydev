EDIT DEPACCLIEN  WHERE   DEPACLIEN_DEP_AC_NUM IN (11508100040489);-- DELETE ROW 

EDIT ACNTLIEN   WHERE  ACNTLIEN_INTERNAL_ACNUM IN (11508100040489);-- DELETE ROW 

EDIT LADDEPLINK   WHERE  LADDEPLNK_INTERNAL_ACNUM IN (11508100040489); -- IF GIVEN LOAN ACC DELETE ROW 


EDIT ACNTBAL   WHERE  ACNTBAL_INTERNAL_ACNUM IN (11717800022359) and ACNTBAL_ENTITY_NUM=1;-- UPDATE AC_LIEN AMOUNT/ BC DO ZERO 


EDIT ACNTCBAL  WHERE ACNTCBAL_INTERNAL_ACNUM IN (11717800022359); -- UPDATE AC_LIEN AMOUNT/ BC DO ZERO 
 
 
ACNTLIEN, --lien mark and revoved
LADDEPLINK,---lien acc rate margin
LADACNTDTL, --loan agaist deposit
LADACNTS, --loan agaist deposit with rate 
DEPACCLIEN,--when lien with scheme account
DEPACLIENREV --when reverse lien then insert


ACNTBAL-- lien amount   update
ACNTCBAL --lien amount update for contract based acc