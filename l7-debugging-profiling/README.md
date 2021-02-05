# 计算机教育中缺失的一课 - MIT - L7 - 调试及性能分析

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### 调试

#### 打印调试法与日志

日志相比临时添加打印语句有如下优势：

*   您可以将日志写入文件、socket 或者甚至是发送到远端服务器而不仅仅是标准输出；
*   日志可以支持严重等级（例如 INFO, DEBUG, WARN, ERROR等)，这使您可以根据需要过滤日志；
*   对于新发现的问题，很可能您的日志中已经包含了可以帮助您定位问题的足够的信息。

[这里](https://missing-semester-cn.github.io/static/files/logger.py) 是课堂演示的包含日志的 Python 程序。

`ls` 和 `grep` 这样的程序会使用 [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code)，它是一系列的特殊字符，可以使您的 shell 改变输出结果的颜色。

```bash
#!/usr/bin/env bash
for R in $(seq 0 20 255); do
    for G in $(seq 0 20 255); do
        for B in $(seq 0 20 255); do printf "e[38;2;${R};${G};${B}m█e[0m";
        done
    done
done
```

#### 第三方日志系统

- 程序的日志通常存放在 `/var/log`
- 大多数的 Linux 系统都会使用 `systemd`，这是一个系统守护进程，它会控制您系统中的很多东西，例如哪些服务应该启动并运行
- `systemd` 会将日志以某种特殊格式存放于 `/var/log/journal`，您可以使用 [`journalctl`](http://man7.org/linux/man-pages/man1/journalctl.1.html) 命令显示这些消息
- macOS 系统中是 `/var/log/system.log`，但是有更多的工具会使用系统日志，它的内容可以使用 [`log show`](https://www.manpagez.com/man/1/log/) 显示
- 对于大多数的 UNIX 系统，您也可以使用[`dmesg`](http://man7.org/linux/man-pages/man1/dmesg.1.html) 命令来读取内核的日志
- 使用 [`logger`](http://man7.org/linux/man-pages/man1/logger.1.html) 这个 shell 程序将日志加入到系统日志中
- 一些像 [`lnav`](http://lnav.org/) 这样的工具，它为日志文件提供了更好的展现和浏览方式

#### 调试器

调试器可以：

*   当到达某一行时将程序暂停；
*   一次一条指令地逐步执行程序；
*   程序崩溃后查看变量的值；
*   满足特定条件时暂停程序；
*   其他高级功能。

常见调试器有：

- [`pdb`](https://docs.python.org/3/library/pdb.html)：Python 的调试器
- [`ipdb`](https://pypi.org/project/ipdb/)：一种增强型的 `pdb` ，它使用[`IPython`](https://ipython.org/) 作为 REPL并开启了 tab 补全、语法高亮、更好的回溯和更好的内省，同时还保留了`pdb` 模块相同的接口
-  [`gdb`](https://www.gnu.org/software/gdb/) ( 以及它的改进版 [`pwndbg`](https://github.com/pwndbg/pwndbg)) 和 [`lldb`](https://lldb.llvm.org/)：C 和类 C 语言的调试器，还可以探索任意进程及其机器状态：寄存器、堆栈、程序计数器等

#### 专门工具

- 追踪普通二进制程序执行的系统调用：[`strace`](http://man7.org/linux/man-pages/man1/strace.1.html)（Linux）和 [`dtrace`](http://dtrace.org/blogs/about/)（macOS 和 BSD），一个叫做 [`dtruss`](https://www.manpagez.com/man/1/dtruss/) 的封装使 `dtruss` 具有和 `strace` (更多信息参考 [这里](https://8thlight.com/blog/colin-jones/2015/11/06/dtrace-even-better-than-strace-for-osx.html)）类似的接口
- 网络数据包分析工具：[`tcpdump`](http://man7.org/linux/man-pages/man1/tcpdump.1.html) 和 [Wireshark](https://www.wireshark.org/)
- web 开发：Chrome/Firefox 的开发者工具

#### 静态分析

[静态分析](https://en.wikipedia.org/wiki/Static_program_analysis) 工具将程序的源码作为输入然后基于编码规则对其进行分析并对代码的**正确性**进行推理。

大多数的编辑器和 IDE 都支持在编辑界面显示这些工具（还有风格检查或安全检查）的分析结果、高亮有警告和错误的位置。这个过程通常称为 **code linting** 。

- **静态分析工具**
    - [`pyflakes`](https://pypi.org/project/pyflakes)：Python 的静态分析工具
    - [`mypy`](http://mypy-lang.org/)：另外一个 Python 静态分析工具，它可以对代码进行类型检查
    - [`shellcheck`](https://www.shellcheck.net/)：shell 脚本的静态分析工具，在 shell 工具那一节课介绍过
- **风格检查和安全检查工具**
    - [`pylint`](https://www.pylint.org/), [`pep8`](https://pypi.org/project/pep8/), [`black`](https://github.com/psf/black)：都是 Python 的风格检查工具
    - gofmt：Go 的风格检查工具
    - rustfmt：Rust 的风格检查工具
    - [`prettier`](https://prettier.io/)：JavaScript, HTML 和 CSS 的风格检查工具
    - [`bandit`](https://pypi.org/project/bandit/)：Python 的安全检查工具
- **Vim 的 code linting 插件**
    - [`ale`](https://vimawesome.com/plugin/ale)
    - [`syntastic`](https://vimawesome.com/plugin/syntastic)

### 性能分析

#### 计时

最常见的做法是打印两处代码之间的时间差来获得执行时间（wall clock time），例如使用 Python 的 [`time`](https://docs.python.org/3/library/time.html)模块。不过，执行时间也可能会误导您，因为您的电脑可能也在同时运行其他进程，也可能在此期间发生了等待。通常来说，用户时间 + 系统时间代表了您的进程所消耗的实际 CPU （更详细的解释可以参照[这篇文章](https://stackoverflow.com/questions/556405/what-do-real-user-and-sys-mean-in-the-output-of-time1)）。

*   真实时间 - 从程序开始到结束流失掉的真实时间，包括其他进程的执行时间以及阻塞消耗的时间（例如等待 I/O或网络）；
*   _User_ - CPU 执行用户代码所花费的时间；
*   _Sys_ - CPU 执行系统内核代码所花费的时间。

例如，试着执行一个用于发起 HTTP 请求的命令并在其前面添加 [`time`](http://man7.org/linux/man-pages/man1/time.1.html) 前缀。网络不好的情况下您可能会看到下面的输出结果。请求花费了 2s 才完成，但是进程仅花费了 15ms 的 CPU 用户时间和 12ms 的 CPU 内核时间。

```
$ time curl https://missing.csail.mit.edu &> /dev/null`
real    0m2.561s
user    0m0.015s
sys     0m0.012s
```

#### 性能分析工具（profilers）

##### CPU

[How do Ruby & Python profilers work?](https://jvns.ca/blog/2017/12/17/how-do-ruby---python-profilers-work-/)

大多数情况下，当人们提及性能分析工具的时候，通常指的是 CPU 性能分析工具。以 Python 的性能分析工具举例：

- **追踪分析器（tracing）**
    - [cProfile](https://docs.python.org/2/library/profile.html#module-cProfile)：追踪函数调用耗时。需要注意的是它显示的是每次函数调用的时间。看上去可能快到反直觉，尤其是如果您在代码里面使用了第三方的函数库，因为内部函数调用也会被看作函数调用
    -  [line_profiler](https://github.com/rkern/line_profiler)：行分析器。
-  **采样分析器（sampling）**（周期性地监测您的程序并记录程序堆栈）
    -  [pyflame](https://github.com/uber/pyflame)

##### 内存

- 对于手动管理内存的语言可能存在内存泄漏问题，例如 C、C++，可以使用类似 [Valgrind](https://valgrind.org/) 这样的工具来检查
- 对于有 GC 的语言，例如 Python、Java、JavaScript，内存分析器也是很有用的，因为对于某个对象来说，只要有指针还指向它，那它就不会被回收，可以使用 [memory-profiler](https://pypi.org/project/memory-profiler/) 来对 Python 代码进行内存分析

#### 事件分析

前面提到 `strace` 可用以追踪程序执行的系统调用，[`perf`](http://man7.org/linux/man-pages/man1/perf.1.html) 命令可以追踪报告特定的系统事件，例如不佳的缓存局部性（poor cache locality）、大量的页错误（page faults）或活锁（livelocks）。下面是关于常见命令的简介：

*   `perf list` - 列出可以被 pref 追踪的事件；
*   `perf stat COMMAND ARG1 ARG2` - 收集与某个进程或指令相关的事件；
*   `perf record COMMAND ARG1 ARG2` - 记录命令执行的采样信息并将统计数据储存在`perf.data`中；
*   `perf report` - 格式化并打印 `perf.data` 中的数据。

#### 可视化

对于采样分析器来说，常见的显示 CPU 分析数据的形式是 [火焰图](http://www.brendangregg.com/flamegraphs.html)，火焰图会在 Y 轴显示函数调用关系，并在 X 轴显示其耗时的比例。

[![FlameGraph](http://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)](http://www.brendangregg.com/FlameGraphs/cpu-bash-flamegraph.svg)

调用图和控制流图可以显示子程序之间的关系，它将函数作为节点并把函数调用作为边。将它们和分析器的信息（例如调用次数、耗时等）放在一起使用时，调用图会变得非常有用，它可以帮助我们分析程序的流程。 在 Python 中您可以使用 [`pycallgraph`](http://pycallgraph.slowchop.com/en/master/) 来生成这些图片。

#### 资源监控

*   **通用监控**
    *   [`htop`](https://hisham.hm/htop/index.php) 是 [`top`](http://man7.org/linux/man-pages/man1/top.1.html) 的改进版，常用快捷键有：`<F6>` 进程排序、 `t` 显示树状结构和 `h` 打开或折叠线程
    *  [`glances`](https://nicolargo.github.io/glances/)，实现类似但是用户界面更好
    *  如果需要， [`dstat`](http://dag.wiee.rs/home-made/dstat/)，合并测量进程，可以实时地计算不同子系统资源的度量数据，例如 I/O、网络、 CPU 利用率、上下文切换等等
*   **I/O 操作**
    *   [`iotop`](http://man7.org/linux/man-pages/man8/iotop.8.html) 可以显示实时 I/O 占用信息而且可以非常方便地检查某个进程是否正在执行大量的磁盘读写操作
*   **磁盘使用**
    *   [`df`](http://man7.org/linux/man-pages/man1/df.1.html) 可以显示每个分区的信息
    *   [`du`](http://man7.org/linux/man-pages/man1/du.1.html) 可以显示当前目录下每个文件的磁盘使用情况（ **d**isk **u**sage）。`-h` 选项可以使命令以对人类更加友好的格式显示数据
    *   [`ncdu`](https://dev.yorhel.nl/ncdu)是一个交互性更好的 `du` ，可以在不同目录下导航、删除文件和文件夹
*   **内存使用**
    *   [`free`](http://man7.org/linux/man-pages/man1/free.1.html) 可以显示系统当前空闲的内存。内存，也可以使用 `htop` 这样的工具来显示
*   **打开文件**
    *   [`lsof`](http://man7.org/linux/man-pages/man8/lsof.8.html) 可以列出被进程打开的文件信息。 当我们需要查看某个文件是被哪个进程打开的时候，这个命令非常有用；
*   **网络连接和配置**
    *   [`ss`](http://man7.org/linux/man-pages/man8/ss.8.html) 能帮助我们监控网络包的收发情况以及网络接口的显示信息，`ss` 常见的一个使用场景是找到端口被进程占用的信息
    *   [`ip`](http://man7.org/linux/man-pages/man8/ip.8.html) 命令可以显示路由、网络设备和接口信息
    *   `netstat` 和 `ifconfig` 这两个命令已经被前面那些工具所代替了
*   **网络使用**
    *   [`nethogs`](https://github.com/raboof/nethogs) 和 [`iftop`](http://www.ex-parrot.com/pdw/iftop/) 是非常好的用于对网络占用进行监控的交互式命令行工具

如果您希望测试一下这些工具，您可以使用 [`stress`](https://linux.die.net/man/1/stress) 命令来为系统人为地增加负载。

#### 专用工具

[`hyperfine`](https://github.com/sharkdp/hyperfine) 这样的命令行可以帮您快速进行基准测试（benchmark）。例如，我们在 shell 工具和脚本那一节课中我们推荐使用 `fd` 来代替 `find`。我们这里可以用 `hyperfine` 来比较一下它们。

```bash
$ hyperfine --warmup 3 'fd -e jpg' 'find . -iname "*.jpg"'
```

浏览器（例如 Chrome 和 Firefox）也包含了很多不错的性能分析工具，可以用来分析页面加载，让我们可以搞清楚时间都消耗在什么地方（加载、渲染、脚本等等）。

## 课后习题

### 调试

#### 习题 2

学习 [这份](https://github.com/spiside/pdb-tutorial) `pdb` 实践教程并熟悉相关的命令。更深入的信息您可以参考[这份](https://realpython.com/python-debugging-pdb)教程。

#### 习题 3

给 Vim 安装 ale 插件后：

[![yGL6FP.png](https://s3.ax1x.com/2021/02/05/yGL6FP.png)](https://imgchr.com/i/yGL6FP)

修改后：

```bash
for f in $(glob '*.m3u')
do
  grep -qi "hq.*mp3" "$f" \
    && echo "Playlist $f contains a HQ file in mp3 format"
done
```

#### 习题 4

阅读 [可逆调试](https://undo.io/resources/reverse-debugging-whitepaper/) 并尝试创建一个可以工作的例子（使用 [`rr`](https://rr-project.org/) 或 [`RevPDB`](https://morepypy.blogspot.com/2016/07/reverse-debugging-for-python.html)）。

### 性能分析

#### 习题 2

简单递归的调用图：

[![yGjUzT.png](https://s3.ax1x.com/2021/02/05/yGjUzT.png)](https://imgchr.com/i/yGjUzT)

带备忘录的递归的调用图：

[![yGvZm4.png](https://s3.ax1x.com/2021/02/05/yGvZm4.png)](https://imgchr.com/i/yGvZm4)

#### 习题 3

[![yGv43V.png](https://s3.ax1x.com/2021/02/05/yGv43V.png)](https://imgchr.com/i/yGv43V)

#### 习题 4

执行 `stress -c 3` 时，在 htop 中可以看到，有三个 CPU 核心正在满负荷工作（不一定是 0, 1, 2 这三个）。

执行 `taskset --cpu-list 0,2 stress -c 3` 时，在 htop 中可以看到，stress 程序只占用了 0, 2 两个 CPU，这是 taskset 命令的参数指定的。如果改为 `taskset --cpu-list 0-2 stress -c 3`，则将占用 0, 1, 2 三个 CPU。

用 [`cgroups`](http://man7.org/linux/man-pages/man7/cgroups.7.html)来实现相同的操作：参考 [Cgroup限制cpu使用](https://www.cnblogs.com/wuchangblog/p/13937715.html) 和 [用 cgroups 管理 cpu 资源](http://xiezhenye.com/2013/10/用-cgroups-管理-cpu-资源.html)。
