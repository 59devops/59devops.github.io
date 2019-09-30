---
title: Mac下Homebrew的安装与使用
date: 2019-09-27 14:29:49
tags:
- Others
categories:
- Others
---

### Homebrew是什么？

官方解释： 
Homebrew是以最简单，最灵活的方式来安装苹果公司在MacOS中不包含的UNIX工具。 

<!-- more -->

### Homebrew 怎么安装 ？怎么卸载 ？


1. 安装，打开终端，复制粘贴，大约1分钟左右，下载完成，过程中需要输入密码，其他无需任何操作：

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

2. 卸载，有安装就要有卸载，打开终端，复制粘贴：

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
```

### Homebrew 怎么使用？常用命令有哪些？ ###

```text
安装软件，如：brew install oclint
卸载软件，如：brew uninstall oclint
搜索软件，如：brew search oclint
更新软件，如：brew upgrade oclint
查看安装列表， 如：brew list
更新Homebrew，如：brew update
```

### 安装wget命令 ###

```shell
brew install wget --with-libressl
```

### 安装ftp客户端 ###

```shell
brew install telnet 
brew install inetutils 
brew link --overwrite inetutils
```
