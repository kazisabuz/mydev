PKG_GLOBAL
ei "CMN" key diye COMBLK table e rowlock korar (for 100 s) babostha ache ei package e jeta sob program ID theke call hoi almost..
"CMN" akta default key - jodi PANLOCKLOG table e kono program id r jonno key define kora na thake tahole "CMN" key diye 
COMBLK table e rowlock hoi....


PANLOCKLOG table e ideally sob program ID r jonno akta kore row thaka uchit...
akhon emon kono program ID theke transaction hoiteche jar jonno PANLOCKLOG table e kono row define kora nai - 
jar karone "CMN" default key diye rowlock hoiteche...


PANLOCKLOG table e 2 ta column rowlocking (in COMBLK table) korar jonno use hoi....PANLOCKLOG_LOCK_KEY & PANLOCKLOG_BRN_WISE_LOCK_REQD...
.ekhane 1st column er je value thake sei value ke key hisebe dhore COMBLK table e akta row lock kora hoi before doing any transaction..
.akta twist hocche, jodi 2nd column er value "1" hoi, tahole key hisebe 1st column with the branch code - etake key hisebe treat kora hoi...



COMBLK table e "ACCUPDT" or "CORPTFR" (in COMBLK_KEY column with like search) diye kono row thakar kotha na akhon production e...nicher 2 
ta row insert korle COMBLK table e "ACCUPDT<BRANCH_CODE>"/"CORPTFR<BRANCH_CODE>" diye records dhukte thakbe for each of 
the branch that starts to use these two screens...


INSERT INTO PANLOCKLOG
(PANLOCKLOG_PGM_ID, PANLOCKLOG_LOCK_KEY, PANLOCKLOG_LOG_REQD, PANLOCKLOG_ADD_LOG_REQD, PANLOCKLOG_BRN_WISE_LOCK_REQD)
VALUES
('MACCUPDATE', 'ACCUPDT', '1', '0', 1);

INSERT INTO PANLOCKLOG
(PANLOCKLOG_PGM_ID, PANLOCKLOG_LOCK_KEY, PANLOCKLOG_LOG_REQD, PANLOCKLOG_ADD_LOG_REQD, PANLOCKLOG_BRN_WISE_LOCK_REQD)
VALUES
('ECORPTFR', 'CORPTFR', '1', '0', 1);


PANLOCKLOG.PANLOCKLOG_BRN_WISE_LOCK_REQD

ei column er value '1' kore dio for 'MINDCLIENTS' and 'MCORPCLIENTS' program ID (PANLOCKLOG_PGM_ID) r jonno jodi already na kora thake..