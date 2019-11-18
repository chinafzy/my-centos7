# My Centos
每次想在docker做一点尝试工作，发现官方镜像总有各种不便利，几次折腾后，就考虑自己搞一个不那么强调**正确**而只是为了**方便**的镜像。

## 这个是什么？
基于Docker的官方Centos7镜像，做的便利工具包，包含了这些功能：
+ 增加了常用的工具
```
  net-tools telnet curl wget ncat iputils \
  vim tree which htop \
  make gcc
```
当前的docker牛啊神啊，都喜欢打**最小**镜像，实际上这样的东西在使用中会很别扭，遇到一点问题，发现这个缺那个少的。不知道节省这一点磁盘有什么意义。  
无论是生产还是开发环境，这三类工具都是必不可少的，网络/make/状态查看
+ 增加了keep running功能，搭建一个什么都不做但是保持运行状态的centos，这个功能非常简单，但是超级实用。
+ 增加了entrypoint.d功能，参考下面
+ 增加了run-once.d功能，参考下面

## 怎么用？
首先编译镜像，取名为`centos:my7`
```
docker build -t centos:my7 .
```

### 简单用途
使用命令`docker --rm run centos:my7`，会出现类似的界面，表示运行成功
```
2019-11-15 02-24-42-552: entrypoint starts with:here we are
2019-11-15 02-24-42-565: /docker/entrypoint.d/001-hello.sh starts
2019-11-15 02-24-42-571: this is /docker/entrypoint.d/001-hello.sh
...
2019-11-15 02-24-42-620: /docker/entrypoint.d/900.sh ends
2019-11-15 02-24-42-621: entrypoint ends
2019-11-15 02-24-42-623: Please set env KEEP_RUNNING=1 if you wanna keep running.
```

### 保持服务运行
增加环境变量`KEEP_RUNNING=1`会让当前container保持运行状态。
```
% docker run -d --name centos7 -e KEEP_RUNNING=1 centos:my7
1dfde0c428fc9a9ddd907e904e9d756e4e6b3c402f0bd2657281ec2d68f3095a
% docker ps
CONTAINER ID     IMAGE            COMMAND                  CREATED          STATUS          PORTS       NAMES
1dfde0c428fc     centos:my7       "/docker/entrypoint.…"   4 seconds ago    Up 3 seconds                centos7
```
**注意**：启动KEEP_RUNNING功能后，使用run方式创建container，要加上-d参数，否则当前窗口无法接受终止命令，只能docker stop，或者杀掉当前窗口。

### /docker/entrypoint.d 是什么？怎么用？
放在这个目录下面的脚本会在每次开机时候运行，以文件名的顺序来执行，
例如：
+ 001-hello.sh
+ 050-run-once.sh
+ 100-your-shell1.sh
+ 900-good-bye.sh

注意：000-099和900-999命名字段是保留字段，请勿使用。

### /docker/run-once.d 是什么？怎么用？
放在这个目录下面的脚本会启动**一次**，以文件名的顺序来执行，例如：

+ 001-init.sh
+ 100-your-shell1.sh
+ 999-end.sh

很明显的，这个适用于初始化场景，例如初始化数据库。

## 如何扩展
