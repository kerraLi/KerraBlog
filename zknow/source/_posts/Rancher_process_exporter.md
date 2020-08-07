---
title: Rancher平台添加Pod自定义进程监控
date: 2020/06/28 16:10:25
updated: 2020/06/28 16:10:25
comments: true
tags: 
- Rancher
- Prometheus
categories:
- 监控日志
---

# 概述
&nbsp; &nbsp; 在某些场景下，我们需要对Pod容器中的进程资源使用情况进行监控，在主机上可以使用Prometheus-process-exporter直接监控进程，在容器中我们可以通过添加Sidecar的方式运行process-exporter，结合Rancher平台的自定义监控功能，可以轻松实现对每个Pod容器中进程的监控。


# 阅读本文前提条件
>* 对Rancher Monitoring功能有一定了解；
>* 对Rancher自定义监控工作方式有一定了解；
>* 对Kubernetes Sidecar有一定了解；
>* 对Prometheus有一定了解；


# 整体思路
&nbsp; &nbsp; Prometheus-process-exporter可以对进程进行监控，首先先将process-exporter以Sidecar的方式进行启动，通过挂在configmap卷，将process-exporter的配置文件进行挂载，然后添加Sidecar启动命令使用该配置文件，配置完毕能正常启动Pod后，Pod的yaml文件中添加共享进程命名空间的配置，使process-exporter可以拿到主容器的进程信息。然后开启Rancher的项目监控功能，升级工作负载，添加自定义监控。最后在grafana中添加相关仪表盘即可展示进程监控信息。

# 正文
## 开启Rancher项目监控功能
&nbsp; &nbsp; 进入项目 --> 工具中，可以看到有个监控功能，该监控区别于集群监控，启用后会在当前项目中启动一套prometheus和grafana的工作负载，启动成功后，可以看到工作负载中新增了一个自定义监控的配置项。
![-w1249](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933323017989.jpg)

![-w1228](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933324857509.jpg)

## 部署process-exporter
### 添加configmap
由于process-exporter的启动，需要添加配置文件，才能将进程进行分组监控，于是我们使用挂载configmap卷的方式来实现，首先需要添加一个configmap，在以下配置文件示例中，默认监控所有进程，有关该配置文件的详细信息可以[点击查看](https://github.com/ncabatoff/process-exporter)
```
apiVersion: v1
kind: ConfigMap
data:
  process.yaml: |-
    process_names:
      - name: "{{.Comm}}"
        cmdline:
        - '.+'
```
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933331255284.jpg)

### 添加Sidecar
* 镜像 ncabatoff/process-exporter
* 启动命令 -config.path /config/process.yaml (该路径与configmap挂载路径相同)
* 挂载configmap卷

```
      containers:
      ....
       - args:
        - -config.path
        - /config/process.yaml
        image: ncabatoff/process-exporter
        imagePullPolicy: Always
        name: process-exporter
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
          readOnlyRootFilesystem: false
          runAsNonRoot: false
        stdin: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        tty: true
        volumeMounts:
        - mountPath: /config/
          name: vol1
     ....
```
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933333557228.jpg)

### 添加自定义监控
升级工作负载，添加自定义监控
* 端口 9256
* url 	/metrics
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933334821649.jpg)

由于Pod 容器之间默认无法共享共享进程命名空间，因此此时process-exporter只能采集到Sidecar容器中的进程，我们需要编辑工作负载的yaml文件，添加参数让容器之间共享进程命名空间。
* 参数 shareProcessNamespace: true
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933336471590.jpg)

上诉操作完成后，项目Prometheus中应该会自动添加一个targets
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933336954167.jpg)

此时，我们已经可以在Prometheus中查询该Pod的进程监控数据了
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933337478261.jpg)

### 添加grafana dashboards
为了方便展示，我们需要在Grafana中添加一个dashboards；
* dashboardsID 249
这里我们使用Grafana的导入功能，直接输入dashboardsID即可
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933338385841.jpg)

dashboards展示
![](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/Mweb/2020-06-28-15933338637066.jpg)

&nbsp; &nbsp; 至此，我们已经成功的将一个Pod中的进程使用Prometheus进行监控了，可以通过Grafana查看到进程状态和使用的资源信息。

# 总结
&nbsp; &nbsp; 通过使用Rancher项目监控的自定义监控功能，可以拓展出很多玩法，使用现有的Prometheus-exporter可以方便的监控任何资源的信息。

# 参考资料
[process-exporter](https://github.com/ncabatoff/process-exporter)
[Rancher自定义监控](https://rancher2.docs.rancher.cn/docs/project-admin/tools/monitoring/_index/)
[Grafana dashboards](https://grafana.com/grafana/dashboards/249)
[Prometheus官方文档](https://prometheus.io/docs/introduction/overview/)
