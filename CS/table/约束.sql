
-- 1：通过修改表结构添加主键

/*
   create table 表名(
     ...
   );
   alter table <表名> add primary key（字段列表);
*/

use mydb1;
-- 添加单列主键
create table emp4(
  eid int, 
  name varchar(20), 
  deptId int, 
  salary double
);

alter table emp4 add primary key(eid);

-- 添加多列主键
create table emp5(
  eid int, 
  name varchar(20), 
  deptId int, 
  salary double
);

alter table emp5 add primary key(name, deptId);


-- 删除主键

-- 1.删除单列主键
alter table emp1 drop primary key;

-- 2.删除多列主键
alter table emp5 drop primary key;


use mydb1;
-- 自增正约束
create table t_user1 ( 
  id int primary key auto_increment, 
  name varchar(20)
);

insert into t_user1 values(NULL,'张三');
insert into t_user1(name) values('李四');

delete from t_user1;  -- delete删除数据之后，自增长还是在最后一个值基础上加1

insert into t_user1 values(NULL,'张三');
insert into t_user1(name) values('李四');



truncate t_user1; -- truncate删除之后，自增长从1开始

insert into t_user1 values(NULL,'张三');
insert into t_user1(name) values('李四');


-- 指定自增长的初始值
-- 方式一：创建表时指定
create table t_user2 ( 
  id int primary key auto_increment, 
  name varchar(20)
)auto_increment = 100;

insert into t_user2 values(NULL,'张三');
insert into t_user2 values(NULL,'张三');

delete from t_user2; 

insert into t_user2 values(NULL,'张三');
insert into t_user2 values(NULL,'张三');

truncate t_user2; -- truncate删除之后，自增长从1开始

insert into t_user2 values(NULL,'张三');
insert into t_user2 values(NULL,'张三');

-- 方式二：创建表之后指定
create table t_user3 ( 
  id int primary key auto_increment, 
  name varchar(20)
);

alter table t_user3 auto_increment = 200;

insert into t_user3 values(NULL,'张三');
insert into t_user3 values(NULL,'张三');


-- 非空约束
/*
 MySQL 非空约束（NOT   NULL）指字段的值不能为空。对于使用了非空约束的字段，如果用户在添加数据时没有指定值，数据库系统就会报错。
*/

-- 格式
/*
 方式1：<字段名><数据类型> not null;
 方式2：alter table 表名 modify 字段 类型 not null;
*/
use mydb1;
-- 1. 创建非空约束-方式1，创建表时指定
create table mydb1.t_user6 ( 
  id int , 
  name varchar(20)  not null,   -- 指定非空约束
  address varchar(20) not null  -- 指定非空约束
);

insert into t_user6(id) values(1001); -- 不可以
insert into t_user6(id,name,address) values(1001,NULL,NULL); -- 不可以
insert into t_user6(id,name,address) values(1001,'NULL','NULL'); -- 可以（字符串：NULL）
insert into t_user6(id,name,address) values(1001,'',''); -- 可以（空串） 



-- 2.创建非空约束-方式2，创建表之后指定
create table t_user7 ( 
  id int , 
  name varchar(20) ,   -- 指定非空约束
  address varchar(20)  -- 指定非空约束
);

alter table t_user7 modify name varchar(20) not null;
alter table t_user7 modify address varchar(20) not null;

desc t_user7;

-- 3.删除非空约束
-- alter table 表名 modify 字段 类型 

alter table t_user7 modify name varchar(20) ;
alter table t_user7 modify address varchar(20) ;




-- 唯一约束

/*
唯一约束（Unique Key）是指所有记录中字段的值不能重复出现。例如，为 id 字段加上唯一性约束后，每条记录的 id 值都是唯一的，不能出现重复的情况。
*/

-- 语法：
/*
方式1：<字段名> <数据类型> unique
方式2：alter table 表名 modify 字段 类型 not null;
*/
use mydb1;
-- 1. 添加唯一约束-方式1-创建表时指定
create table t_user8 ( 
 id int , 
 name varchar(20) , 
 phone_number varchar(20) unique  -- 指定唯一约束 
);


insert into t_user8 values(1001,'张三',138);
insert into t_user8 values(1002,'张三2',139);

insert into t_user8 values(1003,'张三3',NULL);
insert into t_user8 values(1004,'张三4',NULL);  -- 在MySQL中NULL和任何值都不相同 甚至和自己都不相同

-- 2. 添加唯一约束-方式1-创建表之后指定
-- 格式：alter table 表名 add constraint 约束名 unique(列);

create table t_user9 ( 
  id int , 
  name varchar(20) , 
  phone_number varchar(20) -- 指定唯一约束 
); 

alter table t_user9 add constraint unique_pn unique(phone_number);


insert into t_user9 values(1001,'张三',138);
insert into t_user9 values(1002,'张三2',138);

-- 3. 删除唯一约束
-- 格式：alter table <表名> drop index <唯一约束名>;

alter table t_user9 drop index unique_pn;


-- 默认约束
-- 1.创建默认约束
/*
 方式1： <字段名> <数据类型> default <默认值>;
 方式2: alter table 表名 modify 列名 类型 default 默认值; 
*/

use mydb1;
-- 方式1-创建表时指定
create table t_user10 ( 
  id int , 
  name varchar(20) ,
  address varchar(20) default '北京' -- 指定默认约束 
);




insert into t_user10(id,name,address) values(1001,'张三','上海');
insert into t_user10 values(1002,'李四',NULL);

-- 方式2-创建表之后指定
-- alter table 表名 modify 列名 类型 default 默认值; 
create table t_user11 ( 
  id int , 
  name varchar(20) , 
  address varchar(20)  
);

alter table t_user11 modify address varchar(20) default '深圳';

insert into t_user11(id,name) values(1001,'张三');

-- 2.删除默认约束
-- alter table <表名> change column <字段名> <类型> default null; 

alter table t_user11 modify address varchar(20) default null;

insert into t_user11(id,name) values(1002,'李四');



-- 零填充约束(zerofill)

-- 1. 添加约束
create table t_user12 ( 
  id int zerofill  , -- 零填充约束
  name varchar(20)   
);

insert into t_user12 values(123, '张三');

insert into t_user12 values(1, '李四');

insert into t_user12 values(2, '王五');

-- 2.删除约束
alter table t_user12 modify id int;



-- 总结

-- 1：通过修改表结构添加主键约束

create table emp4(
  eid int primary key, 
  name varchar(20), 
  deptId int, 
  salary double
);


-- 2:添加自增正约束
create table t_user1 ( 
  id int primary key auto_increment, 
  name varchar(20)
);

-- 3：创建非空约束

create table mydb1.t_user6 ( 
  id int , 
  name varchar(20)  not null,   -- 指定非空约束
  address varchar(20) not null  -- 指定非空约束
);

-- 4：创建唯一约束
create table t_user8 ( 
 id int , 
 name varchar(20) , 
 phone_number varchar(20) unique  -- 指定唯一约束 
);


-- 5:创建默认约束
create table t_user10 ( 
  id int , 
  name varchar(20) ,
  address varchar(20) default '北京' -- 指定默认约束 
);



