

create table ${cat}.${sch}.filetest
  as select * from samples.tpch.customers
  limit 100;

