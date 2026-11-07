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
├── CLAUDE.md               # 매 세션 먼저 읽는 프로젝트 지침
├── CLAUDE.local.md         # 개인 지침 (커밋 제외)
├── .gitignore              # settings.local.json, CLAUDE.local.md, .env 등 제외 추가
├── .mcp.json               # 팀 공유 MCP 서버 (빈 목록)
├── .worktreeinclude        # worktree에 복사할 무시된 파일 (.env)
└── .claude/
    ├── settings.json       # 권한 + 훅 등록 (커밋)
    ├── settings.local.json # 개인 설정 (커밋 제외)
    ├── rules/
    │   ├── testing.md      # 테스트 파일을 다룰 때만 적용
    │   └── api-design.md   # API 코드를 다룰 때만 적용
    ├── hooks/
    │   ├── block-secrets.sh    # 위험한 명령 차단 (deny와 2중 방어)
    │   └── format-on-save.sh   # 수정한 파일 자동 포맷
    ├── commands/
    │   ├── review.md       # /review
    │   └── test-fix.md     # /test-fix
    ├── output-styles/
    │   └── teaching.md     # 설명을 붙이는 응답 스타일 (/output-style teaching)
    ├── skills/
    └── agents/
```

## 기본 보안 설정

스택과 관계없이 아래 항목을 차단합니다. `settings.json`의 deny 규칙이 1차로 막고, deny가 놓치는 형태(`/bin/rm -rf`, `bash -c '...'`, `| sudo bash`, `cat .env` 등)는 `block-secrets.sh` 훅이 한 번 더 막습니다.

- `.env`, `*.pem`, `*.key` 파일 읽기
- `rm -rf`
- `git push --force`
- 파이프로 스크립트를 바로 실행하는 명령 (`curl ... | sh` 등)

## 기존 파일 처리

기존 `CLAUDE.md`나 `.claude/settings.json`이 있으면 덮어쓰지 않습니다. 백업, 병합, 건너뛰기 중 하나를 고를 수 있습니다. 그 밖의 파일은 이미 있으면 건너뜁니다.

## 알아 둘 점

- 프로젝트 `settings.json`의 허용 규칙과 훅은 Claude Code에서 폴더를 신뢰한 뒤에 적용됩니다. 차단(deny) 규칙은 바로 적용됩니다.
- `teaching` 응답 스타일은 `/output-style teaching`으로 직접 켜야 합니다.
- `.mcp.json`은 빈 목록으로 만들어집니다. 쓸 MCP 서버는 직접 추가하세요.

## 기여

이슈와 PR을 환영합니다. 새 스택 템플릿은 `references/stacks/`에 스택별 파일(기본 명령, `allow` 목록)로 추가하고, `references/stacks.md`의 스택별 파일 목록에 한 줄을 더해 주세요.

## 라이선스

[MIT](LICENSE)
