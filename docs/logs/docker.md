# Docker 운영 및 검증 로그

## 1. Docker 기본 점검

```bash
$ docker --version
Docker version 28.5.2, build ecc6942

$ docker info
Client:
 Version:    28.5.2
 Context:    orbstack
 Debug Mode: true

Server:
 Containers: 10
  Running: 2
  Paused: 0
  Stopped: 8
 Images: 3
 Server Version: 28.5.2
 Storage Driver: overlay2
 Operating System: OrbStack
 OSType: linux
 Architecture: x86_64
 CPUs: 6
 Total Memory: 15.67GiB
 Name: orbstack
 Docker Root Dir: /var/lib/docker
```

```bash
$ docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}'
REPOSITORY                 TAG       IMAGE ID       CREATED          SIZE
codyssey-workstation-web   1.0       003c6288e668   7 minutes ago    48.2MB
<none>                     <none>    815000b2d0c3   16 minutes ago   48.2MB
my-web                     1.0       231ac90befcb   2 hours ago      62.3MB
ubuntu                     latest    0b1ebe5dd426   8 days ago       78.1MB
hello-world                latest    e2ac70e7319a   3 weeks ago      10.1kB

$ docker ps -a --filter name=codyssey --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES                      IMAGE                          STATUS                      PORTS
codyssey-volume-two        ubuntu                         Up 28 seconds
codyssey-bind-8089-fixed   codyssey-workstation-web:1.0   Up 7 minutes (healthy)      0.0.0.0:8089->80/tcp, [::]:8089->80/tcp
codyssey-bind-8089         815000b2d0c3                   Exited (1) 12 minutes ago
codyssey-web-8088          815000b2d0c3                   Up 14 minutes (healthy)     0.0.0.0:8088->80/tcp, [::]:8088->80/tcp
codyssey-hello             hello-world                    Exited (0) 16 minutes ago
codyssey-ubuntu-demo       ubuntu                         Up 16 minutes
```

## 2. hello-world 실행

```bash
$ docker run --name codyssey-hello hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

```bash
$ docker logs codyssey-hello

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## 3. ubuntu 컨테이너 실행, exec, attach 관찰

```bash
$ docker run -dit --name codyssey-ubuntu-demo ubuntu bash
07cdd5c74093b4adeea79ccc450a8a04f0dfd79aa642c773708a16d887d229b4

$ docker exec codyssey-ubuntu-demo bash -lc "ls / | sed -n '1,10p'; echo 'hello from ubuntu container'"
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
hello from ubuntu container
```

```bash
$ docker exec -d codyssey-ubuntu-demo sh -lc "sleep 30"

$ docker top codyssey-ubuntu-demo
PID                 USER                TIME                COMMAND
6815                root                0:00                bash
7264                root                0:00                sh -lc sleep 30
7273                root                0:00                sleep 30
```

```bash
$ docker attach codyssey-ubuntu-demo
root@07cdd5c74093:/# pwd
/
root@07cdd5c74093:/# echo attached-main-process
attached-main-process

$ docker ps --filter name=codyssey-ubuntu-demo --format 'table {{.Names}}\t{{.Status}}'
NAMES                  STATUS
codyssey-ubuntu-demo   Up 3 minutes
```

해석:

- `attach`는 메인 `bash` 프로세스 프롬프트에 바로 붙었다.
- `exec`는 `docker top`에서 보이는 것처럼 별도의 `sh` / `sleep` 프로세스를 추가로 만들었다.

## 4. Dockerfile 기반 커스텀 이미지 빌드

```bash
$ docker build -t codyssey-workstation-web:1.0 .
#0 building with "orbstack" instance using docker driver
#1 [internal] load build definition from Dockerfile
#2 [internal] load metadata for docker.io/library/nginx:1.27-alpine
#6 [2/4] COPY app/ /usr/share/nginx/html/
#7 [3/4] COPY docker-entrypoint.d/40-render-page.sh /docker-entrypoint.d/40-render-page.sh
#8 [4/4] RUN chmod +x /docker-entrypoint.d/40-render-page.sh
#9 exporting to image
#9 naming to docker.io/library/codyssey-workstation-web:1.0
#9 DONE 0.3s
```

## 5. 포트 매핑과 웹 접속 검증

```bash
$ docker run -d -p 8088:80 --name codyssey-web-8088 \
  -e APP_MODE=standalone \
  -e APP_MESSAGE='Direct docker run on port 8088' \
  codyssey-workstation-web:1.0
aceae05ae7468cac9332afec75ab33641324d28bad96d4e493c5d929fb27ccb2
```

```bash
$ docker logs codyssey-web-8088
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/40-render-page.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/04/18 19:23:19 [notice] 1#1: nginx/1.27.5
```

```bash
$ curl -i http://localhost:8088
HTTP/1.1 200 OK
Server: nginx/1.27.5
Date: Sat, 18 Apr 2026 19:24:13 GMT
Content-Type: text/html
Content-Length: 773

<!DOCTYPE html>
<html lang="ko">
  <body>
    <main class="shell-card">
      <p class="message">Direct docker run on port 8088</p>
      <dd>standalone</dd>
      <dd>80</dd>
    </main>
  </body>
</html>
```

```bash
$ docker stats --no-stream codyssey-web-8088 codyssey-ubuntu-demo
CONTAINER ID   NAME                   CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O         PIDS
aceae05ae746   codyssey-web-8088      0.00%     9.504MiB / 15.67GiB   0.06%     830B / 126B     9.64MB / 12.3kB   7
07cdd5c74093   codyssey-ubuntu-demo   0.00%     4.113MiB / 15.67GiB   0.03%     1.04kB / 126B   10.1MB / 0B       1
```

## 6. 바인드 마운트 전/후 비교

### 6-1. 첫 시도와 실패 원인

```bash
$ docker run -d -p 8089:80 --name codyssey-bind-8089 \
  -v ${PWD}/bind-mount/site:/usr/share/nginx/html \
  codyssey-workstation-web:1.0
```

```bash
$ docker logs codyssey-bind-8089
/docker-entrypoint.d/40-render-page.sh: line 7: can't open /usr/share/nginx/html/index.template.html: no such file
```

### 6-2. 엔트리포인트 수정 후 재검증

`40-render-page.sh`를 수정해 템플릿이 없으면 렌더링을 건너뛰도록 만들고 이미지를 다시 빌드했다.

```bash
$ docker build -t codyssey-workstation-web:1.0 .
#7 [3/4] COPY docker-entrypoint.d/40-render-page.sh /docker-entrypoint.d/40-render-page.sh
#9 naming to docker.io/library/codyssey-workstation-web:1.0
```

```bash
$ docker run -d -p 8089:80 --name codyssey-bind-8089-fixed \
  -v ${PWD}/bind-mount/site:/usr/share/nginx/html \
  codyssey-workstation-web:1.0
5688530d33b2e781368de8eab81defa25c1b885b63d0b0e0b27c62812b1e965b

$ curl -i http://localhost:8089
HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Length: 237

<!DOCTYPE html>
<html lang="ko">
  <body>
    <h1>Bind mount before change</h1>
    <p>The host file is mounted into the container.</p>
  </body>
</html>
```

호스트 파일 수정:

```bash
$ cat bind-mount/site/index.html
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <title>Bind Mount Demo</title>
  </head>
  <body>
    <h1>Bind mount after change</h1>
    <p>The container served the updated host file without rebuilding the image.</p>
  </body>
</html>
```

수정 후 재요청:

```bash
$ curl -i http://localhost:8089
HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Length: 264

<!DOCTYPE html>
<html lang="ko">
  <body>
    <h1>Bind mount after change</h1>
    <p>The container served the updated host file without rebuilding the image.</p>
  </body>
</html>
```

```bash
$ docker logs codyssey-bind-8089-fixed
40-render-page.sh: index.template.html not found, skipping template rendering
127.0.0.1 - - [18/Apr/2026:19:30:12 +0000] "GET / HTTP/1.1" 200 237 "-" "Wget" "-"
192.168.215.1 - - [18/Apr/2026:19:31:26 +0000] "GET / HTTP/1.1" 200 264 "-" "curl/8.7.1" "-"
```

## 7. Docker 볼륨 영속성 검증

```bash
$ docker volume create codyssey-data
codyssey-data

$ docker volume inspect codyssey-data
[
    {
        "CreatedAt": "2026-04-19T04:35:06+09:00",
        "Driver": "local",
        "Mountpoint": "/var/lib/docker/volumes/codyssey-data/_data",
        "Name": "codyssey-data",
        "Scope": "local"
    }
]
```

첫 번째 컨테이너에서 데이터 생성:

```bash
$ docker run -d --name codyssey-volume-one -v codyssey-data:/data ubuntu sleep infinity
c02ffc6e650f03f07026e0f2e37a43e84d66e9f3b609982e9a322e60378d1677

$ docker exec codyssey-volume-one bash -lc "echo persisted-from-volume > /data/hello.txt && cat /data/hello.txt"
persisted-from-volume
```

첫 번째 컨테이너 삭제 후 두 번째 컨테이너에서 재확인:

```bash
$ docker rm -f codyssey-volume-one
codyssey-volume-one

$ docker run -d --name codyssey-volume-two -v codyssey-data:/data ubuntu sleep infinity
524551906a1b6cb92b2ad0da57bcc1bf804ac9bdf91fd9b1b91cc98c15f696d6

$ docker exec codyssey-volume-two bash -lc "cat /data/hello.txt"
persisted-from-volume
```
