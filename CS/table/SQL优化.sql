use mydb13_optimize;
CREATE TABLE tb_user
(
  id int(11) NOT NULL AUTO_INCREMENT,
  username varchar(45) NOT NULL,
  password varchar(96) NOT NULL,
  name varchar(45) NOT NULL,
  birthday datetime DEFAULT NULL,
  sex char(1) DEFAULT NULL,
  email varchar(45) DEFAULT NULL,
  phone varchar(45) DEFAULT NULL,
  qq varchar(32) DEFAULT NULL,
  status varchar(32) NOT NULL COMMENT '用户状态',
  create_time datetime NOT NULL,
  update_time datetime DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY unique_user_username (username)
) ;




-- 1、首先，检查一个全局系统变量 'local_infile' 的状态， 如果得到如下显示 Value=OFF，则说明这是不可用的
show global variables like 'local_infile';


-- 2、修改local_infile值为on，开启local_infile
set global local_infile=1;


-- 3、加载数据 
-- 结论：当通过load向表加载数据时，尽量保证文件中的主键有序，这样可以提高执行效率
/*
脚本文件介绍 :
	sql1.log  ----> 主键有序
	sql2.log  ----> 主键无序
*/

-- 主键有序 -22.617s

load data local infile 'D:\\sql_data\\sql1.log' into table tb_user fields terminated by ',' lines terminated by '\n';

truncate table tb_user;

-- 主键无序-81.739s
load data local infile 'D:\\sql_data\\sql2.log' into table tb_user fields terminated by ',' lines terminated by '\n';



-- 关闭唯一性校验
SET UNIQUE_CHECKS=0;

truncate table tb_user;
load data local infile 'D:\\sql_data\\sql1.log' into table tb_user fields terminated by ',' lines terminated by '\n';

SET UNIQUE_CHECKS=1;

select * from tb_user


-- 优化order by语句
CREATE TABLE `emp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `age` int(3) NOT NULL,
  `salary` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;
insert into `emp` (`id`, `name`, `age`, `salary`) values('1','Tom','25','2300');
insert into `emp` (`id`, `name`, `age`, `salary`) values('2','Jerry','30','3500');
insert into `emp` (`id`, `name`, `age`, `salary`) values('3','Luci','25','2800');
insert into `emp` (`id`, `name`, `age`, `salary`) values('4','Jay','36','3500');
insert into `emp` (`id`, `name`, `age`, `salary`) values('5','Tom2','21','2200');
insert into `emp` (`id`, `name`, `age`, `salary`) values('6','Jerry2','31','3300');
insert into `emp` (`id`, `name`, `age`, `salary`) values('7','Luci2','26','2700');
insert into `emp` (`id`, `name`, `age`, `salary`) values('8','Jay2','33','3500');
insert into `emp` (`id`, `name`, `age`, `salary`) values('9','Tom3','23','2400');
insert into `emp` (`id`, `name`, `age`, `salary`) values('10','Jerry3','32','3100');
insert into `emp` (`id`, `name`, `age`, `salary`) values('11','Luci3','26','2900');
insert into `emp` (`id`, `name`, `age`, `salary`) values('12','Jay3','37','4500');
 
-- 创建组合索引
create index idx_emp_age_salary on emp(age,salary);

-- 排序,order by

explain select * from emp order by age;        -- Using filesort
explain select * from emp order by age,salary; -- Using filesort


explain select id from emp order by age;  -- Using index
explain select id,age from emp order by age;  -- Using index
explain select id,age,salary,name from emp order by age;  -- Using filesort

-- order by后边的多个排序字段要求尽量排序方式相同
explain select id,age from emp order by age asc, salary desc;  -- Using index; Using filesort
explain select id,age from emp order by age desc, salary desc;  -- Backward index scan; Using index

-- order by后边的多个排序字段顺序尽量和组合索引字段顺序一致
explain select id,age from emp order by salary,age; -- Using index; Using filesort



show variables like 'max_length_for_sort_data'; -- 4096
show variables like 'sort_buffer_size'; 






-- 优化limit
select count(*) from tb_user;

select * from tb_user limit 0,10;

explain select * from tb_user limit 900000,10; -- 0.684

explain select * from tb_user a, (select id from tb_user order by id limit 900000,10) b where a.id = b.id; -- 0.486



explain select * from tb_user where id > 900000 limit 10;





drop index idx_emp_age_salary on emp;

explain select age,count(*) from emp group by age;

