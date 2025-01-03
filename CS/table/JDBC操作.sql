drop database if exists mydb16_jdbc;
create database if not exists mydb16_jdbc;


use mydb16_jdbc;

create table if not exists student(
	sid int primary key auto_increment,
	sname varchar(20),
	age int
);

insert into student values(NULL,'宋江',30),(NULL,'武松',28),(NULL,'林冲',26);



select * from student;



-- 防止SQL注入
create table if not exists user(
	uid int primary key auto_increment,
	username varchar(20),
	password varchar(20)
);

insert into user values(NULL,'zhangsan','123456'),(NULL,'lisi','888888');

-- SQL注入
drop table if exists user;
create table user(
	uid int primary key auto_increment,
	username varchar(20),
	password varchar(20)
);
insert into user values(NULL, 'zhangsan','123456'),(NULL,'lisi','888888');




