CREATE OR REPLACE Function FN_BIS_GETINTEREST
        (pInternalAcNum in number
        ) Return number

 IS
   IntRate number;
 Begin

   Select max(LnAcIr_appl_Int_Rate) into IntRate
   From LNACIR
   where LNACIR_INTERNAL_ACNUM = pInternalAcNum;

   if IntRate >0 then
      return IntRate;
   else

       -- panacea will have interest slabs.
       -- but to BIS only maximum interest is migrated
     Select max(LnAcIrdtl_Int_Rate) into IntRate
     From LNACIRDTL
     where LNACIRDTL_INTERNAL_ACNUM = pInternalAcNum;

     if IntRate > 0 then

        return IntRate;

     else

         Select max(lnprodir_appl_int_rate) into intrate
         From lnprodir
         where lnprodir_prod_code = (Select acnts_prod_code from
               acnts where acnts_internal_acnum = pInternalAcnum);

         if intrate > 0 then
            return IntRate;
         else

           Select max(lnprodirdtl_int_rate) into intrate
           From lnprodirdtl
           where lnprodirdtl_prod_code = (Select acnts_prod_code from
                 acnts where acnts_internal_acnum = pInternalAcnum);

           return IntRate;

         end if;

     end if;

   end if;

 END FN_BIS_GETINTEREST;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
