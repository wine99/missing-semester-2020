# 计算机教育中缺失的一课 - MIT - L1 - 课程概览与 shell

> https://missing.csail.mit.edu/
> https://missing-semester-cn.github.io/
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### 关于重定向和 cat

``` bash
$ echo hello > hello.txt
$ cat hello.txt
hello
$ cat < hello.txt
hello
$ cat < hello.txt > hello2.txt
$ cat hello2.txt
hello
```

本以为 `cat < hello.txt` 会报错 `cat: hello: No such file or directory`。猜想正确工作的原因是“参数”和“输入”的区别（未经验证或查找资料）：cat 程序将输入打印在屏幕上，`cat hello.txt` 中的 `hello.txt` 是参数，将该文件的内容作为输入；而 `cat < hello.txt` 是输入重定向，意思也是将文件中的内容作为程序的输入，而不是将文件的内容作为参数，因此二者效果相同。

### tee 的小用处

```bash
$ cd /sys/class/backlight/thinkpad_screen
$ sudo echo 3 > brightness
An error occurred while redirecting file 'brightness'
open: Permission denied
```

出乎意料的是，我们还是得到了一个错误信息。毕竟，我们已经使用了 `sudo` 命令！关于 shell，有件事我们必须要知道。`|`、`>`、和 `<` 是通过 shell 执行的，而不是被各个程序单独执行。 `echo` 等程序并不知道 `|` 的存在，它们只知道从自己的输入输出流中进行读写。 对于上面这种情况， _shell_ (权限为您的当前用户) 在设置 `sudo echo` 前尝试打开 brightness 文件并写入，但是系统拒绝了 shell 的操作因为此时 shell 不是根用户。

明白这一点后，我们可以这样操作：

```bash
$ echo 3 | sudo tee brightness 
```

因为打开 `/sys` 文件的是 `tee` 这个程序，并且该程序以 `root` 权限在运行，因此操作可以进行。

## 课后练习

[![szNEBq.png](https://s3.ax1x.com/2021/01/27/szNEBq.png)](https://imgchr.com/i/szNEBq)

[![szNAun.png](https://s3.ax1x.com/2021/01/27/szNAun.png)](https://imgchr.com/i/szNAun)

