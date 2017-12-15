---
title: PMML中RuleSet模型定义
date: 2017-12-15 15:35:36
tags: [PMML]
categories: [技术]
---

### 内容简介

本文主要讲述 **PMML** 中的 **RuleSet** 模型的定义。RuleSet模型在PMML中的定义分为以下几个部分：

1. 头信息
2. 数据字典
3. RuleSet模型中的挖掘模式（MiningSchema）
4. RuleSet模型中的规则冲突策略
5. RuleSet模型中的具体规则

<!-- more -->

### 一、RuleSet模型的PMML定义文件的头信息

	<Header copyright="MyCopyright">
		<Application name="MyApplication" version="1.0"/>
	</Header>
		
1. copyright 表示版权；
2. name 表示应用名称，version 表示版本号。

### 二、数据字典

#### 数据字典

数据字典包含多个数据字段，定义如下：

	<DataDictionary numberOfFields="2">
		<DataField ... />
	</DataDictionary>

1. numberOfFields 表示数据字段的数目。

#### 数据字段

数据字段根据`optype`有三种类型，`categorical`、`ordinal`和`continuous`。

##### categorical 类型
		
	<DataField name="BP" displayName="BP" optype="categorical" dataType="string">
		<Value value="HIGH" property="valid"/>
		<Value value="LOW" property="valid"/>
		<Value value="NORMAL" property="valid"/>
	</DataField>

1. 	`name`字段表示字段的名称，和`displayName`的区别在于`name`在PMML内部使用，`displayName`可以在外部供应用使用；
2. `dataType`表示字段的类型；
3. `value` 表示具体的类别；
4. `property`表示属性，共有`valid`、`invalid`、`missing`三个属性。`valid`表示该值是一个有效的值；`invalid`表示该值是一个无效的值；`missing`表示该值是一个缺失的值。

#####  continuous 类型		
		
	<DataField name="K" displayName="K" optype="continuous" dataType="double">
		<Interval closure="closedClosed" leftMargin="0.020152" rightMargin="0.079925"/>
	</DataField>

1. closure 表示开闭情况，共有四种情况，`openClosed` `openOpen` `closedOpen`和`closedClosed`；
2. leftMargin 表示左值；
3. rightMargin 表示右值。

##### ordinal 类型

	<DataField name="Volume" optype="ordinal" dataType="string">
		<Value value="loud"/>
		<Value value="louder"/>
		<Value value="insane"/>
	</DataField>
	
1. ordinal 定义有顺序的，如上的定义表示loud < louder < insane。

#### RuleSet模型

##### 挖掘模式

	<MiningSchema>
		<MiningField name="BP" usageType="active"/>
		<MiningField name="$C-Drug" usageType="target"/>
		<MiningField name="$CC-Drug" usageType="supplementary"/> 
	</MiningSchema>

1. usageType 有多种选项，常用的有`active`表示作为输入使用，`target`表示标记，`supplementary`表示额外描述信息。

##### 规则冲突策略

	<RuleSelectionMethod criterion="weightedSum"/>
	<RuleSelectionMethod criterion="weightedMax"/>
	<RuleSelectionMethod criterion="firstHit"/>

1. 规则冲突策略共有三种，`weightedSum`根据命中规则的权重的和进行比较，`weightedMax`根据命中规则的权重进行比较，取最大，`firstHit`返回首条命中的规则。

##### 简单规则

	<SimpleRule id="RULE1" score="drugB" recordCount="79" nbCorrect="76" confidence="0.9" weight="0.9">
		<CompoundPredicate booleanOperator="and">
			<SimplePredicate field="BP" operator="equal" value="HIGH"/>
			<SimplePredicate field="Na" operator="lessOrEqual" value="0.77240998"/>
		</CompoundPredicate>
		<ScoreDistribution value="drugA" recordCount="2"/>
		<ScoreDistribution value="drugB" recordCount="76"/>
	</SimpleRule>
	
1. id 表示该条规则，必须是独一无二的。
2. score 表示该条规则的结果。
3. recordCount 表示该条规则命中的样本数目。
4. nbCorrect 表示该条规则命中正确的样本数目。
5. confidence 表示该条规则的置信度。
6. weight 表示该条规则的权重。
7. booleanOperator 表示简单断言之间的操作，有`and` `or` `xor` 三种。
8. field 表示数据字段名称。
9. operator 表示操作。
10. value 表示值。

##### 复杂规则

复杂规则有点像树的分叉。例如从`A > 1`出发，会有两条分叉，不需要像简单规则写两次`A > 1`，只需写一次就好。

参考资料

1. http://dmg.org/pmml/v4-3/RuleSet.html
2. http://dmg.org/pmml/v4-3/DataDictionary.html
3. http://dmg.org/pmml/v4-3/MiningSchema.html