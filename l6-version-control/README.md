# 计算机教育中缺失的一课 - MIT - L6 - 版本控制 (Git)

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

### Git 的数据模型

Git 通过一系列快照来管理其历史记录。快照则是被追踪的最顶层的树。可以认为 `git commit` 会创建一个快照。

```
type object = blob | tree | commit

// 文件就是一组数据
type blob = array<byte>

// 一个包含文件和目录的目录
type tree = map<string, tree | file>

// 每个提交都包含一个父辈，元数据和顶层树
type commit = struct {
    parent: array<commit>
    author: string
    message: string
    snapshot: tree
}

// 还有引用（reference），比如
// HEAD, master, origin/HEAD, origin/master
// 都是引用
// 引用是指向提交的指针，与对象不同的是，它是可变的（引用可以被更新，指向新的提交）
```

实际上，Git 在储存数据时，所有的对象都会基于它们的SHA-1 hash进行寻址。Blobs、trees 和 commits 都一样，它们都是对象。当它们引用其他对象时，它们并没有真正的在硬盘上保存这些对象，而是仅仅保存了它们的哈希值作为引用。例如，上面为代码中的 `parent: array<commit>` 其实际上不是一个 commit 数组，而是一个哈希值数组，这些哈希值指向真正的对象，也就是一些 commits。

```
objects = map<string, object>

def store(object):
    id = sha1(object)
    objects[id] = object

def load(id):
    return objects[id]
```

例如，`git cat-file -p 698281b`（ 698281b 是某个tree，也就是某个文件夹的哈希值的一部分前缀）的结果是：

```
100644 blob 4448adbf7ecd394f42ae135bbeed9676e894af85    baz.txt
040000 tree c68d233a33c5c06e0340e4c224f0afca87c8ce87    foo 
```

而 `git cat-file -p 4448adb`（ 4448adb 是baz.txt 的哈希值的一部分前缀）的结果即为 baz.txte 的内容。

### Git 的命令行接口

**历史**:

*   `git log --all --graph --decorate --oneline`：可视化历史记录（有向无环图），zsh 的 git 插件定义了很多别名，比如该命令的别名是 gloga，去掉 --all 的别名是 glog
*   `git diff <filename>`：显示与上一次提交之间的差异
*   `git diff <old-revision> [<new-revision>] <filename>`：显示某个文件两个版本之间的差异，new-revision 默认是 HEAD
*   `git diff --cached <filename>`：不加 cached 标识的 diff 的意思是显示尚未暂存的改动，加了之后是查看已暂存的将要添加到下次提交里的内容

**修改、撤销和合并**：

*   `git add -p`：交互式暂存，例如交互过程中可以按 s 键进行 split，对文件中各个地方的改动分别选择暂存与否
*   `git checkout -- <file>`：丢弃（尚未暂存的）修改
*   `git reset [<tree-ish>] <file>`：取消暂存，把文件从暂存区放回工作区，<tree-ish> 默认为 HEAD
*   `git reset [--soft | --mixed [-N] | --hard | --merge | --keep] [<commit>]`：（见下图）撤销 commit，把 commit 放回暂存区（soft），或放回工作区（mixed），或丢弃（hard），本质是对 HEAD 的移动
*   `git reset [--soft | --mixed [-N] | --hard] HEAD^`，上一条的特例，比较常用
*   `git rebase <branch>`：在一个过时的分支上面开发的时候，执行 `rebase` 以此同步 `master` 分支最新变动
*   `git rebase -i HEAD~n`：交互式变基，可用于修改 commit 信息，合并 commit 等等
*   `git mergetool`：使用工具来处理合并冲突
*   `git stash`：把工作区暂存起来，允许你切换到其他分支，博主有时候在错误的分支上进行了修改，会用这个命令把修改暂存起来，然后换到正确的工作分支后使用 `git stash pop`

[![y1zWCV.png](https://s3.ax1x.com/2021/02/04/y1zWCV.png)](https://imgchr.com/i/y1zWCV)

**远端操作**：

*   `git clone --shallow`：克隆仓库，但是不包括版本历史信息
*   `git remote add <name> <url>`：添加一个远端
*   `git push <remote> <local branch>:<remote branch>`：将对象传送至远端并更新远端引用
*   `git branch --set-upstream-to=<remote>/<remote branch>`：创建本地和远端分支的关联关系

**其他**：

*   `.gitignore`: [指定](https://git-scm.com/docs/gitignore) 故意不追踪的文件
*   `git blame`：查看最后修改某行的人
*   `git bisect`：通过二分查找搜索历史记录
*   `git init --bare`：几乎用不到，在课程视频中，讲师在某一个空文件夹中使用该命令，将该文件夹作为 remote，然后将一个已有的仓库 push 到该文件夹
*   `git config --global core.excludesfile ~/.gitignore_global`：在 `~/.gitignore_global` 中创建全局忽略规则
*   [Removing sensitive data from a repository](https://docs.github.com/en/github/authenticating-to-github/removing-sensitive-data-from-a-repository)

### 杂项

*   **图形用户界面**: Git 的 [图形用户界面客户端](https://git-scm.com/downloads/guis) 有很多，但是我们自己并不使用这些图形用户界面的客户端，我们选择使用命令行接口
*   **Shell 集成**: 将 Git 状态集成到您的 shell 中会非常方便。([zsh](https://github.com/olivierverdier/zsh-git-prompt),[bash](https://github.com/magicmonty/bash-git-prompt))。[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)这样的框架中一般以及集成了这一功能
*   **编辑器集成**: 和上面一条类似，将 Git 集成到编辑器中好处多多。[fugitive.vim](https://github.com/tpope/vim-fugitive) 是 Vim 中集成 GIt 的常用插件
*   **工作流**:我们已经讲解了数据模型与一些基础命令，但还没讨论到进行大型项目时的一些惯例 ( 有[很多](https://nvie.com/posts/a-successful-git-branching-model/) [不同的](https://www.endoflineblog.com/gitflow-considered-harmful) [处理方法](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow))
*   **GitHub**: Git 并不等同于 GitHub。 在 GitHub 中您需要使用一个被称作[拉取请求（pull request）](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)的方法来向其他项目贡献代码
*   **Other Git 提供商**: GitHub 并不是唯一的。还有像[GitLab](https://about.gitlab.com/) 和 [BitBucket](https://bitbucket.org/)这样的平台。

### 资源

*   [Pro Git](https://git-scm.com/book/en/v2)，**强烈推荐**！学习前五章的内容可以教会您流畅使用 Git 的绝大多数技巧，因为您已经理解了 Git 的数据模型，后面的章节提供了很多有趣的高级主题（[Pro Git 中文版](https://git-scm.com/book/zh/v2)）
*   如何编写 [良好的提交信息](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
*   Git 是一个 [高度可定制的](https://git-scm.com/docs/git-config) 工具
*   [Oh Shit, Git!?!](https://ohshitgit.com/) ，简短的介绍了如何从 Git 错误中恢复；
*   [Git for Computer Scientists](https://eagain.net/articles/git-for-computer-scientists/) ，简短的介绍了 Git 的数据模型
*   [Git from the Bottom Up](https://jwiegley.github.io/git-from-the-bottom-up/) 详细的介绍了 Git 的实现细节，而不仅仅局限于数据模型
*   [How to explain git in simple words](https://smusamashah.github.io/blog/2017/10/14/explain-git-in-simple-words)
*   [Learn Git Branching](https://learngitbranching.js.org/) 通过基于浏览器的游戏来学习 Git

## 课后习题

### 习题 2

是谁最后修改来 `README.md`文件？

```
$ git log --all -n1 --pretty=format:"%an" README.md
```

最后一次修改 `_config.yml` 文件中 `collections:` 行时的提交信息是什么？

```
$ git blame _config.yml | grep "collections:" | head -n1 | awk '{print $1}' | sed -E "s/\^//" | xargs git show

# OR

$ git blame _config.yml | grep "collections:" | head -n1 | awk '{print $1}' | sed -E "s/\^//" | xargs git log -n1 --pretty=format:"%s%n%n%b"
```
