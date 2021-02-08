# 计算机教育中缺失的一课 - MIT - L11 - Q&A

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### OS 学习资料

- [MIT’s 6.828](https://pdos.csail.mit.edu/6.828/) - 研究生阶段的操作系统课程，带你实现一个 OS
- 现代操作系统 - Andrew S. Tanenbaum，对各种概念做了系统的讲解
- FreeBSD的设计与实现（ _The Design and Implementation of the FreeBSD Operating System_ ） - 关于FreeBSD OS 不错的资源(注意，FreeBSD OS 不是 Linux)
- [用 Rust 写操作系统](https://os.phil-opp.com/)

### `source script.sh` 和 `./script.sh`

不同点在于哪个会话执行这个命令。 对于 `source` 命令来说，命令是在当前的bash会话中执行的，因此当 `source` 执行完毕，对当前环境的任何更改（例如更改目录或是定义函数）都会留存在当前会话中。 单独运行 `./script.sh` 时，当前的bash会话将启动新的bash会话（实例），并在新实例中运行命令 `script.sh`。

### 性能分析工具

- 最简单但是有效的：在代码中添加打印运行时间的语句，通过二分法逐步定位到花费时间最长的代码段。
- Valgrind 的 [Callgrind](http://valgrind.org/docs/manual/cl-manual.html) 可以让你运行程序并计算所有的时间花费以及所有调用堆栈。然后，它会生成带注释的代码版本，其中包含每行花费的时间。注意它不支持线程。
- 特定的编程语言可能会有自带的或者特定的第三方的分析工具
- 用于用户程序内核跟踪的[eBPF](http://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html)、低级的性能分析工具 [`bpftrace`](https://github.com/iovisor/bpftrace)：分析系统调用中的等待时间，因为有时代码中最慢的部分是系统等待磁盘读取或网络数据包之类的事件

### 浏览器插件

- [uBlock Origin](https://github.com/gorhill/uBlock)：[用途广泛（wide-spectrum）](https://github.com/gorhill/uBlock/wiki/Blocking-mode)的拦截器
    - [简易模式（easy mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-easy-mode)
    - [中等模式（medium mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-medium-mode)
    - [强力模式（hard mode）](https://github.com/gorhill/uBlock/wiki/Blocking-mode:-hard-mode)
- [Stylus](https://github.com/openstyles/stylus/)：自定义CSS样式加载到网站
    - 不要使用Stylish，它会[窃取浏览记录](https://www.theregister.co.uk/2018/07/05/browsers_pull_stylish_but_invasive_browser_extension/)
    - 可以使用其他用户编写并发布在[userstyles.org](https://userstyles.org/)中的样式
- 全页屏幕捕获：完整的页面截屏
    - 内置于 Firefox 和 [Chrome 扩展程序](https://chrome.google.com/webstore/detail/full-page-screen-capture/fdpohaocaechififmbbbbbknoalclacl?hl=en)中
- [多账户容器](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/)：将Cookie分为“容器”从而允许你以不同的身份浏览web网页并且/或确保网站无法在它们之间共享信息
- 密码集成管理器：可以使用火狐和谷歌自带的密码管理器，也可以使用第三方专门的密码管理器，通常拥有更强大的功能。使用密码管理器也可以防止钓鱼网站，因为管理器不会在假冒的域名站点弹出自动填充。

### 数据整理工具

- 在数据整理一讲中提到的分别针对 JSON 和 HTML 的 jq 和 pup
- Perl 语言**非常**擅长处理文本，值得进行学习，但它是一种“Write Only”的语言，因为写出来的代码可读性非常差
- Vim 也可以用来整理数据，例如利用 Vim 的宏
- Python 的 [pandas](https://pandas.pydata.org/) 库是整理表格数据（或类似格式）的好工具
- [Pandoc](https://www.pandoc.org/)：a universal document converter，可以在各种文档之间进行转换，HTML、Markdown、LaTex、docx、XML 等等
- R语言（一种有争议的[不好](http://arrgh.tim-smith.us/)的语言）作为一种主要用于统计分析的编程语言，在管道的最后一步（比如画图展示）非常有用，其绘图库 [ggplot2](https://ggplot2.tidyverse.org/) **非常**强大。

### Docker 与虚拟机的区别

- 虚拟机会执行整个的 OS 栈，包括内核（即使这个内核和主机内核相同）
- 容器与主机分享内核（在Linux环境中，有LXC机制来实现），当然容器内部感知不到，仍像是在使用自己的硬件启动程序
- 容器的隔离性较弱而且只有在主机运行相同的内核时才能正常工作
    - 例如，如果你在macOS 上运行 Docker，Docker 需要启动 Linux虚拟机去获取初始的 Linux内核，这样的开销仍然很大
- Docker 是容器的特定实现，它是为软件部署而定制的，有一些奇怪之处，例如
    - 在默认情况下，Docker 容器没有任何形式的持久化存储，关闭之后数据消失，而与之对应虚拟机通常有一个虚拟硬盘文件保存在主机上

### 如何选择操作系统

- 可以使用任何 Linux 发行版（Distro）去学习 Linux 与 UNIX 的特性和其内部工作原理
- 发行版之间的根本区别是发行版如何处理软件包更新
    - Arch Linux 采用滚动更新策略，用了最前沿的软件包（bleeding-edge），但软件可能并不稳定
    - Debian，CentOS 或 Ubuntu LTS 的更新策略要保守得多，因此更加稳定
- Mac OS 是介于 Windows 和 Linux 之间的一个操作系统
    - Mac OS 是基于BSD 而不是 Linux
- 另一种值得体验的是 FreeBSD
    - 与 Linux 相比，BSD 生态系统的碎片化程度要低得多，并且说明文档更加友好
- 作为程序员，你为什么还在用 Windows？除非你开发 Windows 应用程序或需要使用某些 Windows 系统更好支持的功能（例如对游戏的驱动程序支持）（有被冒犯到。。。）
- 对于双系统，我们认为最有效的是 macOS 的 bootcamp，因为长期来看，任何其他组合都可能会出现问题，尤其是当你结合了其他功能比如磁盘加密

### Vim 还是 Emacs

Emacs 不使用 vim 的模式编辑，但是这些功能可以通过 Emacs 插件比如 [Evil](https://github.com/emacs-evil/evil) 或 [Doom Emacs](https://github.com/hlissner/doom-emacs) 来实现。 Emacs的优点是可以用 Lisp 语言进行扩展（Lisp 比 vim 默认的脚本语言 vimscript 要更好用）。

### 机器学习应用的技巧

- 机器学习应用需要进行许多实验，探索数据，可以使用 Shell 轻松快速地搜索这些实验结果，并且以合理的方式汇总。
- 使用课程中介绍过的数据整理的工具，通过使用 JSON 文件记录实验的所有相关参数，让你的实验结果变得井井有条且可复现。
- 如果不使用集群提交 GPU 作业，那你应该研究如何使这些过程自动化。

### 两步验证（2FA）

最简单的情形是可以通过接收手机的 SMS 来实现（尽管 SMS 2FA 存在 [已知问题](https://www.kaspersky.com/blog/2fa-practical-guide/24219/)）。我们推荐使用 [YubiKey](https://www.yubico.com/) 之类的 [U2F](https://en.wikipedia.org/wiki/Universal_2nd_Factor) 方案。

### 如何选择浏览器

- Chrome 的渲染引擎是 Blink，JS 引擎是 V8。
- Firefox 的渲染引擎是 Gecko，JS 引擎是 SpiderMonkey。
- 其他浏览器大多都是 Chrome 的变种，用着 Chromium 内核，运行着同样的引擎，例如新版的 Microsoft Edge。至于 Safari 则基于 WebKit(与Blink类似的引擎)。这些浏览器仅仅是更糟糕的 Chrome 版本。
- Firefox 与 Chrome 的在各方面不相上下，但在隐私方面更加出色。
- Firefox 正在使用 Rust 重写他们的渲染引擎，名为 Servo。
- 一款目前还没有完成的叫 Flow 的浏览器，它实现了全新的渲染引擎，有望比现有引擎速度更快。