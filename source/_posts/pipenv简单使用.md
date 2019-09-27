---
title: pipenv简单使用
date: 2019-09-27 13:06:02
tags:
- Python
categories:
- Python
---

pipenv 是 Pipfile 主要倡导者、requests 作者 Kenneth Reitz 写的一个命令行工具，主要包含了Pipfile、pip、click、requests和virtualenv。Pipfile和pipenv本来都是Kenneth Reitz的个人项目，后来贡献给了pypa组织。Pipfile是社区拟定的依赖管理文件，用于替代过于简陋的 requirements.txt 文件。

<!-- more -->

## 1、安装pipenv

> 参考：https://github.com/pypa/pipenv

### 1.1 pip安装

```shell
pip install pipenv
```

### 1.2 Mac通过brew安装

```shell
brew install pipenv
```

## 2、pipenv简单使用

### 2.1 创建虚拟环境

```shell
# 进入项目目录
cd projectdir
# 创建虚拟环境
pipenv install
```

> 上面的命令会自动在~/.local/share/virtualenvs/目录下创建一个projectdir加一串随机字符串的虚拟环境目录。

### 2.2 创建指定python版本的虚拟环境

```shell
# 指定python版本为3.6.5
pipenv install --python 3.6.5
# 或者
pipenv --python 3.6.5
```

### 2.3 修改pipenv默认虚拟环境位置为当前目录下

```shell
# 设置环境变量PIPENV_VENV_IN_PROJECT=1
export export PIPENV_VENV_IN_PROJECT=1
```

> ###### 在初始化虚拟环境的时候，pipenv默认会把虚拟环境的python目录以 及后来安装的各种模块放到/home/$username/.local/share/virtualenvs里，一般/和home是在一个分区的(之前就遇到过/所在的分区写满了，整个服务器都挂掉了)，如果想放到其他地方可以有以下几种方法：
>
> 1. export PIPENV_VENV_IN_PROJECT=1 设置这个环境变量，pipenv会在当前目录下创建.venv的目录，以后都会把模块装到这个.venv下。
> 2. 自己在项目目录下手动创建.venv的目录，然后运行 pipenv run 或者 pipenv shell pipenv都会在.venv下创建虚拟环境。
> 3. 设置WORKON_HOME到其他的地方 （**如果当前目录下已经有.venv,此项设置失效**）。

### 2.4 激活虚拟环境

```shell
pipenv shell
```

### 2.5 安装相关模块并加入到Pipfile

```shell
pipenv install packagename
# 比如
pipenv install flask
```

### 2.6 安装固定版本模块并加入到Pipfile

```shell
pipenv install django==1.11
```

### 2.7 显示虚拟环境信息

```shell
pipenv --venv
```

### 2.8 显示目录信息

```shell
pipenv --where
```

### 2.9 显示Python解释器信息

```shell
pipenv --py
```

### 2.10 查看目前安装的库及其依赖

```shell
pipenv graph
```

### 2.11 检查安全漏洞

```shell
pipenv check
```

### 2.12 卸载全部包

```shell
pipenv uninstall --all
```

## 3、设置pipenv安装源为国内源

修改当前目录下Pipfile文件，将[source]下的url属性改成国内的源即可：

```text
[[source]]
url = "https://mirrors.aliyun.com/pypi/simple"
verify_ssl = true
name = "pypi"
```
