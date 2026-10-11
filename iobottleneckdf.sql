-- Databricks notebook source
select * from 
zhenghu.nvidia_tpcds_sf3000.store_sales
where ss_item_sk = '33297'
