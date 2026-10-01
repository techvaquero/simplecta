-- Databricks notebook source
SET spark.sql.shuffle.partitions = 200;

create or replace table users.roberto_salcido.sptest
as

with websales (
select *, 
case when ws_item_sk < 350000 then 999999 else ws_item_sk end as newjk
from tpcds.sf_10000.web_sales
)

select 
*
from websales ws
left join tpcds.sf_10000.item it
on ws.newjk = it.i_item_sk