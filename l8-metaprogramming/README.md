# 计算机教育中缺失的一课 - MIT - L8 - 元编程

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

元编程通常又指 [用于操作程序的程序](https://en.wikipedia.org/wiki/Metaprogramming)，讲座中讨论的更多是关于开发**流程**。

### 构建系统

“构建系统”帮助我们执行一系列的“构建过程”。构建过程包括：目标（targets），依赖（dependencies），规则（rules）。您必须告诉构建系统您具体的构建目标，系统的任务则是找到构建这些目标所需要的依赖，并根据规则构建所需的中间产物，直到最终目标被构建出来。

理想的情况下，如果目标的依赖没有发生改动，并且我们可以从之前的构建中复用这些依赖，那么与其相关的构建规则并不会被执行。

`make` 是最常用的构建系统之一，您会发现它通常被安装到了几乎所有基于UNIX的系统中。`make` 的教程可以参考阮一峰的这篇文章：[Make 命令教程](https://www.ruanyifeng.com/blog/2015/02/make.html)。

其他常见的构建系统/工具：

- C 与 C++：Cmake，可以参考 [CMake 入门实战](https://www.hahack.com/codes/cmake/)
- Java：Maven，Ant，Gradle
- 前端开发：Grunt，Gulp，Webpack
- Ruby：Rake
- Rust：Cargo


### 依赖管理

#### 软件仓库

- Ubuntu：可以通过 `apt` 这个工具来访问 Ubuntu 软件包仓库
- CentOS，Redhat：通过 `yum` 这个工具来访问软件仓库
- Archlinux/Manjaro：通过 `pacman` 工具访问 Archlinux 软件仓库和 Arch 用户软件仓库（AUR，Arch User Repository）
- Ruby：通过 `gem` 工具访问 RubyGems
- Python：通过 `pip` 工具访问 Pypi

#### 版本号

不同项目所用的版本号其具体含义并不完全相同，但是一个相对比较常用的标准是[语义版本号](https://semver.org/)，这种版本号具有不同的语义，它的格式是这样的：major.minor.patch（主版本号.次版本号.补丁号）。相关规则有：

*   如果新的版本没有改变 API，请将补丁号递增；
*   如果您添加了 API 并且该改动是向后兼容的，请将次版本号递增；
*   如果您修改了 API 但是它并不向后兼容，请将主版本号递增。

这样做有很多好处，例如如果我们的项目是基于您的项目构建的，那么只要最新版本的主版本号只要没变就是安全的，次版本号不低于之前我们使用的版本即可。换句话说，如果我依赖的版本是`1.3.7`，那么使用`1.3.8`、`1.6.1`，甚至是`1.3.0`都是可以的。如果版本号是 `2.2.4` 就不一定能用了，因为它的主版本号增加了。

### 持续集成系统

持续集成，或者叫做 CI 是一种雨伞术语（umbrella term），它指的是那些“当您的代码变动时，自动运行的东西”，可以认为是一种云端构建系统。

市场上有很多提供各式各样 CI 工具的公司，例如 Travis CI、Azure Pipelines 和 GitHub Actions。

它们使用方法大同小异：在代码仓库中添加一个文件（recipe），在其中编写规则，规则包括 events 和 actions。

最常见的规则是：如果有人提交代码，执行测试套。当这个事件被触发时，CI 提供方会启动一个（或多个）虚拟机，执行您制定的规则，并且通常会记录下相关的执行结果。您可以进行某些设置，这样当测试套失败时您能够收到通知或者当测试全部通过时，您的仓库主页会显示一个徽标。

Github 还有一个维护依赖关系的 CI 工具 [Dependabot](https://dependabot.com/)。

GitHub Pages 是一个很好的例子。Pages 在每次`master`有代码更新时，会执行 Jekyll 博客软件，然后使您的站点可以通过某个 GitHub 域名来访问。对于我们来说这些事情太琐碎了，我现在我们只需要在本地进行修改，然后使用 git 提交代码，发布到远端。CI 会自动帮我们处理后续的事情。

### 测试

*   测试套（Test suite）：所有测试的统称
*   单元测试（Unit test）：一个“微型测试”，用于对某个封装的特性进行测试
*   集成测试（Integration test）: 一个“宏观测试”，针对系统的某一大部分进行，测试其不同的特性或组件是否能协同工作。
*   回归测试（Regression test）：用于保证之前引起问题的 bug 不会再次出现
*   模拟（Mocking）: 使用一个假的实现来替换函数、模块或类型，屏蔽那些和测试不相关的内容。例如，您可能会“模拟网络连接” 或 “模拟硬盘”

## 课后练习

### 习题 1

一些有用的 make [构建目标](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html#Standard-Targets)（例如本题用到了 [phony](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html)）。

```makefile
.PHONY: clean
clean:
      git ls-files -o | xargs rm
      # 这样还会删掉 gitignore 中的文件，例如一些编辑器配置文件
      # 此题也可以这样做
      # rm plot-*.png
      # rm paper.pdf
```

### 习题 3

```bash
#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.

# Redirect output to stderr.
exec 1>&2

if (! make)
then
    cat <<\EOF
Error: make failed.

Excuting 'make paper.pdf'.
EOF
    make paper.pdf
    exit 1
fi
```

### 习题 4

基于 [GitHub Pages](https://help.github.com/en/actions/automating-your-workflow-with-github-actions) 创建任意一个可以自动发布的页面。添加一个[GitHub Action](https://github.com/features/actions) 到该仓库，对仓库中的所有 shell 文件执行 `shellcheck`([方法之一](https://github.com/marketplace/actions/shellcheck))。

### 习题 5

[构建属于您的](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/building-actions) GitHub action，对仓库中所有的`.md`文件执行[`proselint`](http://proselint.com/) 或 [`write-good`](https://github.com/btford/write-good)，在您的仓库中开启这一功能，提交一个包含错误的文件看看该功能是否生效。
