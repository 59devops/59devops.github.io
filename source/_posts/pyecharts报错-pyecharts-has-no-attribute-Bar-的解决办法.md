---
title: pyecharts报错'pyecharts' has no attribute 'Bar'的解决办法
date: 2019-09-27 13:30:38
tags:
- Python
- pyecharts
categories:
- Python
---

## pyecharts报错'pyecharts' has no attribute 'Bar'的解决办法

### 1、出错原因

因为用下面语句安装`pyecharts`时，默认会安装最新版本的`pyecharts`，python解释器版本更新的速度慢很多，现在的python解释器默认的是与0.1.9.4版本的`pyecharts`配合，你安装最新的，python解释器不能识别，所以会报错。

```shell
pip install pyecharts
```
<!-- more -->

### 2、解决方法

```shell
# 1.先安装wheel
pip install wheel
# 2.再安装pyecharts0.1.9.4版本
pip install pyecharts==0.1.9.4
```

### 3、验证

```python
from pyecharts import Bar

bar1 = Bar("我的第一个图表", "副标题")
bar1.add("服装", ['衬衣', '羊毛衫', '雪纺衫', '裤子', '高跟鞋', '袜子'], [5, 20, 36, 10, 75, 90])
bar1.show_config()
bar1.render()
```

运行上面的代码会生成如下的render.html文件：

![](http://static.staryjie.com/static/images/20190821102409.png)

在浏览器打开：

![](http://static.staryjie.com/static/images/20190821102534.png)
