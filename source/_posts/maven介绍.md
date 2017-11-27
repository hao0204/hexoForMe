---
title: Maven 介绍
date: 2017-11-27 11:16:38
tags: [Maven]
categories: [技术]
---

### 内容简介

本文讲述 **Maven** 的基本内容，包括 **Maven** 的简介、依赖机制和生命周期的介绍，具体的使用较为简单，这里不再阐述。
<!-- more -->

### Maven是什么

官方的说法是“我们需要一种标准的方法来构建项目，一个明确的定义来说明项目的组成，一种发布项目信息的简单方法，以及在多个项目中共享 **JARs** 的方法。而结果就是，我们可以使用 **Maven** 来构建和管理任何基于 **Java** 的项目。”

**Maven** 的目标是：

1. 使构建过程变得容易；
2. 提供统一的构建系统；
3. 提供高质量的项目信息；
4. 提供最佳实践开发指南；
5. 允许透明迁移到新特性

### Maven的依赖机制

**Maven** 的仓库有三种类型：本地资源库、中央存储库和远程仓库。当在 **pom.xml** 中定义了如下的依赖时：

	<dependencies>
	    <dependency>
		<groupId>log4j</groupId>
		<artifactId>log4j</artifactId>
		<version>1.2.14</version>
	    </dependency>
	</dependencies>
 
 **Maven** 将按照如下的顺序搜索 **log4j**：
 
 1. 在 **Maven** 的本地仓库搜索 **log4j** 
 2. 在 **Maven** 中央存储库搜索 **log4j**
 3. 在 **Maven** 远程仓库搜索 **log4j**(如果在 **pom.xml** 中有定义远程仓库)

中央存储库的定义可以在 `/usr/local/Cellar/maven/3.5.0/libexec/conf/settings.xml` 中（如果是用**brew** 安装 **maven**）修改，比如替换成阿里云的中央仓库。也可以在 **.m2** 文件夹下新建一个 **settings.xml** 文件再修改。
 
想要在远程仓库中搜索，必须在 **pom.xml** 中定义远程仓库。如下所示：
 
	 <repositories>
		<repository>
			<id>alimaven</id>
			<name>aliyun maven</name>
			<url>http://maven.aliyun.com/nexus/content/groups/public/</url>
		</repository>
	</repositories>
 
### Maven的生命周期

这是我一直没搞清楚，也是我写本文的主要原因。每次大佬给打包命令的时候都不明白，为什么要用install？为什么不用package？
言归正传，**Maven** 有三个标准的内嵌的生命周期：
 
 * **default**：处理项目的部署
 * **clean**：处理项目的清理
 * **site**：处理项目站点文档的产生

#### default 生命周期 

**default** 生命周期有23个阶段，这里列出主要的7个阶段：

阶段 | 处理的事情
--- | --- |
validate | 验证项目是正确的，并且所有必要的信息可用于完成构建过程
compile | 编译项目的源代码
test | 使用适当的测试框架测试已编译的源代码，这些测试代码不应该被要求打包或者部署
package | 提取编译后的代码，并在其分发的格式打包，如JAR文件
verify | 对集成测试的结果进行任何检查，以确保满足质量标准
install | 将包安装到本地资源库，它可以用作本地其他项目的依赖
deploy | 将最后的包复制到远程存储库，以便与其他开发人员和项目共享，这是default生命周期的最后一步

而且，这里是顺序运行的，所以在运行 **install** 或者其他阶段之前肯定已经运行了前面几步。

#### 清理 生命周期 

清理 生命周期共有 3 个阶段。

阶段 | 处理的事情
--- | --- |
pre-clean | 执行实际项目清理前所需的流程
clean | 清理所有以前构建产生的文件
post-clean | 执行完成项目清理工作所需的流程

例如 `pre-*`, `post-*`, `process-*`的阶段一般不在命令行直接使用，所以我们一般使用mvn clean。	 

注：site 生命周期 笔者很少用到，这里不再阐述。

### 参考资料

1. http://maven.apache.org/guides/
2. http://blog.csdn.net/xiaolyuh123/article/details/74091268
3. http://www.yiibai.com/maven/

