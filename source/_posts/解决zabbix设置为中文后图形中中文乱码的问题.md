---
title: 解决zabbix设置为中文后图形中中文乱码的问题
date: 2019-09-27 14:08:10
tags:
- zabbix
categories:
- zabbix
---

### 1、下载汉化的字体 ###

zabbix3.4中，存放字体的目录在`/usr/share/zabbix/fonts/`

```
wget -O /usr/share/zabbix/fonts/msyh.ttf https://raw.githubusercontent.com/chenqing/ng-mini/master/font/msyh.ttf
```
<!-- more -->
### 2、修改配置文件 ###

修改`/usr/share/zabbix/include/defines.inc.php`文件：

```shell
vim /usr/share/zabbix/include/defines.inc.php
```

![](http://static.staryjie.com/static/images/20180620140701.png)

![](http://static.staryjie.com/static/images/20180620140744.png)

### 3、重启zabbix-server ###

```shell
systemctl restart zabbix-server.service
```

![](http://static.staryjie.com/static/images/20180620140937.png)
