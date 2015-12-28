# Periscope (潜望镜)
> Project Renaissance  

## Art Hackathon 2015    
此项目为在[“**纪元：中国文艺黑客马拉松（1）落地松 新作一個杭州人**” ](http://caa-ins.org/index.php?title=Loadingthon) 中实现的作品  
并且为中国美术学院所赞助

# 介绍
![image](https://raw.githubusercontent.com/hACKbUSTER/Renaissance/master/banner.jpg)

寓意在地面下不可见的区域通过音乐感受地面上的风景和情感。  
这是一个大胆的跨界项目，来自音乐家和开发者的碰撞。将数据听觉化，当你在地铁上飞驰的时候，通过所经过的地面建筑数据，天气数据，空气数据，时间，地理位置这些数据实时生成音乐，让你无需在地面上也能感受到城市所特有的风景和情感。并且预留了交互式音乐的入口。

# 预览
![image](https://raw.githubusercontent.com/hACKbUSTER/Renaissance/master/screenshot_1.png)  
![image](https://raw.githubusercontent.com/hACKbUSTER/Renaissance/master/screenshot_2.png)  

> 音乐编程的工程部分我们会尽快更新到公共平台上。整体的使用体验未来可能会有视频资料。

# 来自设备的OSC数据的格式
此文档最后定义了客户端数据和生成音乐的服务端进行数据传输的格式协议。
## 1 拖移 Drag

### Pattern 
/location_x/date_type/location_y
### Values
"318.3",1,"154.3"

## 2 点击 Tap

### Pattern 
/location_x/date_type/location_y
### Values
"318.3",2,"154.3"

## 3 加速度 Gyro

### Pattern 
/gyro_x/gyro_y/gyro_z/date_type
### Values
"0.03","-0.02","0.02",3

## 4 角度 Attitude

### Pattern 
/attitude_roll/attitude_pitch/attitude_yaw/date_type
### Values
"20.43","-30.02","102.00",4