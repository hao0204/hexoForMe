---
title: 使用ASM获取类定义
date: 2017-05-15 14:11:21
tags: [java, asm]
categories: [技术]
---
### 内容简介

[**`ASM`**](http://asm.ow2.org) 是一个`java`字节码操纵框架。在本人学习、查阅资料过程中，发现资料较少，而且大多讲述如何使用其来生成一个类。本文主要讲述对于`java`字节码，如何使用`ASM`树`API`来获取类的定义。

<!-- more -->

### ASM介绍

`ASM`是一个`java`字节码操纵、分析框架，它能被用来动态生成类或者修改现有类的功能，可以直接产生二进制类文件。`ASM`提供了与其他字节码框架相似的功能，但是它更关注于易使用性以及性能。因为它设计和实现尽可能的轻量以及快速，所以在动态系统中的使用非常普遍。

`ASM`库提供了两个用于生成和转换已编译类的`API`：一个是核心`API`，以基于事件的形式来表示类，另一个是树`API`，以基于对象的形式来表示类。这两者各有有缺点：

> 1. 基于事件的`API`要快于基于对象的`API`，所需要的内存也较少,因为它不需要在内存中 创建和存储用于表示类的对象树。
> 2. 但在使用基于事件的`API`时，类转换的实现可能要更难一些，因为在任意给定时刻，类中只有一个元素可供使用(也就是与当前事件对应的元素)，而在使用基于对象的`API`时，可以在内存中获得整个类。

`ASM`框架中的核心类有以下几个：

> 1. `ClassReader`: 该类用来解析编译过的`class`字节码文件。
> 
> 2. `ClassWriter`: 该类用来重新构建编译后的类，比如说修改类名、属性以及方法，甚至可以生成新的类的字节码文件。
> 
> 3. `ClassAdapter`: 该类实现了`ClassVisitor`接口，它将对它的方法调用委托给另一个`ClassVisitor`对象。
> 
> 4. `ClassNode`：基于`ClassNode`可以用于生成和转换已编译好的 Java 类，本文也是主要使用`ClassNode`。

接下来看一下已编译好的类的总体结构

### 已编译好的类总体结构

#### 概述

已编译类的总体结构非常简单。实际上，与原生编译应用程序不同，已编译类中保留了来自源代码的结构信息和几乎所有符号。事实上，已编译类中包含如下各部分：

> 1. 描述类的修饰符（比如`public`和`private`）、名字、超类、接口和注释。
> 
> 2. 用来描述类中声明的每个字段的修饰符、名字、类型和注释。 
> 
> 3. 描述类中声明的每个方法及构造器的修饰符、名字、返回类型与参数类型、注释。它还以 Java 字节代码指令的形式，包含了该方法的已编译代码。

但是在源文件类和已编译类之间还是有一些差异：

> 1. 一个已编译类仅描述一个类，而一个源文件中可以包含几个类。比如，一个源文件描述 了一个类，这个类又有一个内部类，那这个源文件会被编译为两个类文件：主类和内部类各一个文件。但是，主类文件中包含对其内部类的引用，定义了内部方法的内层类会包含引用，引向其封装的方法。
> 
> 2. 已编译类中当然不包含注释（`comment`），但可以包含类、字段、方法和代码属性，可以利用这些属性为相应元素关联更多信息。`Java 5` 中引入可用于同一目的的注释（`annotaion`）以后，属性已经变得没有什么用处了。
> > 3. 编译类中不包含`package`和`import`部分，因此，所有类型名字都必须是完全限定的。
> 
> 4. 另一个非常重要的结构性差异是已编译类中包含常量池（`constant pool`）部分。这个池是一个数组，包含了在类中出现的所有数值、字符串和类型常量。这些常量仅在常量池中定义一次，然后可以利用其索引，在类文件中的所有其他各部分进行引用。

一个已编译类的整体规范如下图：
![Overall structure of a compiled class(* means zero or more)](/images/asm use first step-1.png)

java 类型在已编译类和源文件类中的表示不同，后面几节来具体的解释。
 
#### 内部名

在许多情况下，一种类型只能是类或接口类型。例如，一个类的超类、由一个类实现的接口，或者由一个方法抛出的异常就不能是基元类型或数组类型，必须是类或接口类型。这些类型在已编译类中用内部名字表示。一个类的内部名就是这个类的完全限定名，其中的点号用斜线代替。例如，`String`的内部名为`java/lang/String`。

#### 类型描述符

内部名只能用于类或接口类型。所有其他`java`类型，比如字段类型，在已编译类中都是用类型描述符表示的。如下表

Java类型 | 类型描述符
--- | --- |
`boolean` | `Z`
`char` | `C`
`byte` | `B`
`short` | `S`
`int` | `I`
`float` | `F`
`long` | `J`
`double` | `D`
`Object` | `Ljava/lang/Object;`
`int[]` | `[I`
`Object[][]` | `[[Ljava/lang/Object;`

#### 方法描述符

方法描述符是一个类型描述符列表，它用一个字符串描述一个方法的参数类型和返回类型。方法描述符以左括号开头，然后是每个形参的类型描述符，然后是一个右括号，接下来是返回类型的类型描述符。例如`(I)I`描述一个方法，它接受一个`int`类型的参数，返回一个`int`。下表给出了几个方法描述符实例。

源文件中的方法声明 | 方法描述符
--- | --- |
`void m(int i, float f)` | `(IF)V`
`int m(Object o)` | `(Ljava/lang/Object;)I`
`int[] m(int i, String s)` | `(ILjava/lang/String;)[I`
`Object m(int[] i)` | `([I)Ljava/lang/Object;`

#### 举个例子

如我们有以下一个`java`文件：
	
	public class People {
		private String id;
    	private double money;

	    public String getId() {
	        return id;
	    }
	
	    public void setId(String id) {
	        this.id = id;
	    }
	
	    public double getMoney() {
	        return money;
	    }
	
	    public void setMoney(double money) {
	        this.money = money;
	    }
	}

现在我们对它进行编译：`javac People.java`。现在我们得到了它的`class`文件，`People.class`文件。接着我们对它进行反编译：`javap -s -private People`。`-s`参数输出描述符，`-private`参数输出所有类成员和函数。对参数有不了解的可以使用`man javap`获取帮助。反编译的结果如下：

	public class People {
		private java.lang.String id;
    		descriptor: Ljava/lang/String;
		private double money;
    		descriptor: D
		public People();
			descriptor: ()V
    		
    	public java.lang.String getId();
    		descriptor: ()Ljava/lang/String;
    	
    	public void setId(java.lang.String);
    		descriptor: (Ljava/lang/String;)V
    		
    	public double getMoney();
    		descriptor: ()D
		public void setMoney(double);
				descriptor: (D)V
	}

可以发现反编译所获得的描述符结果与我们预期的一致。

现在已经了解了已编译好的类的总体结构，接下来使用`ASM`进行类的分析。

### 使用`ASM`

#### 读取class字节码

`ClassReader`类用来读取`class`字节码文件。
	
	File file = new File(".../.../*.class");
	try {
		ClassReader reader = new ClassReader(new FileInputStream(file));
		ClassNode cn = new ClassNode();
		reader.accept(cn, 0);
	} catch (IOException e) {
		e.printStackTrace();
	}

#### 获取类的超类

	String superClass = cn.superName;

#### 获取类的接口

	List<String> interfaces = cn.interfaces;

#### 获取类的成员变量

	List<FieldNode> fields = cn.fields;
	for (FieldNode fieldNode : fields) {
		...
	}
`fieldNode`就是类的一个成员变量，可以再从`fieldNode`中获取变量的修饰符、类型（描述符）、名字等。
	
##### 获取类的成员变量的修饰符

	List<FieldNode> fields = cn.fields;
	for (FieldNode fieldNode : fields) {
		int access = fieldNode.access;
	}
获取到的`access`变量的值就是用来修饰类的成员变量的。但是或许你会疑惑修饰符应该是`public`, `private`等，为什么会是`int`类型的呢？那是因为字段修饰符放在`access_flags`项目中，映射如下：

标志名称 | 标志值 | 含义
--- |	--- | --- |
`ACC_PUBLIC` | `0x0001` | 字段是否是`public`
`ACC_PRIVATE` | `0x0002` | 字段是否为`private`
`ACC_PROTECTED` | `0x0004` | 字段是否为`protected`
`ACC_STATIC` | `0x0008` | 字段是否为`static`
`ACC_FINAL` | `0x0010` | 字段是否为`final`
`ACC_VOLATILE` | `0x0040` | 字段是否为`volatile`
`ACC_TRANSTENT` | `0x0080` | 字段是否为`transient`
`ACC_SYNCHETIC` | `0x1000` | 字段是否为由编译器自动产生
`ACC_ENUM` | `0x4000` | 字段是否为`enum`
所以如果`access`值是`25`，那么它的类修饰符是`public static final`，因为`25=16(0x0010)+8(0x0008)+1(0x0001)`。

#### 获取类的成员方法

	List<MethodNode> methodNodes = cn.methods;
	for (MethodNode methodNode : methodNodes) {
		...	
	}
`methodNode `就是类的一个成员方法，可以再从`methodNode `中获取方法的修饰符、类型（描述符）、方法参数、方法内部的变量、名字、方法的具体指令等。

##### 获取类的成员方法中的具体指令

	List<MethodNode> methodNodes = cn.methods;
	for (MethodNode methodNode : methodNodes) {
		InsnList insnList = methodNode.instructions;
		for (int i = 0; i < insnList.size(); ++i) {
			...
		}	
	}
`InsnList`类中存放的一个关键的类成员是`AbstractInsnNode`，`AbstractInsnNode`是一个抽象类，可用的方法较少，接着就需要根据具体的类型获取需要的内容。如下面代码：
	
	if (insnList.get(i) instanceof MethodInsnNode) {
		MethodInsnNode methodInsnNode = (MethodInsnNode)insnList.get(i);
		...
	}

#### 举个例子

`People`类：

	public class People {
		private String id;
		private double weight;
		public double height;
		
		public String getId() {
		    return id;
		}
		
		public void setId(String id) {
		    this.id = id;
		}
		
		public double getWeight() {
		    return weight;
		}
		
		public void setWeight(double weight) {
		    this.weight = weight;
		}
		
		public double getHeight() {
		    return height;
		}
		
		public void setHeight(double height) {
		    this.height = height;
		}
		
		public String Compare(People other) {
		    if (CompareHeight(other) && CompareWeight(other))
		        return "stronger";
		    return "";
		}
		
		public boolean CompareHeight(People other) {
		    if (this.height > other.height)
		        return true;
		    return false;
		}
		
		public boolean CompareWeight(People other) {
		    if (this.weight > other.weight)
		        return true;
		    return false;
		}
	}

使用`ASM`获取类代码：

	import jdk.internal.org.objectweb.asm.ClassReader;
	import jdk.internal.org.objectweb.asm.tree.*;

	import java.io.File;
	import java.io.FileInputStream;
	import java.io.FileNotFoundException;
	import java.io.IOException;

	public class Main {
		public static void main(String[] args) {
			File file = new File("src/main/java/People.class");
			try {
				ClassReader reader = new ClassReader(new FileInputStream(file));
				ClassNode cn = new ClassNode();
				reader.accept(cn, 0);
		
				System.out.println("super class: " + cn.superName);
				System.out.println("implements interface: " + cn.interfaces);
		
				for (FieldNode fieldNode : cn.fields) {
					System.out.println("class member name: " + fieldNode.name + ". class member type: " + fieldNode.desc);
				}
		
				for (MethodNode methodNode : cn.methods) {
					System.out.println("class method name: " + methodNode.name + ". class method type: " + methodNode.desc);
					InsnList insnList = methodNode.instructions;
					for (int i = 0; i < insnList.size(); i++) {
						if (insnList.get(i) instanceof MethodInsnNode) {
							MethodInsnNode methodInsnNode = (MethodInsnNode)insnList.get(i);
							System.out.println("\t" + "using method name: " + methodInsnNode.name + ". using method type: " + methodInsnNode.desc);
						}
					}
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

最后结果:
![Result](/images/asm use first step-2.png)

#### 使用环境

1. 使用`ASM`框架需要导入`asm`的`jar`包，可用`maven`导入。
2. `JDK1.8`

### 参考资料
1. http://asm.ow2.org
2. http://download.forge.objectweb.org/asm/asm4-guide.pdf
3. 《深入理解Java虚拟机》第2版 周志明著