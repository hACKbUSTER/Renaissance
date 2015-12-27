# Periscope (潜望镜)
Project Renaissance
Art Hackathon 2015
此项目为在“纪元：中国文艺黑客马拉松（1）落地松 新作一個杭州人” [网络地址](http://caa-ins.org/index.php?title=Loadingthon) 中实现的作品 为中国美术学院所赞助



此文档首先定义了客户端数据和生成音乐的服务端进行数据传输的格式协议。

# 来自设备的OSC数据的格式

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