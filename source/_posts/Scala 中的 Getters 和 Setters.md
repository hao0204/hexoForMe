---
title: Scala 中的 Getters 和 Setters
date: 2017-12-11 16:09:09
tags: [Scala]
categories: [技术]
---

### 内容简介

本文主要讲述 Scala 中的 Getters 和 Setters 方法以及与Java中的区别。

<!-- more -->

### Getters 和 Setters

一般而言，Scala 中的 Getters 和 Setters 是定义变量的时候自动生成的。如下代码：

	class Person1() {
		var name = "";
	}

	//...
	person1 = new Person1();
	person1.name = "a";
	println(person1.name);
	
通过`.`直接使用。

这时，写过 Java 代码或其他面向对象语言的程序员会疑惑，这看上去，不就是对类中公共属性的调用吗？是这样吗？其实不是的。

我们来看下面这段代码：
	
	def main(args: Array[String]): Unit = {
		val person1 = new Person1()
		person1.name = "a"
	}
	
编译之后，使用 `javap -p -c` 反编译类文件，其中部分结果为：

![](/images/Scala 中的 Getters 和 Setters/0.jpg)

可以发现最后调用了 Person1 中的 name_$eq 方法进行 set 操作，而不是对类的公共属性的操作。

那么常量会自动生成方法吗？private的变量又如何呢？笔者进行了实验，实验结果见下表。

代码 | 反编译结果
--- | ---|
![](/images/Scala 中的 Getters 和 Setters/1-1.jpg) | ![](/images/Scala 中的 Getters 和 Setters/1-2.jpg)
![](/images/Scala 中的 Getters 和 Setters/2-1.jpg) | ![](/images/Scala 中的 Getters 和 Setters/2-2.jpg)
![](/images/Scala 中的 Getters 和 Setters/3-1.jpg) | ![](/images/Scala 中的 Getters 和 Setters/3-2.jpg)
![](/images/Scala 中的 Getters 和 Setters/4-1.jpg) | ![](/images/Scala 中的 Getters 和 Setters/4-2.jpg)

可以发现：

1. 生成的字段都是 private 的访问范围； 
2. 变量拥有 public 范围的 get 和 set 方法；
3. 常量只拥有 public 范围的 get 方法；
4. 定义为 private 的字段的生成的方法为 priavte；
5. 如果字段范围声明为 private[this]，那么不生成方法。

当然，在使用中，如果一个字段声明为 private，那么我们不能通过`.`操作符来获取或者修改该字段。这时，就得自己编写getter 和 setter 方法。举个例子：

	class Person3() {
		var _name = "";
		
		def name = _name
		def name_= (value: String): Unit = {
			_name = value
		}
	}
	
现在就可以跟前面一样，使用`.name`来 get 或者 set 操作了。这里的 `name_=` 就是 反编译结果中的 `name_$eq`。

### 与Java中Getters 和 Setters的区别

Java 中通过`.`使用类变量又是怎么回事呢？来看下面的代码：

	class Test {
		public static void main(String[] args) {
			Person person = new Person();
			person.name = "a";
		}
	}

	class Person {
    	String name;
	}
	
我们查看反编译类的结果，如下图。

![](/images/Scala 中的 Getters 和 Setters/6.jpg)

可以发现，Java使用是 putfield 关键字，而不是调用方法。

### 参考链接

1. https://www.dustinmartin.net/getters-and-setters-in-scala/	
