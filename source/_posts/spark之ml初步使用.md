---
title: spark之ml初步使用
date: 2017-11-09 15:00:54
tags: [spark, ml，scala]
categories: [技术]
---
### 内容简介

最近，笔者在使用spark的ml包构建模型时，发现资料较少，而且spark中examples包下的代码也过于片面，所使用的数据集都是libsvm格式。然而现实中，数据集一般以csv格式居多。因此，在本文中使用ml包以及csv格式的数据集进行初步的使用介绍。

<!-- more -->

### spark的安装和部署

spark的安装和部署的可以参见官网。

### 使用介绍

这里我们进行 spark 使用的详细的介绍。

1. 初始化spark，可以设置spark程序的名称。如果通过 webUI 的方式访问spark，可以在 Name 列看到名称。

		val spark = SparkSession
			.builder()
      		.appName("Model")
     	 	.getOrCreate()

2. 读取csv格式的数据集。inferSchema 选项表示允许spark自动推断数据类型。假设train.csv有204列，其中最后一列是标签。

		val data = spark
			.read
			.format("com.databricks.spark.csv")
			.option("inferSchema", "true")
			.load("train.csv")
			
3. csv文件读取到的数据有多个特征，需要将train.csv中的203个特征整合到一个特征中。因为train.csv中没有列名，所以spark会自动将列命名为"_c0"，"_c1"，...，"_cn"。

		val cloumns = Range(0,204)
			.map(x => "_c" + x)
			.toArray
    	val vectorAssembler = new VectorAssembler()
    		.setInputCols(cloumns)
    		.setOutputCol("features")
    	val data2 = vectorAssembler
    		.transform(data)
    		
4. 分割数据集为训练集和测试集。
	
		val Array(trainData, testData) = data2.randomSplit(Array(0.7, 0.3))
		
5. 定义模型

   5-1. 逻辑回归模型。当然也有别的参数可供配置。
   
   		val lor = new LogisticRegression()
      		.setFeaturesCol("features")   //设置想要学习的特征
      		.setLabelCol("_c204")         //设置数据的标签
      		.setRegParam(0.0)             //设置正则化参数
      		.setElasticNetParam(0.0)      //设置混合参数
     	 	.setMaxIter(100)              //设置迭代次数
      		.setTol(1E-6)                 //设置容错
      		.setFitIntercept(true)        //设置是否适应截距
      	
   5-2. 随机森林模型。当然也有别的参数可供配置。
   			
   		val randomForest = new RandomForestClassifier()
      		.setLabelCol("_c204")
    		.setFeaturesCol("features")
      		.setNumTrees(10)
   
   5-3. GBDT模型
   		
   		val gbt = new GBTClassifier()
      		.setFeaturesCol("features")
      		.setLabelCol("_c204")
 
6. 定义数据处理的流水。这里用了GBDT模型。

		val pipline = new Pipeline().setStages(Array(gbt)) 
	
7. 训练模型。

		val model = pipline.fit(trainData)

8. 用测试集测试模型。会有一列列名为 prediction 的输出，
    
    	val prediction = model.transform(testData)

9. 评估测试结果。
    
    	val evaluator = new MulticlassClassificationEvaluator()
      		.setLabelCol("_c204")
      		.setPredictionCol("prediction")
      		.setMetricName("accuracy")

    	val accuracy = evaluator.evaluate(prediction)

10. 输出结果。
 
		println("accuracy: " + accuracy)

11. 关闭spark。
    
    	spark.stop()

### 完整代码

以随机森林为例。

	import org.apache.spark.ml.{Pipeline}
	import org.apache.spark.ml.classification.{RandomForestClassifier}
	import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
	import org.apache.spark.ml.feature.VectorAssembler
	import org.apache.spark.sql.SparkSession

	object RandomForestModelTest {
 	 	def main(args: Array[String]): Unit = {
    		val spark = SparkSession.builder().appName("RandomForestModel").getOrCreate()

    		val data = spark.read.format("com.databricks.spark.csv").option("inferSchema", "true").load("/sch/data/train.csv")

    		val columns = Range(0, 204).map(x => "_c" + x).toArray
    		val vectorAssembler = new VectorAssembler().setInputCols(columns).setOutputCol("features")
    		val data2 = vectorAssembler.transform(data)

    		val Array(trainData, testData) = data2.randomSplit(Array(0.7, 0.3))

    		val randomForest = new RandomForestClassifier()
     			.setLabelCol("_c204")
      			.setFeaturesCol("features")
      			.setNumTrees(10)

    		val pipeline = new Pipeline().setStages(Array(randomForest))

    		val model = pipeline.fit(trainData)

    		val predictions = model.transform(testData)

    		val evaluator = new MulticlassClassificationEvaluator()
     		 	.setLabelCol("_c204")
      			.setPredictionCol("prediction")
      			.setMetricName("accuracy")

    		val accuracy = evaluator.evaluate(predictions)

    		println("accuracy: " + accuracy)

    		spark.stop()
  		}
	}

### 参考资料

1. http://spark.apache.org/docs/latest/ml-guide.html
2. http://www.mamicode.com/info-detail-1683740.html