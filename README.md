## Connect Announce CN
对于中国大陆的用户，GeoLite2-City的准确率很差，在地级市、区、县得到的结果往往是Unknown。本插件基于[IP138的IP查询服务](https://user.ip138.com/ip/doc)，加强对中国大陆的用户IP的识别。

## 如何使用
安装拓展：
* [REST in Pawn](https://forums.alliedmods.net/showthread.php?t=298024)

在[IP138平台](https://user.ip138.com/ip/doc)注册并开通IP查询服务后，将connect_announce_cn.sp中的`GEOIP_API_TOKEN`替换成你的token，编译并移动到`addons/sourcemod/plugins/`中即可。

## Convars
```
connect_announce_enabled "1"
connect_announce_timeout "10"
```