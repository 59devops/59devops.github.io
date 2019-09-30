---
title: Mac上修改MySQL默认字符集为utf8
date: 2019-09-30 13:59:58
tags:
- MySQL
categories:
- MySQL
---

### 1、检查默认安装的mysql的字符集

```shell
mysql> show variables like '%char%';
+--------------------------+-----------------------------------------------------------+
| Variable_name            | Value                                                     |
+--------------------------+-----------------------------------------------------------+
| character_set_client     | utf8                                                      |
| character_set_connection | utf8                                                      |
| character_set_database   | latin1                                                    |
| character_set_filesystem | binary                                                    |
# For advice on how to change settings please see
| character_set_results    | utf8                                                      |
| character_set_server     | latin1                                                    |
| character_set_system     | utf8                                                      |
| character_sets_dir       | /usr/local/mysql-5.6.40-macos10.13-x86_64/share/charsets/ |
+--------------------------+-----------------------------------------------------------+
8 rows in set (0.00 sec)
```
<!-- more -->

> character\_set\_database和character\_set\_server依然是latin1的字符集，也就是说mysql后续创建的表都是latin1字符集的，不是utf8，会造成一些麻烦。所以有必要修改my.cnf。

**在修改my.cnf之前一定要关闭mysql进程，不然会遇到mysql的sock不能连接的问题。**

### 2、关闭mysqld后台进程

* 系统偏好设置里面控制mysqld，避免了去找mysqld安装位置的麻烦。

![](http://static.staryjie.com/static/images/20181205093637.png)

点击 Stop MySQL Server

![](http://static.staryjie.com/static/images/20181205093709.png)

![](http://static.staryjie.com/static/images/20181205093754.png)

### 3、修改mysql配置文件/etc/my.cnf

```shell
sudo cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
sudo vim /etc/my.cnf
```

```text
[client]部分加入：  
default-character-set=utf8  

[mysqld]部分加入：  
character-set-server=utf8
```

> 修改完成之后，启动MySQL

### 4、检查结果

```shell
mysql> show variables like '%char%';
+--------------------------+-----------------------------------------------------------+
| Variable_name            | Value                                                     |
+--------------------------+-----------------------------------------------------------+
| character_set_client     | utf8                                                      |
| character_set_connection | utf8                                                      |
| character_set_database   | utf8                                                      |
| character_set_filesystem | binary                                                    |
| character_set_results    | utf8                                                      |
| character_set_server     | utf8                                                      |
| character_set_system     | utf8                                                      |
| character_sets_dir       | /usr/local/mysql-5.6.40-macos10.13-x86_64/share/charsets/ |
+--------------------------+-----------------------------------------------------------+
8 rows in set (0.00 sec)
```
