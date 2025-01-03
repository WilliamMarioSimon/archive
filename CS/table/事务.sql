create database if not exists mydb12_transcation;
use mydb12_transcation;
-- 创建账户表
create table account(
	id int primary key, -- 账户id
	name varchar(20), -- 账户名
	money double -- 金额
);


--  插入数据
insert into account values(1,'zhangsan',1000);
insert into account values(2,'lisi',1000);


-- 设置MySQL的事务为手动提交(关闭自动提交)
select @@autocommit;
set autocommit = 0;

-- 模拟账户转账
-- 开启事务 
begin;
update account set money = money - 200 where name = 'zhangsan';
update account set money = money + 200 where name = 'lisi';
-- 提交事务
commit;


-- 回滚事务
rollback;

select * from account;


-- 查看隔离级别 
show variables like '%isolation%';

-- 设置隔离级别
/*
set session transaction isolation level 级别字符串
级别字符串：read uncommitted、read committed、repeatable read、serializable
	
*/
-- 设置read uncommitted
set session transaction isolation level read uncommitted;
-- 这种隔离级别会引起脏读，A事务读取到B事务没有提交的数据

-- 设置read committed
set session transaction isolation level read committed;
-- 这种隔离级别会引起不可重复读，A事务在没有提交事务之前，可看到数据不一致


-- 设置repeatable read （MySQ默认的）
set session transaction isolation level repeatable read;
-- 这种隔离级别会引起幻读，A事务在提交之前和提交之后看到的数据不一致

-- 设置serializable
set session transaction isolation level serializable;
-- 这种隔离级别比较安全，但是效率低，A事务操作表时，表会被锁起，B事务不能操作。



-- SQL的优化

insert into account values(3,'wangwu',1000);
-- 查看当前会话SQL执行类型的统计信息
show session status like 'Com_______';

-- 查看全局（自从上次MySQL服务器启动至今）执行类型的统计信息
show global status like 'Com_______';



-- 查看针对InnoDB引擎的统计信息
show status like 'Innodb_rows_%';




-- 查看慢日志配置信息
show variables like '%slow_query_log%';

-- 开启慢日志查询
set global slow_query_log = 1;

-- 查看慢日志记录SQL的最低阈值时间,默认如果SQL的执行时间>=10秒，则算慢查询，则会将该操作记录到慢日志中去
show variables like '%long_query_time%';
select sleep(12);
select sleep(10);


-- 修改慢日志记录SQL的最低阈值时间

set global long_query_time = 5;


-- 通过show processlist查看当前客户端连接服务器的线程执行状态信息

show processlist;

select sleep(50);




-- ----------------explain执行计划-------------------------

create database mydb13_optimize;
use mydb13_optimize;


-- 1、查询执行计划 
explain  select * from user where uid = 1;

-- 2、查询执行计划
explain  select * from user where uname = '张飞';

-- 2.1、id 相同表示加载表的顺序是从上到下
explain select * from user u, user_role ur, role r where u.uid = ur.uid and ur.rid = r.rid ;


-- 2.2、 id 不同id值越大，优先级越高，越先被执行。 
explain select * from role where rid = (select rid from user_role where uid = (select uid from user where uname = '张飞'))
-- 2.3/
explain select * from role r ,
(select * from user_role ur where ur.uid = (select uid from user where uname = '张飞')) t where r.rid = t.rid ; 
