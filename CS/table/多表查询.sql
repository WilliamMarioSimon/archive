-- 多表查询-数据准备

use mydb3;
-- 创建部门表
create table if not exists dept3(
  deptno varchar(20) primary key ,  -- 部门号
  name varchar(20) -- 部门名字
);

-- 创建员工表
create table if not exists emp3(
  eid varchar(20) primary key , -- 员工编号
  ename varchar(20), -- 员工名字
  age int,  -- 员工年龄
  dept_id varchar(20)  -- 员工所属部门
);

-- 给dept3表添加数据
insert into dept3 values('1001','研发部');
insert into dept3 values('1002','销售部');
insert into dept3 values('1003','财务部');
insert into dept3 values('1004','人事部');

-- 给emp3表添加数据
insert into emp3 values('1','乔峰',20, '1001');
insert into emp3 values('2','段誉',21, '1001');
insert into emp3 values('3','虚竹',23, '1001');
insert into emp3 values('4','阿紫',18, '1001');
insert into emp3 values('5','扫地僧',85, '1002');
insert into emp3 values('6','李秋水',33, '1002');
insert into emp3 values('7','鸠摩智',50, '1002'); 
insert into emp3 values('8','天山童姥',60, '1003');
insert into emp3 values('9','慕容博',58, '1003');
insert into emp3 values('10','丁春秋',71, '1005');





-- 1.交叉连接查询
/*
1. 交叉连接查询返回被连接的两个表所有数据行的笛卡尔积
2. 笛卡尔集可以理解为一张表的每一行去和另外一张表的任意一行进行匹配
3. 假如A表有m行数据，B表有n行数据，则返回m*n行数据
4. 笛卡尔积会产生很多冗余的数据，后期的其他查询可以在该集合的基础上进行条件筛选

格式：select * from 表1,表2,表3….; 
*/

-- 内连接查询
/*
  隐式内连接（SQL92标准）：select * from A,B where 条件;
  显示内连接（SQL99标准）：select * from A inner join B on 条件;
*/


-- 查询每个部门的所属员工
-- 隐式内连接
select * from dept3,emp3 where dept3.deptno = emp3.dept_id;
select * from dept3 a,emp3 b where a.deptno = b.dept_id;
-- 显式内连接
select * from dept3 inner join emp3 on dept3.deptno = emp3.dept_id;
select * from dept3 a join emp3 b on a.deptno = b.dept_id;

-- 查询研发部门的所属员工
-- 隐式内连接
select * from dept3 a ,emp3 b where a.deptno = b.dept_id and name = '研发部'; 
-- 显式内连接
select * from dept3 a join emp3 b on a.deptno = b.dept_id and name = '研发部'; 

-- 查询研发部和销售部的所属员工
select * from dept3 a join emp3 b on a.deptno = b.dept_id and (name = '研发部' or name = '销售部') ; 
select * from dept3 a join emp3 b on a.deptno = b.dept_id and name in('研发部' ,'销售部') ; 

-- 查询每个部门的员工数,并升序排序
select 
	a.name,a.deptno,count(1) 
from dept3 a 
   join emp3 b on a.deptno = b.dept_id 
group by 
  a.deptno,name;


-- 查询人数大于等于3的部门，并按照人数降序排序

select
  a.deptno,
  a.name,
  count(1) as total_cnt
from dept3 a
	join emp3 b on a.deptno = b.dept_id
group by 
  a.deptno,a.name
having 
  total_cnt >= 3
order by 
  total_cnt desc;








