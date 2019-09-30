---
title: Mac下安装Anaconda3
date: 2019-09-27 14:42:54
tags:
- Others
categories:
- Others
---

### 1.下载Anaconda3安装包 ###

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-5.3.0-MacOSX-x86_64.pkg
```
<!-- more -->
### 2.安装 ###

正常安装

### 3.添加环境变量 ###

```shell
echo 'export PATH="~/anaconda3/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

### 4.检查 ###

```shell
conda --versions
```
> 参考：
[Anaconda使用总结 - Python - 伯乐在线](http://python.jobbole.com/86236/)

[macOS Anaconda 安装和卸载 - 简书](https://www.jianshu.com/p/d250a4245d81)
