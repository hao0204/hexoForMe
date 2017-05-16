---
title: golang单元测试介绍
date: 2017-03-20 16:42:37
tags: [Go]
categories: [技术]
---

### 内容简介

本文主要讲述 **golang** 语言中的单元测试，涉及 **golang** 自带的用于单元测试的 **testing** 包、其中用于黑盒测试的 **quick** 包、以及 **github** 开源项目中的 **check** 包。

<!-- more -->

### 单元测试概念

在计算机编程中，单元测试（Unit Testing）又称为模块测试, 是针对程序模块（软件设计的最小单位）来进行正确性检验的测试工作。

程序单元是应用的最小可测试部件。在过程化编程中，一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

通常来说，程式设计师每修改一次程序就会进行最少一次单元测试，在编写程序的过程中前后很可能要进行多次单元测试，以证实程序达到软件规格书要求的工作目标，沒有程序错误；虽然单元测试不是什么必须的，但也不坏。

### golang中的testing包使用简介

在Go语言的包中，testing包提供了对自动化测试的支持，用 `go test` 命令可以运行所有类似 `func TestXxx(*testing.T)` 格式的函数。

Golang中的单元测试对文件名、方法名和参数都有很严格的要求：

1. 文件名必须以 **xx_test.go** 命名
2. 方法必须是 **Test[^a-z]** 开头
3. 方法参数必须 **t *testing.T**

我们以 **leetcode** 上的第**504**题**Base 7**为例。此题要求给定一个整数，返回一个7进制的字符串。如输入100，输出"202"；输入-7，输出"-10"。此题解的代码如下，保存在 **Base7.go** 文件中.

	func convertToBase7(num int) string {
		if num == 0 {
			return "0"
		}
		flag := false
	    if num < 0 {
			flag = true
	    	num = -num
		}
		res := ""
		for num > 0 {
			a := num % 7;
			res = strconv.Itoa(a) + res
			num /= 7
		}
		if flag {
			res = "-" + res
		}
		return res
	}

下面我们开始编写 **convertToBase7** 函数的单元测试。

1. 新建测试文件，取名 **Base7_test.go**。
2. 编写单元测试代码如下：

		func TestConvertToBase7_1(t *testing.T) {
				if convertToBase7(100) != "202" {
				t.Errorf("convertToBase7 wrong")
			}
		}

		func TestConvertToBase7_2(t *testing.T){
				if convertToBase7(-7) != "-10" {
				t.Errorf("convertToBase7 wrong")
			}
		}

3. 运行。可使用IDE的运行按钮，也可以在命令行中输入 **go test** 命令运行。
4. 结果如下：

![测试结果1](/images/golang单元测试介绍/golang unit test introduce-1.png)

### golang中的quick包使用简介

quick包实现了一些函数来帮助黑盒测试。
有以下一些结构、接口和方法：

	func Check(f interface{}, config *Config) error
	func CheckEqual(f, g interface{}, config *Config) error
	func Value(t reflect.Type, rand *rand.Rand) (value reflect.Value, ok bool)
	type CheckEqualError
		func (s *CheckEqualError) Error() string
	type CheckError
		func (s *CheckError) Error() string
	type Config
	type Generator
	type SetupError
		func (s SetupError) Error() string

其中可以实现 **Generator** 接口中的 **Generate** 方法来实现生成数据的逻辑。然后用Check等方法来判断。同样写 **convertToBase7** 方法的测试用例。

1. 编写单元测试代码如下：(由于只需要 **int** 类型的基本类型的测试数据，所以 **Generate** 方法可以不写，**Golang** 语言内部已经实现。)
	
		func runConvertToBase7(data int) bool {
			return convertToBase7(data) == strconv.FormatInt(int64(data), 7)
		}

		func TestConvertToBase7_3(t *testing.T)  {
			if err := quick.Check(runConvertToBase7, nil); err != nil {
				t.Errorf("convertToBase7 wrong")
			}
		}

2. 运行。
3. 结果如下：

![测试结果2](/images/golang单元测试介绍/golang unit test introduce-2.png)

### check包使用简介

在使用 **Golang** 语言提供的单元测试时，可以发现没有 **java**等语言提供的 **aeesrt** 断言好用。因此可以使用 **github** 开源项目中的 [**check**](http://labix.org/gocheck) 包。 **check** 包也有一些要求，官网例子如下：

	package hello_test

	import (
		"testing"
		"io"
		. "gopkg.in/check.v1"
	)

	// Hook up gocheck into the "go test" runner.
	func Test(t *testing.T) { TestingT(t) }

	type MySuite struct{}

	var _ = Suite(&MySuite{})

	func (s *MySuite) TestHelloWorld(c *C) {
		c.Assert(42, Equals, "42")
		c.Assert(io.ErrClosedPipe, ErrorMatches, "io: .*on closed pipe")
		c.Check(42, Equals, 42)
	}

它提供了四个函数来固定测试所需的操作。

1. `func (s *SuiteType) SetUpSuite(c *C)` - Run once when the suite starts running.
2. `func (s *SuiteType) SetUpTest(c *C)` - Run before each test or benchmark starts running.
3. `func (s *SuiteType) TearDownTest(c *C)` - Run after each test or benchmark runs.
4. `func (s *SuiteType) TearDownSuite(c *C)` - Run once after all tests or benchmarks have finished running.

同样 **convertToBase7** 函数的测试代码如下：

	func Test(t *testing.T) {
		check.TestingT(t)
	}

	type base7Suite struct {
		data int
	}

	var _ = check.Suite(&base7Suite{})

	func (s *base7Suite) SetUpTest(c *check.C) {
		r := rand.New(rand.NewSource(time.Now().UnixNano()))
		s.data = r.Intn(100)
	}

	func (s *base7Suite) TestBlockSuite1(c *check.C) {
		c.Assert(convertToBase7(s.data), check.Equals, 	strconv.FormatInt(int64(s.data), 7))
	}  

测试结果如下：

![测试结果3](/images/golang单元测试介绍/golang unit test introduce-3.png)

### 编程环境

作者使用的编程语言为 [**golang**](https://golang.org)，版本为 **go version go1.7.5 darwin/amd64**

### 参考链接

1. https://golang.org/pkg/testing/
2. https://golang.org/pkg/testing/quick/#CheckEqual
3. https://godoc.org/gopkg.in/check.v1#Suite
4. http://labix.org/gocheck

### 推荐阅读

如果想要获取更为详细的语言的单元测试的介绍，以下博客我觉得较为详细。

1. http://tabalt.net/blog/golang-testing/