---
title: PyCharm创建普通项目配置支持jinja2语法
date: 2019-09-30 13:53:56
tags:
- PyCharm
- 工具
categories:
- 工具
---

打开项目的根目录的.idea文件夹中`项目名.iml`文件（隐藏文件）

打开这个iml文件，在component标签的同级，添加如下代码：

<!-- more -->

```shell
<component name="TemplatesService">
<option name="TEMPLATE_CONFIGURATION" value="Jinja2" />
<option name="TEMPLATE_FOLDERS">
<list>
<option value="$MODULE_DIR$/templates" />
</list>
</option>
</component>
```
