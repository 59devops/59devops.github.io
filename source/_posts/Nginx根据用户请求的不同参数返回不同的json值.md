---
title: Nginx根据用户请求的不同参数返回不同的json值
date: 2019-09-30 14:02:40
tags:
- Nginx
categories:
- Nginx
---

　　用户请求url:http://localhost:8000/getconfig?v=1.03.01,根据参数v=1.03.01或者其他的值返回不同的json值。如果用户请求不带该参数，则返回默认的json值。

<!-- more -->

　　下面是nginx.conf的配置：
```bash
server {
        listen       8000;
        server_name  localhost;
        #charset koi8-r;
        #access_log  logs/host.access.log  main;

        location ~ ^/getconfig {
			default_type application/json;
			if ( $query_string ~* ^(.*)v=1.03.01$ ){
			return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock000/","h5":"http://118.31.69.127:8090/","phone":"4000670019","cr":"Copyright xxxxx"}}';
			}
			return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock000/","h5":"http://118.31.69.127:8090/","phone":"4000670019","cr":"Copyright xxxxx"}}';
        }
}
```
　　用户请求http://localhost:8000/getconfig时，应该返回
```bash
return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock000/","h5":"http://118.31.69.127:8090/","phone":"4000670019","cr":"Copyright xxxxx"}}';
```
　　浏览器模拟请求：http://localhost:8000/getconfig
    ![](http://static.staryjie.com/static/images/20190930141611-JRDNrU.png)
　　

　　浏览器请求：http://localhost:8000/getconfig?v=1.03.01时：
    ![](http://static.staryjie.com/static/images/20190930141701-jKF0zE.png)
　

　　可以满足需求，当有多个参数值的时候，本人没有想出来别的更好的办法，本来以为可以使用if else或者if else if的，结果我在测试的时候配置检查都不通过，没办法就采用了下面的办法：
```bash
server {
        listen       8000;
        server_name  localhost;
        #charset koi8-r;
        #access_log  logs/host.access.log  main;

        location ~ ^/getconfig {
            default_type application/json;
            if ( $query_string ~* ^(.*)v=1.03.01$ ){
            return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock000/","h5":"http://118.31.69.127:8090/","phone":"4000670019","cr":"Copyright xxxxx"}}';
            }
            if ( $query_string ~* ^(.*)v=1.03.02$ ){
            return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock122/","h5":"http://118.31.69.127:8092/","phone":"40006700191222","cr":"Copyright xxxxx1222"}}';
            }
            return 200 '{"status": "0","message": "OK","body": {"api":"http://116.62.113.124:8080/basestock000/","h5":"http://118.31.69.127:8090/","phone":"4000670019","cr":"Copyright xxxxx"}}';
        }
}
```
　　请求http://localhost:8000/getconfig?v=1.03.02：
    ![](http://static.staryjie.com/static/images/20190930141731-TYua5p.png)


　　虽然也可以达到目的，但是感觉特别low，希望哪位大神有别的比较高端的解决方法可以指导一下 ^=^!
