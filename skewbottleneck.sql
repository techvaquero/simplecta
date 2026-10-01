-- Databricks notebook source
create or replace table users.roberto_salcido.skewtest
as 

with storesales (
select *, 
case when ss_item_sk < 350000 then 999999 else ss_item_sk end as newjk
from tpcds.sf_10000.store_sales
)


select 
/*+ SHUFFLE_HASH(ss) */
*
from storesales ss
join tpcds.sf_10000.item it
on ss.newjk = it.i_item_sk