-- Databricks notebook source
select * from 
hms_msisovic.tpcds_sf10000_delta.store_sales
where ss_item_sk = '33297'