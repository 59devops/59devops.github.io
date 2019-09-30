---
title: >-
  phpize命令在安装AMQP插件是报错phpize：Cannot find autoconf. Please check your autoconf
  installation and the  envir的解决方法
date: 2019-09-30 14:05:08
tags:
- PHP
- AMQP
categories:
- PHP
---

1、出现错误的场合：

运行/usr/local/php/bin/phpize时出现：
```bash
Configuring for: PHP Api Version: 20041225 Zend Module Api No: 20060613 Zend Extension Api No: 220060519 Cannot find autoconf. Please check your autoconf installation and the $PHP_AUTOCONF environment variable. Then, rerun this script. 
```
解决办法是：

<!-- more -->
```bash
cd /usr/src && wget http://ftp.gnu.org/gnu/m4/m4-1.4.9.tar.gz
tar -zvxf m4-1.4.9.tar.gz # cd m4-1.4.9/
./configure && make && make install # cd ../
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.62.tar.gz
tar -zvxf autoconf-2.62.tar.gz
cd autoconf-2.62/
./configure && make && make install
```
当然，也可以直接yum安装就可以了：
```bash
yum install m4 yum install autoconf
```
2、解释./configure
    ./configure的意思是执行当前目录下面的configure文件
    configure一般都有可执行的权限，如果没有的话，用./configure是不能执行的，但是可以这样执行：
    ```bash
    sh ./configure
    ```

3、解释autoconf
    Autoconf是一个用于生成可以自动地配置软件源代码包以适应多种Unix类系统的 shell脚本的工具。由Autoconf生成的配置脚本在运行的时候与Autoconf是无关的， 就是说配置脚本的用户并不需要拥有Autoconf。
    由Autoconf生成的配置脚本在运行的时候不需要用户的手工干预；通常它们甚至不需要通过给出参数以确定系统的类型。相反，它们对软件包可能需要的各种特征进行独立的测试。（在每个测试之前，它们打印一个单行的消息以说明它们正在进行的检测，以使得用户不会因为等待脚本执行完毕而焦躁。）因此，它们在混合系统或者从各种常见Unix变种定制而成的系统中工作的很好。没有必要维护文件以储存由各个Unix变种、各个发行版本所支持的特征的列表。
    对于每个使用了Autoconf的软件包，Autoconf从一个列举了该软件包需要的，或者可以使用的系统特征的列表的模板文件中生成配置脚本。在shell代码识别并响应了一个被列出的系统特征之后，Autoconf允许多个可能使用（或者需要）该特征的软件包共享该特征。如果后来因为某些原因需要调整shell代码，就只要在一个地方进行修改； 所有的配置脚本都将被自动地重新生成以使用更新了的代码。
    Metaconfig包在目的上与Autoconf很相似，但它生成的脚本需要用户的手工干预，在配置一个大的源代码树的时候这是十分不方便的。不象Metaconfig脚本，如果在编写脚本时小心谨慎， Autoconf可以支持交叉编译（cross-compiling）。
