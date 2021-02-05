# 计算机教育中缺失的一课 - MIT - L5 - 命令行环境

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### 任务控制

shell 会使用 UNIX 提供的信号机制执行进程间通信。当一个进程接收到信号时，它会停止执行、处理该信号并基于信号传递的信息来改变其执行。就这一点而言，信号是一种软件中断。

#### 结束进程

*   See `man signal` for reference
*   `kill`: sends signals to a process; default is TERM
*   `SIGINT`: `^C`; interrupt program; terminate process
*   `SIGQUIT`: `^\`; quit program
*   `SIGKILL`: terminate process; kill program; cannot be captured by process and will always terminate immediately
    *   Can result in orphaned child processes
*   `SIGSTOP`: pause a process
    *   `SIGTSTP`: `^Z`; terminal stop
*   `SIGHUP`: terminal line hangup; terminate process; will be sent when terminal is closed    
    *   Use `nohup` to avoid
*   `SIGTERM`: signal requesting graceful process exit
    *   To send this signal: `kill -TERM <pid>`


下面这个 Python 程序向您展示了捕获信号 `SIGINT` 并忽略它的基本操作，它并不会让程序停止。为了停止这个程序，我们需要使用 `SIGQUIT` 信号。

```python
#!/usr/bin/env python import signal, time

def handler(signum, time):
    print("nI got a SIGINT, but I am not stopping")

signal.signal(signal.SIGINT, handler)
i = 0
while True:
    time.sleep(.1)
    print("r{}".format(i), end="")
    i += 1 
```

```
$ python sigint.py
24^C
I got a SIGINT, but I am not stopping
26^C
I got a SIGINT, but I am not stopping
30^\[1]    39913 quit       python sigint.py
```

#### 暂停和后台执行进程

使用 [`fg`](http://man7.org/linux/man-pages/man1/fg.1p.html) 或 [`bg`](http://man7.org/linux/man-pages/man1/bg.1p.html) 命令恢复暂停的工作。它们分别表示在前台继续或在后台继续。

[`jobs`](http://man7.org/linux/man-pages/man1/jobs.1p.html) 命令会列出当前终端会话中尚未完成的全部任务。可以使用 pid 引用这些任务（也可以用 [`pgrep`](http://man7.org/linux/man-pages/man1/pgrep.1.html) 找出 pid）。也可以使用百分号 + 任务编号（`jobs` 会打印任务编号）来选取该任务。如果要选择最近的一个任务，可以使用 `$!` 这一特殊参数。

命令中的 `&` 后缀可以让命令在直接在后台运行，不过它此时还是会使用 shell 的标准输出。

使用 `Ctrl-Z` 放入后台的进程仍然是终端进程的子进程，一旦关闭终端（会发送另外一个信号 `SIGHUP`），这些后台的进程也会终止。为了防止这种情况发生，可以使用 [`nohup`](http://man7.org/linux/man-pages/man1/nohup.1.html) (一个用来忽略 `SIGHUP` 的封装) 来运行程序。针对已经运行的程序，可以使用 `disown` 。

```
$ sleep 1000
^Z
[1]  + 18653 suspended  sleep 1000

$ nohup sleep 2000 &
[2] 18745
appending output to nohup.out

$ jobs
[1]  + suspended  sleep 1000
[2]  - running    nohup sleep 2000

$ bg %1
[1]  - 18653 continued  sleep 1000

$ jobs
[1]  - running    sleep 1000
[2]  + running    nohup sleep 2000

$ kill -STOP %1
[1]  + 18653 suspended (signal)  sleep 1000

$ jobs
[1]  + suspended (signal)  sleep 1000
[2]  - running    nohup sleep 2000

$ kill -SIGHUP %1
[1]  + 18653 hangup     sleep 1000

$ jobs
[2]  + running    nohup sleep 2000

$ kill -SIGHUP %2

$ jobs
[2]  + running    nohup sleep 2000

$ kill %2
[2]  + 18745 terminated  nohup sleep 2000

$ jobs 

```

### 终端多路复用

终端多路复用使我们可以分离当前终端会话并在将来重新连接。这让您操作远端设备时的工作流大大改善，避免了 `nohup` 和其他类似技巧的使用。

现在最流行的终端多路器是 [`tmux`](http://man7.org/linux/man-pages/man1/tmux.1.html)。

*   **会话** - 每个会话都是一个独立的工作区，其中包含一个或多个窗口
    *   `tmux` 开始一个新的会话
    *   `tmux new -s NAME` 以指定名称开始一个新的会话
    *   `tmux ls` 列出当前所有会话
    *   在 `tmux` 中输入 `<C-b> d`（detach），将当前会话分离
    *   `tmux a`（attach）重新连接最后一个会话。您也可以通过 `-t` 来指定具体的会话
*   **窗口** - 相当于编辑器或是浏览器中的标签页，从视觉上将一个会话分割为多个部分
    *   `<C-b> c` 创建一个新的窗口，使用 `<C-d>`关闭
    *   `<C-b> N` 跳转到第 _N_ 个窗口，注意每个窗口都是有编号的
    *   `<C-b> p`（previous）切换到前一个窗口
    *   `<C-b> n`（next）切换到下一个窗口
    *   `<C-b> ,` 重命名当前窗口
    *   `<C-b> w` 列出当前所有窗口
*   **面板** - 像 vim 中的分屏一样，面板使我们可以在一个屏幕里显示多个 shell
    *   `<C-b> "` 水平分割
    *   `<C-b> %` 垂直分割
    *   `<C-b> <方向>` 切换到指定方向的面板，<方向> 指的是键盘上的方向键
    *   `<C-b> z`（zoom）切换当前面板的缩放
    *   `<C-b> [` 开始往回卷动屏幕。您可以按下空格键来开始选择，回车键复制选中的部分
    *   `<C-b> <空格>` 在不同的面板排布间切换

扩展阅读： [这里](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) 是一份 `tmux` 快速入门教程， [而这一篇](http://linuxcommand.org/lc3_adv_termmux.php) 文章则更加详细，它包含了 `screen` 命令。您也许想要掌握 [`screen`](http://man7.org/linux/man-pages/man1/screen.1.html) 命令，因为在大多数 UNIX 系统中都默认安装有该程序。

### 别名

```bash
# colorls
source $(dirname $(gem which colorls))/tab_complete.sh
alias ls=colorls
alias l="ls -lh"
alias ll="ls -lAh"
alias la="ls -lah"

alias hz="history | fzf"
alias mv="mv -i"
alias cp="cp -i"
alias mkdir="mkdir -p"

# To ignore an alias run it prepended with 
\ls
# Or disable an alias altogether with unalias
unalias la

# To get an alias definition just call it with alias
alias l
# Will print l='ls -lh'
```

### 配置文件（Dotfiles）

*   [shell startup scripts](https://blog.flowblok.id.au/2013-02/shell-startup-scripts.html)
*   [guide to dotfiles on github](https://dotfiles.github.io/tutorials/)
*   [example popular dotfiles](https://github.com/mathiasbynens/dotfiles)

管理配置文件的一个方法是，把它们集中放在一个文件夹中，例如 `~/.dotfiles/`，并使用版本控制系统进行管理，然后通过脚本将其 **符号链接** 到需要的地方。这么做有如下好处：

*   **安装简单**: 如果您登录了一台新的设备，在这台设备上应用您的配置只需要几分钟的时间；
*   **可以执行**: 您的工具在任何地方都以相同的配置工作
*   **同步**: 在一处更新配置文件，可以同步到其他所有地方
*   **变更追踪**: 您可能要在整个程序员生涯中持续维护这些配置文件，而对于长期项目而言，版本历史是非常重要的

一些技巧：

```bash
if [[ "$(uname)" == "Linux" ]]; then {do_something}; fi

# 使用和 shell 相关的配置时先检查当前 shell 类型
if [[ "$SHELL" == "zsh" ]]; then {do_something}; fi

# 您也可以针对特定的设备进行配置
if [[ "$(hostname)" == "myServer" ]]; then {do_something}; fi

# Test if ~/.aliases exists and source it
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
```

### 远端设备

#### SSH (Secure Shell)

```bash
# 连接设备
ssh foo@bar.mit.edu 
ssh foobar@192.168.1.42
# 如果存在配置文件，可以简写
ssh bar

# 执行命令
# 在本地查询远端 ls 的输出
ssh foobar@server ls | grep PATTERN
# 在远端对本地 ls 输出的结果进行查询
ls | ssh foobar@server grep PATTERN
```

#### SSH 密钥

基于密钥的验证机制使用了密码学中的公钥，我们只需要向服务器证明客户端持有对应的私钥，而不需要公开其私钥。这样您就可以避免每次登录都输入密码的麻烦了秘密就可以登录。

```bash
ssh-keygen -t ed25519 -C "_your_email@example.com_"
# If you are using a legacy system that doesn't support the Ed25519 algorithm, use:
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

生成的 **id_rsa** 和 **id_rsa.pub** 两个文件（或者 **id_ed25519** 和 **id_ed25519.pub**），分别为的**私钥**和**公钥**。私钥等效于你的密码，所以一定要好好保存它。要检查您是否持有某个密钥对的密码并验证它，您可以运行 `ssh-keygen -y -f /path/to/key`。

`ssh` 会查询 `.ssh/authorized_keys` 来确认那些用户可以被允许登录。您可以通过下面的命令将一个公钥拷贝到这里：

```bash
cat .ssh/id_ed25519.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys' 
```

如果支持 `ssh-copy-id` 的话，可以使用下面这种更简单的解决方案：

```bash
ssh-copy-id -i .ssh/id_ed25519.pub foobar@remote
```

#### 通过 SSH 复制文件

使用 ssh 复制文件有很多方法：

*   `ssh+tee`, 最简单的方法是执行 `ssh` 命令，然后通过这样的方法利用标准输入实现 `cat localfile | ssh remote_server tee serverfile`。回忆一下，[`tee`](http://man7.org/linux/man-pages/man1/tee.1.html) 命令会将标准输出写入到一个文件；
*   [`scp`](http://man7.org/linux/man-pages/man1/scp.1.html) ：当需要拷贝大量的文件或目录时，使用`scp` 命令则更加方便，因为它可以方便的遍历相关路径。语法如下：`scp path/to/local_file remote_host:path/to/remote_file`；
*   [`rsync`](http://man7.org/linux/man-pages/man1/rsync.1.html) 对 `scp` 进行来改进，它可以检测本地和远端的文件以防止重复拷贝。它还可以提供一些诸如符号连接、权限管理等精心打磨的功能。甚至还可以基于 `--partial`标记实现断点续传。`rsync` 的语法和`scp`类似。

#### 端口转发

**本地端口转发** ![Local Port Forwarding](https://i.stack.imgur.com/a28N8.png%C2%A0 "本地端口转发")

**远程端口转发** ![Remote Port Forwarding](https://i.stack.imgur.com/4iK3b.png%C2%A0 "远程端口转发")

常见的情景是使用本地端口转发，即远端设备上的服务监听一个端口，而您希望在本地设备上的一个端口建立连接并转发到远程端口上。例如，我们在远端服务器上运行 Jupyter notebook 并监听 `8888` 端口。 然后，建立从本地端口 `9999` 的转发，使用 `ssh -L 9999:localhost:8888 foobar@remote_server` 。这样只需要访问本地的 `localhost:9999` 即可。

#### SSH 配置

使用 `~/.ssh/config` 文件来创建别名，类似 `scp`、`rsync`和`mosh`的这些命令都可以读取这个配置并将设置转换为对应的命令行选项。

```
Host vm
    User foobar
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 9999 localhost:8888

# 在配置文件中也可以使用通配符
Host *.mit.edu
    User foobaz 
```

服务器侧的配置通常放在 `/etc/ssh/sshd_config`。您可以在这里配置免密认证、修改 shh 端口、开启 X11 转发等等。也可以为每个用户单独指定配置。

#### 杂项

连接远程服务器的一个常见痛点是遇到由关机、休眠或网络环境变化导致的掉线。如果连接的延迟很高也很让人讨厌。[Mosh](https://mosh.org/)（即 mobile shell ）对 ssh 进行了改进，它允许连接漫游、间歇连接及智能本地回显。

有时将一个远端文件夹挂载到本地会比较方便， [sshfs](https://github.com/libfuse/sshfs) 可以将远端服务器上的一个文件夹挂载到本地，然后您就可以使用本地的编辑器了。

### Shell & 框架

常见的 Shell：

- [bash](http://www.gnu.org/software/bash/)
- [zsh](https://www.zsh.org/)
- [fish](https://fishshell.com/)

常见的 Shell 框架：

- [oh-my-zsh](https://ohmyz.sh/)
- [prezto](https://github.com/sorin-ionescu/prezto)

### 终端模拟器

一些经典的模拟器：

- [xterm](https://invisible-island.net/xterm/)
- [GNOME Terminal](https://wiki.gnome.org/Apps/Terminal)
- [Konsole](https://konsole.kde.org/)
- [Xfce Terminal](https://docs.xfce.org/apps/terminal/start)
- [urxvt](http://software.schmorp.de/pkg/rxvt-unicode.html)
- [Terminator](https://gnometerminator.blogspot.com/)

一些新兴的模拟器（通常具有更好的性能，例如下面两个具有 GPU 加速）：

- [Alacritty](https://github.com/jwilm/alacritty)
- [kitty](https://sw.kovidgoyal.net/kitty/)

## 课后练习

### 任务控制

#### 习题 1

```
$ sleep 1000
^Z
[1]  + 689 suspended  sleep 1000

$ sleep 2000                                                                   
^Z
[2]  + 697 suspended  sleep 2000

$ jobs
[1]  - suspended  sleep 1000
[2]  + suspended  sleep 2000

$ bg %1
[1]  - 689 continued  sleep 1000

$ jobs
[1]  - running    sleep 1000
[2]  + suspended  sleep 2000

$ pgrep -af "sleep 1"
689 sleep 1000

$ pkill -f "sleep 1"
[1]  - 689 terminated  sleep 1000

$ jobs
[2]  + suspended  sleep 2000

$ pkill -f "sleep 2"

$ jobs
[2]  + suspended  sleep 2000

$ pkill -9 -f "sleep 2"
[2]  + 697 killed     sleep 2000

$ jobs

```

参见 `man kill`，默认发送的信号是 TERM。`-9` 等价于 `-SIGKILL` 或者 `-KILL`

#### 习题 2

```
$ sleep 10 &
[1] 1121

$ pgrep sleep | wait ; ls
[1]  + 1121 done       sleep 10

   Nothing to show here
```

```bash
$ pidwait() {
    wait $1
    echo "done"
    eval $2
}

$ sleep 10 &
[1] 1420

$ pidwait 1420 "ls"
[1]  + 1420 done       sleep 10
done

   Nothing to show here
```
