# Tips - 使用 Homebrew 安装 Jenkins

## Reason

Jenkins 官网下载的 pkg 安装显然不够优雅，看似安装简单，卸载却比较麻烦，而且会自动创建 Jenkins 账户。

***Why NOT Homebrew?***

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

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)
