
-- 分布函数- CUME_DIST
/*
 用途：分组内小于、等于当前rank值的行数 / 分组内总行数
 应用场景：查询小于等于当前薪资（salary）的比例
*/

use mydb4;

select 
 dname,
 ename,
 salary,
 cume_dist() over(order by salary) as rn1,
 cume_dist() over(partition by dname order by salary) as rn2
from employee;

/*
  rn1:
   3 / 12 = 1/4 = 0.25
   5 / 12 =  0.4166666666666667
  rn2: 
	  1 / 6 = 0.1666666666666667
		3 / 6 = 0.5
*/


-- percent_rank
/*
用途：每行按照公式(rank-1) / (rows-1)进行计算。其中，rank为RANK()函数产生的序号，rows为当前窗口的记录总行数
应用场景：不常用
*/

select 
 dname,
 ename,
 salary,
 rank() over(partition by dname order by salary desc) as rn,
 percent_rank() over(partition by dname order by salary desc) as rn2
from employee;

/*
 rn2:
  第一行: (1 - 1) / (6 - 1) = 0
  第二行: (1 - 1) / (6 - 1) = 0
  第三行: (3 - 1) / (6 - 1) = 0.4
*/



 -- 前后函数-LAG和LEAD
 /*
 用途：返回位于当前行的前n行（LAG(expr,n)）或后n行（LEAD(expr,n)）的expr的值
 应用场景：查询前1名同学的成绩和当前同学成绩的差值
*/
select 
 dname,
 ename,
 salary,
 hiredate,
 lag(hiredate, 1, '2000-01-01') over(partition by dname order by hiredate ) as time1,
 lag(hiredate, 2) over(partition by dname order by hiredate ) as time2
from employee;

select 
 dname,
 ename,
 salary,
 hiredate,
 lead(hiredate, 1, '2000-01-01') over(partition by dname order by hiredate ) as time1,
 lead(hiredate, 2) over(partition by dname order by hiredate ) as time2
from employee;

-- 头尾函数-FIRST_VALUE和LAST_VALUE
/*

用途：返回第一个（FIRST_VALUE(expr)）或最后一个（LAST_VALUE(expr)）expr的值
应用场景：截止到当前，按照日期排序查询第1个入职和最后1个入职员工的薪资
*/
select 
 dname,
 ename,
 salary,
 hiredate,
 first_value(salary) over(partition by dname order by hiredate ) as first,
 last_value(salary) over(partition by dname order by hiredate ) as last
from employee;





-- 其他函数-NTH_VALUE(expr, n)、NTILE(n)
/*

NTH_VALUE(expr,n)
用途：返回窗口中第n个expr的值。expr可以是表达式，也可以是列名
应用场景：截止到当前薪资，显示每个员工的薪资中排名第2或者第3的薪资
*/
select 
 dname,
 ename,
 salary,
 hiredate,
 nth_value(salary,2) over(partition by dname order by hiredate ) as second_salary,
 nth_value(salary,3) over(partition by dname order by hiredate ) as third_salary
from employee;







-- NTILE
/*


用途：将分区中的有序数据分为n个等级，记录等级数
应用场景：将每个部门员工按照入职日期分成3组
*/

select 
 dname,
 ename,
 salary,
 hiredate,
 ntile(3) over(partition by dname order by hiredate ) as nt
from employee;


-- 取出每一个部门的第一组员工

select 
*
from (
	select 
	 dname,
	 ename,
	 salary,
	 hiredate,
	 ntile(3) over(partition by dname order by hiredate ) as nt
	from employee
)t
where t.nt = 1;




create database mydb5;
use mydb5;

-- 方式1-创建表的时候直接指定
create  table student(
    sid int primary key,
    card_id varchar(20),
    name varchar(20),
    gender varchar(20),
    age int,
    birth date, 
    phone_num varchar(20),
    score double,
    index index_name(name) -- 给name列创建索引
);

select * from student where name = '张三';




-- 方式2-直接创建
-- create index indexname on tablename(columnname); 
create index index_gender on student(gender); 



-- 方式3-修改表结构(添加索引)
-- alter table tablename add index indexname(columnname)
alter table student add index index_age(age);





-- 1、查看数据库所有索引 
-- select * from mysql.`innodb_index_stats` a where a.`database_name` = '数据库名’; 
select * from mysql.`innodb_index_stats` a where a.`database_name` = 'mydb5';



-- 2、查看表中所有索引 
-- select * from mysql.`innodb_index_stats` a where a.`database_name` = '数据库名' and a.table_name like '%表名%’; 
select * from mysql.`innodb_index_stats` a where a.`database_name` = 'mydb5' and a.table_name like '%student%';

-- 3、查看表中所有索引 
-- show index from table_name; 
show index from student;



-- 删除索引
/*
  drop index 索引名 on 表名 
  -- 或 
  alter table 表名 drop index 索引名 

*/

 drop index index_gender on student; 

 alter table student drop index index_age; 




-- 索引的操作-创建索引-单列索引-唯一索引
/*

唯一索引与前面的普通索引类似，不同的就是：索引列的值必须唯一，但允许有空值。如果是组合索引，则列值的组合必须唯一。它有以下几种创建方式：
*/
-- 方式1-创建表的时候直接指定
create  table student2(
    sid int primary key,
    card_id varchar(20),
    name varchar(20),
    gender varchar(20),
    age int,
    birth date, 
    phone_num varchar(20),
    score double,
    unique index_card_id(card_id) -- 给card_id列创建索引
);
-- 方式2-直接创建
-- create unique index 索引名 on 表名(列名) 
create  table student2(
    sid int primary key,
    card_id varchar(20),
    name varchar(20),
    gender varchar(20),
    age int,
    birth date, 
    phone_num varchar(20),
    score double
);
create unique index index_card_id on student2(card_id);

-- 方式3-修改表结构(添加索引)
-- alter table 表名 add unique [索引名] (列名)
alter table student2 add unique index_phone_num(phone_num);



-- 操作-删除索引
 drop index index_card_id on student2; 

 alter table student2 drop index index_phone_num; 


-- 主键索引

show index from student2;




-- 组合索引
use mydb5;
-- 创建索引的基本语法-- 普通索引
-- create index indexname on table_name(column1(length),column2(length)); 
create index index_phone_name on student(phone_num,name);

-- 操作-删除索引
 drop index index_phone_name on student; 

-- 创建索引的基本语法-- 唯一索引

create  unique index index_phone_name on student(phone_num,name); 
/*
  1 a
	1 b
	2 a
	1 a 不行
*/






select * from student where name = '张三'; 
select * from student where phone_num = '15100046637'; 
select * from student where phone_num = '15100046637' and name = '张三'; 
select * from student where name = '张三' and phone_num = '15100046637';
 
/* 
  三条sql只有 2 、 3、4能使用的到索引idx_phone_name,因为条件里面必须包含索引前面的字段  才能够进行匹配。
  而3和4相比where条件的顺序不一样，为什么4可以用到索引呢？是因为mysql本身就有一层sql优化，他会根据sql来识别出来该用哪个索引，我们可以理解为3和4在mysql眼中是等价的。 
*/
*/
show variables like '%ft%';


use mydb5;
-- 创建表的适合添加全文索引
create table t_article (
     id int primary key auto_increment ,
     title varchar(255) ,
     content varchar(1000) ,
     writing_date date -- , 
     -- fulltext (content) -- 创建全文检索
);

insert into t_article values(null,"Yesterday Once More","When I was young I listen to the radio",'2021-10-01');
insert into t_article values(null,"Right Here Waiting","Oceans apart, day after day,and I slowly go insane",'2021-10-02'); 
insert into t_article values(null,"My Heart Will Go On","every night in my dreams,i see you, i feel you",'2021-10-03');
insert into t_article values(null,"Everything I Do","eLook into my eyes,You will see what you mean to me",'2021-10-04');
insert into t_article values(null,"Called To Say I Love You","say love you no new year's day, to celebrate",'2021-10-05');
insert into t_article values(null,"Nothing's Gonna Change My Love For You","if i had to live my life without you near me",'2021-10-06');
insert into t_article values(null,"Everybody","We're gonna bring the flavor show U how.",'2021-10-07');

-- 修改表结构添加全文索引
alter table t_article add fulltext index_content(content)

-- 添加全文索引
create fulltext index index_content on t_article(content);



-- 使用全文索引

select * from t_article where match(content) against('yo'); -- 没有结果
 
select * from t_article where match(content) against('you'); -- 有结果
select * from t_article where content like '%you%'; 







create table shop_info (
  id  int  primary key auto_increment comment 'id',
  shop_name varchar(64) not null comment '门店名称',
	geom_point geometry not null comment '经纬度',
  spatial key geom_index(geom_point)
);




