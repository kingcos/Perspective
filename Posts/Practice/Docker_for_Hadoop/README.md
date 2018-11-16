# Practice - 从 0 开始使用 Docker 快速搭建 Hadoop 集群环境

| Date | Notes | Hadoop | Other |
|:-----:|:-----:|:-----:|:-----:|
| 2017-03-27 | 首次提交 | 2.7.2 | Docker CE, IntelliJ IDEA 2016.3 |

## Preface

自从学习 iOS/Swift 以来，就没有太多时间分配给 Java 专业课，毕竟我不是个三心二用还能样样学好的人。不过作为大三的专业课，分布式计算技术还是有去上课的，毕竟不能最后挂科吧 :]

曾有人说，「开发一个项目，至少有 50% 时间在配置环境」。确实，在折腾了三周的课时之后，我才按照老师给的详细步骤配置好 Hadoop 的环境。尽管如此，由于种种原因，班里仍有很多同学还没有配置好 Hadoop 的环境，导致课程一直停滞。在偶然中，我想到了 Docker，Docker 这个词我至少在半年前已经听说（当然，恕我孤陋寡闻，Docker 早在 13 年即发行），但一直没有去了解和使用。时至今日，我对 Docker 的了解也十分少，简单的来说，Docker 是一种容器（Container）管理工具，通过 Docker 我们可以配置可移植的环境，方便发布。Docker 基于 Linux，但也提供了 macOS 和 Windows 桌面版，方便在我们的本地机器测试、使用。

虽然本文是一个小白向的文章，但下载和安装的过程也不会在本文涉及。一是官方网站必然提供了相应的教程，纯粹的翻译毫无意义；二是下载和安装可能随着后续更新发生略微的区别，而本文只着眼于配置 Hadoop 集群环境的搭建。

**不过由于个人对 Hadoop 和 Docker 的了解甚少，如有错误，希望指出，我会学习、改正。**

## Linux

- Info:
- Ubuntu 16.10 x64

> Docker 本身就是基于 Linux 的，所以首先以我的一台服务器做实验。虽然最后跑 wordcount 已经由于内存不足而崩掉，但是之前的过程还是可以参考的。

#### 连接服务器

- 使用 ssh 命令连接远程服务器。

```shell
ssh root@[Your IP Address]
```

![ssh root@127.0.0.1](1.png)

#### 更新软件列表

```shell
apt-get update
```

![apt-get update](2.png)

- 更新完成。

![更新完成](3.png)

#### 安装 Docker

```shell
sudo apt-get install docker.io
```

![sudo apt-get install docker.io](4.png)

- 当遇到输入是否继续时，输入「Y／y」继续。

![Y](5.png)

- 安装完成。

![安装完成](6.png)

- 输入「docker」测试是否安装成功。

![docker](7.png)

#### 拉取镜像

- 镜像，是 Docker 的核心，可以通过从远程拉取镜像即可配置好我们所需要的环境，我们这次需要的是 Hadoop 集群的镜像。

![kiwenlau/hadoop-cluster-docker](8.png)

- 在本文中，我们将使用 [kiwenlau](http://kiwenlau.com) 的 Hadoop 集群镜像以及其配置。由于我的服务器本身即在国外，因此拉取镜像的速度较快，国内由于众所周知的原因，可以替换为相应的国内源，以加快拉取速度。

```shell
sudo docker pull kiwenlau/hadoop:1.0
```

- 拉取镜像完成。

![sudo docker pull kiwenlau/hadoop:1.0](9.png)

#### 克隆仓库

- 克隆仓库到当前文件夹（可以自行创建并切换到相应文件夹）。

```shell
git clone https://github.com/kiwenlau/hadoop-cluster-docker
```

- 克隆仓库完成。

![克隆仓库完成](10.png)

#### 桥接网络

```shell
sudo docker network create --driver=bridge hadoop
```

![sudo docker network create --driver=bridge hadoop](11.png)

#### 运行容器

```shell
cd hadoop-cluster-docker
./start-container.sh
```

- 默认是 1 个主节点，2 个从节点，当然也可以根据性能调整为 N 节点，详见文末参考链接。

![./start-container.sh](12.png)

#### 启动 Hadoop

```shell
./start-hadoop.sh
```

- 在上一步，我们已经运行容器，即可直接运行 Hadoop。启动时长与机器性能有关，也是难为了我这一台 512 MB 内存的服务器。

![./start-hadoop.sh](13.png)

#### 测试 Word Count

```shell
./run-wordcount.sh
```

- Word Count 是一个测试 Hadoop 的 Shell 脚本，即计算文本中的单词个数。不过由于我的服务器内存不够分配无法完成，所以后续以本机进行测试。

#### 网页管理

- 我们可以通过网页远程管理 Hadoop：
- Name Node: [Your IP Address]:50070/
- Resource Manager: [Your IP Address]:8088/

## macOS

- Info:
- macOS 10.12.4 beta (16E191a)

#### 下载 & 安装

- 打开 Docker 官方网站：[https://www.docker.com](https://www.docker.com)，选择社区版，并下载、安装。Windows 系统用户可以选择 Windows 版本。

![Docker CE](14.png)

![macOS or Windows](15.png)

#### 运行 Docker

- 打开 Docker。为了简单，我没有改动配置，如需更改，可以在 Preferences 中修改。

![Docker is running](16.png)

- 我们可以在终端（Terminal）输入「docker」，测试是否安装成功。

![docker](17.png)

#### 拉取镜像 & 克隆仓库 & 桥接网络 & 运行容器 & 启动 Hadoop

- 同 Linux。

#### 测试 Word Count

```shell
./run-wordcount.sh
```

- 同 Linux，但这次我们可以运算出结果了。

![./run-wordcount.sh](18.png)

## Windows

> 其实最开始就没有打算放出 Windows 版，倒不是因为觉得 Windows 不好，而是目前手头没有 Windows 的电脑，借用同学的电脑也不是很方便。如果需要安装 Docker，需要 CPU 支持虚拟化，且安装了 64 位 Windows 10 Pro/企业版（需要开启 Hyper-V）。其他版本的 Windows 可以安装 Docker Toolbox。

- 暂无。

## IntelliJ IDEA

> 我们的 Hadoop 集群已经在容器里安装完成，而且已经可以运行。相比自己一个个建立虚拟机，这样的确十分方便、快捷。为了便于开发调试，接下来就需要在 IntelliJ IDEA 下配置开发环境，包管理工具选择 Gradle。Maven 配合 Eclipse 的配置网上已经有很多了，需要的同学可以自行搜索。

### Docker 开启 9000 端口映射

- 由于我们使用的是 [kiwenlau](http://kiwenlau.com) 的镜像和开源脚本，虽然加快了配置过程，但是也屏蔽了很多细节。比如在其脚本中只默认开启了 50070 和 8088 的端口映射，我们可以通过 `docker ps`（注意是在本机，而不是在容器运行该命令）列出所有容器，查看容器映射的端口。

```shell
cd hadoop-cluster-docker
vim start-container.sh
```

- 切换到脚本文件夹，使用 Vim 编辑 start-container.sh。在图中光标处添加以下内容，保存并退出。

```
-p 9000:9000 \
```

![映射 9000 端口](19.png)

- 重启容器，并查看容器状态，如图即为映射成功。

![映射端口成功](20.png)

### 开启 Web HDFS 管理*

> 该步非必须。为了方便在网页端管理，因此开启 Web 端，默认关闭。

```shell
which hadoop
cd /usr/local/hadoop/etc/hadoop/
ls

vi core-site.xml
```

- 找到 Hadoop 配置文件路径，使用 Vi 编辑，若 Vi 的插入模式（Insert Mode）中，上下左右变成了 ABCD，那么可以使用以下命令即可：`cp /etc/vim/vimrc ~/.vimrc` 修复。

![Hadoop 配置文件](21.png)

- 添加以下内容。

```xml
<property>
<name>dfs.webhdfs.enabled</name>
<value>true</value>
</property>
```

![添加以上内容](22.png)

### 启动 Hadoop

- 同 Linux。

### 构建依赖

- 使用 IntelliJ IDEA 新建一个 Gradle 项目，在 Build.gradle 中加入以下依赖（对应容器 Hadoop 版本）。

```groovy
compile group: 'org.apache.hadoop', name: 'hadoop-common', version: '2.7.2'
compile group: 'org.apache.hadoop', name: 'hadoop-hdfs', version: '2.7.2'
```

### Demo

```java
import org.apache.commons.io.IOUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;
import org.junit.Before;
import org.junit.Test;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URI;

/**
* Created by kingcos on 25/03/2017.
*/
public class HDFSOperations {

FileSystem fileSystem;

@Before
public void configure() throws Exception {
Configuration configuration = new Configuration();
configuration.set("fs.defaultFS", "hdfs://192.168.1.120:9000");
fileSystem = FileSystem.get(URI.create("hdfs://192.168.1.120:9000"), configuration, "root");
}

@Test
public void listFiles() throws IOException {
Path path = new Path("/");
RemoteIterator<LocatedFileStatus> iterator = fileSystem.listFiles(path, true);

while (iterator.hasNext()) {
LocatedFileStatus status = iterator.next();
System.out.println(status.getPath().getName());
}
}

@Test
public void rm() throws IOException {
Path path = new Path("/");
fileSystem.delete(path, true);
}

@Test
public void mkdir() throws IOException {
Path path = new Path("/demo");
fileSystem.mkdirs(path);
}
}
```

- 之后便可以通过 IDEA 直接写代码来测试，这里简单写了几个方法。

## 总结

- 在写这篇文章之前，其实我对 Docker 的概念很不了解。但是通过 Learn by do it. 大致知道了其中的概念和原理。我们完全可以构建自己的容器 Dockerfile，来部署生产和开发环境，其强大的可移植性大大缩短配置的过程。
- 由于个人对 Hadoop 和 Docker 的了解甚少，如有错误，希望指出，我会学习、改正。
- 如果有时间，我会再折腾一下其他的玩法 :]

## Reference

- [基于 Docker 搭建 Hadoop 集群之升级版](http://kiwenlau.com/2016/06/12/160612-hadoop-cluster-docker-update/)
