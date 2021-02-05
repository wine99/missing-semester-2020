# 计算机教育中缺失的一课 - MIT - L2 - Shell 工具和脚本

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### Shell 脚本

#### 特殊变量

*  `$0` - 脚本名
*  `$1` 到 `$9` - 脚本的参数。 `$1` 是第一个参数，依此类推。
*  `$@` - 所有参数
*  `$#` - 参数个数
*  `$?` - 前一个命令的返回值
*  `$$` - 当前脚本的进程识别码
*  `!!` - 完整的上一条命令，包括参数。常见应用：当你因为权限不足执行命令失败时，可以使用 `sudo !!`再尝试一次。
*  `$_` - 上一条命令的最后一个参数。如果你正在使用的是交互式shell，你可以通过按下 `Esc` 之后键入 `.` 来获取这个值。

### 进程替换

一个冷门的类似特性是 _进程替换_ ( _process substitution_ )， `<( CMD )` 会执行 `CMD` 并将结果输出到一个临时文件中，并将 `<( CMD )` 替换成临时文件名。这在我们希望返回值通过文件而不是STDIN传递时很有用。例如， `diff <(ls foo) <(ls bar)` 会显示文件夹 `foo` 和 `bar` 中文件的区别。

### 通配（globbing）

```bash
convert image.{png,jpg}
# 会展开为
convert image.png image.jpg

cp /path/to/project/{foo,bar,baz}.sh /newpath
# 会展开为
cp /path/to/project/foo.sh /path/to/project/bar.sh /path/to/project/baz.sh /newpath

# 也可以结合通配使用
mv *{.py,.sh} folder
# 会移动所有 *.py 和 *.sh 文件

mkdir foo bar

# 下面命令会创建foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h这些文件
touch {foo,bar}/{a..h}
touch foo/x bar/y
# 显示foo和bar文件的不同
diff <(ls foo) <(ls bar)
# 输出
# < x
# ---
# > y
```

### shebang

注意，脚本并不一定只有用bash写才能在终端里调用。比如说，这是一段Python脚本，作用是将输入的参数倒序输出：

```python
#!/usr/local/bin/python import sys
for arg in reversed(sys.argv[1:]):
    print(arg) 
```

shell知道去用python解释器而不是shell命令来运行这段脚本，是因为脚本的开头第一行的 [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))。

在 `shebang` 行中使用 [`env`](http://man7.org/linux/man-pages/man1/env.1.html) 命令是一种好的实践，它会利用环境变量中的程序来解析该脚本，这样就提高来您的脚本的可移植性。`env` 会利用我们第一节讲座中介绍过的`PATH` 环境变量来进行定位。 例如，使用了`env`的shebang看上去时这样的`#!/usr/bin/env python`。

### shellcheck

编写 `bash` 脚本有时候会很别扭和反直觉。例如 [shellcheck](https://github.com/koalaman/shellcheck) 这样的工具可以帮助你定位sh/bash脚本中的错误。例如：

[![y9OItH.png](https://s3.ax1x.com/2021/01/28/y9OItH.png)](https://imgchr.com/i/y9OItH)

[![y9xQvn.png](https://s3.ax1x.com/2021/01/28/y9xQvn.png)](https://imgchr.com/i/y9xQvn)

## Shell 工具

### 查看命令如何使用

- [tldr](https://tldr.sh/)
- [cheat](https://github.com/cheat/cheat)

### 查找文件

- [find](http://man7.org/linux/man-pages/man1/find.1.html)
- [locate](http://man7.org/linux/man-pages/man1/locate.1.html)
- [fd](https://github.com/sharkdp/fd)

[locate 和 find 的对比](https://unix.stackexchange.com/questions/60205/locate-vs-find-usage-pros-and-cons-of-each-other)。

### 查找代码

- [grep](http://man7.org/linux/man-pages/man1/grep.1.html)
- [rg](https://github.com/BurntSushi/ripgrep)
- [ack](https://beyondgrep.com)
- [ag](https://github.com/ggreer/the_silver_searcher)

grep 的例子：

[![y9zXFO.png](https://s3.ax1x.com/2021/01/28/y9zXFO.png)](https://imgchr.com/i/y9zXFO)

rg 的例子：

```bash
# 查找所有使用了 requests 库的文件
rg -t py 'import requests'
# 查找所有没有写 shebang 的文件（包含隐藏文件）
rg -u --files-without-match "^#!"
# 查找所有的foo字符串，并打印其之后的5行
rg foo -A 5
# 打印匹配的统计信息（匹配的行和文件的数量）
rg --stats PATTERN
```

### 查找 shell 命令

- history | grep
- history | [fzf](https://github.com/junegunn/fzf)
- 快捷键 Ctrl + R
- 自动补全：[fish shell](https://fishshell.com/) 或者 [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

有一点值得注意，输入命令时，如果您在命令的开头加上一个空格，它就不会被加进shell记录中。当你输入包含密码或是其他敏感信息的命令时会用到这一特性。如果你不小心忘了在前面加空格，可以通过编辑。`bash_history`或 `.zhistory` 来手动地从历史记录中移除那一项。

### 文件夹导航

- [fasd](https://github.com/clvv/fasd)
- autojump: [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
- [tree](https://linux.die.net/man/1/tree)
- [ranger](https://github.com/ranger/ranger)

> **Oh-my-zsh? 新手上路看这篇：[Setting up Windows Terminal, WSL and Oh-my-Zsh](https://www.ivaylopavlov.com/setting-up-windows-terminal-wsl-and-oh-my-zsh/#install_windows_terminal)**

## 课后练习

### 习题 1

[![yCCQ0I.png](https://s3.ax1x.com/2021/01/28/yCCQ0I.png)](https://imgchr.com/i/yCCQ0I)

### 习题 2

macro.sh:

```bash
macro() {
    macro_dir=$(pwd)
    echo "I am in $macro_dir" | tee /mnt/f/code/learn/missing-semester/l2-shell-tools/macro.txt
}
```

polo.sh:

```bash
polo() {
    cd "$macro_dir" || exit
    macro
}
```

[![yC0XE4.png](https://s3.ax1x.com/2021/01/29/yC0XE4.png)](https://imgchr.com/i/yC0XE4)

### 习题 3

ex3_solution.sh:

```bash
#!/usr/bin/env bash

./ex3_problem.sh > ex3_result.txt 2> ex3_result.txt
state=$?
count=0

while [[ state -eq 0 ]]; do
    ./ex3_problem.sh >> ex3_result.txt 2>> ex3_result.txt
    state=$?
    count=$((count + 1))
done

cat ex3_result.txt
echo "ex3_problem ran $count times before failure"
```

[![yCyUkF.png](https://s3.ax1x.com/2021/01/29/yCyUkF.png)](https://imgchr.com/i/yCyUkF)

### 习题 4

```bash
$ tree ex4_html_folder
ex4_html_folder
├── 1.html
├── 1.txt
├── a
│   ├── a 1.html
│   ├── a 1.txt
│   ├── a 2.txt
│   └── a 3.txt
└── b
    ├── b 1.html
    ├── b 2.html
    └── b 3.html

2 directories, 9 files
```

参考 `tldr xargs` 给出的用法示例：

```
 - Delete all files with a .backup extension (-print0 uses a null character to split file names, and -0 uses it as delimiter):
   find . -name {{'*.backup'}} -print0 | xargs -0 rm -v
```

`tldr tar` 给出了 tar 命令的用法示例：

```
 - [c]reate an archive from [f]iles:
   tar cf {{target.tar}} {{file1}} {{file2}} {{file3}}

 - E[x]tract a (compressed) archive [f]ile into the target directory:
   tar xf {{source.tar[.gz|.bz2|.xz]}} --directory={{directory}}

 - Lis[t] the contents of a tar [f]ile [v]erbosely:
   tar tvf {{source.tar}}
```

因此本题解答如下：

```bash
find . -name "*.html" -print0 | xargs -0 tar cf html.tar
```

验证一下：

```bash
$ tar tvf html.tar
-rwxrwxrwx yzj/yzj           0 2021-01-29 15:00 ./ex4_html_folder/1.html
-rwxrwxrwx yzj/yzj           0 2021-01-29 15:25 ./ex4_html_folder/a/a 1.html
-rwxrwxrwx yzj/yzj           0 2021-01-29 15:25 ./ex4_html_folder/b/b 1.html
-rwxrwxrwx yzj/yzj           0 2021-01-29 15:25 ./ex4_html_folder/b/b 2.html
-rwxrwxrwx yzj/yzj           0 2021-01-29 15:25 ./ex4_html_folder/b/b 3.html

$ mkdir ex4_html_folder_extracted
$ tar xf html.tar --directory=ex4_html_folder_extracted
$ tree ex4_html_folder_extracted
ex4_html_folder_extracted
└── ex4_html_folder
    ├── 1.html
    ├── a
    │   └── a 1.html
    └── b
        ├── b 1.html
        ├── b 2.html
        └── b 3.html

3 directories, 5 files
```

上面的解法是把 find 命令的输出的分隔符，由原本的换行符变成了 null，然后让 xargs 也用 null 作为分隔符。也可以用 -d 选项指定换行符作为分隔符，因此另解如下：

```bash
find . -name "*.html" | xargs -d "\n" tar cf html.tar
```

### 习题 5

```bash
# 按最近修改顺序列出文件
$ find . -type f -print0 | xargs -0 ls -lt --color
-rwxrwxrwx 1 yzj yzj 10240 Jan 29 15:27  ./html.tar
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/a/a 1.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder_extracted/ex4_html_folder/a/a 1.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/a/a 3.txt'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/a/a 2.txt'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/a/a 1.txt'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/b/b 1.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/b/b 2.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder/b/b 3.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder_extracted/ex4_html_folder/b/b 1.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder_extracted/ex4_html_folder/b/b 2.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:25 './ex4_html_folder_extracted/ex4_html_folder/b/b 3.html'
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:01  ./ex4_html_folder/1.txt
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:00  ./ex4_html_folder/1.html
-rwxrwxrwx 1 yzj yzj     0 Jan 29 15:00  ./ex4_html_folder_extracted/ex4_html_folder/1.html
-rwxrwxrwx 1 yzj yzj   837 Jan 29 10:14  ./ex3_result.txt
-rwxrwxrwx 1 yzj yzj   291 Jan 29 10:11  ./ex3_solution.sh
-rwxrwxrwx 1 yzj yzj   205 Jan 29 09:58  ./ex3_problem.sh
-rwxrwxrwx 1 yzj yzj    58 Jan 29 09:52  ./macro.txt
-rwxrwxrwx 1 yzj yzj    49 Jan 29 09:48  ./polo.sh
-rwxrwxrwx 1 yzj yzj   129 Jan 29 09:44  ./macro.sh
-rwxrwxrwx 1 yzj yzj    50 Jan 28 21:41  ./mcd.sh
-rwxrwxrwx 1 yzj yzj   509 Jan 28 21:10  ./example.sh

# 找到最近修改的文件
$ find . -type f -print0 | xargs -0 ls -lt --color | head -n1
-rwxrwxrwx 1 yzj yzj 10240 Jan 29 15:27 ./html.tar
```
