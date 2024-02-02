CREATE WIDGET TEXT cat DEFAULT "financeclone";

CREATE WIDGET TEXT sch DEFAULT "dev";


create table ${cat}.${sch}.filetest
  as select * from samples.tpch.customers
  limit 100;

create table ${cat}.${sch}.filetestuno
  as select * from samples.tpch.customers
  limit 100;
