---
title: Jenkins构建完成之后运行脚本可以杀掉TomCat但是起不来的解决方法
date: 2019-09-27 14:17:31
tags:
- Jenkins
categories:
- Jenkins
---

写了一个重启TomCat的脚本，让jenkins编译、打包、发布时调用。在本地写好重启tomcat的脚本后，本地执行脚本没有问题，但在远程服务器上SSH免密登录执行后。发现可以把TomCat杀死，但TomCat却起不来。试了很多次发现都是只能够杀掉TomCat但是启动不起来。

百度了一下，有人说脚本远程运行的话，远程会话结束以后会把这个子进程干掉。也就是说当Jenkins远程执行完这个脚本之后，这个脚本所衍生的所有子进程都会被杀掉。
<!-- more -->
重启Tomcat的脚本：

```shell
#重启tomcat服务器
pid=`lsof -i:8080|awk 'NR==2{print $2}'`
kill -9 $pid
sh /home/tomcat/bin/startup.sh &
```

为了证实这一说法，修改了脚本：

```shell
#重启tomcat服务器
pid=`lsof -i:8080|awk 'NR==2{print $2}'`
kill -9 $pid
cd /home/tomcat/bin/
sh ./startup.sh
sleep 60
```

Jenkins再次构建并执行该脚本，发现TomCat启来了，有日志了，也看到端口了，60秒后端口就自动消失了，同时这个不会写到日志里。说明上面关于远程执行的脚本会话结束以后会把这个子进程干掉的说法是成立的。

### 解决办法 ###

在脚本的启动命令前加上nohup ,即如下

```shell
nohup sh /home/tomcat/bin/startup.sh &
```

或者：

在使用jenkins的时候shell脚本里边加上这一行就行了：`BUILD_ID=DONTKILLME`

在jenkins中配置自动更新部署项目时，如果采取用execute shell启动/关闭tomcat，会发现可以进行关闭tomcat，但是无法启动tomcat，虽然构建会显示执行成功，但是查看进程，tomcat是没有启动的。这是因为Jenkins默认会在Build结束后Kill掉所有的衍生进程。需要进行以下配置，才能避免此类情况发生:重设环境变量build_id，在execute shell输入框中加入BUILD_ID=DONTKILLME,即可防止jenkins杀死启动的tomcat进程。

```shell
BUILD_ID=DONTKILLME
#重启tomcat服务器
pid=`lsof -i:8080|awk 'NR==2{print $2}'`
kill -9 $pid
sh /home/tomcat/bin/startup.sh &
```

参考链接：
[SSH远程启动tomcat后，退出SSH,tomcat也退出](https://www.cnblogs.com/superjt/p/4079013.html)
[jenkins中通过execute shell启动的进程会被杀死的问题](http://blog.csdn.net/zhengxu189891/article/details/18710155)
