# Tips - 使用 Homebrew 安装 MySQL

## Solution

- 安装 Homebrew

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

- 安装 MySQL（注意观察可能有错误信息，比如需要 `brew link`，需要在相应文件夹下开启「写」权限）

```shell
brew install mysql
```

- 开启 MySQL 服务

```shell
# 现在启动，并加入自启动
brew services start mysql

# 后台启动
mysql.server start
```

- 连接 MySQL

```shell
mysql -uroot
```

- 创建用户并授权

```sql
-- CREATE USER 'USERNAME'@'HOST_NAME' IDENTIFIED BY 'PASSWORD';
CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD';

-- GRANT PRIVILEGE ON DATABASE_NAME.TABLE_NAME TO 'USERNAME'@'HOST_NAME'
GRANT ALL ON *.* TO 'pig'@'%';
```

- 关闭 MySQL 服务

```shell
# 对应上述开启方法
brew services stop mysql

mysql.server stop
```

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)
