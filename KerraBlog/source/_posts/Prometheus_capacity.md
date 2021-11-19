---
title: 如何规划Prometheus的资源使用
date: 2019/12/23 20:46:25
updated: 2020/03/09 21:40:61
comments: true
tags: 
- Prometheus
categories:
- 监控日志
---

# 概述
&nbsp; &nbsp;在使用Prometheus监控Kubernetes集群时，如果是使用Prometheus-operator或者使用容器云平台例如Rancher的监控功能，那么Prometheus的组件和一些Export组件会部署在Kubernetes集群中，这就带来了一个对这些组件的资源使用限制的问题，如果不进行限制，容易导致相应Pod耗尽主机资源，严重的情况下还会导致雪崩，限制的话又带来了一个限制多少资源够用的问题，限制使用资源少了，可能会导致组件频繁重启，限制使用资源多了，对于资源本身就紧张的集群，又造成了浪费。因此，本文章记录了如何计算Prometheus相关组件部署在Kubernetes集群中的资源使用；

<br/>

# 阅读本文前提条件
>* 对Kubernetes资源限制概念有一定了解；
>* 对Prometheus的使用有一定了解；
>* 对Prometheus架构设计有一定了解；
>* 本文以容器云平台Rancher作为例子，内容均以举例的形式表现；


<br/>

# 获取当前Prometheus所监控集群的每秒刮擦的样本数量

* 首先需要拿到Prometheus每一种Job平均收集的样本数量，可以通过以下Promql查看，这里截图以容器云平台Rancher为例：

>公式：  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;avg(scrape_samples_scraped) by (job)   
>
>解释：  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1、scrape_samples_scraped 这个metrics代表Prometheus被刮取的样本数；  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2、avg即为平均数；  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3、by (job)是具有job标签;

![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/%E6%96%87%E7%AB%A0%E5%9B%BE%E7%89%87/Prometheus%E6%8C%87%E6%A0%87%E6%95%B0%E9%87%8F.jpg)

<br/>

* 拿到了每一种Job平均收集的样本数量后，如果每一个job都是相同的scrape_interval(刮取时间间隔)，那么简单的除以60就可以的得出每一个job每秒刮取的样本数量
> 公式：
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;avg(scrape_samples_scraped) / 60
> 
> 解释：  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1、/60 即为除以60秒，拿到每秒的平均数；  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2、这里的结果可能有不满足1个样本的情况，这里取平均值；

![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/%E6%96%87%E7%AB%A0%E5%9B%BE%E7%89%87/Prometheus_job%E6%AF%8F%E7%A7%92%E5%B9%B3%E5%9D%87.jpg)

<br/>

* 上面拿到了每个job在1秒中刮取的样本数量，这时候只需要将所有job每秒获得样本数量相加，即可拿到当前Prometheus所监控集群的每秒刮擦的样本数量

> 公式:  
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sum(scrape_samples_scraped) / 60  
>
> 解释:  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1、sum 即为计算总数函数；

![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/%E6%96%87%E7%AB%A0%E5%9B%BE%E7%89%87/Prometheus%E6%AF%8F%E7%A7%92%E6%8B%89%E5%8F%96%E6%80%BB%E6%95%B0.jpg)

<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 其实到这里也能发现，其实只需要最后一条Promql就可以拿到当前Prometheus所监控集群的每秒刮擦的样本数量，前面两个Promql只是解释最后一个Promql是怎么来的。到这里，已经拿到了想要的数据，这个数据是计算Prometheus使用资源的基础数据；

<br/>

# 每个样本会使用多少资源？
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;通过上面的Promql，现在已经拿到了Prometheus每秒钟会刮擦的样本数量，那么只需要得知每条样本的大小乘上存储时间，基本就可以知道所需要多少资源了，现在看一下每条样本需要使用多少资源。

![avater](https://zknow-1256858200.cos.ap-guangzhou.myqcloud.com/%E6%96%87%E7%AB%A0%E5%9B%BE%E7%89%87/Prometheus%E6%A0%B7%E6%9C%AC%E7%BB%84%E6%88%90.jpg)

* 通过上面这幅官方对一个样本组成的解释，可以得知一个样本包含一个int时间戳和一个float值，因此原始大小为16个字节。磁盘的使用根据Gorllia在TSBD论文中的描述，Prometheus使用了一种叫做delta-of-delta的算法，这种算法可以将每条样本的大小压缩到原始的大小压缩八分之一。

<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;现在得知每条样本的大小为

>内存：16 bytes
>
>磁盘：1~2 bytes

<br/>

# 磁盘使用量的计算
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;现在已经知道了每一条样本的磁盘使用量和每秒钟Prometheus刮取的样本数量，只需要知道存储时间，即可计算出磁盘使用量

> 假设存储时间为1小时，每秒刮取样本数量为400，那么公式如下：
> * 存储时间(3600s) * 每秒刮取样本数量(400) * 每条样本大小(2 bytes) ≈ 2.7 MB

<br/>

# 内存使用量的计算
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Prometheus内存资源的使用与磁盘有所不同，Prometheus刮擦样本后会先寄存在内存中，被称为样本数据块。样本数据块会在2个小时进行压缩写入磁盘。
>这里Prometheus通过预写入(WAL)文件防止崩溃后数据丢失，当Prometheus崩溃重启后，会读取该文件得以回复数据，预写入的WAL文件以128MB为大小分段写入在磁盘上，WAL文件包括了还没有进行压缩的数据，因此会比较大。根据Prometheus刮取数据的量，WAL文件可能会有多个，保留2个小时。
>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这些样本数据块保留时间为存储时间的10%，但是至少保留两个小时，举例子说如果存储1个小时，1个小时的10%不足2个小时，也会按照2个小时计算；

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这样计算内存使用量就涉及到一个block的时间，也就是样本数据块在内存中的时间，假如存储时间为12小时计算公式如下：
> 存储时间(12小时) * 10%(0.1) = 1.2小时 
> 
> 结果小于2小时，按照最小两小时计算 = 7200秒

<br/>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 现在获取到了样本数据块block的时间，每秒刮取样本的数量和每条样本使用内存的大小，即可使用下面公式计算Prometheus内存使用量
> 每秒刮取样本数量(400) * 样本数据块block的时间(7200s) * 每条样本16 bytes ≈ 43MB
> > 这里得到的43MB是Prometheus每秒刮取400个指标，存储12个小时所使用的内存用量，当然Prometheus本身也会使用一定的内存，这里是要一起规划进去的。

<br/>

# 总结

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  以上就是Prometheus运行在Kubernetes集群中或者使用容器云平台Rancher开启监控后对Prometheus使用资源的计算。根据实际场景，开启Rancher监控后每台主机指标数量如下：
> 
> Node_exporter 每台主机1分钟大概刮取600条指标，根据主机数量增长指标数量也会增长；
>
> Kube_exporter 每个集群1分钟大概刮取450条指标，根据集群规模决定

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在实际环境应用场景中，可以根据以上计算方式计算出Prometheus大概的用量，方便更好的做资源规划，防止集群雪崩或者因为资源预留过小Prometheus频繁重启；

<br/>

>参考资料：
>>Rancher监控指标列表：https://rancher.com/docs/rancher/v2.x/en/cluster-admin/tools/monitoring/expression/
>>
>>prometheus-operator：https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md
>>
>>How much disk space do Prometheus blocks use:https://www.robustperception.io/how-much-disk-space-do-prometheus-blocks-use
>>
>特别感谢：
>>
>>感谢Rancher研发工程师Frank提供技术上的支持
>>
>>Github地址：https://github.com/thxcode
 
