# Tips - 使用 Homebrew 安装 Jenkins

| Platform | Notes |
|:-----:|:-----:|
| macOS 10.13.4 | Jenkins 2.114 & Java 8 |

## Solution

- 安装 Homebrew

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

- 安装 Jenkins（目前 Jenkins 尚未支持 Java 9+，请使用 Java 8 环境）

```shell
brew install jenkins
```

- 运行 Jenkins（注意替换 `$JENKINS_VERSION_CODE` 为你的安装版本号）

```shell
java -jar /usr/local/Cellar/jenkins/$JENKINS_VERSION_CODE/libexec/jenkins.war --httpPort=8080
```

## Extension

- [macOS 下管理多个 Java 版本](../Java_Multiple_Versions)

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)
