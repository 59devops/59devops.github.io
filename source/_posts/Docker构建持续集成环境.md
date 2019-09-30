---
title: Docker构建持续集成环境
date: 2019-09-27 13:43:13
tags:
- Docker
- CI&CD
categories:
- CI&CD
---

### 1、CI/CD介绍

CI/CD是一个持续的闭环的流程。

![CI/CD](http://static.staryjie.com/static/images/20190626160504.png)

<!-- more -->

#### 1.1 什么是CI？

​		在软件工程中，持续集成（CI）是指将所有开发者的工作副本每天多次合并到主干的做法。Grady Booch 在1991年的 Booch method 中首次命名并提出了 CI 的概念，尽管在当时他并不主张每天多次集成。而 XP（Extreme programming，极限编程）采用了 CI 的概念，并提倡每天不止一次集成。

#### 1.2 什么是CD？

​		持续交付/持续部署(CD)就是在持续集成的基础上，产品不断的迭代更新，最终能够交付到客户手中或者部署到生成环境。

#### 1.3 CI/CD的优点

1. 解放了重复性劳动

   自动化部署工作可以解放集成、测试、部署等重复性劳动，而机器集成的频率明显比手工高很多。

2. 更快地修复问题

   持续集成更早的获取变更，更早的进入测试，更早的发现问题，解决问题的成本显著下降。

3. 更快的交付成果

   更早发现错误减少解决错误所需的工作量。集成服务器在构建环节发现错误可以及时通知开发人员修复。集成服务器在部署环节发现错误可以回退到上一版本，服务器始终有一个可用的版本。

4. 减少手工的错误

   在重复性动作上，人容易犯错，而机器犯错的几率几乎为零。

5. 减少了等待时间

   缩短了从开发、集成、测试、部署各个环节的时间，从而也就缩短了中间可以出现的等待时机。持续集成，意味着开发、集成、测试、部署也得以持续。

6. 更高的产品质量

   集成服务器往往提供代码质量检测等功能，对不规范或有错误的地方会进行标致，也可以设置邮件和短信等进行警告。

#### 1.4 CI/CD最佳实践

1. 频繁检出代码

   有时候代码冲突无可避免，频繁检出代码，可以让本地的副本和代码库中的版本最小差异化。

2. 频繁提交代码

   与频繁检出代码的原理类似，频繁提交代码，可以让其他人检出副本和代码库中的版本最小差异化。

3. 减少分支，回归主干

   多个分支并行应及早将变更集成到主干中，避免同时维护软件的多个版本。

4. 使用自动化构建

   可以使用Maven、Ant等来实现自动化构建，可以在构建过程中实现自动化测试。前提是有写单元测试用例。

5. 提交测试

   在提交工作之前，每个程序员必须本地集成所有代码，做一个完整的构建和运行，并通过所有的单元测试，这样能减少集成测试在集成服务器上构建失败的风险。

6. 当前状态对每个人都可见

   集成服务器在持续集成过程中发现问题应及时发送警告给相关的干系人。

### 2、发布流程设计

![](http://static.staryjie.com/static/images/20190627094657.png)

#### 2.1 发布流程

1. 开发将代码提交到Git服务器(GitLab/GitHub/SVN等)
2. Jenkins拉取Git服务器上的代码通过Maven或者Ant构建
3. docker结合脚本(docker build & docker run)将构建好的代码封装在docker镜像中并推送到Docker镜像仓库
4. 不同的环境的配置文件可以通过配置中心来配置，测试环境拉取对应的镜像和配置文件到测试环境中运行
5. 测试通过后，结合配置中心，拉取镜像和正式环境配置文件，在正式环境中运行

#### 2.2 配置中心的必要性

​		配置中心能够根据不同的环境配置好不同的配置文件，免去了人工替换配置文件的步骤，减少了出错率，大大的提高持续集成、持续部署、持续交付的效率。目前常用的配置中心有[apollo](https://github.com/ctripcorp/apollo)和[disconf](https://github.com/knightliao/disconf)等。

​		配置中心的搭建可以在网上找到各种文档，也可以在参考官方的安装文档。[apollo安装](https://blog.csdn.net/luhong327/article/details/81453001)、[disconf安装](https://www.cnblogs.com/garfieldcgf/p/6439221.html)

### 3、部署Git服务器

#### 3.1 安装git

```shell
yum install -y git
```

#### 3.2 添加git用户并设置密码

```shell
useradd git
passwd git
```

#### 3.3 创建项目

```shell
# 1.切换到git用户
su - git
# 2.创建项目
mkdir -p solo.git
cd solo.git/
# 3.初始化项目
git --bare init
```

#### 4.4 Jenkins服务器实现免密码交互

```shell
# 1.生成私钥
ssh-keygen
# 2.将公钥发送到Git服务器
ssh-copy-id git@10.0.0.20
```

![](http://static.staryjie.com/static/images/20190629160945.png)

![](http://static.staryjie.com/static/images/20190629161138.png)

### 4、部署Harbor镜像仓库

#### 4.1 部署方式

1. 在线安装
2. 离线安装
3. OVA程序安装

#### 4.2 离线安装

##### 4.2.1 安装docker和docker-compose

​		因为Harbor离线安装方式是基于docker-compose编排安装的。

```shell
# 1.获取docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# 2.给予可执行权限
sudo chmod +x /usr/local/bin/docker-compose
# 3.加入环境变量，有多种方式，个人认为下面的方式最简单有效
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# 4.检查
docker-compose --version
```

##### 4.2.2 下载Harbor离线安装包

```shell
# Harbor下载地址https://github.com/goharbor/harbor/releases
cd /opt && wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz
```

##### 4.2.3 安装Harbor

###### 4.2.3.1 解压安装包

```shell
# 1.解压安装包
tar xf harbor-offline-installer-v1.8.0.tar
```

###### 4.2.3.2 修改配置文件

```shel
vim /opt/harbor/harbor.yml

hostname: harbor.biu2ful.xyz
https:
   port: 443
   certificate: /etc/docker/certs.d/harbor.biu2ful.xyz/ca.crt
   private_key: /etc/docker/certs.d/harbor.biu2ful.xyz/ca.key
harbor_admin_password: Harbor123456
database:
  password: root123
data_volume: /data
clair:
  updaters_interval: 12
  http_proxy:
  https_proxy:
  no_proxy: 127.0.0.1,localhost,core,registry
jobservice:
  max_job_workers: 10
chart:
  absolute_url: disabled
log:
  level: info
  rotate_count: 50
  rotate_size: 200M
  location: /var/log/harbor
_version: 1.8.0
```

​		精简后的配置文件如下图：

![](http://static.staryjie.com/static/images/20190630212517.png)

###### 4.2.3.3 生成对应的签名证书文件

```shell
# 1.创建证书存放路径
mkdir -p /etc/docker/certs.d/harbor.biu2ful.xyz/
# 2.生成自签名证书key文件
openssl genrsa -out /etc/docker/certs.d/harbor.biu2ful.xyz/ca.key 2048
# 3.生成自签名证书crt文件
openssl req -x509 -new -nodes -key /etc/docker/certs.d/harbor.biu2ful.xyz/ca.key -subj "/CN=harbor.biu2ful.xyz" -days 100000 -out /etc/docker/certs.d/harbor.biu2ful.xyz/ca.crt
```

###### 4.2.3.4 配置Harbor

```shell
cd /opt/harbor/ && ./prepare
```

![](http://static.staryjie.com/static/images/20190630215243.png)

###### 4.2.3.4 安装Harbor

```shell
./install
```

![](http://static.staryjie.com/static/images/20190630215318.png)

![](http://static.staryjie.com/static/images/20190630215331.png)

#### 4.3 客户端配置

##### 4.3.1 创建证书存放路径

```shell
mkdir -p /etc/docker/certs.d/harbor.biu2ful.xyz/
```

##### 4.3.2 获取自签名证书crt文件

```shell
# 从Harbor所在服务器scp证书文件到docker客户端，其中10.0.0.30是docker客户端的地址，根据自己的对应修改。
scp ca.crt root@10.0.0.30:/etc/docker/certs.d/harbor.biu2ful.xyz/
```

##### 4.3.3 重启docker服务

```shell
systemctl restart docker.service
```

#### 4.4 测试是否能够正常使用

##### 4.4.1浏览器访问

​		访问：https://harbor.biu2ful.xyz/

![](http://static.staryjie.com/static/images/20190630215555.png)

##### 4.4.2 docker客户端登陆

```shell
docker login harbor.biu2ful.xyz
```

![](http://static.staryjie.com/static/images/20190630215733.png)

##### 4.4.3 推送和拉取镜像

```shell
# 推送镜像到Harbor仓库
docker tag mysql:5.6 harbor.biu2ful.xyz/library/mysql:5.6
docker push harbor.biu2ful.xyz/library/mysql:5.6
```

![](http://static.staryjie.com/static/images/20190630215828.png)

```shell
# 从Harbor仓库拉取镜像
docker image rm harbor.biu2ful.xyz/library/mysql:5.6
docker pull harbor.biu2ful.xyz/library/mysql:5.6
```

![](http://static.staryjie.com/static/images/20190630215855.png)

### 5、构建业务基础镜像

#### 5.1 编写Dockerfile

```text
FROM centos:7
MAINTAINER staryjie@gmail.com

RUN yum install unzip iproute -y
ENV JAVA_HOME /usr/local/jdk1.8.0_141/
ADD apache-tomcat-8.0.46.tar.gz /usr/local
RUN mv /usr/local/apache-tomcat-8.0.46.tar.gz /usr/local/tomcat
WORKDIR /usr/local/tomcat
EXPOSE 8080
ENTRYPOINT ["./bin/catalina.sh", "run"]
```

#### 5.2 通过Dockerfile构建镜像

```shell
docker build -t tomcat:v1 .
```

#### 5.3 将镜像推送到Harbor仓库

```shell
docker tag tomcat:v1 harbor.biu2ful.xyz/test/tomcat:v
docker push harbor.biu2ful.xyz/test/tomcat:v1
```

![](http://static.staryjie.com/static/images/20190629163516.png)

### 6、测试服务器安装Docker

#### 6.1 安装依赖

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2 chrony
```

##### 6.2 添加阿里云的docker仓库

```shell
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

##### 6.3 安装docker

```shell
yum install -y docker-ce docker-ce-cli containerd.io
```

##### 6.4 启动并设置开机自启

```shell
systemctl start docker.service
systemctl enable docker.service
```

##### 6.5 配置daocloud加速

```shell
systemctl start docker.service
systemctl enable docker.service
systemctl start chronyd.service
systemctl enable chronyd.service
```

##### 6.6 重启docker服务

```shell
systemctl restart docker
```

##### 6.7 检查是否正常安装docker

```shell
docker run hello-world
```

>  下面是一个很简单的安装脚本：

```shell
#!/bin/bash

# 1.安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2 chrony
# 2.添加阿里云的docker仓库
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 3.安装docker
yum install -y docker-ce docker-ce-cli containerd.io
# 4.启动并设置开机自启
systemctl start docker.service
systemctl enable docker.service
# 5. 配置daocloud加速
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
# 6.重启docker服务
systemctl restart docker
# 7.检查是否正常安装docker
docker run hello-world
```

### 7、Jenkins安装

#### 7.1 构建jenkins镜像

​		编写Dockerfile：

```text
FROM jenkins/jenkins
USER root
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && wget http://static.staryjie.com/sources.list -O /etc/apt/sources.list
RUN apt-get update && apt-get install -y git libltdl-dev
```

​		通过Dockerfile构建镜像：

```shell
docker build -t jenkins:v1 .
```

> 在安装的时候发现版本太低的Jenkins很多插件都装不上，建议使用最新版本的Jenkins。
>
> https://www.cnblogs.com/sxdcgaq8080/p/10489326.html

#### 7.2 通过镜像启动容器

```shell
docker run -d \
--name jenkins \
-p 8080:8080 \
-p 50000:50000 \
# jenkins目录
-v /var/jenkins_home/:/var/jenkins_home \
# 挂载宿主机maven到jenkins容器
-v /usr/local/maven3.6/:/usr/local/maven \
# 挂载宿主机jdk到jenkins容器
-v /usr/local/jdk1.8.0_141/:/usr/local/jdk \
# 挂载宿主机docker到jenkins容器
-v /var/run/docker.sock:/var/run/docker.sock \
# 将docker相关命令挂载到jenkins容器
-v $(which docker):/usr/bin/docker \
# 挂载sshkey，实现免密码
-v ~/.ssh:/root/.ssh \
jenkins:v1
# registry.cn-hangzhou.aliyuncs.com/harbor-aliyun/jenkins:v1
```

![](http://static.staryjie.com/static/images/20190629160309.png)

#### 7.3 浏览器访问http://ip:8080

![](http://static.staryjie.com/static/images/20190629160423.png)

#### 7.4 自定义安装Jenkins插件

![](http://static.staryjie.com/static/images/20190629161631.png)

![](http://static.staryjie.com/static/images/20190629161741.png)

#### 7.5 创建管理员账号

![](http://static.staryjie.com/static/images/20190630124544.png)

### 8、Jenkins基本配置

#### 8.1 配置Jenkins的URL

​		根据自己的实际情况设置，可以直接是ip+端口，或者域名通过nginx或者其他web中间件代理。

![](http://static.staryjie.com/static/images/20190630124656.png)

#### 8.2 开始使用Jenkins

![](http://static.staryjie.com/static/images/20190630125049.png)

开始使用Jenkins之后进到Jenkins的首页：

![](http://static.staryjie.com/static/images/20190630125137.png)

#### 8.3 系统管理-全局配置

##### 8.3.1 配置JDK

​		在启动jenkins容器的时候我们将宿主机的jdk挂载到了容器中，所以不需要勾选自动安装，只需要将启动时候指定的路径填写好即可：

![](http://static.staryjie.com/static/images/20190630125555.png)

##### 8.3.2 配置git

​		git是通过yum安装的，所以配置直接使用默认的就可以：

![](http://static.staryjie.com/static/images/20190630125837.png)

##### 8.3.3 配置Maven

​		和jdk配置一样，在启动jenkins容器的时候就已经将宿主机的Maven挂载在容器中了，所以只要配置好路径即可：

![](http://static.staryjie.com/static/images/20190630130047.png)

#### 8.4 系统管理-系统配置

##### 8.4.1 SSH remote hosts配置

​		增加一个Jenkins要访问的docker主机的ip，为了实现免密码交互，将Jenkins主机的公钥发送到docker主机：

```shell
ssh-copy-id root@10.0.0.30
```

​		在Jenkins中添加凭据：

![](http://static.staryjie.com/static/images/20190630131002.png)

​		在系统配置中添加SSH remote hosts配置：

![](http://static.staryjie.com/static/images/20190630131541.png)

### 9、Jenkins创建项目

#### 9.1 创建项目

​		在首页有一个创建新任务的选项。

![](http://static.staryjie.com/static/images/20190630131704.png)

​		创建一个Maven的项目：

![](http://static.staryjie.com/static/images/20190630131803.png)

#### 9.2 项目配置

##### 9.2.1 源码管理

​		在源码管理选项中选择自己的源码管理方式和源码拉取地址：

![](http://static.staryjie.com/static/images/20190630132104.png)

##### 9.2.2 Maven构建前-配置Maven跳过项目测试用例

​		参数是：clean package -Dmaven.test.skip=true

![](http://static.staryjie.com/static/images/20190630132326.png)

##### 9.2.3 Maven构建后配置

​		通过构建后配置将war包基于基础业务镜像进行构建新的镜像，并上传到Harbor镜像仓库：

```shell
cd $WORKSPACE
docker login -u admin -p Harbor123456 harbor.biu2ful.xyz
cat > Dockerfile << EOF
FROM harbor.biu2ful.xyz/test/tomcat:v1
MAINTAINER staryjie@gmail.com

COPY target/solo.war /tmp/ROOT.war
RUN rm -rf /usr/local/tomcat/webapps/* &&  \
         unzip /tmp/ROOT.war -d /usr/local/tomcat/webapps/ROOT && \
         rm -f /tmp/ROOT.war
ENTRYPOINT ["./bin/catalina.sh", "run"]
EOF

docker build -t harbor.biu2ful.xyz/test/solo:v1 .
docker push harbor.biu2ful.xyz/test/solo:v1
```

![](http://static.staryjie.com/static/images/20190630143110.png)

##### 9.2.4 构建完成后在远程主机上执行命令

​		上一步将新构建的镜像推送到Harbor仓库，这一步通过仓库的镜像在远程主机上启动一个容器。

```shell
BUILD_ID=DONTKILLME
docker login -uadmin -pHarbor123456 harbor.biu2ful.xyz
docker rm -f solo|true
docker image rm -f harbor.biu2ful.xyz/test/solo:v1|true
docker run -d --name solo -p 8888:8080 -v /usr/local/jdk1.8.0_141/:/usr/local/jdk1.8.0_141/ harbor.biu2ful.xyz/test/solo:v1
```

![](http://static.staryjie.com/static/images/20190630144948.png)

### 10、测试

#### 10.1 将项目代码推送到Git服务器

​		这里通过一个GitHub上java的开源博客系统来测试。

```shell
# 1.将Git服务器新建的仓库clone到本地
cd /root/cicd && git clone root@10.0.0.20:/home/git/solo.git
# 2.获取代码
git clone https://github.com/b3log/solo.git
# 3.将GitHub上clone的代码复制到从Git仓库clone的空仓库里面
cp ./solo-master/* ./solo/ -rf
# 4.将代码通过git提交到Git服务器创建好的仓库
git config --global user.email "staryjie@163.com"
git config --global user.name "staryjie"
git add .
git commit -m "all"
git push origin master
```

#### 10.2 Jenkins构建

##### 10.2.1 构建项目

​		通过上面已经创建的Maven项目solo_blog来构建：

![](http://static.staryjie.com/static/images/20190630133041.png)

##### 10.2.3 查看控制台输出

​		点击立即构建之后就可以点击查看控制台输出来查看整个构建过程:

![](http://static.staryjie.com/static/images/20190630133217.png)

​		第一次构建需要花费的时间比较多，耐心等待一会儿就可以看到构建结果：

![](http://static.staryjie.com/static/images/20190630134051.png)

​		在服务器上查看构建好的war包：

![](http://static.staryjie.com/static/images/20190630134258.png)

​		添加构建后将war包和基础镜像构建新镜像并推送到Harbor仓库的配置后，再次构建：

![](http://static.staryjie.com/static/images/20190630143336.png)

​		在Harbor仓库查看镜像：

![](http://static.staryjie.com/static/images/20190630143506.png)

​		配置了远程主机拉取镜像并运行容器之后，查看Jenkins执行结果：

![](http://static.staryjie.com/static/images/20190630211739.png)

​		在远程主机查看是否有对应的镜像和已经运行的叫solo的容器：

![](http://static.staryjie.com/static/images/20190630211617.png)

![](http://static.staryjie.com/static/images/20190630213434.png)

​		在浏览器上访问：http://10.0.0.30:8888

![](http://static.staryjie.com/static/images/20190630211855.png)
