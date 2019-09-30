---
title: Jenkins自定义主题安装
date: 2019-09-27 13:50:54
tags:
- Jenkins
categories:
- Jenkins
---

* 首先必须先安装`Simple Theme Plugin`插件

* 在http://afonsof.com/jenkins-material-theme/网站中生成需要的主题css文件

* 将`jenkins-material-theme.css`文件上传到Jenkins服务器

* 创建目录，并将css文件放在对应的目录中。Jenkins默认的目录在`/var/jenkins_home/`

  ```shell
  mkdir -p /var/jenkins_home/userContent/material/
  cp jenkins-material-theme.css /var/jenkins_home/userContent/material/
  ```

<!-- more -->

* 在Jenkins中设置

![](http://static.staryjie.com/static/images/20190715152354.png)

* 保存之后会自动重新加载主题

![](http://static.staryjie.com/static/images/20190715152442.png)
