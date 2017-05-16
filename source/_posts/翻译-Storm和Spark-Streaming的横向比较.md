---
title: '[翻译] Storm和Spark Streaming的横向比较'
date: 2017-02-09 21:18:28
tags: [翻译, storm , spark streaming]
categories: [技术]
---
本文翻译自 http://xinhstechblog.blogspot.com/2014/06/storm-vs-spark-streaming-side-by-side.html

另，首先在 http://www.cnblogs.com/hysoka/articles/4097972.html 看到，然而觉得样式不太喜欢以及图片显示不出来，所以重新对原文做了翻译。

### 内容简介

本文主要讲述[storm](http://storm.apache.org)和[spark streaming](http://spark.apache.org/streaming/)之间的横向比较，给大家一个直观的感受，以及帮助大家在做流处理时能够选择合适的开源框架。

<!-- more -->

### 一、概述

Storm和Spark Streaming是分布式流处理的开源框架。但是，它们之间也有一些重要的差异，在下文中可以看到。

#### 处理模型以及延迟

虽然这两个框架都提供可扩展性和容错能力，但它们在处理模型中有根本的不同。 Storm一次处理一个即将到达的事件，而Spark Streaming会处理在一定的时间内（时间间隔可自己设置）在窗口中收到的一批事件。 因此，Storm可以实现处理事件的亚秒级延迟，而Spark Streaming有几秒钟的延迟。

#### 容错和数据保证

二者在容错数据保证上做出了各自的权衡。Spark Streaming在容错方面提供了对状态计算的更好的支持。 

在Storm中，每个单独的记录必须在其通过系统时被跟踪，因此Storm仅保证每个记录至少被处理一次，但是从故障中恢复期间允许出现重复。 这意味着可变状态可能不正确地更新了两次。

另一方面，Spark Streaming只需要在批处理级别进行跟踪处理，因此即使发生节点故障等故障，也可以有效地保证每个小批量都能够被精确处理一次。 [实际上，Storm的Trident库也提供了精确处理一次机制。 但是，它依赖于事务来更新状态，这是更慢的，并且通常是由用户去实现。]

![Storm vs Spark Streaming comparison.](/images/[翻译] Storm和Spark Streaming的横向比较/Storm vs Spark Streaming-1.png)

#### 小结

总之，如果你需要亚秒级延迟并且没有数据丢失，Storm是一个不错的选择。 如果你需要有状态计算，保证每个事件精确处理一次，Spark Streaming更好。 Spark Streaming编程逻辑也可能更容易，因为它类似于批处理编程，如果您正在使用批处理（尽管是非常小的批次）。

### 二、实现和程序API

#### 实现

Storm主要使用[Clojure](http://www.clojure.org)中实现，而Spark Streaming使用[Scala](http://www.scala-lang.org)实现。 这是要记住，如果你想去阅读代码来看看系统如何工作的或者自己去定制一些东西，更要牢记它们的编程实现。Storm是由BackType和Twitter联合开发的；Spark Streaming是在加州大学伯克利分校开发的。

#### 程序API

Storm提供一套Java API，同时可以很好的支持其它编程语言。Spark Streaming可以用Scala开发，也支持Java。

#### 批处理框架集成

Spark Streaming有一个好的特性是它运行在Spark上。因此，你可以使用相同(或者非常近似)的代码去实现批处理操作，或者在Spark Streaming上对Spark进行交互式的查询。这减少了编写用于处理流数据和历史数据所需的单独的代码的需求。

![Storm vs Spark Streaming: implementation and programming API.](/images/[翻译] Storm和Spark Streaming的横向比较/Storm vs Spark Streaming-2.png)

#### 小结

Spark Streaming的两个优势：
 1. 它不是用Clojure实现的(更具通用性)
 2. 它可以很好的与Spark批处理计算框架集成

### 三、产品和支持

#### 产品使用

Storm已经发布几年了，在Twitter上从2011年运行至今，现在也有很多其他公司在使用。相对而言，Spark Streaming是一个新项目，仅在2013在Sharethrough上投入生产使用。

#### Hadoop分发和支持

Storm(仅支持这一个)是Hortonworks Hadoop data platform数据平台的流式计算解决方案。而Spark Streaming同时支持MapR's distribution和Cloudera's Enterprise data platform两个Hadoop数据平台。另外还有Databricks公司对包含Spark Streaming的Spark stack提供支持。

#### 集群管理集成

两套系统均可以运行在它们自己的集群上，Storm仍然只能运行于Mesos上，Spark Streaming在YARN和Mesos上均可以运行。

![Storm vs Spark Streaming: production and support.](/images/[翻译] Storm和Spark Streaming的横向比较/Storm vs Spark Streaming-3.png)

#### 小结

Storm的实际产品应用经验要比Spark Streaming久得多。但是Spark Streaming有两点优势：
1. 作为开源产品有一个重量级公司给予支持和贡献技术力量；
2. 原生适配YARN。