# 计算机教育中缺失的一课 - MIT - L4 - 数据整理

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### REGEX

1. [入门交互式教程](https://regexone.com/)
2. [进阶文字教程](https://deerchao.cn/tutorials/regex/regex.htm)

[regex debugger](https://regex101.com/r/qqbZqh/2)

### A taste of data wrangling

``` bash
ssh myserver journalctl
 | grep sshd
 | grep "Disconnected from"
 | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [0-9.]+ port [0-9]+( [preauth])?$/2/'
 | sort | uniq -c
 | sort -nk1,1 | tail -n10
 | awk '{print $2}' | paste -sd, 
```

`sort -n` 会按照数字顺序对输入进行排序（默认情况下是按照字典序排序 `-k1,1` 则表示“仅基于以空格分割的第一列进行排序”。`,n` 部分表示“仅排序到第n个部分”，默认情况是到行尾。就本例来说，针对整个行进行排序也没有任何问题，我们这里主要是为了学习这一用法！

如果我们希望得到登陆次数最少的用户，我们可以使用 `head` 来代替`tail`。或者使用`sort -r`来进行倒序排序。

我们可以利用 `paste`命令来合并行(`-s`)，并指定一个分隔符进行分割 (`-d`)。

### AWK

`awk` 其实是一种编程语言，只不过它碰巧非常善于处理文本。

`awk` 程序接受一个模式串（可选），以及一个代码块，指定当模式匹配时应该做何种操作。默认当模式串即匹配所有行（上面命令中当用法）。 在代码块中，`$0` 表示整行的内容，`$1` 到 `$n` 为一行中的 n 个区域，区域的分割基于 `awk` 的域分隔符（默认是空格，可以通过`-F`来修改）。在这个例子中，我们的代码意思是：对于每一行文本，打印其第二个部分，也就是用户名。

再举个例子，让我们统计一下所有以`c` 开头，以 `e` 结尾，并且仅尝试过一次登陆的用户。

```bash
 | awk '$1 == 1 && $2 ~ /^c[^ ]*e$/ { print $2 }' | wc -l 
```

其中 `wc -l` 统计输出结果的行数。

既然 `awk` 是一种编程语言，那么则可以这样：

```bash
BEGIN { rows = 0 }
$1 == 1 && $2 ~ /^c[^ ]*e$/ { rows += $1 }
END { print rows } 
```

`BEGIN` 也是一种模式，它会匹配输入的开头（ `END` 则匹配结尾）。然后，对每一行第一个部分进行累加，最后将结果输出。

### bc

bc (Berkeley Calculator) 是一个命令行计算器。例如这样，可以将每行的数字加起来：

```bash
 | paste -sd+ | bc -l 
```

下面这种更加复杂的表达式也可以：

```bash
echo "2*($(data | paste -sd+))" | bc -l 
```

### Shell 命令中的 `-`

虽然到目前为止我们的讨论都是基于文本数据，但对于二进制文件其实同样有用。例如我们可以用 ffmpeg 从相机中捕获一张图片，将其转换成灰度图后通过SSH将压缩后的文件发送到远端服务器，并在那里解压、存档并显示。

```bash
ffmpeg -loglevel panic -i /dev/video0 -frames 1 -f image2 -
 | convert - -colorspace gray -
 | gzip
 | ssh mymachine 'gzip -d | tee copy.jpg | env DISPLAY=:0 feh -' 
```

其中 `-frames 1` 为第一帧画面，`-f image2` 将结果保存为图片而不是视频格式。

命令中 `-` 代表标准输入输出流，例如 `convert - -colorspace gray -` 的意思是把标准输入流的内容作为程序的输入，灰度处理后的结果再放到标准输出流中。

## 课后练习

### 习题 2

words 文件可以在这里下载：[/usr/share/dict/words](https://gist.github.com/wchargin/8927565)

```bash
$ grep -E "^.*[aA].*[aA].*[aA].*$" /usr/share/dict/words \
| grep -vE "'s$" \
| sed -E "s/^.*(\w{2})$/\1/" \
| sort \
| uniq -ic \
| sort -r \
| head -n3

    101 an
     63 ns
     51 ia
```

共存在多少种词尾两字母组合？显然

```bash
$ echo "26*26" | bc -l
676
```

我们把刚才的词尾保存下来，把所有的字母组合也保存为文件。

```bash
$ grep -E "^.*[aA].*[aA].*[aA].*$" /usr/share/dict/words \
| grep -vE "'s$" \
| sed -E "s/^.*(\w{2})$/\1/" \
| sort \
| uniq -i > words.txt 2> words.txt

$ cat words.txt | head -n5
aa
ac
ad
ae
ag

$ echo {a..z}{a..z} | sed -E 's/ /\n/g' > full_words.txt

$ cat full_words.txt | head -n5
aa
ab
ac
ad
ae
```

分别统计统计一下组合数：

```bash
$ wc -w full_words.txt
676 full_words.txt
$ wc -w words.txt
110 words.txt
```

然后我们找没有出现过的组合，具体做法是把 words.txt 中的每一行作为查找串，在 full_words.txt 中不匹配的行。

```bash
$ grep -F -v -f words.txt full_words.txt | head -n 5
ab
af
ai
aj
ao
```

结果应该共有 `676 - 110 = 566` 个，验证一下：

```bash
$ grep -F -v -f words.txt full_words.txt | wc -w
566
```

### 习题 3

用输出重定向进行原地替换只会得到空文件。`man sed` 中可以看到 sed 有 -i 选项，可以进行原地替换。

```
       -i[SUFFIX], --in-place[=SUFFIX]

              edit files in place (makes backup if SUFFIX supplied)
```
