---
title: b'driver 'overlay' failed to remove root filesystem 的解决方法
date: 2019-09-30 13:56:41
tags:
- Docker
categories:
- Docker
---

### 1、docker-compose启的nexus仓库意外dead ###

&emsp;&emsp;公司的maven私服nexus是通过docker-compose启动的，不知道什么原因意外死掉了。再次启动的时候报错：

```shell
[root@test-java nexus]# docker-compose up -d
Removing nexus_nexus_1
ERROR: driver "overlay" failed to remove root filesystem for 738f492a57f80951b279c3bd82f59b6230275a298ab74d7f26c4564cf3d1cf2c: remove /var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/merged: device or resource busy
```
<!-- more -->

### 2、原因分析 ###

&emsp;&emsp;看报错应该是之前的容器无法删除导致的，`device or resource busy`应该是还有某些进程在占用。

### 3、处理问题 ###

&emsp;&emsp;先通过`docker rm`命令尝试删除该容器：

```shell
[root@test-java nexus]# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS                           NAMES
141d9363cf95        jenkins             "/bin/tini -- /usr..."   12 days ago         Exited (137) 10 days ago                                   jenkins
85e5f06d1344        jenkins             "/bin/tini -- /usr..."   12 days ago         Exited (130) 12 days ago                                   reverent_ritchie
738f492a57f8        sonatype/nexus3     "bin/nexus run"          2 weeks ago         Dead                                                       nexus_nexus_1
eef939679dd1        nginx:1.13.3        "/usr/local/nginx/..."   2 months ago        Created                    443/tcp, 0.0.0.0:8087->80/tcp   nginx2
5087229bf9aa        nginx:1.13.3        "/usr/local/nginx/..."   2 months ago        Exited (0) 2 weeks ago                                     nginx
c67cf4bdefd9        sonatype/nexus3     "bin/nexus run"          9 months ago        Dead                                                       c67cf4bdefd9_nexus_nexus_1
[root@test-java nexus]# docker rm 738f492a57f8
Error response from daemon: driver "overlay" failed to remove root filesystem for 738f492a57f80951b279c3bd82f59b6230275a298ab74d7f26c4564cf3d1cf2c: remove /var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/merged: device or resource busy
```

&emsp;&emsp;无法正常删除，尝试强制删除：

```shell
[root@test-java nexus]# docker rm -f 738f492a57f8
Error response from daemon: driver "overlay" failed to remove root filesystem for 738f492a57f80951b279c3bd82f59b6230275a298ab74d7f26c4564cf3d1cf2c: remove /var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/merged: device or resource busy
```

&emsp;&emsp;通过`docker rm`无法删除，提示文件系统相关的问题，应该是和docker容器的文件系统有关，docker是通过挂载的形式使用宿主机文件系统的。查看一下跟报错有关的挂载信息：

```shell
[root@test-java nexus]# grep docker /proc/*/mountinfo|grep 6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887
/proc/814/mountinfo:80 79 0:38 / /var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/merged rw,relatime - overlay overlay rw,lowerdir=/var/lib/docker/overlay/e580d619ecdb1aeb01f73ad07d727812a3f9776af5af0679eecfd60198884aaf/root,upperdir=/var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/upper,workdir=/var/lib/docker/overlay/6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887/work
```

>注意：`6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887`这串数字是和报错中的一致的。

&emsp;&emsp;可以看到有跟该容器相关的挂载信息仍然处于挂载中，所以导致无法删除。

&emsp;&emsp;获取该挂载进程的pid并杀掉该进程：

```shell
[root@test-java nexus]# grep docker /proc/*/mountinfo|grep 6031651302dba6053c5fde07937f4fd00dfc063577fa343b12c83f1c26b77887 | awk -F ":" '{print $1}' | awk -F "/" '{print $3}'
814
[root@test-java nexus]# kill -9 814
```

&emsp;&emsp;重新启动nexus：

```shell
[root@test-java nexus]# docker-compose up -d
Removing nexus_nexus_1
Recreating c67cf4bdefd9_nexus_nexus_1 ... error

ERROR: for c67cf4bdefd9_nexus_nexus_1  b'driver "overlay" failed to remove root filesystem for c67cf4bdefd9746ab850d09960211b02d0d184aa5e7c602095b1acdee57dc813: remove /var/lib/docker/overlay/ec743b1c55a524fd85421621314aa5acd44a29601f917f1f2eaed5f1a6d6c727/merged: device or resource busy'

ERROR: for nexus  b'driver "overlay" failed to remove root filesystem for c67cf4bdefd9746ab850d09960211b02d0d184aa5e7c602095b1acdee57dc813: remove /var/lib/docker/overlay/ec743b1c55a524fd85421621314aa5acd44a29601f917f1f2eaed5f1a6d6c727/merged: device or resource busy'
ERROR: Encountered errors while bringing up the project.
```

&emsp;&emsp;还有这样的报错，说明还有相关的挂载进程没有停止掉。找出进程并杀掉：

```shell
[root@test-java nexus]# grep docker /proc/*/mountinfo|grep ec743b1c55a524fd85421621314aa5acd44a29601f917f1f2eaed5f1a6d6c727 | awk -F ":" '{print $1}' | awk -F "/" '{print $3}'
20910
21073
[root@test-java nexus]# kill -9 20910
[root@test-java nexus]# kill -9 21073
-bash: kill: (21073) - No such process
```

&emsp;&emsp;再次启动：

```shell
[root@test-java nexus]# docker-compose up -d
Removing nexus_nexus_1
Recreating c67cf4bdefd9_nexus_nexus_1 ... done
[root@test-java nexus]# 
```

&emsp;&emsp;启动成功！
