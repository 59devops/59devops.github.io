---
title: Jenkins+GitLab+Ansible-playbook的环境安装(yum)
date: 2019-09-27 13:49:43
tags:
- Jenkins
categories:
- Jenkins
---

### 1、安装GitLab

#### 1.1 配置gitlab的yum源

```shell
# 参考：https://packages.gitlab.com/gitlab/gitlab-ce/install#bash-rpm
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh|bash
yum install -y gitlab-ce
```
<!-- more -->

#### 1.2 启动GitLab与管理

```shell
gitlab-ctl reconfigure
gitlab-ctl start
gitlab-ctl status
gitlab-ctl stop
gitlab-ctl restart
ps -aux|grep runsvdir
```

### 2、安装JDK

```shell
yum install -y java-1.8.0-openjdk
```

### 3、安装Jenkins

#### 3.1 配置Jenkins的yum源

```shell
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

#### 3.2 安装Jenkins

```shell
yum install -y jenkins
```

#### 3.3 启动jenkins

```shell
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins
```

#### 3.4 修改Jenkins配置文件

##### 3.4.1 修改Jenkins运行用户

```shell
vim /etc/sysconfig/jenkins

# 修改$JENKINS_USER，并去掉当前行的注释
$JENKINS_USER='work'
```

##### 3.4.2 修改Jenkins相关文件夹用户权限

```shell
chown -R work:work /var/lib/jenkins
chown -R work:work /var/cache/jenkins
chown -R work:work /var/log/jenkins
```

##### 3.4.3 重启Jenkins服务并检查运行Jenkins的用户是否已经切换为work

```shell
systemctl restart jenkins
ps -ef|grep jenkins
```

#### 3.5 Jenkins插件推荐

```text
1.Git Parameter			# 构建参数
2.build-name-setter		# ${BUILD_NUMBER}-$moudle-$release_tag
3.user build vars plugin	# 获取运行job的用户名
4.Jenkins修改本地默认主题
	主题URL：http://afonsof.com/jenkins-material-theme/
	1) Jenkins安装 Simple Theme插件
	2) 浏览器下载stylish css导入服务器。放到 /var/cache/jenkins/war/css
	3) 然后在Jenkins的系统配置中添加Theme配置 http://10.0.0.100:8080/css/jenkins-material-theme.css
```
