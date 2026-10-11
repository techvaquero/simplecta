-- Databricks notebook source
SET spark.sql.shuffle.partitions = 200;
create external table rstest.roberto_salcido.sptest
location "s3://us-east-1-dev-account-staging-uc-ext-loc-bucket-2/abhijit_test2/perfrs/sptest"

as

with websales (
select *, 
case when ws_item_sk < 350000 then 999999 else ws_item_sk end as newjk
from zhenghu.nvidia_tpcds_sf3000.web_sales
)

select 
*
from websales ws
left join zhenghu.nvidia_tpcds_sf3000.item it
on ws.newjk = it.i_item_sk