-- BEFORE IMPORTING THE PANACEA TABLES DUMP FOR THE FIRST BRANCH ALONE THE FOLLOWING SCRIPT HAS TO BE EXECUTED TO CLEAN ALL THE CORE TABLES EXCEPT MASTERS & PARAMETERS.
-- DOCUMENT UPDATED BY RAMESH M ON 14-FEB-2012;
-- TOTAL NO.OF TABLES : 198
-- LAST FILE CHECKED IN : 22/MAR/13 ; LAST UPDATED DATE : 23/03/13.

TRUNCATE TABLE RDFRZ							                ;
TRUNCATE TABLE AMLACNTCL                          ;
TRUNCATE TABLE AMLACSOPENSUMM                     ;
TRUNCATE TABLE AMLACDORMINOP                      ;
TRUNCATE TABLE IBRADVICES                         ;
TRUNCATE TABLE TRANSTLMNT                         ;
TRUNCATE TABLE ACBALASONHIST                      ;
TRUNCATE TABLE GLBALASONHIST                      ;
TRUNCATE TABLE LNOD                               ;
TRUNCATE TABLE LNODHIST                           ;
TRUNCATE TABLE ACASLL                             ;
TRUNCATE TABLE ACASLLDTL                          ;
TRUNCATE TABLE ACNTBAL                            ;
TRUNCATE TABLE ACNTBBAL                           ;
TRUNCATE TABLE ACNTCBAL                           ;
TRUNCATE TABLE ACNTCBBAL                          ;
TRUNCATE TABLE ACNTCONTRACT                       ;
TRUNCATE TABLE ACNTCVDBBAL                        ;
TRUNCATE TABLE ACNTFRZ                            ;
TRUNCATE TABLE ACNTLINK                           ;
TRUNCATE TABLE ACNTMAIL                           ;
TRUNCATE TABLE TEMP_SEC                           ;
TRUNCATE TABLE ACNTOTN                            ;
TRUNCATE TABLE ACNTS                              ;
TRUNCATE TABLE ACNTLIEN                           ;
TRUNCATE TABLE ACNTSTATUS                         ;
TRUNCATE TABLE ACNTVDBBAL                         ;
TRUNCATE TABLE ADVBAL                             ;
TRUNCATE TABLE ADVBBAL                            ;
TRUNCATE TABLE ADVVDBBAL                          ;
TRUNCATE TABLE ASSETCLS                           ;
TRUNCATE TABLE ASSETCLSHIST                       ;
TRUNCATE TABLE BATCHCOUNTER                       ;
TRUNCATE TABLE CBISS                              ;
TRUNCATE TABLE CLIENTNUM                          ;
TRUNCATE TABLE CLIENTOTN                          ;
TRUNCATE TABLE CLIENTOTNDTL                       ;
TRUNCATE TABLE CLIENTS                            ;
TRUNCATE TABLE CLIENTSBKDTL                       ;
TRUNCATE TABLE CONNPINFO                          ;
TRUNCATE TABLE CORPCLIENTS                        ;
TRUNCATE TABLE DDPOISS                            ;
TRUNCATE TABLE DDPOISSDTL                         ;
TRUNCATE TABLE DDPOISSDTLANX                      ;
TRUNCATE TABLE DDPOPAYDB                          ;
TRUNCATE TABLE DENOMBAL                           ;
TRUNCATE TABLE DENOMDBAL                          ;
TRUNCATE TABLE DEPACCLIEN                         ;
TRUNCATE TABLE DEPIA                              ;
TRUNCATE TABLE DEPCLS                             ;
TRUNCATE TABLE DEPINTPAYMENT                      ;
TRUNCATE TABLE DEPINTPAYMENTDTL                   ;
TRUNCATE TABLE GLBBAL                             ;
TRUNCATE TABLE GLSUM2010                          ;
TRUNCATE TABLE GLSUM2011                          ;
TRUNCATE TABLE GLSUM2012                          ;
TRUNCATE TABLE GLSUM2013                          ;
TRUNCATE TABLE IACLINK                            ;
TRUNCATE TABLE INDCLIENTS                         ;
TRUNCATE TABLE JOINTCLIENTS                       ;
TRUNCATE TABLE JOINTCLIENTSDTL                    ;
TRUNCATE TABLE LADACNTDTL                         ;
TRUNCATE TABLE LNGSACNTS                          ;
TRUNCATE TABLE LNGSACNTDTL                        ;
TRUNCATE TABLE LADACNTS                           ;
TRUNCATE TABLE LIMITLINE                          ;
TRUNCATE TABLE LIMITLINEHIST                      ;
TRUNCATE TABLE LIMITSERIAL                        ;
TRUNCATE TABLE LLACNTOS                           ;
TRUNCATE TABLE LLPROD                             ;
TRUNCATE TABLE LNACAODHIST                        ;
TRUNCATE TABLE LNACDISB                           ;
TRUNCATE TABLE LNACDSDTL                          ;
TRUNCATE TABLE LNACDSDTLHIST                      ;
TRUNCATE TABLE LNACGUAR                           ;
TRUNCATE TABLE LNACIR                             ;
TRUNCATE TABLE LNACIRHIST                         ;
TRUNCATE TABLE LNACIRS                            ;
TRUNCATE TABLE LNACIRSHIST                        ;
TRUNCATE TABLE LNACMIS                            ;
TRUNCATE TABLE LNACMISHIST                        ;
TRUNCATE TABLE LNACRS                             ;
TRUNCATE TABLE LNACRSDTL                          ;
TRUNCATE TABLE LNACRSHDTL                         ;
TRUNCATE TABLE LNACRSHIST                         ;
TRUNCATE TABLE LNSUSPBAL                          ;
TRUNCATE TABLE LNSUSPLED                          ;
TRUNCATE TABLE LOANACNTOTN                        ;
TRUNCATE TABLE LOANACNTS                          ;
TRUNCATE TABLE MARGINREC                          ;
TRUNCATE TABLE NOMENTRY                           ;
TRUNCATE TABLE NOMREG                             ;
--TRUNCATE TABLE PBCOUNT                            ;
TRUNCATE TABLE PBDCONTDSA                         ;
TRUNCATE TABLE PBDCONTDSAHIST                     ;
TRUNCATE TABLE PBDCONTRACT                        ;
TRUNCATE TABLE PIDDOCS                            ;
TRUNCATE TABLE PROVLED                            ;
TRUNCATE TABLE RDINS                              ;
TRUNCATE TABLE STOPCHQ                            ;
TRUNCATE TABLE STOPLEAF                           ;
TRUNCATE TABLE TDSPI                              ;
TRUNCATE TABLE TDSPIDTL                           ;
TRUNCATE TABLE TRAN2010                           ;
TRUNCATE TABLE TRANADV2010                        ;
TRUNCATE TABLE TRANBAT2010                        ;
TRUNCATE TABLE TRANADVADDN2010                    ;
TRUNCATE TABLE TRAN2011                           ;
TRUNCATE TABLE TRANADV2011                        ;
TRUNCATE TABLE TRANBAT2011                        ;
TRUNCATE TABLE TRANADVADDN2011                    ;
TRUNCATE TABLE TRAN2012                           ;
TRUNCATE TABLE TRANADV2012                        ;
TRUNCATE TABLE TRANBAT2012                        ;
TRUNCATE TABLE TRANADVADDN2012                    ;
TRUNCATE TABLE VAULTBAL                           ;
TRUNCATE TABLE VAULTDBAL                          ;
TRUNCATE TABLE TBILLSERIAL                        ;
TRUNCATE TABLE INVSPDOCIMG                        ;
TRUNCATE TABLE CLAMIMAGE                          ;
TRUNCATE TABLE SPDOCIMAGE                         ;
TRUNCATE TABLE SECRCPT                            ;
TRUNCATE TABLE SECASSIGNMENTS                     ;
TRUNCATE TABLE SECASSIGNMTDTL                     ;
TRUNCATE TABLE SECASSIGNMTBAL                     ;
TRUNCATE TABLE SECASSIGNMTDBAL                    ;
TRUNCATE TABLE SECMORTGAGE                        ;
TRUNCATE TABLE SECMORTEC                          ;
TRUNCATE TABLE SECINVEST                          ;
TRUNCATE TABLE SECVEHICLE                         ;
TRUNCATE TABLE SECCLIENT                          ;
TRUNCATE TABLE SECSHARES                          ;
TRUNCATE TABLE SECSHARESDTL                       ;
TRUNCATE TABLE SECINSUR                           ;
TRUNCATE TABLE SECSTKBKDB                         ;
TRUNCATE TABLE SECSTKBKDBDTL                      ;
TRUNCATE TABLE SECSTKBKDT                         ;
TRUNCATE TABLE SECSTKBKDTDTL                      ;
TRUNCATE TABLE LNDP                               ;
TRUNCATE TABLE LNDPHIST                           ;
TRUNCATE TABLE LIMFACCURR                         ;
TRUNCATE TABLE LIMITLINEAUX                       ;
TRUNCATE TABLE LOANACHIST                         ;
TRUNCATE TABLE LOANACHISTDTL                      ;
TRUNCATE TABLE LOANACDTL                          ;
TRUNCATE TABLE LIMITLINECTREQ                     ;
TRUNCATE TABLE LNSUBVENRECV                       ;
TRUNCATE TABLE LNACSUBSIDY                        ;
TRUNCATE TABLE LNACIRDTL                          ;
TRUNCATE TABLE LNACIRHDTL                         ;
TRUNCATE TABLE ADDRDTLS                           ;
TRUNCATE TABLE PBDCONTTRFOD                       ;
TRUNCATE TABLE TDSREMITGOV                        ;
TRUNCATE TABLE HOVERING                           ;
TRUNCATE TABLE HOVERRECBRK                        ;
TRUNCATE TABLE AMLACTURNOVER                      ;
TRUNCATE TABLE HOVERSEQ                           ;
TRUNCATE TABLE ECSACMAP                           ;
TRUNCATE TABLE LADDEPLINK                         ;
TRUNCATE TABLE LADDEPLINKHIST                     ;
TRUNCATE TABLE LADDEPLINKHISTDTL                  ;
TRUNCATE TABLE LNGOVTSEC                          ;
TRUNCATE TABLE SECVAL                             ;
TRUNCATE TABLE LOCKERAVL                          ;
TRUNCATE TABLE LOCKERAVLHIST                      ;
TRUNCATE TABLE LOCKERAM                           ;
TRUNCATE TABLE LOCKERCHGSHIST                     ;
TRUNCATE TABLE LOCKERACCHIST                      ;
TRUNCATE TABLE LOCKERACC                          ;
TRUNCATE TABLE LOCKERKEYHIST                      ;
TRUNCATE TABLE LOCKERKEY                          ;
TRUNCATE TABLE LOCKERDTLS                         ;
TRUNCATE TABLE LOCKERRENT                         ;
TRUNCATE TABLE LOCKERSTAT                         ;
TRUNCATE TABLE LOCKERSTATHIST                     ;
TRUNCATE TABLE ACSEQGEN                           ;
TRUNCATE TABLE DEPRCPTPRNT                        ;
TRUNCATE TABLE LEGALNOTICE                        ;
TRUNCATE TABLE LEGALSTAT                          ;
TRUNCATE TABLE LEGALACTION                        ;
TRUNCATE TABLE LNACINTCTL                         ;
TRUNCATE TABLE LNACINTCTLHIST                     ;
TRUNCATE TABLE ITFORMS                            ;
TRUNCATE TABLE CLIENTMEM                          ;
TRUNCATE TABLE MEMNUM                             ;
TRUNCATE TABLE DEPCLIENTNOMMEM                    ;
TRUNCATE TABLE NOMINALMEMNUM                      ;
TRUNCATE TABLE LNNOMINALMEM                       ;
TRUNCATE TABLE LNNOMINALMEMDTL                    ;
TRUNCATE TABLE ACNTOTNNEW                         ;
TRUNCATE TABLE LNACCHGS                           ;
TRUNCATE TABLE LNACCHGSQBAL                       ;
TRUNCATE TABLE LNACCHGSQLED                       ;
TRUNCATE TABLE LNACINTARHIST                      ;
TRUNCATE TABLE LNACINTARDTL                       ;
TRUNCATE TABLE LNACINTARHDTL                      ;
TRUNCATE TABLE LNACINTAR                          ;
TRUNCATE TABLE LNTOTINTDBMIG                      ;
TRUNCATE TABLE SMSBREG                            ;
TRUNCATE TABLE SMSBREGDTL                         ;
TRUNCATE TABLE SMSBREGSVC                         ;
TRUNCATE TABLE IVRACNTS                           ;
TRUNCATE TABLE GLSUM2013                          ;
TRUNCATE TABLE TRAN2013                           ;
TRUNCATE TABLE TRANADV2013                        ;
TRUNCATE TABLE TRANBAT2013                        ;
TRUNCATE TABLE TRANADVADDN2013                    ;
TRUNCATE TABLE CTRAN2013                          ;
TRUNCATE TABLE LOANIA                             ;
TRUNCATE TABLE ACBALASONHIST_MAX                  ;
TRUNCATE TABLE ACBALASONHIST_AVGBAL               ;
TRUNCATE TABLE NOMREGDTL                          ;
TRUNCATE TABLE NOMREG                             ;
TRUNCATE TABLE LOANIADTL                          ;
TRUNCATE TABLE TEMP_CLIENT                        ;
TRUNCATE TABLE ACNTSEXCISEBONUS                   ;
TRUNCATE TABLE ACGENPM                            ;
TRUNCATE TABLE ACGENPMDTL                         ;
TRUNCATE TABLE ACBALASONHIST_MIN                  ;
-- NEWLY ADDED                                    ;
TRUNCATE TABLE CASHRP                             ;
--SHOULD BE TRUNCATED                             ;
TRUNCATE TABLE CLIENTDEDUP                        ;
TRUNCATE TABLE CLIENTS_TIN                        ;
TRUNCATE TABLE GRPCLIENTSDTLHIST                  ;
TRUNCATE TABLE GRPCLIENTSEXPDTL                   ;
TRUNCATE TABLE UDEFADDNFLDS                       ;
TRUNCATE TABLE DEPARHIST                          ;
                                                 
                                                  
TRUNCATE TABLE DDADVPART                          ;
TRUNCATE TABLE DDADVPARTDTL                       ;
                                                  
TRUNCATE TABLE SNDPROD                            ;
TRUNCATE TABLE MMB_ACNTS                          ;
                                                  
TRUNCATE TABLE TRAN2014                           ;
TRUNCATE TABLE GLSUM2014                          ;
TRUNCATE TABLE TRAN2014                           ;
TRUNCATE TABLE TRANADV2014                        ;
TRUNCATE TABLE TRANBAT2014                        ;
TRUNCATE TABLE TRANADVADDN2014                    ;
                                                  
TRUNCATE TABLE TRAN2015                           ;
TRUNCATE TABLE GLSUM2015                          ;
TRUNCATE TABLE TRAN2015                           ;
TRUNCATE TABLE TRANADV2015                        ;
TRUNCATE TABLE TRANBAT2015                        ;
TRUNCATE TABLE TRANADVADDN2015                    ;
TRUNCATE TABLE CTRAN2015                          ;

TRUNCATE TABLE TRAN2016                           ;
TRUNCATE TABLE GLSUM2016                          ;
TRUNCATE TABLE TRAN2016                           ;
TRUNCATE TABLE TRANADV2016                        ;
TRUNCATE TABLE TRANBAT2016                        ;
TRUNCATE TABLE TRANADVADDN2016                    ;
TRUNCATE TABLE CTRAN2016                          ;

TRUNCATE TABLE TRAN2017                           ;
TRUNCATE TABLE GLSUM2017                          ;
TRUNCATE TABLE TRANADV2017                        ;
TRUNCATE TABLE TRANBAT2017                        ;
TRUNCATE TABLE TRANADVADDN2017                    ;
TRUNCATE TABLE CTRAN2017                          ;


TRUNCATE TABLE TRAN2018                           ;
TRUNCATE TABLE GLSUM2018                          ;
TRUNCATE TABLE TRANADV2018                        ;
TRUNCATE TABLE TRANBAT2018                        ;
TRUNCATE TABLE TRANADVADDN2018                    ;
TRUNCATE TABLE CTRAN2018                          ;
                                                  
TRUNCATE TABLE ACNTTRANPROFAMT                    ;
TRUNCATE TABLE CORPCLINEACT                       ;
TRUNCATE TABLE SBCAIA                             ;
TRUNCATE TABLE SBCAIABRK                          ;
TRUNCATE TABLE IBANACLINK                         ;
TRUNCATE TABLE CUSLMT                             ;
TRUNCATE TABLE CUSLMTDTL                          ;


truncate table auditlog2013                       ;
truncate table auditlog2014                       ;
truncate table auditlog2015                       ;
truncate table auditlog2016                       ;
truncate table auditlog2017                       ;
                                                  
                                                  
         /*                                    
 
TRUNCATE TABLE MIG_ACNTLIEN                       ;
TRUNCATE TABLE MIG_ACNTS                          ;
TRUNCATE TABLE MIG_ASSETCLS                       ;
TRUNCATE TABLE MIG_AVGBAL                         ;
TRUNCATE TABLE   MIG_CHEQUE                       ;
TRUNCATE TABLE   MIG_CLIENTS                      ;
TRUNCATE TABLE   MIG_DDPO                         ;
TRUNCATE TABLE   MIG_DEP                          ;
TRUNCATE TABLE   MIG_DEPIA                        ;
TRUNCATE TABLE   MIG_GLOP_BAL                     ;
TRUNCATE TABLE   MIG_LAD                          ;
TRUNCATE TABLE   MIG_LADDTL                       ;
TRUNCATE TABLE   MIG_LNACDSDTL                    ;
TRUNCATE TABLE   MIG_LNACGUAR                     ;
TRUNCATE TABLE   MIG_LNACIRS                      ;
TRUNCATE TABLE   MIG_LNACNT                       ;
TRUNCATE TABLE   MIG_LNACRSDTL                    ;
TRUNCATE TABLE   MIG_LNTOTINTDBMIG                ;
TRUNCATE TABLE   MIG_MAXBAL                       ;
TRUNCATE TABLE   MIG_MINBAL                       ;
TRUNCATE TABLE   MIG_NOMREG                       ;
TRUNCATE TABLE   MIG_PBDCONTRACT                  ;
TRUNCATE TABLE   MIG_PBDCONTRACT_TEMP             ;
TRUNCATE TABLE   MIG_PIDDOCS                      ;
TRUNCATE TABLE   MIG_POST                         ;
TRUNCATE TABLE   MIG_POST_CHK                     ;
TRUNCATE TABLE   MIG_RDINS                        ;
TRUNCATE TABLE   MIG_SECMORT                      ;
TRUNCATE TABLE   MIG_STOPCHQ                      ;
TRUNCATE TABLE   MIG_VALIDATION                   ;
TRUNCATE TABLE   TEMP_CLIENT                      ;
TRUNCATE TABLE   TEMP_LOANIA                      ;
TRUNCATE TABLE   TEMP_SBCAIA                      ;
TRUNCATE TABLE   TEMP_SEC                         ;
TRUNCATE TABLE   MIG_SIGNATURE                    ;
 */