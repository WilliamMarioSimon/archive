-- 查看MySQL是否开启了binlog日志
show variables like 'log_bin';


-- 查看binlog日志的格式
show variables like 'binlog_format';

-- 查看所有日志
show binlog events;

-- 查看最新的日志
show master status;

-- 查询指定的binlog日志
show binlog events in 'binlog.000010';
select * from mydb1.emp2;
select count(*) from mydb1.emp2;
update mydb1.emp2 set salary = 8000;






-- 从指定的位置开始,查看指定的Binlog日志
show binlog events in 'binlog.000010' from 156;


-- 从指定的位置开始,查看指定的Binlog日志,限制查询的条数
show binlog events in 'binlog.000010' from 156 limit 2;
--从指定的位置开始，带有偏移，查看指定的Binlog日志,限制查询的条数
show binlog events in 'binlog.000010' from 666 limit 1, 2;

-- 清空所有的 binlog 日志文件
reset master


-- 查看MySQL是否开启了查询日志
show variables like 'general_log';

-- 开启查询日志
set global  general_log=1;

select * from mydb1.emp2;
select * from mydb6_view.emp;

select count(*) from mydb1.emp2;
select count(*) from mydb6_view.emp;
update mydb1.emp2 set salary = 9000;


-- 慢日志查询

-- 查看慢查询日志是否开启
show variables like 'slow_query_log%';

-- 开启慢查询日志
set global slow_query_log = 1;

-- 查看慢查询的超时时间
show variables like 'long_query_time%';


select sleep(12);


