# dotclaude 스킬 명세

## 배포 정보
- 저장소: `gunobo/dotclaude`
- 공개 여부: 공개 (Public)
- 설명 (Repo description): Claude Code 프로젝트용 `.claude` 폴더와 `CLAUDE.md`를 스택별 표준 구조로 만드는 스킬
- 라이선스: MIT
- 토픽: `claude-code`, `claude-skills`, `project-setup`

## 목적
새 프로젝트에서 Claude Code를 바로 쓸 수 있도록 `.claude` 폴더와 `CLAUDE.md`를 표준 구조로 만든다.

## 대상
스택을 가리지 않는 범용 공개 스킬.

## 입력
- 프로젝트 이름
- 스택 (Python, Node/TypeScript, React/Vite, Next.js, Go, 기타)
- 빌드·테스트·린트 명령 (스택 기본값 제안 후 수정)
- 팀 공유 여부

## 출력
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

## 규칙
- 보안 차단은 스택과 무관하게 항상 적용한다 (`.env`, 키 파일, `rm -rf`, 강제 푸시, 파이프 실행). `settings.json`의 deny와 `block-secrets.sh` 훅으로 2중 적용한다.
- 훅은 `settings.json`의 `hooks`에 등록해야 동작한다. 스크립트만 복사하지 않는다.
- 스택별 명령과 허용 목록은 `references/stacks.md`를 따른다.
- 기존 `CLAUDE.md`, `settings.json`은 덮어쓰지 않는다. 백업, 병합, 건너뛰기 중 하나를 묻는다. 그 밖의 파일은 이미 있으면 건너뛴다.
- `CLAUDE.md`는 200줄을 넘기지 않는다.

## 범위 밖
- 프로젝트 코드 생성
- `.claude/agent-memory/`, `.claude/workflows/` (Claude Code가 직접 만든다)
- MCP 서버 내용 채우기 (`.mcp.json`은 빈 목록으로만 만든다)
- 의존성 설치 실행
- Git 원격 저장소 설정

## 파일 구성
- `SKILL.md`: 실행 절차
- `references/stacks.md`, `references/stacks/`: 스택별 기본값
- `references/templates.md`: rules, hooks, CLAUDE.local.md, .mcp.json, .worktreeinclude, output-styles 템플릿
- `assets/hooks/`: 훅 스크립트 원본
- `README.md`: 설치와 사용 안내
- `LICENSE`: MIT 라이선스 전문
