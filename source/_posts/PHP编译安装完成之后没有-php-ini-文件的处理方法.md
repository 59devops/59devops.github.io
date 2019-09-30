---
title: PHP编译安装完成之后没有'php.ini'文件的处理方法
date: 2019-09-30 13:49:08
tags:
- PHP
categories:
- PHP
---

在我们编译安装PHP的时候，编译安装完成是不会自动生成php.ini文件的，所以需要我们手动生成。

<!-- more -->

### 1.通过命令行确定`php.ini`文件的位置

```bash
php -r "phpinfo();" | grep 'php.ini'
```

上面的命令需要在编译安装完PHP之后配好了环境变量，如果没有的话需要使用绝对路径来执行。

```bash
/usr/local/php/bin/php -r 'phpinfo();' | grep 'php.ini'
```

`/usr/local/php/bin/php`就是PHP编译安装后所在的路径。

![](http://static.staryjie.com/static/images/20190409155837.png)

如图所示，`php.ini`文件应该放在`/usr/local/php/lib/`目录下面。

### 2.生成`php.ini`文件

一般在PHP源码包中都会有现成的默认配置文件存在，只需要根据需要将他们做一定的修改即可使用。

```bash
[root@ggy-php ~]# find /tools/php-7.1.9/ -name "php.ini*"
/tools/php-7.1.9/php.ini-production
/tools/php-7.1.9/php.ini-development
[root@ggy-php ~]# 
```

通过find命令可以找到两个配置文件，一个是开发环境使用的，一个是生产环境使用的。根据自己的需要，修改配置文件并复制到`/usr/local/php/lib/`目录下，重启PHP即可。

```
cp /tools/php-7.1.9/php.ini-production /usr/local/php/lib/php.ini
killall php-fpm
/usr/local/php/sbin/php-fpm &
```
