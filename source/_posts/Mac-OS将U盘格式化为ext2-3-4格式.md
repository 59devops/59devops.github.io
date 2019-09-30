---
title: Mac OS将U盘格式化为ext2/3/4格式
date: 2019-09-27 14:04:35
tags:
- Others
categories:
- Others
---

### 1、安装HomeBrew

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
<!-- more -->
### 2、安装e2fsprogs插件

```shell
brew install e2fsprogs
```

### 3、找到U盘盘符

```shell
diskutil list
```

![](http://static.staryjie.com/static/images/20190728191811.png)

### 4、取消U盘挂载

```shell
diskutil unmountdisk /dev/disk2
```

### 5、格式化为ext4格式

```shell
sudo $(brew --prefix e2fsprogs)/sbin/mkfs.ext4 /dev/disk2
```

回车，输入 Mac 密码再回车，过程需要稍等片刻，等待完成即可拔掉 U盘，这时候 U盘格式已经为 ext4 了。
