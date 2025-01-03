-- 存储过程---------------

create database mysql7_procedure;
use mysql7_procedure;

-- 1:创建存储过程
/*
delimiter 自定义结束符号
create procedure 储存名([ in ,out ,inout ] 参数名 数据类形...)
begin
  sql语句
end 自定义的结束符合
delimiter ;
*/
delimiter $$
create procedure  proc01()
begin
 select empno,ename from emp;
end $$
delimiter ;

-- 调用存储过程
call proc01();
call proc01();


-- 变量定义
/*
语法1： 声明变量 declare var_name type [default var_value]; 
语法2：
select col_name [...] into var_name[,...] 
from table_name wehre condition 

*/
delimiter $$
create procedure proc02()
begin
  declare var_name01 varchar(20) default 'aaa';  -- 声明/定义变量
	set var_name01 = 'zhangsan';  -- 给变量赋值
	select var_name01; -- 输出变量的值
end $$
delimiter ;

call proc02();


/*
select col_name [...] into var_name[,...] 
from table_name wehre condition 

其中：
col_name 参数表示查询的字段名称；
var_name 参数是变量的名称；
table_name 参数指表的名称；
condition 参数指查询条件。
注意：当将查询结果赋值给变量时，该查询语句的返回结果只能是单行单列。
*/

delimiter $$
create procedure proc03()
begin
  declare my_ename varchar(20) ;  -- 声明/定义变量
	select ename into my_ename from emp where empno = 1001;  -- 给变量赋值
	select my_ename; -- 输出变量的值
end $$
delimiter ;

call proc03();


-- 用户变量

delimiter $$
create procedure proc04()
begin
 set @var_nam01 = 'beijing';
 select  @var_nam01;
end $$
delimiter ;
call proc04();

select @var_nam01; -- 也可以使用用户变量






use mysql7_procedure;

 -- 系统变量
 -- 全局变量
 use mysql7_procedure
 -- 查看全局变量 
show global variables; 
-- 查看某全局变量 
select @@global.auto_increment_increment; 
-- 修改全局变量的值 
set global sort_buffer_size = 40000; 
set @@global.sort_buffer_size = 33000;

select @@global.sort_buffer_size; 

-- 会话变量
-- 查看会话变量
show session variables;
-- 查看某会话变量 
select @@session.auto_increment_increment;
-- 修改会话变量的值
set session sort_buffer_size = 50000; 
set @@session.sort_buffer_size = 60000 ;

select @@session.sort_buffer_size;







-- ---------传入参数：in---------------------------------
use mysql7_procedure;
-- 封装有参数的存储过程，传入员工编号，查找员工信息
delimiter $$
create procedure proc06(in empno int )
begin
  select * from emp where emp.empno = empno;
end $$

delimiter ;

call proc06(1001);
call proc06(1002);




-- ------------------------------------
-- 封装有参数的存储过程，可以通过传入部门名和薪资，查询指定部门，并且薪资大于指定值的员工信息

delimiter $$

create procedure proc07(in param_dname varchar(50), in param_sal decimal(7,2))
begin
 select * from dept a, emp b where a.deptno = b.deptno and a.dname = param_dname and b.sal > param_sal;
end $$
delimiter ;

call proc07('学工部',20000);
call proc07('销售部',10000);







-- ---------传出参数：out---------------------------------
use mysql7_procedure;
-- 封装有参数的存储过程，传入员工编号，返回员工名字
delimiter $$

create procedure proc08(in in_empno int, out out_ename varchar(50))
begin
  select ename into out_ename  from emp where empno = in_empno;
end $$

delimiter ;

call proc08(1002, @o_ename);

select @o_ename;



-- ------------------------------------------
-- 封装有参数的存储过程，传入员工编号，返回员工名字和薪资


delimiter $$

create procedure proc09(in in_empno int, out out_ename varchar(50), out out_sal decimal(7,2))
begin
  select ename, sal into out_ename , out_sal
	from emp 
	where empno = in_empno;
end $$

delimiter ;

call proc09(1002, @o_ename,@o_sal);

select @o_ename;
select @o_sal;











-- ------------------------------------
-- 封装有参数的存储过程，可以通过传入部门名和薪资，查询指定部门，并且薪资大于指定值的员工信息

delimiter $$

create procedure proc07(in param_dname varchar(50), in param_sal decimal(7,2))
begin
 select * from dept a, emp b where a.deptno = b.deptno and a.dname = param_dname and b.sal > param_sal;
end $$
delimiter ;

call proc07('学工部',20000);
call proc07('销售部',10000);







use mysql7_procedure;

-- 传入一个数字，传出这个数字的10倍值
delimiter $$

create procedure proc10(inout num int)
begin
  set num = num * 10;
end $$
delimiter ;

set @inout_num = 3;
call proc10(@inout_num);

select @inout_num;



-- 传入员工名，拼接部门号，传入薪资，求出年薪
-- 关羽 ----> 30_关羽 

delimiter $$

create procedure proc11(inout inout_ename varchar(50), inout inout_sal int)
begin
  select concat_ws('_',deptno,ename)  into  inout_ename from emp where emp.ename = inout_ename;
	set inout_sal = inout_sal * 12;
end $$

delimiter ;

set @inout_ename = '关羽';
set @inout_sal = 3000;

call proc11(@inout_ename,@inout_sal);

select  @inout_ename ;
select  @inout_sal;

-- 存储过程-if
-- 案例1
-- 输入学生的成绩，来判断成绩的级别：
/*
  score < 60 :不及格
  score >= 60  , score <80 :及格
	score >= 80 , score < 90 :良好
	score >= 90 , score <= 100 :优秀
	score > 100 :成绩错误
*/

delimiter  $$
create procedure proc_12_if(in score int)
begin
  if score < 60 
	  then
		  select '不及格';
	elseif  score < 80
	  then
		  select '及格' ;
	elseif score >= 80 and score < 90
	   then 
		   select '良好';
  elseif score >= 90 and score <= 100
	   then 
		   select '优秀';
	 else
	   select '成绩错误';
  end if;
end $$
delimiter  ;

call proc_12_if(120)



-- 输入员工的名字，判断工资的情况。
/*
  sal < 10000 :试用薪资
	sal >= 10000 and sal < 20000 :转正薪资
	sal >= 20000 :元老薪资
*/
delimiter  $$
create procedure proc_13_if(in in_ename varchar(20))
begin
 declare var_sal decimal(7,2);
 declare result varchar(20);
 select sal into var_sal from emp where ename = in_ename;
 
 if var_sal < 10000
	then
		set result = '试用薪资';
 elseif var_sal < 20000
	then 
	  set result = '转正薪资'	;
 else
	  set result = '元老薪资' ;
 end if;
 select result;
end $$
delimiter  ;

-- 调用
call proc_13_if('关羽');
call proc_13_if('程普');




-- 流程控制语句：case
/*
 支付方式:
   1  微信支付
	 2  支付宝支付
	 3  银行卡支付
	 4  其他方式支付
*/

-- 格式1

delimiter $$

create procedure proc14_case(in pay_type int)
begin
  case pay_type
		when  1 
		  then 
			  select '微信支付' ;
		when  2 then select '支付宝支付' ;
		when  3 then select '银行卡支付';
	  else select '其他方式支付';
	end case ;
end $$
delimiter ;

call proc14_case(2);
call proc14_case(4);


-- 格式2
delimiter  $$
create procedure proc_15_case(in score int)
begin
  case
  when score < 60 
	  then
		  select '不及格';
	when  score < 80
	  then
		  select '及格' ;
	when score >= 80 and score < 90
	   then 
		   select '良好';
  when score >= 90 and score <= 100
	   then 
		   select '优秀';
	 else
	   select '成绩错误';
  end case;
end $$
delimiter  ;

call proc_15_case(88);


-- 存储过程-循环-while
use mysql7_procedure;

-- 创建测试表
create table user (
	uid int primary key,
	username varchar(50),
  password varchar(50)
);

/*
【标签:】while 循环条件 do
    循环体;
end while【 标签】;

*/
-- 需求：向表中添加指定条数的数据
-- -------存储过程-循环-while
delimiter $$
create procedure proc16_while(in insertCount int)
begin
	 declare i int default 1;
	 label:while i <= insertCount do
		 insert into user(uid, username, password) values(i,concat('user-',i),'123456');
		 set i = i + 1;
	 end while label;
end $$
delimiter ;

call proc16_while(10);

-- -------存储过程-循环控制-while + leave
-- leave：直接跳出while循环
truncate table user;

delimiter $$
create procedure proc17_while_leave(in insertCount int) -- 10
begin
	 declare i int default 1;
	 label:while i <= insertCount do -- 10
		 insert into user(uid, username, password) values(i,concat('user-',i),'123456');
		 if i = 5 then
		   leave label;
		 end if;
		 set i = i + 1;
	 end while label;
	 select '循环结束';
end $$
delimiter ;

call proc17_while_leave(10);


-- -------存储过程-while+iterate
-- iterate:跳过本次循环的剩余代码，进入下一次循环
create table user2 (
	uid int ,
	username varchar(50),
  password varchar(50)
);

use mysql7_procedure;
truncate table user2;

delimiter $$
create procedure proc17_while_iterate(in insertCount int) -- 10
begin
	 declare i int default 0;
	 label:while i < insertCount do -- 10
	  set i = i + 1;
	  if i = 5 then
		   iterate label;
		 end if;
		 insert into user2(uid, username, password) values(i,concat('user-',i),'123456');
	 end while label;
	 select '循环结束';
end $$
delimiter ;

call proc17_while_iterate(10);  -- 1 2 3 4 6 7 8 9 10


-- -------存储过程-循环控制-repeat 
use mysql7_procedure;
truncate table user;


delimiter $$
create procedure proc18_repeat(in insertCount int)
begin
	 declare i int default 1;
	 label:repeat
		 insert into user(uid, username, password) values(i,concat('user-',i),'123456');
		 set i = i + 1;
		 until  i  > insertCount
	 end repeat label;
	 select '循环结束';
end $$
delimiter ;

call proc18_repeat(100);



-- 操作游标(cursor)

-- 声明游标
-- 打开游标
-- 通过游标获取值、
-- 关闭游标























-- -------存储过程-循环控制-loop
/*
[标签:] loop
  循环体;
  if 条件表达式 then 
     leave [标签]; 
  end if;
end loop;
*/
use mysql7_procedure;
truncate table user;

delimiter $$
create procedure proc19_loop(in insertCount int)
begin
 declare i int default 1;
 label: loop
  insert into user(uid, username, password) values(i,concat('user-',i),'123456');
  set i = i + 1 ;
	
	if i > insertCount
	 then 
	   leave label;
  end if ;
	
 end loop label;
end $$
delimiter ;

call proc19_loop(100);









-- 操作游标(cursor)

-- 声明游标
-- 打开游标
-- 通过游标获取值、
-- 关闭游标
use mysql7_procedure;
drop procedure if exists proc19_cursor;
-- 需求：输入一个部门名，查询该部门员工的编号、名字、薪资 ，将查询的结果集添加游标
delimiter $$
create procedure proc19_cursor(in in_dname varchar(50))
begin
  -- 定义局部变量
	declare var_empno int;
	declare var_ename varchar(50);
	declare var_sal decimal(7,2);
	
	-- 声明游标
	declare my_cursor cursor for
		select empno,ename,sal
		from dept a, emp b
		where a.deptno = b.deptno and a.dname = in_dname;
		
	-- 打开游标
	open my_cursor;
	-- 通过游标获取值
	label:loop
		fetch my_cursor into var_empno, var_ename,var_sal;
		select var_empno, var_ename,var_sal;
	end loop label;
	
	-- xxxxx
	-- 关闭游标
	close my_cursor;
end $$;

delimiter ;

call proc19_cursor('销售部');







-- 游标 + 句柄
/*
DECLARE handler_action HANDLER
    FOR condition_value [, condition_value] ...
    statement
 
handler_action: {
    CONTINUE
  | EXIT
  | UNDO
}
 
condition_value: {
    mysql_error_code
  | condition_name
  | SQLWARNING
  | NOT FOUND

特别注意：

在语法中，变量声明、游标声明、handler声明是必须按照先后顺序书写的，否则创建存储过程出错。
*/
use mysql7_procedure;
drop procedure if exists proc21_cursor_handler;
-- 需求：输入一个部门名，查询该部门员工的编号、名字、薪资 ，将查询的结果集添加游标
delimiter $$
create procedure proc21_cursor_handler(in in_dname varchar(50))
begin
  -- 定义局部变量
	declare var_empno int;
	declare var_ename varchar(50);
	declare var_sal decimal(7,2);
	-- 定义标记值
	declare flag int default 1;
	
	-- 声明游标
	declare my_cursor cursor for
		select empno,ename,sal
		from dept a, emp b
		where a.deptno = b.deptno and a.dname = in_dname;
		
	-- 定义句柄：定义异常的处理方式
	/*
	  1:异常处理完之后程序该怎么执行
		   continue :继续执行剩余代码
			 exit : 直接终止程序
			 undo: 不支持
			 
	   2: 触发条件
		  条件码:
			  1329
			条件名：
		    SQLWARNING
        NOT FOUND
        SQLEXCEPTION
		  3:异常触发之后执行什么代码
				设置flag的值 ---》 0
	*/
		
	declare continue handler for 1329  set flag = 0;
		
	-- 打开游标
	open my_cursor;
	-- 通过游标获取值
	label:loop
		fetch my_cursor into var_empno, var_ename,var_sal;
		-- 判断flag，如果flag的值为1，则执行，否则不执行
		if flag = 1 then 
		 select var_empno, var_ename,var_sal;
	  else 
		 leave label;
	  end if;
	end loop label;
	
	-- xxxxx
	-- 关闭游标
	close my_cursor;
end $$;

delimiter ;

call proc21_cursor_handler('教研部');
drop table user_2021_11_03;




-- -----------------------------------------
-- 练习
/*
创建下个月的每天对应的表user_2021_12_01、user_2022_12_02、...

需求描述：
我们需要用某个表记录很多数据，比如记录某某用户的搜索、购买行为(注意，此处是假设用数据库保存)，当每天记录较多时，如果把所有数据都记录到一张表中太庞大，需要分表，我们的要求是，每天一张表，存当天的统计数据，就要求提前生产这些表——每月月底创建下一个月每天的表！
*/
-- 思路：循环构建表名 user_2021_11_01 到 user_2020_11_30；并执行create语句。
create database mydb18_proc_demo;
use mydb18_proc_demo;
drop procedure if exists proc22_demo;

delimiter $$
create procedure proc22_demo()
begin
	declare next_year int;  -- 下一个月的年份
	declare next_month int; -- 下一个月的月份
	declare next_month_day int;-- 下一个月最后一天的日期
		
	declare next_month_str varchar(2);  -- 下一个月的月份字符串
	declare next_month_day_str varchar(2);-- 下一个月的日字符串
	
	-- 处理每天的表名
	declare table_name_str varchar(10);
	
	declare t_index int default 1;
	-- declare create_table_sql varchar(200);
	
	-- 获取下个月的年份
	set next_year = year(date_add(now(),INTERVAL 1 month)); -- 2021
	-- 获取下个月是几月 
	set next_month = month(date_add(now(),INTERVAL 1 month)); -- 11
	-- 下个月最后一天是几号
	set next_month_day = dayofmonth(LAST_DAY(date_add(now(),INTERVAL 1 month))); -- 30
	
	if next_month < 10
		then set next_month_str = concat('0',next_month); -- 1  ---》 01
	else
		set next_month_str = concat('',next_month); -- 12
	end if;
	
	
	while t_index <= next_month_day do
		
		if (t_index < 10)
			then set next_month_day_str = concat('0',t_index);
		else
			set next_month_day_str = concat('',t_index);
		end if;
		
		-- 2021_11_01
		set table_name_str = concat(next_year,'_',next_month_str,'_',next_month_day_str);
		-- 拼接create sql语句
		set @create_table_sql = concat(
					'create table user_',
					table_name_str,
					'(`uid` INT ,`uname` varchar(50) ,`information` varchar(50)) COLLATE=\'utf8_general_ci\' ENGINE=InnoDB');
		-- FROM后面不能使用局部变量！
		prepare create_table_stmt FROM @create_table_sql;
		execute create_table_stmt;
		DEALLOCATE prepare create_table_stmt;
		
		set t_index = t_index + 1;
		
	end while;	
end $$

delimiter ;

call proc22_demo();






select year(date_add(now(),INTERVAL 1 month))


select dayofmonth(LAST_DAY(date_add(now(),INTERVAL 1 month)));


