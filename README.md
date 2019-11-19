# My Centos
每次想在docker做一点尝试工作，发现官方镜像总有各种不便利。

几次折腾后，就考虑自己搞一个不那么强调**正确**而只是为了**方便**的镜像。

## 这个是什么？
基于Docker的官方Centos7镜像，做的便利工具包，包含了这些功能：
+ 增加了常用的工具  
  当前的docker牛啊神啊，都喜欢打**最小**镜像.实际上这样的东西在使用中会很别扭，遇到一点问题，发现这个缺那个少的。  
  无论是生产还是开发环境，这三类工具都是必不可少的，网络/make/状态查看
```
  net-tools telnet curl wget ncat iputils \
  vim tree which htop \
  make gcc
```
+ 引入了`keep running`功能，搭建一个什么都不做但是保持运行状态的centos，这个功能非常简单，但是超级实用。
+ 引入了`sub-command`功能和扩展点，参考下面
+ 引入了`entrypoint.d`扩展点功能，参考下面

## 怎么用？
首先编译镜像，取名为`my-centos7`
```
docker build -t my-centos7 .
```

### 简单用途
使用命令`docker run --rm my-centos7`，会出现类似的界面，表示运行成功
```
                _____
             ,-"     "-.
            / o       o \
           /   \     /   \
          /     )-"-(     \
         /     ( 6 6 )     \
        /       \ " /       \
       /         )=(         \
      /   o   .--"-"--.   o   \
     /    I  /  -   -  \  I    \
 .--(    (_}y/\       /\y{_)    )--.
(    ".___l\/__\_____/__\/l___,"    )
 \                                 /
  "-._      o O o O o O o      _,-"
      `--Y--.___________.--Y--'
         |==.___________.==| hjw
         `==.___________.==' `97

2019-11-18 10-20-58-614: Bind logs(/var/log/docker/entrypoint.log) to /dev/stdout
2019-11-18 10-20-58-617: [ENTRYPOINT] starts with:
2019-11-18 10-20-58-621: [ENTRYPOINT] ends
2019-11-18 10-20-58-622: Please set env KEEP_RUNNING=1 if you wanna keep running.
```

### 修改启动画面里面的logo
通过修改环境变量 `LOGO_FILE`(默认/docker/logo.txt)来实现，
+ 将其设置为空，或者指向一个不存在的文件，可以禁止logo的出现
```
% docker run --rm -e LOGO_FILE=  my-centos7
2019-11-19 02-34-12-951: Bind logs(/var/log/docker/entrypoint.log) to /dev/stdout
2019-11-19 02-34-12-954: [ENTRYPOINT] starts with:
2019-11-19 02-34-12-957: [ENTRYPOINT] ends
2019-11-19 02-34-12-959: Please set env KEEP_RUNNING=1 if you wanna keep running.
```
+ 将其指向一个自己上传的一个`asii image`文件，可以显示自定义logo

### 保持服务运行
增加环境变量`KEEP_RUNNING=1`（默认未开启）会让当前container保持运行状态。
```
% docker run -d --name centos7 -e KEEP_RUNNING=1 my-centos7
d3a001ffdb4ca80e757cebcacfc9413541bb0b6c88a2bb72e04810b7b8271a90

% docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
d3a001ffdb4c        my-centos7          "/docker/entrypoint.…"   3 seconds ago       Up 1 second                             centos7
```
**注意：启动KEEP_RUNNING功能后，使用run方式创建container，要加上-d参数，否则当前窗口无法接受终止命令，只能docker stop，或者杀掉当前窗口。**

### 将系统日志传输到 `/etc/stdout`
通过配置环境变量`LOG_STDOUT=1`(默认开启)来实现，

当前镜像的日志文件位于`/var/log/docker/entrypoint.log`，默认将其链接到`/etc/stdout`。

### 使用`sub-command`功能
例如我们可以用`tree /docker`来查看镜像下的文件目录
```
% docker run --rm -e LOGO_FILE=  my-centos7 tree /docker
2019-11-19 06-46-25-848: Bind logs(/var/log/docker/entrypoint.log) to /dev/stdout
2019-11-19 06-46-25-850: [ENTRYPOINT] starts with:tree /docker
2019-11-19 06-46-25-854: [ENTRYPOINT] run sub command:tree /docker
/docker
|-- entrypoint.d
|-- entrypoint.sh
|-- logo.txt
|-- run-cmd.sh
`-- tools.sh

1 directory, 4 files
2019-11-19 06-46-25-861: [ENTRYPOINT] ends
2019-11-19 06-46-25-862: Please set env KEEP_RUNNING=1 if you wanna keep running.
```
这个功能适用于`服务类`（例如在镜像的基础上做一个redis server）场景。

## 【重要】`entrypoint.d`扩展点
镜像提供了一个扩展点，位于目录`/docker/entrypoint.d`，放在这个目录下面的脚本会在每次开机时候运行，例如：
```
100-your-shell1.sh
150-your-shell2-once.sh
900-good-bye.sh
```
规则非常简单：
+ 按照文件名顺序执行  
  建议以3个数字作为文件名开头，以便排序，例如`100-setup.sh` `300-start-server.sh`；而且间隔可以放大一点，便于以后的扩展。  
  **注意**：000-099和900-999命名空间是保留区域，请勿使用。
+ 如果前面的执行失败(脚本返回非0)，则整体异常退出
+ 带有`-once`字样的脚本，将只执行一次  
  这个非常适用于`初始化`类型的工作，例如数据导入。



## 其它说明

### 版本
每个小版本会有tag，在`versions.md`文件中有功能说明。

### `build.sh`
会将当前的镜像打包，标记俩个tag版本
+ latest:
+ `versions.md`中的最后一个版本标记

### `build-github.sh`
会将当前的镜像打包，标记为github使用版本  
参考 [GitHub](https://help.github.com/articles/configuring-docker-for-use-with-github-package-registry/){:target=_blank}
