-- Databricks notebook source
select * from 
tpcds.sf_10000.store_sales
where ss_item_sk = '33297'