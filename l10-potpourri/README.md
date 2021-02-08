# 计算机教育中缺失的一课 - MIT - L10 - 大杂烩

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### 修改键位映射

修改键位映射可以通过软件或者硬件（支持定制固件的键盘）实现。软件可以实现更复杂的修改例如对不同的键盘或软件保存专用的映射配置。

下面是一些修改键位映射的软件：

*   macOS - [karabiner-elements](https://pqrs.org/osx/karabiner/), [skhd](https://github.com/koekeishiya/skhd) 或者 [BetterTouchTool](https://folivora.ai/)
*   Linux - [xmodmap](https://wiki.archlinux.org/index.php/Xmodmap) 或者 [Autokey](https://github.com/autokey/autokey)
*   Windows - 控制面板，[AutoHotkey](https://www.autohotkey.com/) 或者 [SharpKeys](https://www.randyrants.com/category/sharpkeys/)
*   QMK - 如果你的键盘支持定制固件，[QMK](https://docs.qmk.fm/) 可以直接在键盘的硬件上修改键位映射。比如我正在用的宁芝的 atom66（宁芝看到记得给我打钱）。

### 守护进程（daemon）

- 在后台保持运行，不需要用户手动运行或者交互
- 以守护进程运行的程序名一般以 `d` 结尾
- SSH 服务端 `sshd`，用来监听传入的 SSH 连接请求并对用户进行鉴权
- Linux 中的 `systemd`（the system daemon），用来配置和运行守护进程
    - 使用 `systemctl` 命令来与 systemd 交互
    - `systemctl enable|disable|start|stop|restart|status`
- 如果只是想定期运行一些程序，可以直接使用 [`cron`](http://man7.org/linux/man-pages/man8/cron.8.html)。它是一个系统内置的，用来执行定期任务的守护进程。

下面的配置文件使用了 systemd 来运行一个 Python 程序，`systemd` 配置文件的详细指南可参见 [freedesktop.org](https://www.freedesktop.org/software/systemd/man/systemd.service.html)。

```ini
# /etc/systemd/system/myapp.service
[Unit]
# 配置文件描述
Description=My Custom App
# 在网络服务启动后启动该进程
After=network.target

[Service]
# 运行该进程的用户
User=foo
# 运行该进程的用户组
Group=foo
# 运行该进程的根目录
WorkingDirectory=/home/foo/projects/mydaemon
# 开始该进程的命令
ExecStart=/usr/bin/local/python3.7 app.py
# 在出现错误时重启该进程
Restart=on-failure

[Install]
# 相当于Windows的开机启动。即使GUI没有启动，该进程也会加载并运行
WantedBy=multi-user.target
# 如果该进程仅需要在GUI活动时运行，这里应写作：
# WantedBy=graphical.target
# graphical.target在multi-user.target的基础上运行和GUI相关的服务
```

### FUSE

**用户空间文件系统**（**F**ilesystem in **Use**rspace，简称**FUSE**）是一个面向[类Unix](https://zh.wikipedia.org/wiki/%E7%B1%BBUnix "类Unix")计算机操作系统的软件接口，它使无特权的用户能够无需编辑[内核](https://zh.wikipedia.org/wiki/%E5%86%85%E6%A0%B8 "内核")代码而创建自己的[文件系统](https://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)。目前[Linux](https://zh.wikipedia.org/wiki/Linux "Linux")通过[内核模块](https://zh.wikipedia.org/w/index.php?title=%E5%86%85%E6%A0%B8%E6%A8%A1%E5%9D%97&action=edit&redlink=1 "内核模块（页面不存在）")对此进行支持。

一些有趣的 FUSE 文件系统包括：

*   [sshfs](https://github.com/libfuse/sshfs)：一个将所有文件系统操作都使用 SSH 转发到远程主机，由远程主机处理后返回结果到本地计算机的虚拟文件系统。这个文件系统里的文件虽然存储在远程主机，对于本地计算机上的软件而言和存储在本地别无二致
*   [rclone](https://rclone.org/commands/rclone_mount/)：将 Dropbox、Google Drive、Amazon S3、或者 Google Cloud Storage 一类的云存储服务挂载为本地文件系统
*   [gocryptfs](https://nuetzlich.net/gocryptfs/)：覆盖在加密文件上的文件系统。文件以加密形式保存在磁盘里，但该文件系统挂载后用户可以直接从挂载点访问文件的明文
*   [kbfs](https://keybase.io/docs/kbfs)：分布式端到端加密文件系统。在这个文件系统里有私密（private），共享（shared），以及公开（public）三种类型的文件夹
*   [borgbackup](https://borgbackup.readthedocs.io/en/stable/usage/mount.html)：方便用户浏览删除重复数据后的压缩加密备份

### 备份

- 复制存储在同一个磁盘上的数据**不是备份**，因为这个磁盘是一个单点故障（single point of failure）
- 同步方案**不是备份**
    - 如 Dropbox 或者 Google Drive，当数据在本地被抹除或者损坏，同步方案可能会把这些“更改”同步到云端。
    - RAID 这样的磁盘镜像方案也不是备份。它不能防止文件被意外删除、损坏、或者被勒索软件加密。
- 不要盲目信任备份方案。用户应该经常检查备份是否可以用来恢复数据。
    - 云端应用的重大发展使得我们很多的数据只存储在云端。但用户应该有这些数据的离线备份。

有效备份方案的核心特性：

- 版本控制
- 删除重复数据
- 安全性（别人需要有什么信息或者工具才可以访问或者完全删除你的数据及备份）

该课程2019年关于备份的 [课堂笔记](https://missing-semester-cn.github.io/2019/backups)。

### API（应用程序接口）

- 大多数线上服务提供的 API 具有类似的格式。它们的结构化 URL 通常使用 `api.service.com` 作为根路径。
    - 例如可以发送一个 GET 请求（比如使用 `curl`）到[`https://api.weather.gov/points/42.3604,-71.094`](https://missing-semester-cn.github.io/2020/potpourri/%60https://api.weather.gov/points/42.3604,-71.094%60)来获取天气信息
- 通常这些返回都是 `JSON` 格式，你可以使用 [`jq`](https://stedolan.github.io/jq/) 等工具来选取需要的部分。
- 有些需要认证的 API 通常要求用户在请求中加入某种私密令牌（secret token）来完成认证。大多数 API 都会使用 [OAuth](https://www.oauth.com/)。
- [IFTTT](https://ifttt.com/) 这个网站可以将很多 API 整合在一起，让某 API 发生的特定事件触发在其他 API 上执行的任务。IFTTT 的全称 If This Then That 足以说明它的用法，比如在检测到用户的新推文后，自动发布在其他平台。

### 常见命令行标志参数及模式

*   `--help` 或 `-h` 或者类似的标志参数（flag）来显示简略用法
*   会造成不可撤回操作的工具一般会提供“空运行”（dry run）标志参数和“交互式”（interactive）标志参数
*   会造成破坏性结果的工具一般默认进行非递归的操作，但是支持使用“递归”（recursive）标志函数（通常是 `-r`）
*   `--version` 或者 `-V` 标志参数可以让工具显示它的版本信息
*   `--verbose` 或者 `-v` 标志参数来输出详细的运行信息。多次使用这个标志参数，比如 `-vvv`，可以让工具输出更详细的信息（经常用于调试）
*   `--quiet` 标志参数来抑制除错误提示之外的其他输出。
*   使用 `-` 代替输入或者输出文件名意味着工具将从标准输入（standard input）获取所需内容，或者向标准输出（standard output）输出结果，可以参考之前的笔记：[计算机教育中缺失的一课 - MIT - L4 - 数据整理](https://segmentfault.com/a/1190000039141914)
*   有的时候你可能需要向工具传入一个 _看上去_ 像标志参数的普通参数，这时候你可以使用特殊参数 `--` 让某个程序 _停止处理_ `--` 后面出现的标志参数以及选项（以 `-` 开头的内容）：
    * `rm -- -r` 会让 `rm` 将 `-r` 当作文件名；
    * `ssh machine --for-ssh -- foo --for-foo` 的 `--` 会让 `ssh` 知道 `--for-foo` 不是 `ssh` 的标志参数。

### 窗口管理器

大部分操作系统默认的窗口管理方式都是“拖拽”式的，这被称作堆叠式（floating/stacking）管理器。另外一种管理器是平铺式（tiling）管理器，其使用逻辑和 [tmux](https://github.com/tmux/tmux) 管理终端窗口的方式类似（参考之前的笔记：[计算机教育中缺失的一课 - MIT - L5 - 命令行环境](https://segmentfault.com/a/1190000039160431)），可以让我们在完全不使用鼠标的情况下使用键盘切换、缩放、以及移动窗口。

- Linux
    - [awesome](https://awesomewm.org/)
    - [i3](https://i3wm.org/)
- macOS
    - [yabai](https://github.com/koekeishiya/yabai)
    - [Divvy](https://mizage.com/divvy/)
- Windows
    - [FancyZones](https://docs.microsoft.com/en-us/windows/powertoys/fancyzones)

### VPN

关于这一部分，课程的 Lecture Note 写得已经十分简洁，直接摘录下来。

> VPN 现在非常火，但我们不清楚这是不是因为[一些好的理由](https://gist.github.com/joepie91/5a9909939e6ce7d09e29)。你应该了解 VPN 能提供的功能和它的限制。使用了 VPN 的你对于互联网而言，**最好的情况**下也就是换了一个网络供应商（ISP）。所有你发出的流量看上去来源于 VPN 供应商的网络而不是你的“真实”地址，而你实际接入的网络只能看到加密的流量。
>
> 虽然这听上去非常诱人，但是你应该知道使用 VPN 只是把原本对网络供应商的信任放在了 VPN 供应商那里——网络供应商 _能看到的_ ，VPN 供应商 _也都能看到_ 。如果相比网络供应商你更信任 VPN 供应商，那当然很好。反之，则连接VPN的价值不明确。机场的不加密公共热点确实不可以信任，但是在家庭网络环境里，这个差异就没有那么明显。
>
> 你也应该了解现在大部分包含用户敏感信息的流量已经被 HTTPS 或者 TLS 加密。这种情况下你所处的网络环境是否“安全”不太重要：供应商只能看到你和哪些服务器在交谈，却不能看到你们交谈的内容。
>
> 这一切的大前提都是“最好的情况”。曾经发生过 VPN 提供商错误使用弱加密或者直接禁用加密的先例。另外，有些恶意的或者带有投机心态的供应商会记录和你有关的所有流量，并很可能会将这些信息卖给第三方。找错一家 VPN 经常比一开始就不用 VPN 更危险。
>
> MIT 向有访问校内资源需求的成员开放自己运营的 [VPN](https://ist.mit.edu/vpn)。如果你也想自己配置一个 VPN，可以了解一下 [WireGuard](https://www.wireguard.com/) 以及 [Algo](https://github.com/trailofbits/algo)。

### Markdown

[Markdown](https://commonmark.org/help/) 是一个轻量化的标记语言（markup language），也致力于将人们编写纯文本时的一些习惯标准化。

### Hammerspoon (macOS 桌面自动化)

[Hammerspoon](https://www.hammerspoon.org/) 是面向 macOS 的一个桌面自动化框架。它允许用户编写和操作系统功能挂钩的 Lua 脚本，从而与键盘、鼠标、窗口、文件系统等交互。

*   [Getting Started with Hammerspoon](https://www.hammerspoon.org/go/)：Hammerspoon 官方教程
*   [Sample configurations](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations)：Hammerspoon 官方示例配置
*   [Anish’s Hammerspoon config](https://github.com/anishathalye/dotfiles-local/tree/mac/hammerspoon)：讲师 Anish 的 Hammerspoon 配置

### 开机引导以及 Live USB

在计算机启动时，[BIOS](https://en.wikipedia.org/wiki/BIOS) 或者 [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) 会在加载操作系统之前对硬件系统进行初始化，这被称为引导（booting）。在 BIOS 菜单中你可以对硬件相关的设置进行更改，也可以在引导菜单中选择从硬盘以外的其他设备加载操作系统——比如 Live USB。

[Live USB](https://en.wikipedia.org/wiki/Live_USB) 是包含了完整操作系统的闪存盘。Live USB 的用途非常广泛，包括：

*   作为安装操作系统的启动盘；
*   在不将操作系统安装到硬盘的情况下，直接运行 Live USB 上的操作系统；
*   对硬盘上的相同操作系统进行修复；
*   恢复硬盘上的数据。

Live USB 通过在闪存盘上 _写入_ 操作系统的镜像制作，写入不是单纯的往闪存盘上复制 `.iso` 文件。可以使用 [UNetbootin](https://unetbootin.github.io/)、[Rufus](https://github.com/pbatard/rufus)、[UltraISO](https://www.ultraiso.com/) 等 Live USB 写入工具制作。

### 虚拟技术

[虚拟机](https://en.wikipedia.org/wiki/Virtual_machine)（Virtual Machine）以及如[容器化](https://en.wikipedia.org/wiki/OS-level_virtualization)（containerization）(亦称操作系统层虚拟化）等工具可以帮助你模拟一个包括操作系统的完整计算机系统。

- [Vagrant](https://www.vagrantup.com/)：一个构建和配置虚拟开发环境的工具。它支持用户在配置文件中写入比如操作系统、系统服务、需要安装的软件包等描述，然后使用 `vagrant up` 命令在各种环境（VirtualBox，KVM，Hyper-V等）中启动一个虚拟机。
- [Docker](https://www.docker.com/)：一个使用容器化概念的与 Vagrant 类似的工具，在后端服务的部署中应用广泛。
- [VPS](https://en.wikipedia.org/wiki/Virtual_private_server)（虚拟专用服务器）:将一台[服务器](https://zh.wikipedia.org/wiki/%E6%9C%8D%E5%8A%A1%E5%99%A8 "服务器")分割成多个虚拟专用服务器的服务
    - 实现VPS的技术分为容器技术和虚拟机技术
    - 国外的大型云主机服务商有 [Amazon AWS](https://aws.amazon.com/)，[Google Cloud](https://cloud.google.com/)，[DigitalOcean](https://www.digitalocean.com/)
    - [CSAIL OpenStack instance](https://tig.csail.mit.edu/shared-computing/open-stack/)：供 MIT CSAIL 的成员免费申请使用的虚拟机

### 交互式记事本编程

> [交互式记事本](https://en.wikipedia.org/wiki/Notebook_interface)可以帮助开发者进行与运行结果交互等探索性的编程。现在最受欢迎的交互式记事本环境大概是 [Jupyter](https://jupyter.org/)。它的名字来源于所支持的三种核心语言：Julia、Python、R。[Wolfram Mathematica](https://www.wolfram.com/mathematica/) 是另外一个常用于科学计算的优秀环境。
