# Git / GitHub 연동 로그

## 1. Git 설정 확인

민감정보 보호를 위해 사용자 이름과 이메일은 마스킹했다.

```bash
$ git config --list | sed -E 's/(user.name=).+/\1***masked***/; s/(user.email=).+/\1***masked***/; s#(remote.origin.url=https://github.com/)[^/]+/#\1***masked***/#'
credential.helper=osxkeychain
user.name=***masked***
user.email=***masked***
init.defaultbranch=main
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
core.ignorecase=true
core.precomposeunicode=true
remote.origin.url=https://github.com/***masked***/Codyssey1-1.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.main.remote=origin
branch.main.merge=refs/heads/main
branch.main.vscode-merge-base=origin/main
```

## 2. GitHub 원격 저장소 확인

```bash
$ git remote -v | sed -E 's#(https://github.com/)[^/]+/#\1***masked***/#'
origin  https://github.com/***masked***/Codyssey1-1.git (fetch)
origin  https://github.com/***masked***/Codyssey1-1.git (push)
```

## 3. VSCode / GitHub GUI 연동 증거

- 현재 저장소는 GitHub 원격 저장소와 연결되어 있다.
- 다만 VSCode 로그인 창, 계정 아이콘, 저장소 동기화 상태 같은 GUI 증거는 터미널 에이전트가 직접 캡처할 수 없다.
- 제출 시에는 [../evidence/README.md](../evidence/README.md)의 안내에 따라 수동 스크린샷을 추가한다.
