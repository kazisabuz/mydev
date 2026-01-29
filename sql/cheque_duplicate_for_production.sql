/*Checking the data where there is any duplicate data available in the cbiss table and updating the data so that there is no duplicate data in the table. The data is being checking based on the prefix and leaf number of the check.*/
select *
  from cbiss cc
 where (cc.cbiss_chqbk_prefix, cc.cbiss_from_leaf_num) in
       (select c.cbiss_chqbk_prefix, c.cbiss_from_leaf_num
          from cbiss c
         group by c.cbiss_chqbk_prefix, c.cbiss_from_leaf_num
        having count(*) > 1);


update cbiss cc
   set cc.cbiss_chqbk_prefix = 'TAK'
 WHERE ROWID IN (SELECT rid
                   FROM (SELECT ROWID rid,
                                ROW_NUMBER() OVER(PARTITION BY cbiss_chqbk_prefix || cbiss_from_leaf_num ORDER BY ROWID) rn
                           FROM cbiss )
                  WHERE rn <> 1);
