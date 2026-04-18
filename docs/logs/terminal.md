# 터미널 조작 로그

## 1. 현재 위치와 목록 확인

```bash
$ pwd
/Users/<local-user>/cody/Codyssey1-1

$ ls -la
total 32
drwxr-xr-x  12 <local-user>  staff  384 Apr 19 04:17 .
drwxr-xr-x   8 <local-user>  staff  256 Apr 19 03:08 ..
-rw-r--r--   1 <local-user>  staff   75 Apr 19 04:17 .env.example
drwxr-xr-x  13 <local-user>  staff  416 Apr 19 03:09 .git
-rw-r--r--   1 <local-user>  staff   10 Apr 19 04:17 .gitignore
-rw-r--r--   1 <local-user>  staff  612 Apr 19 04:17 Dockerfile
drwxr-xr-x   4 <local-user>  staff  128 Apr 19 04:17 app
drwxr-xr-x   3 <local-user>  staff   96 Apr 19 04:17 bind-mount
-rw-r--r--   1 <local-user>  staff  672 Apr 19 04:17 docker-compose.yml
drwxr-xr-x   3 <local-user>  staff   96 Apr 19 04:17 docker-entrypoint.d
drwxr-xr-x   3 <local-user>  staff   96 Apr 19 04:17 docs
drwxr-xr-x   3 <local-user>  staff   96 Apr 19 04:17 volume
```

## 2. 생성, 이동, 복사, 파일 내용 확인

```bash
$ mkdir -p labs/terminal-lab/docs labs/terminal-lab/archive labs/terminal-lab/secure-dir
$ touch labs/terminal-lab/empty.log
$ cp app/style.css labs/terminal-lab/docs/style-copy.css
$ cp .env.example labs/terminal-lab/docs/notes.txt

$ ls -la labs/terminal-lab
total 0
drwxr-xr-x  6 <local-user>  staff  192 Apr 19 04:18 .
drwxr-xr-x  3 <local-user>  staff   96 Apr 19 04:18 ..
drwxr-xr-x  2 <local-user>  staff   64 Apr 19 04:18 archive
drwxr-xr-x  4 <local-user>  staff  128 Apr 19 04:18 docs
-rw-r--r--  1 <local-user>  staff    0 Apr 19 04:18 empty.log
drwxr-xr-x  2 <local-user>  staff   64 Apr 19 04:18 secure-dir

$ pwd
/Users/<local-user>/cody/Codyssey1-1/labs/terminal-lab

$ cat labs/terminal-lab/docs/notes.txt
WEB_PORT=8090
APP_MODE=compose-demo
APP_MESSAGE=Served from Docker Compose
```

## 3. 이동/이름 변경과 삭제

```bash
$ mv labs/terminal-lab/docs/style-copy.css labs/terminal-lab/archive/style-copy-renamed.css
$ rm labs/terminal-lab/empty.log

$ ls -la labs/terminal-lab/archive
total 8
drwxr-xr-x  3 <local-user>  staff    96 Apr 19 04:18 .
drwxr-xr-x  6 <local-user>  staff   192 Apr 19 04:18 ..
-rw-r--r--  1 <local-user>  staff  1589 Apr 19 04:18 style-copy-renamed.css
```

## 4. 권한 변경 전/후 비교

```bash
$ cp .env.example labs/terminal-lab/permission-file.txt
$ chmod 600 labs/terminal-lab/permission-file.txt
$ chmod 700 labs/terminal-lab/secure-dir

$ ls -l labs/terminal-lab/permission-file.txt
-rw-------  1 <local-user>  staff  75 Apr 19 04:18 labs/terminal-lab/permission-file.txt

$ ls -ld labs/terminal-lab/secure-dir
drwx------  2 <local-user>  staff  64 Apr 19 04:18 labs/terminal-lab/secure-dir

$ chmod 644 labs/terminal-lab/permission-file.txt
$ chmod 755 labs/terminal-lab/secure-dir

$ ls -l labs/terminal-lab/permission-file.txt
-rw-r--r--  1 <local-user>  staff  75 Apr 19 04:18 labs/terminal-lab/permission-file.txt

$ ls -ld labs/terminal-lab/secure-dir
drwxr-xr-x  2 <local-user>  staff  64 Apr 19 04:18 labs/terminal-lab/secure-dir
```
