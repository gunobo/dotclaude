# dotclaude

새 프로젝트에서 Claude Code를 바로 쓸 수 있도록 `.claude` 폴더와 `CLAUDE.md`를 표준 구조로 만드는 스킬입니다.

Python, Node/TypeScript, React/Vite, Next.js, Go 등 스택을 고르면 그에 맞는 명령과 권한 기본값을 넣어 줍니다.

## 설치

```
npx skills add https://github.com/gunobo/dotclaude --skill dotclaude
```

## 사용

Claude Code에서 프로젝트 루트를 연 뒤 아래처럼 요청합니다.

- "프로젝트 초기화해줘"
- ".claude 만들어줘"
- "새 프로젝트 세팅"

프로젝트 이름, 스택, 빌드·테스트 명령을 물어본 뒤 파일을 만듭니다.

## 만들어지는 구조

```
<project>/
├── CLAUDE.md
├── .gitignore                  # settings.local.json, .env 제외 추가
└── .claude/
    ├── settings.json           # 팀 공유 권한 (커밋)
    ├── settings.local.json     # 개인 설정 (커밋 제외)
    ├── commands/
    │   ├── review.md           # /review
    │   └── test-fix.md         # /test-fix
    ├── skills/
    └── agents/
```

## 기본 보안 설정

스택과 관계없이 아래 항목을 차단합니다.

- `.env`, `*.pem`, `*.key` 파일 읽기
- `rm -rf`
- `git push --force`
- 파이프로 스크립트를 바로 실행하는 명령 (`curl ... | sh` 등)

## 기존 파일 처리

기존 `CLAUDE.md`나 `.claude/settings.json`이 있으면 덮어쓰지 않습니다. 백업, 병합, 건너뛰기 중 하나를 고를 수 있습니다.

## 기여

이슈와 PR을 환영합니다. 새 스택 템플릿은 `references/stacks.md`에 추가해 주세요.

## 라이선스

[MIT](LICENSE)
