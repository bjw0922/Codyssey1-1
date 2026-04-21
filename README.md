# AI/SW 개발 워크스테이션 구축

터미널 기본 조작, 파일 권한, Docker 컨테이너 운영, Dockerfile 기반 커스텀 이미지, 포트 매핑, 바인드 마운트, 볼륨 영속성, Git/GitHub 연동 상태를 한 저장소에서 재현 가능하게 정리한 결과물입니다.  
보너스 과제로 `docker compose` 기반 단일 서비스 실행, 멀티 컨테이너 통신, `up/down/ps/logs` 운영 명령, 환경 변수 주입까지 함께 검증했습니다.

## 1. 프로젝트 개요

- 목표: 로컬 개발 환경을 터미널과 Docker 중심으로 표준화하고, "같은 절차를 반복하면 같은 결과가 나온다"는 재현성 개념을 직접 확인한다.
- 선택한 방식: `nginx:1.27-alpine` 기반 정적 웹 서버 이미지를 커스터마이징했다.
- 핵심 검증 포인트:
  - 터미널 조작과 파일 권한 변경이 실제로 동작하는가
  - Docker 데몬과 컨테이너 운영 명령이 정상 동작하는가
  - Dockerfile로 빌드한 이미지가 포트 매핑과 환경 변수 반영을 지원하는가
  - 바인드 마운트는 호스트 변경을 즉시 반영하는가
  - Docker 볼륨은 컨테이너 삭제 후에도 데이터를 유지하는가
  - Docker Compose는 실행 설정을 문서화된 구성으로 바꿔주는가

## 2. 실행 환경

- 실행 일시: 2026-04-19 (Asia/Seoul)
- OS: macOS 15.7.4
- Kernel: Darwin 24.6.0
- Shell: `/bin/zsh`
- Docker: 28.5.2
- Docker Compose: v2.40.3
- Docker Context: `orbstack`
- Git: 2.53.0

## 3. 저장소 구조

```text
.
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .env.compose
├── app/
│   ├── index.template.html
│   └── style.css
├── bind-mount/site/index.html
├── docker-entrypoint.d/40-render-page.sh
├── docs/
│   ├── evidence/README.md
│   └── logs/
│       ├── compose.md
│       ├── docker.md
│       ├── git.md
│       └── terminal.md
├── labs/terminal-lab/
└── volume/README.md
```

## 4. 수행 항목 체크리스트

- [x] 터미널 기본 조작 및 작업 디렉터리 구성
- [x] 파일 1개, 디렉터리 1개 권한 변경 실습
- [x] `docker --version`, `docker info` 점검
- [x] `docker images`, `docker ps -a`, `docker logs`, `docker stats`
- [x] `hello-world` 실행 성공
- [x] `ubuntu` 컨테이너 실행 및 내부 명령 수행
- [x] `attach` / `exec` 차이 관찰 및 정리
- [x] Dockerfile 기반 커스텀 이미지 빌드
- [x] 포트 매핑 후 `curl` 접속 검증
- [x] 바인드 마운트 전/후 비교
- [x] Docker 볼륨 영속성 검증
- [x] Git 사용자 정보/기본 브랜치/remote 상태 확인
- [x] 보너스: Compose 단일 서비스 실행
- [x] 보너스: Compose 멀티 컨테이너 통신
- [x] 보너스: Compose `up/down/ps/logs`
- [x] 보너스: Compose 환경 변수 주입
- [x] VSCode GitHub 로그인 화면 캡처

## 5. 검증 방법과 결과 위치

| 검증 대상 | 사용한 명령 | 결과 위치 |
| --- | --- | --- |
| 터미널 기본 조작 | `pwd`, `ls -la`, `mkdir`, `touch`, `cp`, `mv`, `rm`, `cat` | [docs/logs/terminal.md](docs/logs/terminal.md) |
| 파일 권한 | `chmod 600/644`, `chmod 700/755`, `ls -l`, `ls -ld` | [docs/logs/terminal.md](docs/logs/terminal.md) |
| Docker 기본 점검 | `docker --version`, `docker info`, `docker images`, `docker ps -a` | [docs/logs/docker.md](docs/logs/docker.md) |
| hello-world / ubuntu | `docker run`, `docker exec`, `docker top`, `docker attach` | [docs/logs/docker.md](docs/logs/docker.md) |
| 커스텀 이미지 빌드 | `docker build -t codyssey-workstation-web:1.0 .` | [docs/logs/docker.md](docs/logs/docker.md) |
| 포트 매핑 | `docker run -d -p 8088:80 ...`, `curl -i http://localhost:8088` | [docs/logs/docker.md](docs/logs/docker.md) |
| 바인드 마운트 | `docker run -v ...`, 호스트 파일 수정 후 `curl -i http://localhost:8089` | [docs/logs/docker.md](docs/logs/docker.md) |
| 볼륨 영속성 | `docker volume create`, `docker exec`, `docker rm -f`, `docker run -v` | [docs/logs/docker.md](docs/logs/docker.md) |
| Compose 보너스 | `docker compose up/down/ps/logs`, `curl -i http://localhost:8091` | [docs/logs/compose.md](docs/logs/compose.md) |
| Git/GitHub 상태 | `git config --list`, `git remote -v` | [docs/logs/git.md](docs/logs/git.md) |
| 수동 GUI 증거 | VSCode/GitHub 로그인 화면 | [docs/evidence/README.md](docs/evidence/README.md) |

## 6. 커스텀 이미지 설계 요약

### 선택한 기존 베이스

- 베이스 이미지: `nginx:1.27-alpine`
- 선택 이유:
  - 웹 서버 역할이 명확해서 포트 매핑 실습에 적합하다.
  - 정적 파일 제공만으로도 컨테이너화 흐름을 설명하기 쉽다.
  - Alpine 기반이라 이미지가 비교적 가볍다.

### 내가 적용한 커스텀 포인트

1. `app/index.template.html`, `app/style.css`를 이미지에 복사했다.
   - 목적: 기본 NGINX 화면 대신 과제용 웹 페이지를 제공한다.
2. `/docker-entrypoint.d/40-render-page.sh`를 추가했다.
   - 목적: `APP_MODE`, `APP_MESSAGE`, `APP_PORT` 환경 변수를 `index.html`에 반영한다.
3. `HEALTHCHECK`를 추가했다.
   - 목적: 컨테이너 내부에서 HTTP 응답이 살아 있는지 점검한다.
4. 바인드 마운트 예외 처리를 넣었다.
   - 목적: 호스트 디렉터리가 `/usr/share/nginx/html` 전체를 덮어써도 엔트리포인트가 실패하지 않게 한다.

## 7. 핵심 개념 설명

### 절대 경로와 상대 경로

- 절대 경로: 루트(`/`)부터 시작하는 경로다.
  - 예: `/Users/<local-user>/cody/Codyssey1-1/app/style.css`
- 상대 경로: 현재 작업 디렉터리를 기준으로 해석되는 경로다.
  - 예: `app/style.css`, `labs/terminal-lab/docs/notes.txt`
- 같은 파일이라도 실행 위치가 바뀌면 상대 경로 해석 결과가 달라진다.

### 파일 권한과 755 / 644

- `r`: 읽기(4), `w`: 쓰기(2), `x`: 실행(1)
- 숫자 표기는 `소유자 / 그룹 / 기타 사용자` 순서다.
- `755` = `rwxr-xr-x`
  - 디렉터리에 많이 사용한다.
  - 소유자는 읽기/쓰기/실행, 나머지는 읽기/실행만 가능하다.
- `644` = `rw-r--r--`
  - 일반 텍스트 파일에 많이 사용한다.
  - 소유자는 읽기/쓰기, 나머지는 읽기만 가능하다.

### 포트 매핑이 필요한 이유

- 컨테이너 내부의 포트(`80`)는 기본적으로 호스트 브라우저에서 바로 보이지 않는다.
- `-p 8088:80`처럼 매핑해야 호스트의 `localhost:8088` 요청이 컨테이너의 `80` 포트로 전달된다.
- 즉, 격리된 컨테이너 네트워크와 호스트 접속 지점을 연결하는 다리 역할을 한다.

### Docker 볼륨이 필요한 이유

- 컨테이너 레이어는 컨테이너를 삭제하면 함께 사라질 수 있다.
- Named volume은 Docker가 별도로 관리하는 저장소이므로 컨테이너를 지워도 데이터가 남는다.
- 이번 실습에서는 `/data/hello.txt`를 남긴 뒤 첫 번째 컨테이너를 삭제하고, 두 번째 컨테이너에서 같은 파일을 다시 읽어 영속성을 검증했다.

### Git과 GitHub의 차이

- Git: 내 컴퓨터에서 커밋, 브랜치, 히스토리를 관리하는 로컬 버전 관리 시스템
- GitHub: Git 저장소를 원격으로 공유하고 협업, 리뷰, 이슈 관리까지 지원하는 플랫폼
- 이번 저장소에서는 `git config`와 `remote.origin.url`로 로컬 Git 설정과 GitHub 연결 상태를 확인했다.

### `attach` 와 `exec` 차이

- `docker attach`는 컨테이너의 "메인 프로세스"에 직접 붙는다.
- `docker exec`는 실행 중인 컨테이너 안에서 "새 프로세스"를 추가로 실행한다.
- 실제로 `docker top codyssey-ubuntu-demo` 결과에서 `bash`(메인 프로세스)와 `sleep 30`(exec로 추가한 프로세스)가 동시에 보였다.

## 8. 트러블슈팅

### 사례 1. 바인드 마운트 후 컨테이너가 바로 종료됨

- 문제:
  - `docker run -d -p 8089:80 -v ... codyssey-workstation-web:1.0` 실행 직후 `curl` 접속이 실패했다.
- 원인 가설:
  - 호스트 디렉터리가 `/usr/share/nginx/html` 전체를 덮어써서 `index.template.html`이 사라졌을 가능성이 있다.
- 확인:
  - `docker logs codyssey-bind-8089`에서 `can't open /usr/share/nginx/html/index.template.html: no such file`를 확인했다.
- 해결:
  - `40-render-page.sh`를 수정해 템플릿이 없으면 렌더링을 건너뛰도록 만들었다.
  - 이미지를 다시 빌드한 뒤 `codyssey-bind-8089-fixed` 컨테이너로 재검증했다.

### 사례 2. 컨테이너 직후 `curl` 요청이 너무 빨라 연결 실패

- 문제:
  - 포트가 매핑된 직후 `curl http://localhost:8089`가 `Couldn't connect to server`를 반환했다.
- 원인 가설:
  - 컨테이너 프로세스가 아직 기동 중이거나 Healthcheck가 완료되기 전일 수 있다.
- 확인:
  - `docker ps --filter name=codyssey-bind-8089-fixed`에서 `Up ... (healthy)` 상태를 확인한 뒤 다시 요청하니 200 OK가 반환됐다.
- 해결:
  - 실습 문서에는 "컨테이너 직후 상태 확인 -> 로그 확인 -> 재요청" 순서를 남겼다.

### 사례 3. Codex 샌드박스에서 Docker 소켓 접근 실패

- 문제:
  - Codex 내부 샌드박스에서 `docker info`를 처음 실행했을 때 Orbstack 소켓 접근 권한 오류가 발생했다.
- 원인 가설:
  - 컨테이너 에이전트가 기본 sandbox 권한으로는 `~/.orbstack/run/docker.sock`에 직접 접근하지 못했다.
- 확인:
  - 오류 메시지에 `permission denied while trying to connect to the Docker daemon socket`가 명시됐다.
- 해결/대안:
  - 권한 상승된 Docker 명령으로 실습을 이어갔다.
  - 실제 제출 환경에서는 사용자가 자신의 터미널에서 동일 명령을 실행하면 된다.

## 9. 바로 확인할 파일

- 터미널 로그: [docs/logs/terminal.md](docs/logs/terminal.md)
- Docker 로그: [docs/logs/docker.md](docs/logs/docker.md)
- Compose 로그: [docs/logs/compose.md](docs/logs/compose.md)
- Git 로그: [docs/logs/git.md](docs/logs/git.md)
- 수동 증거 안내: [docs/evidence/README.md](docs/evidence/README.md)
