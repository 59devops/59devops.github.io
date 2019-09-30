---
title: 通过阿里云Python SDK管理ECS安全组
date: 2019-09-27 13:36:23
tags:
- aliyun
- SDK
categories:
- aliyun
---

### 准备工作

```text
1.服务器操作系统 CentOS7
2.Python版本 2.7.5
3.阿里云账号、Access Key ID、Access Key Secret、安全组ID、Region ID(如cn-shanghai)
```

<!-- more -->

### 1、安装pip

```shell
# 默认没有安装pip，首先先安装pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
# 检查是否安装完成
pip -V
```

### 2、安装阿里云Python SDK

```shell
pip install aliyun-python-sdk-ecs
```

### 3、Python SDK实现安全组的增加和删除

#### 3.1 增加安全组规则

```python
#!/usr/local/bin/python2
# -*- coding:utf-8 -*-

from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import AuthorizeSecurityGroupRequest
import sys


class AliGroup:

    def __init__(self, AccessKey, AccessSecret, RegionId):
        self.AccessKey = AccessKey
        self.AccessSecret = AccessSecret
        self.RegionId = RegionId

    def client(self):
        """用于创建AcsClient实例
        """
        client = AcsClient(self.AccessKey, self.AccessSecret, self.RegionId)
        return client

    def authorizeSecurityGroupRequest(self, PortRange, SourceCidrIp, Priority=1, IpProtocol='tcp',
                                      SecurityGroupId='sg-bp1be0nm1c8es3sonuyy'):
        """用于添加安全组规则
        """
        # 创建AuthorizeSecurityGroupRequest实例
        request = AuthorizeSecurityGroupRequest.AuthorizeSecurityGroupRequest()
        # 设置安全组ID
        request.set_SecurityGroupId(SecurityGroupId)
        # 设置协议，比如TCP或者UDP
        request.set_IpProtocol(IpProtocol)
        # 设置端口范围
        request.set_PortRange(PortRange)
        # 如果存在源ip，则设置源ip
        if SourceCidrIp:
            request.set_SourceCidrIp(SourceCidrIp)
        # 设置优先级
        request.set_Priority(Priority)
        # 设置规则的动作为接受
        request.set_Policy('accept')
        # 设置接收数据格式为json
        request.set_accept_format('json')
        return request


if __name__ == '__main__':
    # AliGroup类实例化
    ali = AliGroup("LTAIgURtYA5lRIdF", "Bz4X2kHtW9EbLP3uAU4Bx7kT1xUUbn", "cn-hangzhou")
    # 创建AcsClient实例
    clt = ali.client()
    # 添加安全组规则，由于优先级、协议和安全组ID已经设置默认参数，所以只需要在运行脚本时输入端口范围和源ip两个参数
    add = ali.authorizeSecurityGroupRequest(sys.argv[1], sys.argv[2])
    # 打印输出
    res = clt.do_action_with_exception(add)
    print res

```

#### 3.2 删除安全组规则

```python
#!/usr/local/bin/python2
# -*- coding:utf-8 -*-

from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import RevokeSecurityGroupRequest
import sys


class AliGroup:
    def __init__(self, AccessKey, AccessSecret, RegionId):
        self.AccessKey = AccessKey
        self.AccessSecret = AccessSecret
        self.RegionId = RegionId

    def client(self):
        """用于创建AcsClient的实例
        """
        client = AcsClient(self.AccessKey, self.AccessSecret, self.RegionId)
        return client

    def revokeSecurityGroupRequest(self, PortRange, SourceCidrIp, Priority=1, IpProtocol='tcp',
                                   SecurityGroupId='sg-bp1be0nm1c8es3sonuyy'):
        """删除安全组规则
        """
        request = RevokeSecurityGroupRequest.RevokeSecurityGroupRequest()
        request.set_SecurityGroupId(SecurityGroupId)
        request.set_IpProtocol(IpProtocol)
        request.set_PortRange(PortRange)
        if SourceCidrIp:
            request.set_SourceCidrIp(SourceCidrIp)
        request.set_Policy('accept')
        request.set_accept_format('json')
        return request


if __name__ == '__main__':
    ali = AliGroup("LTAIgURtYA5lRIdF", "Bz4X2kHtW9EbLP3uAU4Bx7kT1xUUbn", "cn-hangzhou")
    clt = ali.client()
    rem = ali.revokeSecurityGroupRequest(sys.argv[1], sys.argv[2])
    res = clt.do_action_with_exception(rem)
    print res

```

### 4、测试

#### 4.1 测试新增安全组规则

* 执行脚本添加规则

![](http://static.staryjie.com/static/images/20190725114537.png)

* web控制台查看安全组

![](http://static.staryjie.com/static/images/20190725114709.png)

#### 4.2 测试删除安全组规则

* 执行脚本删除规则

![](http://static.staryjie.com/static/images/20190725114813.png)

* web控制台查看安全组

![](http://static.staryjie.com/static/images/20190725114844.png)

很明显，之前添加的规则已经被删除了。
