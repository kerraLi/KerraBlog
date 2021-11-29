---
title: Kubernetes集群Pod添加JVM指标导出器
date: 2020/08/07 15:10:25
updated: 2020/08/07 16:10:25
comments: true
tags: 
- Kubernetes
- Prometheus
- Exporter
- Rancher
categories:
- 监控日志
---

一般情况下进行JAVA应用监控的时候通常会监控JVM的数据来进行应用健康和性能的分析，应用容器化之后使用Promtheus有几种方式可以对JVM进行指标进行采集监控，本文将对部分JVM指标暴露监控方式进行使用和分析；


# 阅读本文前提条件
>* 对Prometheus有一定了解；
>* 对Kubernetes有一定了解；
>* 对Rancher Monitoring功能有一定了解；
>* 对Rancher自定义监控工作方式有一定了解；
>* 对Kubernetes Sidecar有一定了解；
>* 本文默认已经启动了一个Kubernets集群和部署了prometheus-operator；


# JVM指标暴露方式
>* 将jmx_exporter与应用构建成一个镜像，暴露端口Prometheus进行采集；
>* 通过Sidecar的方式部署jmx_exporter，暴露端口Prometheus进行采集；
>* 通过Rancher自定义监控的方式进行指标采集；

# 正文
## 一、将jvm_exporter与应用构建成一个镜像，暴露端口Prometheus进行采集

### 使用Dockerfile构建镜像










# 参考资料
[process-exporter](https://github.com/ncabatoff/process-exporter)
[Rancher自定义监控](https://rancher2.docs.rancher.cn/docs/project-admin/tools/monitoring/_index/)
[Grafana dashboards](https://grafana.com/grafana/dashboards/249)
[Prometheus官方文档](https://prometheus.io/docs/introduction/overview/)
