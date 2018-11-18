# Tips - Supervisor 的安装与基本使用

| Platform | Supervisor |
|:-----:|:-----:|
| macOS 10.13.4 | 3.3.4 | 
| Raspbian 4.14 | 3.3.1 |

## Info

Supervisor 是 Linux/UNIX 下的一个由 Python 编写的进程管理工具，可以很方便的用来启动、重启、关闭进程。

## Solution

### Installation

#### macOS

- 使用 HomeBrew 安装

```
brew install supervisor
```

#### Raspbian (Linux)

```
sudo apt-get install supervisor
```

### Usage

- 安装完成后，可以在查看该默认配置，但并非所有配置项均必须定义，可根据自己需要进行配置
- macOS

```conf
; macOS - /etc/supervisord.conf
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

- Raspbian

```conf
; Raspbian - /etc/supervisor/supervisord.conf

; supervisor config file

[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)

[supervisord]
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = /etc/supervisor/conf.d/*.conf
```

- 针对不同程序的配置可以单独放在不同的 `.ini` 文件中
- `PROGRAM_NAME` 替换为该文件命名，`COMMAND` 替换为需要保持运行的命令，注意可执行文件的路径，其他配置这里仅做演示，可根据上表自行配置

```ini
; PROGRAM_NAME.ini
[program:PROGRAM_NAME]
command=COMMAND
autostart=true
autorestart=true
startretries=5
user=kingcos

[supervisord]
```

- 在 `.conf` 文件中可以在 `files` 加入上述配置好的 `.ini`
- `INI_NAME` 即上述文件名

```conf
; supervisord.conf
[include]
files=INI_NAME.ini

[supervisorctl]
```

- 运行，注意配置文件路径

```
# supervisord -c ${SUPERVISOR_CONFIG_PATH}
supervisord -c /path/to/supervisord.conf
```

### Test

- 运行后可以使用 `ps -A | grep PROGRAM_NAME` 来获取启动的进程
- 之后可以使用 `kill` 命令杀掉相应进程，在 `ps -A` 查看是否重启（如果设置了 Restart）

## Stop

- 如果配置有更改，需要重新启动 Supervisor，可以 `ps -ef | grep supervisord` 来获取运行的其进程，使用 `kill` 命令即可杀掉，之后再次运行 Supervisor 即可

## Reference

- [Supervisor](https://supervisord.org)

## Extension

- Linux - systemd
- macOS - Launchd
