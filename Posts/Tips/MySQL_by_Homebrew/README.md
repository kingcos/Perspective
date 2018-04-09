# Tips - 使用 Homebrew 安装 MySQL

## Solution

- 安装 Homebrew

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

- 安装 MySQL（注意观察可能有错误信息，比如 `brew link` 失败，可能要先在相应文件夹下开启「写」权限后再手动尝试）

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

- 连接 MySQL（默认端口为 3306）

```shell
mysql -uroot
```

- 创建用户并授权

```sql
-- CREATE USER 'USERNAME'@'HOST_NAME' IDENTIFIED BY 'PASSWORD';
CREATE USER 'temp_user'@'localhost' IDENTIFIED BY '1234';

-- GRANT PRIVILEGE ON DATABASE_NAME.TABLE_NAME TO 'USERNAME'@'HOST_NAME'
GRANT ALL ON *.* TO 'temp_user'@'localhost';
```

- 关闭 MySQL 服务

```shell
# 对应上述开启方法
brew services stop mysql

mysql.server stop
```

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)
