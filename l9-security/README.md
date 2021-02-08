# 计算机教育中缺失的一课 - MIT - L9 - 安全和密码学

> https://missing.csail.mit.edu/
>
> https://missing-semester-cn.github.io/
>
> https://www.bilibili.com/video/BV14E411J7n2

> 思否主页：https://segmentfault.com/u/wine99

## 笔记

- 2019 年本讲的内容为与 2020 年的普通，标题为 [安全与隐私](https://missing-semester-cn.github.io/2019/security/)，更注重于计算机用户可以如何增强隐私保护和安全
- 相关课程：计算机系统安全 ([6.858](https://css.csail.mit.edu/6.858/))
- 相关课程：密码学 ([6.857](https://courses.csail.mit.edu/6.857/)以及6.875)
- [不要试图创造或者修改加密算法](https://www.schneier.com/blog/archives/2015/05/amateurs_produc.html)
- [Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html): 解答了在一些应用环境下“应该使用什么加密？”的问题

### 熵

[熵](https://en.wikipedia.org/wiki/Entropy_(information_theory))(Entropy) 度量了不确定性并可以用来决定密码的强度。

熵的单位是 _比特_ 。对于一个均匀分布的随机离散变量，熵等于 `log_2(所有可能的个数，即 n)`。 扔一次硬币的熵是1比特。掷一次（六面）骰子的熵大约为2.58比特。

使用多少比特的熵取决于应用的威胁模型。大约40比特的熵足以对抗在线穷举攻击（受限于网络速度和应用认证机制）。而对于离线穷举攻击（主要受限于计算速度），一般需要更强的密码 (比如80比特或更多)。

### 散列函数

[密码散列函数](https://en.wikipedia.org/wiki/Cryptographic_hash_function) (Cryptographic hash function) 可以将任意大小的数据映射为一个固定大小的输出。散列函数具有如下特性：

*   确定性（deterministic）：对于不变的输入永远有相同的输出。
*   不可逆性（non-invertible）：对于`hash(m) = h`，难以通过已知的输出`h`来计算出原始输入`m`。
*   目标碰撞抵抗性/弱无碰撞（target collision resistant）：对于一个给定输入`m_1`，难以找到`m_2 != m_1`且`hash(m_1) = hash(m_2)`。
*   碰撞抵抗性/强无碰撞（collision resistant）：难以找到一组满足`hash(m_1) = hash(m_2)`的输入`m_1, m_2`（该性质严格强于目标碰撞抵抗性）。


[SHA-1](https://en.wikipedia.org/wiki/SHA-1)是Git中使用的一种散列函数，Linux 下有 `sha1sum` 工具。

虽然SHA-1还可以用于特定用途，但它已经[不再被认为](https://shattered.io/)是一个强密码散列函数。参照[密码散列函数的生命周期](https://valerieaurora.org/hash.html)这个表格了解一些散列函数是何时被发现弱点及破解的。

#### 密码散列函数的应用

*   Git中的内容寻址存储(Content addressed storage)：[散列函数](https://en.wikipedia.org/wiki/Hash_function)是一个宽泛的概念（存在非密码学的散列函数），那么Git为什么要特意使用密码散列函数？
    *   普通的散列函数没有无碰撞性，Git 使用密码散列函数，来确保分布式版本控制系统中的两个不同数据不会有相同的摘要信息（例如两个内容不同的 commit 不应该有相同的哈希值）。
*   文件的信息摘要(Message digest)：例如下载文件时，对比下载下来的文件的哈希值和官方公布的哈希值是否相同来判断文件是否损坏或者被篡改。
*   [承诺机制](https://en.wikipedia.org/wiki/Commitment_scheme)(Commitment scheme)：假设你要猜我在脑海中想的一个随机数字，我先告诉你该数字的哈希值，然后你猜数字，我再告诉你正确答案，看你是否猜对，这时你可以通过先前公布的哈希值来确认我没有作弊。

### 密钥生成函数

[密钥生成函数](https://en.wikipedia.org/wiki/Key_derivation_function) (Key Derivation Functions)与密码散列函数类似，用以产生一个固定长度的密钥。但是为了对抗穷举法攻击，密钥生成函数通常较慢。

#### 密码生成函数的应用

- 将其结果作为其他加密算法的密钥，例如对称加密算法
- 数据库中保存的用户密码为密文
    - 针对每个用户随机生成一个[盐](https://en.wikipedia.org/wiki/Salt_(cryptography))，并存储盐，以及密钥生成函数对连接了盐的明文密码生成的哈希值 `KDF(password + salt)`。
    - 在验证登录请求时，使用输入的密码连接存储的盐重新计算哈希值`KDF(input + salt)`，并与存储的哈希值对比。
    - **盐**（Salt），在[密码学](https://zh.wikipedia.org/wiki/%E5%AF%86%E7%A0%81%E5%AD%A6 "密码学")中，是指在[散列](https://zh.wikipedia.org/wiki/%E6%95%A3%E5%88%97 "散列")之前将散列内容（例如：密码）的任意固定位置插入特定的字符串。这个在散列中加入字符串的方式称为“加盐”。
    - 在大部分情况，盐是不需要保密的。
    - 通常情况下，当字段经过散列处理，会生成一段散列值，而散列后的值一般是无法通过特定算法得到原始字段的。但是某些情况，比如一个大型的[彩虹表](https://zh.wikipedia.org/wiki/%E5%BD%A9%E8%99%B9%E8%A1%A8 "彩虹表")，通过在表中搜索该SHA-1值，很有可能在极短的时间内找到该散列值对应的真实字段内容。
    - 加盐可以避免用户的短密码被彩虹表破解，也可以保护在不同网站使用相同密码的用户。

### 对称加密

```
keygen() -> key  （这是一个随机方法，例如使用 KDF(passphrase)）

encrypt(plaintext: array<byte>, key) -> array<byte>  (输出密文)
decrypt(ciphertext: array<byte>, key) -> array<byte>  (输出明文)
```

加密方法`encrypt()`输出的密文`ciphertext`很难在不知道`key`的情况下得出明文`plaintext`。

[AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) 是现在常用的一种对称加密系统。在 Linux 下可以使用 openssl 工具：

```bash
openssl aes-256-cbc -salt -in {源文件名} -out {加密文件名}
openssl aes-256-cbc -d -in {加密文件名} -out {解密文件名}
```

### 非对称加密

非对称加密的“非对称”代表在其环境中，使用两个具有不同功能的密钥： 一个是私钥(private key)，不向外公布；另一个是公钥(public key)，公布公钥不像公布对称加密的共享密钥那样可能影响加密体系的安全性。

```
keygen() -> (public key, private key)  (这是一个随机方法)

encrypt(plaintext: array<byte>, public key) -> array<byte>  (输出密文)
decrypt(ciphertext: array<byte>, private key) -> array<byte>  (输出明文)

sign(message: array<byte>, private key) -> array<byte>  (生成签名)
verify(message: array<byte>, signature: array<byte>, public key) -> bool  (验证签名是否是由和这个公钥相关的私钥生成的)
```

非对称的加密/解密方法和对称的加密/解密方法有类似的特征。
信息在非对称加密中使用 _公钥_ 加密， 且输出的密文很难在不知道 _私钥_ 的情况下得出明文。

在不知道 _私钥_ 的情况下，不管需要签名的信息为何，很难计算出一个可以使 `verify(message, signature, public key)` 返回为真的签名。

#### 非对称加密的应用

*   [PGP电子邮件加密](https://en.wikipedia.org/wiki/Pretty_Good_Privacy)：用户可以将所使用的公钥在线发布，比如：PGP密钥服务器或 [Keybase](https://keybase.io/)。任何人都可以向他们发送加密的电子邮件。
*   聊天加密：像 [Signal](https://signal.org/)、[Telegram](https://telegram.org/) 和 [Keybase](https://keybase.io/) 使用非对称密钥来建立私密聊天。
*   软件签名：Git 支持用户对提交(commit)和标签(tag)进行GPG签名。任何人都可以使用软件开发者公布的签名公钥验证下载的已签名软件。

#### 密钥分发

非对称加密面对的主要挑战是，如何分发公钥并对应现实世界中存在的人或组织。

- Signal的信任模型：信任用户第一次使用时给出的身份(trust on first use)，支持线下(out-of-band)面对面交换公钥（Signal里的safety number）。
- PGP使用的是[信任网络](https://en.wikipedia.org/wiki/Web_of_trust)。
- Keybase主要使用[社交网络证明 (social proof)](https://keybase.io/blog/chat-apps-softer-than-tofu)。

### 案例分析

- 密码管理器
    - 如 [KeePassXC](https://keepassxc.org/)。
- [两步验证](https://en.wikipedia.org/wiki/Multi-factor_authentication)(2FA)（多重身份验证 MFA）
    - 要求用户同时使用密码（“你知道的信息”）和一个身份验证器（“你拥有的物品”，比如[YubiKey](https://www.yubico.com/)）来消除密码泄露或者[钓鱼攻击](https://en.wikipedia.org/wiki/Phishing)的威胁。
- 全盘加密
    - 对笔记本电脑的硬盘进行全盘加密是防止因设备丢失而信息泄露的简单且有效方法。
    - Linux的 [cryptsetup + LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)
    - Windows的 [BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/)
    - macOS的 [FileVault](https://support.apple.com/en-us/HT204837)
- 聊天加密
    - 获取联系人的公钥非常关键。为了保证安全性，应使用线下方式验证用户公钥，或者信任用户提供的社交网络证明。
- SSH
    - `ssh-keygen` 命令会生成一个非对称密钥对。公钥最终会被分发，它可以直接明文存储。但是为了防止泄露，私钥必须加密存储。
    - `ssh-keygen` 命令会提示用户输入一个密码，并将它输入 KDF 产生一个密钥。最终，`ssh-keygen` 使用对称加密算法和这个密钥加密私钥。
    - 当服务器已知用户的公钥（存储在`.ssh/authorized_keys`文件中），尝试连接的客户端可以使用非对称签名来证明用户的身份——这便是[挑战应答方式](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication)。 简单来说，服务器选择一个随机数字发送给客户端。客户端使用用户私钥对这个数字信息签名后返回服务器。服务器随后使用保存的用户公钥来验证返回的信息是否由所对应的私钥所签名。这种验证方式可以有效证明试图登录的用户持有所需的私钥。

## 课后练习

### 熵

1. `Entropy = log_2(100000^5) = 83`
2. `Entropy = log_2((26+26+10)^8) = 48`
3. 第一个更强。
4. 分别需要 31.7 万亿年和 692 年。

### 非对称加密

1.  `ssh-keygen -r ed25519 -o -C "your_email"`
    [生成 SSH 公钥](https://git-scm.com/book/zh/v2/服务器上的-Git-生成-SSH-公钥)
    [How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2)
2.  [How To Use GPG to Encrypt and Sign Messages](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
    [GPG入门教程](http://www.ruanyifeng.com/blog/2013/07/gpg.html)
3.  给Anish发送一封加密的电子邮件（[Anish的公钥](https://keybase.io/anish)）。
4.  `git commit -S`命令签名一个Git commit
    `git show --show-signature`命令验证 commit 的签名
    `git tag -s`命令签名一个Git标签
    `git tag -v`命令验证标签的签名
    [对提交签名](https://docs.github.com/cn/github/authenticating-to-github/signing-commits)

