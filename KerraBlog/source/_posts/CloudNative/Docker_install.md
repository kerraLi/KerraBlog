---
title: 一篇搞定常见操作系统的docker环境部署
date: 2019/03/17 10:46:25
updated: 2019/03/17 18:12:21
comments: true
tags: 
- Docker
categories:
- FuckingDocker
---

# 文章内容结构
![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/zknow_blog/docker_install/Docker%E9%83%A8%E7%BD%B2.png)

<br/>

# Docker ce社区版本
>* 此部分介绍docker ce社区版本在不通的操作系统上使用不通的方式进行部署，包括在线的apt部署、离线的deb和rpm包部署和通用的安装脚本部署；此外，还包括了docker的一些配置优化

<br/>

## Ubuntu操作系统部署Docker-ce

>* 如果以前安装过Docker环境，则需要清除干净，命令如下：
>>* ``` $ sudo apt-get remove docker docker-engine docker.io containerd runc ```

### 使用apt部署
* 更新apt索引
```
命令：
$ sudo apt-get update
```

* 安装软件包
```
命令：
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```
* 添加Docker的官方GPG密钥：
```
命令：
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
* 配置apt储存库信息
```
命令：
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
* 更新apt索引
```
命令：
$ sudo apt-get update
```

* 安装最新版本的Docker Engine-Community和containerd
```
命令：
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

>* apt安装指定版本的docker
>>* 列出仓库中可用版本:  <br/>```$ apt-cache madison docker-ce```
>>* 使用第二列中的版本字符串安装特定版本: <br/>```$ sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io```

* 测试
```
命令：
$ sudo docker run hello-world
```
以上是在Ubuntu系统中使用apt安装Docker环境的内容；

<br/>
<br/>

### 使用deb部署

* 进入下面链接下载deb安装包
>* https://download.docker.com/linux/ubuntu/dists/

* 安装deb包
```
命令：
$ sudo dpkg -i /path/to/package.deb
```

* 测试
```
命令：
$ sudo docker run hello-world
```

链接中有各种版本和操作系统的deb安装包，可根据实际需要下载，然后宝贝到离线环境中，使用dpkg命令安装；

<br/>
<br/>

### 使用脚本部署

* 使用下面命令进行脚本安装，亦或者可以在离线环境下载好上传到离线主机安装
```
命令：
$ curl -fsSL https://get.docker.com -o get-docker.sh
```
* 测试
```
命令：
$ sudo docker run hello-world
```

链接中有各种版本和操作系统的deb安装包，可根据实际需要下载，然后宝贝到离线环境中，使用dpkg命令安装；另外无论任何一种安装方式安装的docker，可以使用下面这条命令以非root用户身份使用Docker：
```
命令：
$ sudo usermod -aG docker your-user
```
---
## Centos操作系统部署Docker-ce

>* 如果以前安装过Docker环境，则需要清除干净，命令如下：
```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine 
```

### 使用yum安装
* 安装软件包
```
$ sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```
>* 安装所需的软件包。yum-utils提供了yum-config-manager功能，device-mapper-persistent-data和lvm2需要devicemapper提供存储驱动程序；

* 添加稳定的yum存储库：
```
命令：
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

* 安装最新版本的Docker Engine-Community和containerd
```
命令：
$ sudo yum install docker-ce docker-ce-cli containerd.io
```

>* apt安装指定版本的docker
>>* 列出仓库中可用版本:  <br/>```$ yum list docker-ce --showduplicates | sort -r```
>>* 使用第二列中的版本字符串安装特定版本: <br/>```$ sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io```

* 启动docker并配置开机自启动
```
命令：
$ sudo systemctl start docker && sudo systemctl enable docker
```
* 测试
```
命令：
$ sudo docker run hello-world
```
以上是在Centos系统中使用yum安装Docker环境的内容；

<br/>
<br/>

### 使用rpm部署

* 进入下面链接下载rpm安装包
>*  https://download.docker.com/linux/centos/7/x86_64/stable/Packages/ 

* 安装deb包
```
命令：
$ sudo yum install /path/to/package.rpm
```
* 启动docker并配置开机自启动
```
命令：
$ sudo systemctl start docker && sudo systemctl enable docker
```

* 测试
```
命令：
$ sudo docker run hello-world
```

链接中有各种版本和操作系统的rpm安装包，可根据实际需要下载，然后宝贝到离线环境中，使用yum命令安装；

<br/>
<br/>

### 使用脚本部署
* 使用下面命令进行脚本安装，亦或者可以在离线环境下载好上传到离线主机安装
```
命令：
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```
* 测试
```
命令：
$ sudo docker run hello-world
```

链接中有各种版本和操作系统的deb安装包，可根据实际需要下载，然后宝贝到离线环境中，使用dpkg命令安装；另外无论任何一种安装方式安装的docker，可以使用下面这条命令以非root用户身份使用Docker：
```
命令：
$ sudo usermod -aG docker your-user
```

---
## 通用脚本安装Docker环境
* 此脚本由Rancher Labs提供，适用于各版本的Centos、Ubuntu和REHL，
>* 版本号可自行修改；
```
命令：
$ wget -O - "https://releases.rancher.com/install-docker/19.03.sh" | sudo bash –
```

---


---
##  通用二进制部署Docker环境
* 通过二进制包可以在离线环境上部署Docker环境

### 1、下载、解压、赋权相关二进制
```
命令：
wget https://download.docker.com/linux/static/stable/x86_64/docker-18.09.9.tgz ##下载二进制包，版本可自行修改

tar -xvf docker-18.09.9.tgz  ##解压缩二进制包
chmod +x docker/*   ##给可执行权限
cp docker/* /usr/bin/  ##复制到/usr/bin
```

### 2、添加 docker 组
```
命令：
groupadd docker
```

### 3、配置 service 
```
echo "[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/docker.service

echo "[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
KillMode=process
Delegate=yes
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/containerd.service

echo "[Unit]
Description=Docker Socket for the API
PartOf=docker.service

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target" > /usr/lib/systemd/system/docker.socket

```

### 4、配置相关服务开机启动
```
命令：
systemctl enable docker.socket containerd.service docker.service
```

### 5、启动 docker 进程并重启系统
```
reboot ##reboot原因：Systemd接管Docker服务，如果不重启可以运行dockerd运行
```


---
# Docker ee版本(预览订阅)
>* 此部分介绍主要针对REHL操作系统，需要评估docker企业版的相关功能和特定场景下的测试需求，部署docker ee企业版(预览订阅)，docker ee提供了30天的试用订阅功能。

## 申请订阅试用

* 访问[Docker ee企业版仓库](https://hub.docker.com/editions/enterprise/docker-ee-trial)，这一步需要提前准备docker账号并登陆；

* 点击开始试用，并填写个人信息；
![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/zknow_blog/docker_install/docker_ee_install1.jpg) ![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/zknow_blog/docker_install/docker_ee_install2.jpg)

* 然后在详情界面可以看到Docker ee的下载链接，请记录这个链接，在后续的安装中会使用到；

![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/zknow_blog/docker_install/docker_ee_install3.jpg)



>* 如果以前安装过Docker环境，则需要清除干净，命令如下：
```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine 
```

### 在REHL8上安装([REHL7点这里查看](https://docs.docker.com/ee/docker-ee/rhel/))
* 删除现有的Docker储存库
```
命令：
$ sudo rm /etc/yum.repos.d/docker*.repo
```
* 将获取的Docker ee下载链接存为环境变量
```
命令：
$ export DOCKERURL="<DOCKER-EE-URL>"
```
* 存储yum变量到etc/yum/vars/中
```
命令：
$ sudo -E sh -c 'echo "$DOCKERURL/rhel" > /etc/yum/vars/dockerurl'
```
* 将OS版本字符串存储在中/etc/yum/vars/dockerosversion，这里使用的是REHL8，如果是REHL7 则改为7即可
```
命令：
$ sudo sh -c 'echo "8" > /etc/yum/vars/dockerosversion'
```

* 安装软件包
```
$ sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```
>* 安装所需的软件包。yum-utils提供了yum-config-manager功能，device-mapper-persistent-data和lvm2需要devicemapper提供存储驱动程序；

* 添加稳定的docker ee yum存储库：
```
命令：
$ sudo -E yum-config-manager \
    --add-repo \
    "$DOCKERURL/rhel/docker-ee.repo"
```

* 安装最新版本的Docker Engine-Community和containerd
```
命令：
$ sudo yum -y install docker-ee docker-ee-cli containerd.io
```

>* apt安装指定版本的docker
>>* 列出仓库中可用版本:  <br/>```$ $ sudo yum list docker-ee  --showduplicates | sort -r```
>>* 使用第二列中的版本字符串安装特定版本: <br/>```$ sudo yum -y install docker-ee-<VERSION_STRING> docker-ee-cli-<VERSION_STRING> containerd.io```

* 启动docker并配置开机自启动
```
命令：
$ sudo systemctl start docker && sudo systemctl enable docker
```
* 测试
```
命令：
$ sudo docker run hello-world
```
以上是在REHL8系统中使用yum安装Docker ee企业版环境的内容；

<br/>
<br/>


# Docker常用优化配置
>* Docker配置文件路径为/etc/docker/daemon.json，一般情况下，daemon.json文件不存在，可以手动建立；

* 配置国内镜像加速源
>* 国内网络环境访问docker hub可能不是特别顺利，因此可以通过更改国内镜像源仓库的方式，提高镜像拉取速度，常用的国内公用镜像源有以下几种，根据网络环境不同，一般Azure的源速度是比较快的；
>>* 网易云加速器 https://hub-mirror.c.163.com
>>* Azure 中国镜像 https://dockerhub.azk8s.cn

通过在daemon.json中添加配置，可以配置镜像源，示例配置如下：
```
{
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```
配置完成后需要重启daemon和docker使其生效，命令如下：

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

* 配置日志文件大小和数量
>* docker容器的日志驱动如果配置为json-file类型(默认)，那么会在主机上生成日志文件，一般在/var/lib/docker/<容器id>/目录下，如果日志文件增长过快可能导致磁盘用尽的问题，因此可以通过daemon.json配置单个日志文件的大小和保存的文件数量，这样可以有效防止因为日志文件过大导致的磁盘用尽；

配置如下：
```
{
	"log-driver": "json-file", ## 日志驱动类型
	"log-opts": {
		"max-size": "100m",  ## 单个日志文件大小
		"max-file": "3" ## 日志文件数量
	}
}
```
配置完成后需要重启daemon和docker使其生效，命令如下：

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

---
* 总结
<br/>
以上就是在各种操作系统中部署Docker环境的方法，除此之外其实还有各种操作系统，比如suse、windwos等环境的docker部署，还有二进制部署等方式，详情就参考docker官方文档吧，这里只是把常用的两种操作系统安装方式整理记录在一起，如果有错误还请多多指正。

>参考资料：
>>* https://docs.docker.com/ee/docker-ee/rhel/
>>* https://docs.docker.com/install/linux/docker-ce/centos/
>>* https://docs.docker.com/install/linux/docker-ce/ubuntu/

