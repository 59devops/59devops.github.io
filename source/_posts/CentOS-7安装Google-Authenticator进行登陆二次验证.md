---
title: CentOS 7安装Google Authenticator进行登陆二次验证
date: 2019-09-27 13:57:12
tags:
- Security
categories:
- Security
---

### 1、安装依赖

```shell
yum install -y epel-* mercurial autoconf automake libtool pam-devel
```

<!-- more -->

### 2、安装google-authenticator 

```shell
yum install -y google-authenticator
```

### 4、PAM组件配置google-authenticator 

```shell
vim /etc/pam.d/sshd
auth required pam_google_authenticator.so
# 或者
echo   "auth       required     pam_google_authenticator.so" >>/etc/pam.d/sshd
```

### 5、修改SSH配置

```shell
vim /etc/ssh/sshd_config
# 将
ChallengeResponseAuthentication no
# 改为
ChallengeResponseAuthentication yes
# 或者
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
```

### 6、重启SSH服务

```shell
systemctl restart sshd.service
```

### 7、生成google-authenticator配置

```shell
google-authenticator
Do you want authentication tokens to be time-based (y/n) y
Warning: pasting the following URL into your browser exposes the OTP secret to Google:
  https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/root@demo%3Fsecret%3DXQ2WB526GLPJ7SI64Z3RZISOEE%26issuer%3Ddemo
                                                        
                                                                                  
                                                                                  
                                                                                  
             这里会有一个二维码，需要在手机上下载`googleauthenticator`APP扫码绑定
             安卓 IOS手机都可以在应用商店搜索安装
                                                                                  
                                                                                  
                                                                                                                                                                     
Your new secret key is: XQ2WB526GLPJ7SI64Z3RZISOEE
Your verification code is 917990
Your emergency scratch codes are:
  42623319
  72314571
  14476695
  95764389
  38976136

Do you want me to update your "/root/.google_authenticator" file? (y/n) y

Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

By default, a new token is generated every 30 seconds by the mobile app.
In order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. This allows for a
time skew of up to 30 seconds between authentication server and client. If you
experience problems with poor time synchronization, you can increase the window
from its default size of 3 permitted codes (one previous code, the current
code, the next code) to 17 permitted codes (the 8 previous codes, the current
code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
between client and server.
Do you want to do so? (y/n) y

If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting? (y/n) y
```

### 8、调整XShell登陆配置

XShell登陆需要更改为Keyboard Interactive验证登陆。

![img](http://static.staryjie.com/static/images/20190614102458.png)

### 9、登陆时需要结合手机APP上的验证码才可以登陆

登陆的时候选择Keyboard Interactive验证登陆。

![](http://static.staryjie.com/static/images/20190614103039.png)

然后输入服务器密码

![](http://static.staryjie.com/static/images/20190614103127.png)

输入手机APP上的验证码

![](http://static.staryjie.com/static/images/20190614103231.png)

![](http://static.staryjie.com/static/images/20190614102721.png)

登陆成功

![](http://static.staryjie.com/static/images/20190614103304.png)



> 因为手机上的 google authenticator这个APP是根据时间来生成随机验证码的，所以必须保证服务器上的时间和手机时间一致，不然可能会出现无法登陆的情况！
>
> 建议安装时间同步服务器或者安装一个自动同步时间的软件(例如：chrony)

```shell
yum install -y chrony
systemctl enable chronyd
systemctl start chronyd
```
