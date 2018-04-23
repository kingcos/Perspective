# Tips - Supervisor 安装与基本使用

| Platform | Notes |
|:-----:|:-----:|
| macOS 10.13.4 | Supervisor 3.3.4 |
| Cent OS 6.5 | Supervisor 2.1-9 |

## Installation

### macOS

- 使用 HomeBrew 安装

```shell
brew install supervisor
```

### CentOS

- 配置清华大学 epel 镜像

```shell
# CentOS 7 请选择相应版本的 rpm 文件
wget https://mirrors.tuna.tsinghua.edu.cn/epel/epel-release-latest-6.noarch.rpm

rpm -ivh epel-release-latest-6.noarch.rpm
```

- 使用 Yum 安装

```shell
yum install supervisor
```

## Usage

- 可以在「/etc/supervisord.conf」中，看到该示例。

```shell
[supervisord]
http_port=/var/tmp/supervisor.sock ; (default is to run a UNIX domain socket server)
;http_port=127.0.0.1:9001  ; (alternately, ip_address:port specifies AF_INET)
;sockchmod=0700              ; AF_UNIX socketmode (AF_INET ignore, default 0700)
;sockchown=nobody.nogroup     ; AF_UNIX socket uid.gid owner (AF_INET ignores)
;umask=022                   ; (process file creation umask;default 022)
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10          ; (num of main logfile rotation backups;default 10)
loglevel=info               ; (logging level;default info; others: debug,warn)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false              ; (start in foreground if true;default false)
minfds=1024                 ; (min. avail startup file descriptors;default 1024)
minprocs=200                ; (min. avail process descriptors;default 200)

;nocleanup=true              ; (don't clean up tempfiles at start;default false)
;http_username=user          ; (default is no username (open system))
;http_password=123           ; (default is no password (open system))
;childlogdir=/tmp            ; ('AUTO' child log dir, default $TEMP)
;user=chrism                 ; (default is current user, required if root)
;directory=/tmp              ; (default is not to cd during start)
;environment=KEY=value       ; (key value pairs to add to environment)

[supervisorctl]
serverurl=unix:///var/tmp/supervisor.sock ; use a unix:// URL  for a unix socket
;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as http_username if set
;password=123                ; should be same as http_password if set
;prompt=mysupervisor         ; cmd line prompt (default "supervisor")

; The below sample program section shows all possible program subsection values,
; create one or more 'real' program: sections to be able to control them under
; supervisor.

;[program:theprogramname]
;command=/bin/cat            ; the program (relative uses PATH, can take args)
;priority=999                ; the relative start priority (default 999)
;autostart=true              ; start at supervisord start (default: true)
;autorestart=true            ; retstart at unexpected quit (default: true)
;startsecs=10                ; number of secs prog must stay running (def. 10)
;startretries=3              ; max # of serial start failures (default 3)
;exitcodes=0,2               ; 'expected' exit codes for process (default 0,2)
;stopsignal=QUIT             ; signal used to kill process (default TERM)
;stopwaitsecs=10             ; max num secs to wait before SIGKILL (default 10)
;user=chrism                 ; setuid to this UNIX account to run the program
;log_stdout=true             ; if true, log program stdout (default true)
;log_stderr=true             ; if true, log program stderr (def false)
;logfile=/var/log/cat.log    ; child log path, use NONE for none; default AUTO
;logfile_maxbytes=1MB        ; max # logfile bytes b4 rotation (default 50MB)
;logfile_backups=10          ; # of logfile backups (default 10)
```

> 也欢迎您关注我的微博 [@萌面大道V](http://weibo.com/375975847)

## Test
