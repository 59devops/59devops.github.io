---
title: FTP服务搭建配置
date: 2019-09-27 14:45:08
tags:
- Linux
- FTP
categories:
- FTP
---

### 1、什么是文件共享服务？

简单来说就是文件域存储块设备可以共享给他人使用。

#### 1.1 实现文件共享服务的三种方式

1. FTP：属于应用层服务，可以跨平台使用
2. NFS：属于内核模式，不可以跨平台使用
3. Samba：可以跨平台使用
<!-- more -->
#### 1.2 实现存储设备域服务器连接的三种方式

1. DAS：连接磁盘
2. NAS：通过nfs/cifs协议实现网络文件共享(文件存储方式)，电子邮件、网页服务器、多媒体流服务、档案分享等就适用于NAS存储架构
3. SAS：通过网线或者光纤实现ISCSI和FCSAN将物理存储设备连接起来使用(块存储方式比较底层，需要格式化并挂载当本地磁盘使用)，数据库有关的应用适用于SAS存储架构

### 2、FTP简介

FTP是File Transfer Protocol文件传输协议的缩写，基于网络来传输文件的应用层协议。

FTP能够通过网络来传输文件，主要是因为工作再应用层所以不会受到平台的限制。

#### 2.1 FTP的工作方式

![](http://static.staryjie.com/static/images/20190702114521.png)

客户端通过TCP三次握手与服务端建立连接，连接建立成功之后才可以进行文件传输。

1. FTP的数据传输分为命令数据与文件数据，命令传输的就是客户端要执行的命令，服务端收到后返回给客户端执行结果，如ls命令就返回给当前目录下的所有文件个目录。文件传输就是客户端要传输的数据，服务端与客户端连接来传输文件数据。
2. FTP的服务端与客户端建立连接大体有三个步骤，建立连接、传输数据、断开连接。
3. FTP是基于TCP协议来传输数据的，使用21端口来建立认证通道，20端口来建立数据通道。
4. FTP是明文传输的。
5. FTP的用户可以分为实体用户(real user)，匿名用户(anonymous user)，访客用户(guest user)。

#### 2.2 FTP的工作模式

由于现在的网络架构中都会有防火墙来阻止端口与高位端口被主动连接，特别20端口是被禁止主动连接的，因为20端口是FTP的数据端口，所以为了解决客户端或者服务端的防火墙问题，FTP就有了主动和被动两种工作模式，通过防火墙内的一端来主动连接防火墙外端的一方，这样子就不会被防火墙阻拦。

##### 2.2.1 主动模式

![](http://static.staryjie.com/static/images/20190703095025.png)

一般用于服务端存在防火墙的情况，客户端无法主动连接到服务端的20数据端口，需要由服务端主动连接到客户端的两个端口。

1. 两端在建立TCP通信通道后，客户端会发送port请求与服务端的21端口认证连接并开放用来建立数据连接的高位端口。
2. 服务端在收到请求后，会通过20端口发送ACK响应请求。
3. 服务端通过20端口与客户端发送的高位端口建立数据连接通道。

##### 2.2.2 被动模式

![](http://static.staryjie.com/static/images/20190703095051.png)

一般用于客户端存在防火墙的情况，服务端在收到连接请求后因为客户端存在防火墙而无法达到客户端高位端口，需要客户端主动连接至服务端的数据传输端口。

1. 两端在建立TCP通信通道连接后，客户端会发送PASV请求给服务端。
2. 服务端在收到PASV请求后就会打开一个高位端口作为数据传输端口来响应给客户端等待客户端连接。
3. 客户端在收到响应后，就会去连接服务端响应的端口建立数据传输通道。

#### 2.3 FTP的用户类型

1. 匿名用户

   anonymous或ftp

2. 本地用户

   账号名称、密码等信息保存在passwd、shadow文件中

3. 虚拟用户

   使用独立的账号/密码数据文件

   user_list ftp_user1  123456  /var/pub

### 3、VSFTPD的安装及使用

官方网站：http://vsftpd.beasts.org

#### 3.1 关闭防火墙和SELINUX

```shell
# 1.关闭防火墙
systemctl stop firewalld.service
systemctl disabled firewalled.service
# 2.关闭SELINUX
## 2.1 永久关闭，需要重启服务器
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
reboot
## 2.2 临时关闭
setenforce 0
```

#### 3.2 安装vsftpd

```shell
yum install -y vsftpd
```

#### 3.3 查看安装生成的文件

```shell
[root@ftp ~]# rpm -qa|grep vsftpd
vsftpd-3.0.2-25.el7.x86_64
[root@ftp ~]# rpm -ql vsftpd
/etc/logrotate.d/vsftpd
/etc/pam.d/vsftpd					# pam认证文件
/etc/vsftpd
/etc/vsftpd/ftpusers			# 限制登录文件
/etc/vsftpd/user_list
/etc/vsftpd/vsftpd.conf		# 主配置文件
/etc/vsftpd/vsftpd_conf_migrate.sh
/usr/lib/systemd/system-generators/vsftpd-generator
/usr/lib/systemd/system/vsftpd.service
/usr/lib/systemd/system/vsftpd.target
/usr/lib/systemd/system/vsftpd@.service
/usr/sbin/vsftpd					# 程序文件
/usr/share/doc/vsftpd-3.0.2
/usr/share/doc/vsftpd-3.0.2/AUDIT
/usr/share/doc/vsftpd-3.0.2/BENCHMARKS
/usr/share/doc/vsftpd-3.0.2/BUGS
/usr/share/doc/vsftpd-3.0.2/COPYING
/usr/share/doc/vsftpd-3.0.2/Changelog
/usr/share/doc/vsftpd-3.0.2/EXAMPLE
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE/README.configuration
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE/vsftpd.conf
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE/vsftpd.xinetd
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE_NOINETD
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE_NOINETD/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE_NOINETD/README.configuration
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/INTERNET_SITE_NOINETD/vsftpd.conf
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/PER_IP_CONFIG
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/PER_IP_CONFIG/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/PER_IP_CONFIG/README.configuration
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/PER_IP_CONFIG/hosts.allow
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_HOSTS
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_HOSTS/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS/README
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS/README.configuration
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS/logins.txt
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS/vsftpd.conf
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS/vsftpd.pam
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS_2
/usr/share/doc/vsftpd-3.0.2/EXAMPLE/VIRTUAL_USERS_2/README
/usr/share/doc/vsftpd-3.0.2/FAQ
/usr/share/doc/vsftpd-3.0.2/INSTALL
/usr/share/doc/vsftpd-3.0.2/LICENSE
/usr/share/doc/vsftpd-3.0.2/README
/usr/share/doc/vsftpd-3.0.2/README.security
/usr/share/doc/vsftpd-3.0.2/REWARD
/usr/share/doc/vsftpd-3.0.2/SECURITY
/usr/share/doc/vsftpd-3.0.2/SECURITY/DESIGN
/usr/share/doc/vsftpd-3.0.2/SECURITY/IMPLEMENTATION
/usr/share/doc/vsftpd-3.0.2/SECURITY/OVERVIEW
/usr/share/doc/vsftpd-3.0.2/SECURITY/TRUST
/usr/share/doc/vsftpd-3.0.2/SIZE
/usr/share/doc/vsftpd-3.0.2/SPEED
/usr/share/doc/vsftpd-3.0.2/TODO
/usr/share/doc/vsftpd-3.0.2/TUNING
/usr/share/doc/vsftpd-3.0.2/vsftpd.xinetd
/usr/share/man/man5/vsftpd.conf.5.gz
/usr/share/man/man8/vsftpd.8.gz
/var/ftp									# FTP家目录
/var/ftp/pub
[root@ftp ~]# 
```

#### 3.4 基于匿名用户的访问控制

要配置基于匿名用户的访问控制，需要修改vsftpd的主配置文件`/etc/vsftpd/vsftpd.conf`，主要有下面几个参数：

- anonymous_enable=YES：启用匿名用户
- anon_upload_enable=YES：允许匿名用户上传文件
- anon_mkdir_write_enable=YES：是否允许匿名用户创建目录，要考虑文件系统上的家目录，必须要有写权限
- anon_other_write_enable=YES：允许匿名用户更多于上传或者建立目录之外的权限，譬如删除或者重命名
- anon_umask=077：指定上传文件的默认所有者和权限

##### 3.4.1 运行匿名用户登录

不修改配置文件直接启动后，直接通过FTP软件连接即可，用户名默认是ftp，没有密码。

```shell
systemctl start vsftpd.service
```

![](http://static.staryjie.com/static/images/20190703141914.png)

但是此时匿名用户是不能上传文件和创建目录的：

![](http://static.staryjie.com/static/images/20190703142455.png)



##### 3.4.2 运行匿名用户上传文件、创建目录

开启允许匿名用户上传文件和创建文件夹的权限：

```shell
cd /etc/vsftpd/
vim vsftpd.conf
# 开启下面三个权限
anonymous_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
# 进入ftp家目录，创建一个文件夹并授权
[root@ftp ~]# cd /var/ftp/
[root@ftp ftp]# mkdir -p ./testdir
[root@ftp ftp]# setfacl -m u:ftp:rwx ./testdir/
[root@ftp ftp]# getfacl ./testdir/
# file: testdir/
# owner: root
# group: root
user::rwx
user:ftp:rwx
group::r-x
mask::rwx
other::r-x
[root@ftp ftp]# 
```

重新登录ftp，在testdir目录中可以创建目录和上传文件，但是却没有删除文件和重命名文件的权限。

![](http://static.staryjie.com/static/images/20190705170142.png)

##### 3.4.3 开启匿名用户删除和重命名权限

```shell
vim /etc/vsftpd/vsftpd.conf
# 增加下面的内容，重启vsftpd服务
anon_other_write_enable=YES
systemctl restart vsftpd.service
```

测试删除文件和重命名：

![](http://static.staryjie.com/static/images/20190703145738.png)

#### 3.5 基于本地用户的访问控制

默认情况下，操作系统的账户是可以直接使用用户名和密码登陆的。并且登陆之后，默认进入自己的家目录。

基于本地用户的访问控制也通过修改vsftpd的配置文件来实现，主要有一下几个参数：

1. local_enable=YES：是否允许Linux用户登录，默认是允许的，当然也可以禁止
2. write_enable=YES：是否允许系统用户上传文件
3. local_root=/ftproot：非匿名用户登录所在目录，当使用Linux用户登录成功之后，就不会默认在自己的家目录了。相反，会位于指定的目录之下
4. local_umask=022：指定系统用户上传文件的默认权限

##### 3.5.1 允许系统用户登录并上传文件

```shell
vim /etc/vsftpd/vsftpd.conf
# 默认以下三个参数都是开启的
local_enable=YES
write_enable=YES
local_umask=022

# 添加一个系统用户并设置密码
useradd centos
echo "123456"|passwd --stdin centos
```

系统用户默认具有上传文件、创建目录、删除和重命名的权限。

![](http://static.staryjie.com/static/images/20190703150846.png)

系统用户默认也可以进入其他目录，所以并不安全，所以如果要启用系统用户登陆FTP那么就要修改配置文件，禁止系统用户访问除了家目录以外的其他目录。

##### 3.5.2 配置本地用户只能访问自己的家目录

修改vsftpd.conf配置文件

```shell
vim /etc/vsftpd/vsftpd.conf
# 开启下面的参数
chroot_local_user=YES
# 这个参数是全局的，开启后所有的本地用户都不能访问除了家目录以外的目录
```

但是开启这个参数之后，由于vsftpd更新到2.3.5之后，vsftpd增强了安全检查，如果用户被限定在了其主目录下，则该用户的主目录不能再具有写权限了！如果检查发现还有写权限，就会报该错误。

要解决这个错误有两种方式：

```shell
# 1.方式一：将对应家目录的写权限去除
chmod a-w /home/centos
# 2.方式二：在配置文件在加入下面的参数
allow_writeable_chroot=YES
```



##### 3.5.3 配置指定的本地用户只能访问家目录

配置指定用户只能访问家目录，其他用户可以访问其他目录，需要在配置文件中关闭全局设置的参数`allow_writeable_chroot=YES`，开启下面两个参数：

```shell
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
```

然后需要创建指定的文件`chroot_list`并在文件中指定对应的用户：

```shell
vim /etc/vsftpd/chroot_list
# 限制只能在家目录
centos

# 重启vsftpd服务
systemctl restart vsftpd.service
# 新建一个用户并设置密码
useradd redhat
echo "123456"|passwd --stdin redhat
```

用centos用户访问，只能在自己的家目录中：

![](http://static.staryjie.com/static/images/20190703162409.png)

用redhat用户访问，可以访问除了家目录以外的其他目录：

![](http://static.staryjie.com/static/images/20190703162439.png)

#### 3.6 设置chroot

在默认配置中，本地用户可以切换到自己家目录以外的其他目录进行浏览，并在权限许可的范围内进行下载和上传。这样的设置对于一个FTP服务器来说是不安全的。

如果希望本地用户登录之后不能访问除了家目录以外的目录，则需要设置chroot选项，具体设置下面三个选项：

```shell
chroot_local_user
chroot_list_enable
chroot_list_file
```

##### 3.6.1 设置所有用户只需chroot

只需要将`chroot_local_user`选项设置为`YES`，所有的本地用户都只能访问自己的家目录。

```shell
chroot_local_user=YES
```

##### 2.6.2 设置部分指定用户执行chroot

需要注释全局的设置或者设为NO，然后开启另外两个选项：

```shell
chroot_local_user=NO
chroot_list_enable=YES
chroot_list_file=/etc/vaftpd/chroot_list
```

这样，文件`/etc/vaftpd/chroot_list`中的用户就只能访问自己的家目录，其他本地用户可以访问除了家目录的其他目录。



配置基于本地用户的访问限制，需要修改配置文件，主要有以下两种方式：

1. 限制指定的本地用户不能访问，而其他本地用户可以访问

   ```shell
   userlist_enable=YES
   userlist_deny=YES
   userlist_file=/etc/vsftpd/user_list
   ```

   使文件/etc/vsftpd/user_list中指定的本地用户不能访问FTP服务器，而其他的本地用户可以访问FTP服务器。

   ```shell
   userlist_enable=YES
   userlist_deny=NO
   userlist_file=/etc/vsftpd/user_list
   ```

#### 3.7 提示信息

##### 3.7.1 登陆提示信息

登陆提示信息图形界面(FTP软件)是看不到的，只适用于ftp作为客户端的时候。可以使用下面的方式进行配置。但是优先级却不一样。

```shell
# 如果限制用户只能访问家目录，下面这个配置优先生效
ftpd_banner="Welcome to Mage Ftp Server!"
# 下面这个优先级较上一个配置低
banner_file=/etc/vsftpd/ftpbanner.txt

# 其他情况当两个配置都在的时候，默认banner_file的优先生效

```

![](http://static.staryjie.com/static/images/20190703165059.png)

![](http://static.staryjie.com/static/images/20190703164725.png)

##### 3.7.2 访问目录提示信息

当用户进入某一目录后，可以给用户一个提示消息。用来提示这个目录的作用。在相应的目录下新建一个隐藏文件`.message`，该文件中进行提示信息描述。需要添加如下配置：

```shell
dirmessage_enable=YES
message_file=.message

# 在/var/ftp/pub下新建.message
vim /var/ftp/pub/.message
This is the public floder.

```

![](http://static.staryjie.com/static/images/20190703165457.png)

#### 3.8 进一步配置VSFTPD

##### 3.8.1 最大传输速率限制

```shell
local_max_rate=50000
anon_max_rate=30000

```

上面的设置是将本地用户的最大传输速率限制为50kbytes/s，匿名用户最大传输速率限制为30kbytes/s。

##### 3.8.2 设置客户端连接时的端口范围

```shell
pasv_min_port=50000
pasv_max_port=60000

```

上面的设置将客户端连接时的端口范围限制在50000-60000之间，提高系统安全性。

##### 3.8.3 基本性能和安全选项配置

```shell
# 1.设置空闲用户会话中断时间(单位:秒)
idle_session_timeout=6000

# 2.设置空闲的数据连接的终端时间(单位:秒)
date_connection_timeout=120

# 3.设置客户端空闲时的自动中断和激活连接时间(单位:秒)
accept_timeout=60
connect_timeout=60
# 上面的配置将是客户端1分钟后自动中断，在中断一分钟后自动激活连接

```

### 4、VSFTPD虚拟用户

#### 4.1 虚拟用户

- 所有虚拟用户会统一映射为一个指定的系统账号：访问共享设置，即为此系统账号的家目录。
- 各虚拟账户可以被赋予不同的访问权限，通过匿名用户的权限控制参数进行指定。

#### 4.2 虚拟账号的存储方式

##### 4.2.1 文本

编辑文本文件，该文件需要被编码为hash格式。奇数行为用户名、偶数行为密码。

```shell
db_load -T -t hash -f vusers.txt vusers.db

```

- 基于文件验证的vsftpd虚拟用户

  ```shell
  # 1.创建用户数据库文件
  vim /etc/vsftpd/vusers.txt
  zhangsan
  123456
  lisi
  123456
  
  # 2. 生成数据库文件
  cd /etc/vsftpd/
  db_load -T -t hash -f vusers.txt vusers.db
  
  # 3.修改数据库文件权限
  chmod 600 ./vusers.db
  
  # 4.创建系统用户和访问FTP目录
  # 创建系统用户并指定家目录
  useradd -d /var/ftproot -s /sbin/nologin vuser
  # 修改家目录权限
  chmod +rwx /var/ftproot
  
  # 5.创建pam配置文件
  # 修改pam配置文件，让vsftpd支持pam模块进行身份验证
  vim /etc/pam.d/vsftpd.db
  auth required pam_userdb.so db=/etc/vsftpd/vusers
  account required pam_userdb.so db=/etc/vsftpd/vusers
  
  # 6.修改vsftpd主配置文件指定pam配置文件
  vim /etc/vsftpd/vsftpd.conf
  guest_enable=YES
  guest_username=vuser
  pam_service_name=vsftpd.db
  
  # 7.修改虚拟用户权限配置
  vim /etc/vsftpd/vsftpd.conf
  user_config_dir=/etc/vsftpd/vusers.d/
  # 创建配置目录并给用户设置权限(权限配置文件与用户名一样)
  mkdir -p /etc/vsftpd/vusers.d/
  cd /etc/vsftpd/vusers.d/
  # 给zhangsan设置权限
  vim zhangsan
  # 虚拟用户上传权限
  anon_upload_enable=YES
  # 虚拟用户创建文件夹
  anon_mkdir_write_enable=NO
  # 虚拟的其他用户对指定用户目录的写权限
  anon_other_write_enable=NO
  # 修改登录目录至其他目录
  # local_root=/ftproot
  
  ```

  重启vsftpd服务，用zhangsan用户登录，只能上传文件，不能创建文件夹和删除文件：

  ![](http://static.staryjie.com/static/images/20190705150335.png)

  ```shell
  # 给lisi配置权限
  cd /etc/vsftpd/vusers.d/
  vim lisi
  # 虚拟用户上传权限
  anon_upload_enable=YES
  # 虚拟用户创建文件夹
  anon_mkdir_write_enable=YES
  # 虚拟的其他用户对指定用户目录的写权限
  anon_other_write_enable=YES
  # 修改登录目录至其他目录
  #local_root=/ftproot
  
  ```

  重启vsftpd服务，用lisi账号登陆，可以上传、新建、删除：

  ![](http://static.staryjie.com/static/images/20190705150834.png)

##### 4.2.2 关系型数据库

实时查询数据库完成用户认证。

- MySQL

  https://www.cnblogs.com/zhenhui/p/5916116.html

  pam需要依赖于pam_mysql

  - /lib/security/pam_mysql.so
  - /usr/share/doc/pam_mysql-0.7/README

1. 安装MySQL及pam_mysql插件

```shell
yum install -y mariadb-server pam-devel mariadb-devel vsftpd ftp
# 下载pam_mysql源码包
wget http://www.huzs.net/soft/vsftpd/pam_mysql-0.7RC1.tar.gz
# 编译安装pam_mysql
tar xf pam_mysql-0.7RC1.tar.gz && cd pam_mysql-0.7RC1
./configure --with-openssl --with-pam-mods-dir=/lib/security/
make && make install

```

2. 创建vsftpd数据库和用户表

```shell
# 启动数据库
systemctl enable mariadb.service
systemctl start mariadb.service
# 初始化数据库
/usr/bin/mysql_secure_installation

```

```sql
CREATE DATABASE vsftpd;
use vsftpd;
CREATE TABLE users (
	id int AUTO_INCREMENT NOT NULL,
  name char(20) binary NOT NULL,
  password char(48) binary NOT NULL,
  primary key(id)
);

```

![](http://static.staryjie.com/static/images/20190705154517.png)

3. 创建虚拟用户

```sql
INSERT INTO users(name,password) values('jack',PASSWORD('123456')),('tom',PASSWORD('123456'));

```

![](http://static.staryjie.com/static/images/20190705154758.png)

4. 授权

```sql
GRANT ALL ON vsftpd.* TO 'vsftpd'@'localhost' IDENTIFIED BY 'vsftpdpass';
GRANT ALL ON vsftpd.* TO 'vsftpd'@'127.0.0.1' IDENTIFIED BY 'vsftpdpass';
FLUSH PRIVILEGES;

```

5. 配置pam认证

```shell
# 1.建立pam认证所需文件
vim /etc/pam.d/vsftpd.mysql
# 2.添加下面两行
auth required /lib/security/pam_mysql.so user=vsftpd passwd=vsftpdpass host=127.0.0.1 db=vsftpd table=users usercolumn=name passwdcolumn=password crypt=2
account required /lib/security/pam_mysql.so user=vsftpd passwd=vsftpdpass host=127.0.0.1 db=vsftpd table=users usercolumn=name passwdcolumn=password crypt=2

```

6. 创建虚拟用户的映射用户

```shell
useradd -s /sbin/nologin -d /var/ftproot vuser
setfacl -m u:vuser:rwx /var/ftproot

```

7. 修改vsftpd的配置文件，使其适应mysql认证

```shell
vim /etc/vsftpd/vsftpd.conf
pam_service_name=vsftpd.mysql
guest_enable=YES
guest_username=vuser

```

8. 配置虚拟用户具有不同的访问权限

```shell
# 1.配置虚拟用户有单独的权限设定
vim /etc/vsftpd/vsftpd.conf
user_config_dir=/etc/vsftpd/vusers_conf

# 2.创建所需目录，并为虚拟用户提供配置文件
mkdir /etc/vsftpd/vusers_conf
cd /etc/vsftpd/vusers_conf
# 配置虚拟用户具有不同的访问权限
vim jack
# 写入以下内容
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES

vim tom
# 写入以下内容
anon_upload_enable=YES
anon_mkdir_write_enable=NO
anon_other_write_enable=NO

```

9. 重启vsftpd服务并测试

```shell
systemctl restart vsftpd.service

```

登陆jack账户，有上传、新建、删除、重命名的权限：

![](http://static.staryjie.com/static/images/20190705161128.png)

登陆tom账户，只有上传的权限：

![](http://static.staryjie.com/static/images/20190705161328.png)
