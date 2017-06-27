---
title: 如何在mac终端下控制字体颜色
date: 2017-06-27 15:52:12
tags:
---
### 内容简介

在编写 **Go** 代码输出 **json** 格式的字符串时，发现都是系统默认的字体颜色，不便于可读。想着如果能够跟jq一样，输出带颜色的字符串那该有多棒。此篇博客主要讲述**mac**终端下控制字体颜色，由于**linux**与**mac**同出一源，所以基本上也符合**linux**的终端.

<!-- more -->

### 在终端中控制字体颜色

通常我们可以使用`echo`命令加`-e`选项输出各种颜色的文本，例如：`echo -e "\033[31mRed Text\033[0m"`，可以输出红色的字体<font color="red">Red Text</font>。

其中：`"\033[31m"`和`"\033[0m"`是 **ANSI** 转义序列（ANSI escape code/sequence），它控制文本输出的格式、颜色等，大多数的类 **unix** 终端仿真器都能够解释 **ANSI** 转义序列。同类的多种设置项可以组合在一起，中间用分号 **;** 隔开

常用的参数列表如下：

编码 | 说明
--- | --- |
0 |	关闭所有格式，还原为初始状态
1 |	粗体/高亮显示
2 |	模糊（※）
3 |	斜体（※）
4 |	下划线（单线）
5 |	闪烁（慢）
6 |	闪烁（快）（※）
7 |	交换背景色与前景色
8 |	隐藏（伸手不见五指，啥也看不见）（※）
30-37 | 前景色，即30+x，x表示不同的颜色（参见下面的“颜色表”）
40-47 | 背景色，即40+x，x表示不同的颜色（参见下面的“颜色表”）

“颜色表”：

颜色值x | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
--- | --- | --- | --- | --- | --- | --- | ---| --- |
颜色 |	黑 | 红 | 绿 | 黄 | 蓝 | 紫 | 青 | 白

#### 样例

shell代码 | 结果
--- | --- |
`echo -e "\033[31mText\033[0m"` | <font color="red">Text</font>
`echo -e "\033[32mText\033[0m"` | <font color="green">Text</font>
`echo -e "\033[33mText\033[0m"` | <font color="yellow">Text</font>
`echo -e "\033[34mText\033[0m"` | <font color="blue">Text</font>
`echo -e "\033[35mText\033[0m"` | <font color="purple">Text</font>
`echo -e "\033[36mText\033[0m"` | <font color="cyan">Text</font>
`echo -e "\033[37mText\033[0m"` | <font color="white">Text</font>
`echo -e "\033[1;31mText\033[0m"` | <font color="red"><strong>Text</strong></font>

### Go语言转换json

好的，言归正传，目标是想把 **json** 数据输出成 **jq** 打开一样的效果，那么就是需要装饰 **json** 数据，代码如下：

	func Decorate(src string) string {
		desc := src
		desc = strings.Replace(desc, "[", "\033[30;1m[\033[0m", -1)
		desc = strings.Replace(desc, "]", "\033[30;1m]\033[0m", -1)
		desc = strings.Replace(desc, "{", "\033[30;1m{\033[0m", -1)
		desc = strings.Replace(desc, "}", "\033[30;1m}\033[0m", -1)
		desc = strings.Replace(desc, "\"", "\033[34;1m\"", -1)
		desc = strings.Replace(desc, "\033[34;1m\":", "\"\033[0m:", -1)
		desc = strings.Replace(desc, ": \033[34;1m\"", ": \033[32m\"", -1)
		desc = strings.Replace(desc, "\033[34;1m\",", "\"\033[0m,", -1)
		desc = strings.Replace(desc, "\033[34;1m\"\n", "\"\033[0m\n", -1)
		desc = strings.Replace(desc, ":", "\033[30;1m:\033[0m", -1)
		return desc
	}

测试代码如下：

	func main() {
		json := `{
		"name": "Bob",
		"height": 1.72
	}`
		fmt.Println(utils.Decorate(json))
	}
	
结果：

![result](/images/如何在mac终端下控制字体颜色/result-1.png)

### 参考资料

1. http://www.cnblogs.com/ghj1976/p/4242017.html
2. http://www.epooll.com/archives/770/






