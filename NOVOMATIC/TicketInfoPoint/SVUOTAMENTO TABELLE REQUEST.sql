select * from etl.request
select * from etl.requestdetail order by requestdetailid

truncate table etl.requestdetail
delete from etl.request