-- Databricks notebook source
create or replace table rstest.roberto_salcido.skewtest
location "s3://us-east-1-dev-account-staging-uc-ext-loc-bucket-2/abhijit_test2/perfrs/skewtest"

as 

with storesales (
select *, 
case when ss_item_sk < 350000 then 999999 else ss_item_sk end as newjk
from zhenghu.nvidia_tpcds_sf3000.store_sales
)


select 
/*+ SHUFFLE_HASH(ss) */
*
from storesales ss
join zhenghu.nvidia_tpcds_sf3000.item it
on ss.newjk = it.i_item_sk
