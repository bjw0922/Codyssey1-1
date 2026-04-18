# Docker Compose 보너스 로그

## 1. 환경 변수 파일

```bash
$ cat .env.compose
WEB_PORT=8091
APP_MODE=compose-bonus
APP_MESSAGE=Configured through environment variables
```

## 2. `docker compose up -d --build`

```bash
$ docker compose --env-file .env.compose up -d --build
 inspector Pulled
 codyssey-workstation-web:1.0  Built
 Network codyssey1-1_default  Created
 Container compose-web  Created
 Container compose-inspector  Created
 Container compose-web  Started
 Container compose-web  Healthy
 Container compose-inspector  Started
```

## 3. `docker compose ps`

```bash
$ docker compose ps
NAME                IMAGE                          COMMAND                  SERVICE     CREATED          STATUS                    PORTS
compose-inspector   busybox:1.36                   "sh -c 'wget -qO- ht…"   inspector   19 seconds ago   Up 13 seconds
compose-web         codyssey-workstation-web:1.0   "/docker-entrypoint.…"   web         19 seconds ago   Up 19 seconds (healthy)   0.0.0.0:8091->80/tcp, [::]:8091->80/tcp
```

## 4. 멀티 컨테이너 통신 로그

`inspector` 서비스가 내부 DNS 이름 `web`로 접속해 HTML을 가져온 결과다.

```bash
$ docker compose logs inspector
compose-inspector  | <!DOCTYPE html>
compose-inspector  | <html lang="ko">
compose-inspector  |   <head>
compose-inspector  |     <meta charset="utf-8" />
compose-inspector  |     <meta name="viewport" content="width=device-width, initial-scale=1" />
compose-inspector  |     <title>Codyssey Workstation</title>
compose-inspector  |     <link rel="stylesheet" href="/style.css" />
compose-inspector  |   </head>
compose-inspector  |   <body>
compose-inspector  |     <main class="shell-card">
compose-inspector  |       <p class="eyebrow">AI/SW Development Workstation</p>
compose-inspector  |       <h1>Containerized Web Server</h1>
```

## 5. 환경 변수 반영 + 포트 매핑 확인

```bash
$ curl -i http://localhost:8091
HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Length: 786

<!DOCTYPE html>
<html lang="ko">
  <body>
    <main class="shell-card">
      <p class="message">Configured through environment variables</p>
      <dd>compose-bonus</dd>
      <dd>80</dd>
    </main>
  </body>
</html>
```

## 6. `docker compose down`

```bash
$ docker compose down
 Container compose-inspector  Stopped
 Container compose-inspector  Removed
 Container compose-web  Stopped
 Container compose-web  Removed
 Network codyssey1-1_default  Removed

$ docker compose ps
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```
