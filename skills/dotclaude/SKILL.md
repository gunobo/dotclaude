---
name: dotclaude
description: 새 프로젝트에서 Claude Code를 바로 쓸 수 있도록 `.claude` 폴더(settings.json, settings.local.json, rules, hooks, commands, skills, agents, output-styles)와 `CLAUDE.md`, `CLAUDE.local.md`, `.mcp.json`, `.worktreeinclude`, `.gitignore` 항목을 스택별 표준 구조로 만든다. Python, Node/TypeScript, React/Vite, Next.js, Go, 기타 스택의 빌드·테스트·린트 명령과 권한 허용 목록을 넣고, `.env`·키 파일 읽기, `rm -rf`, 강제 푸시, 파이프 실행 차단을 settings.json deny와 PreToolUse 훅으로 항상 적용한다. "프로젝트 초기화", "프로젝트 초기화해줘", ".claude 만들어줘", ".claude 폴더 세팅", "새 프로젝트 세팅", "CLAUDE.md 만들어줘", "Claude Code 설정 잡아줘"처럼 프로젝트에 Claude Code 설정을 처음 갖추려는 요청이면 사용자가 스킬 이름을 말하지 않아도 이 스킬을 사용한다.
---

# dotclaude

새 프로젝트에 Claude Code용 `.claude` 폴더와 `CLAUDE.md`를 표준 구조로 만든다.

## 범위

하는 일: 아래 "생성 구조"의 파일과 폴더를 만들고 내용을 채운다.

하지 않는 일 (요청받아도 이 스킬의 범위 밖이라고 알린다):
- 프로젝트 코드 생성
- 의존성 설치 실행 (`npm install`, `pip install`, `go mod download` 등)
- Git 원격 저장소 설정

## 1단계: 입력 받기

다음을 묻는다. 이미 대화나 프로젝트 파일에서 알 수 있는 값은 확인만 받는다.

1. **프로젝트 이름**
2. **스택**: Python, Node/TypeScript, React/Vite, Next.js, Go, 기타 중 하나
3. **빌드·테스트·린트 명령**: `references/stacks/`에서 고른 스택 파일의 기본값을 먼저 제안하고, 사용자가 고칠 수 있게 한다
4. **팀 공유 여부**: 팀이 `.claude/settings.json`을 함께 쓰는지

스택별 기본 명령과 `allow` 목록은 반드시 다음 순서로 읽고 적용한다. 기억에 의존해 명령을 만들지 않는다.

1. [references/stacks.md](references/stacks.md): 모든 스택의 공통 원칙과 스택별 파일 목록
2. 고른 스택의 파일 하나만: `references/stacks/` 아래 `python.md`, `node-typescript.md`, `react-vite.md`, `nextjs.md`, `go.md`, `other.md`(기타). 표준이 아닌 스택이면 `other.md`의 절차를 따른다.

사용자가 명령을 바꾸면 `allow` 목록도 바뀐 명령에 맞게 다시 만든다. 허용 목록은 실제로 쓰는 명령과 일치해야 의미가 있다.

## 2단계: 기존 파일 확인

파일을 쓰기 전에 프로젝트 루트에서 다음을 확인한다.

- `CLAUDE.md` 또는 `.claude/CLAUDE.md` (Claude Code는 두 위치 모두 프로젝트 지침으로 읽고, 둘 다 있으면 함께 불러온다)
- `.claude/settings.json`

하나라도 있으면 **덮어쓰지 않는다.** `.claude/CLAUDE.md`만 있으면 루트에 `CLAUDE.md`를 새로 만들지 않는다. 지침이 두 벌이 되기 때문이다. 이때는 `.claude/CLAUDE.md`를 기존 `CLAUDE.md`로 보고 아래 선택지를 적용한다. 파일마다 다음 셋 중 하나를 사용자에게 묻고, 답을 받은 뒤에만 진행한다.

| 선택 | 동작 |
| --- | --- |
| 백업 | 기존 파일을 `<파일명>.bak-YYYYMMDD-HHMMSS`로 복사한 뒤 새 파일을 쓴다 |
| 병합 | 기존 내용을 유지하고 빠진 부분만 더한다 (아래 병합 규칙) |
| 건너뛰기 | 그 파일은 손대지 않는다 |

병합 규칙:
- `settings.json`: JSON으로 읽어 `permissions.allow`, `permissions.deny` 배열을 합집합으로 만든다(중복 제거). `Read(!.env.example)`은 `Read(./.env*)` 뒤에 오도록 순서를 지킨다. `hooks`는 이벤트별 배열에 이 스킬의 항목을 추가하되, 같은 명령이 이미 있으면 넣지 않는다. 기존의 다른 키는 그대로 둔다. 아래 보안 차단 항목은 병합 결과의 `deny`에 반드시 있어야 한다. 기존 `allow`에 보안 차단과 겹치는 규칙이 있으면 지우지 말고 사용자에게 알린다(deny가 allow보다 우선하므로 차단은 유지된다).
- `CLAUDE.md`: 기존 내용은 그대로 두고, 아래 템플릿에서 기존 파일에 없는 섹션만 끝에 덧붙인다. 병합 결과도 200줄을 넘기면 안 된다. 넘으면 덧붙일 섹션을 줄이고 그 사실을 알린다.
- 건너뛰기를 고른 `settings.json`에 보안 차단 항목이 빠져 있으면, 빠진 항목을 목록으로 보여 주고 직접 추가하라고 안내한다.

그 밖의 파일:
- `.gitignore`: 있으면 빠진 줄만 끝에 추가하고, 없으면 새로 만든다.
- 위 두 파일과 `.gitignore`를 뺀 나머지 생성 파일(`.claude/settings.local.json`, `commands/`, `rules/`, `hooks/`, `output-styles/`, `CLAUDE.local.md`, `.mcp.json`, `.worktreeinclude`): 이미 있으면 덮어쓰지 않고 건너뛴 뒤 결과 보고에 적는다.
- `AGENTS.md`: Codex, Cursor 같은 다른 도구용 지침 파일이다. 손대지 않는다. 다만 Claude Code는 `CLAUDE.md`가 있으면 `AGENTS.md`를 읽지 않으므로, `AGENTS.md`가 있으면 새로 쓰거나 병합하는 `CLAUDE.md`의 제목 바로 아래에 `@AGENTS.md` 한 줄을 넣어 불러오게 한다(이미 있으면 넣지 않는다). 백틱이나 코드 블록 안에 쓰면 불러오지 않으므로 맨 글자로 쓴다. 그래야 기존 지침이 조용히 무시되지 않는다. 결과 보고에 이 사실을 적는다.

## 3단계: 파일 생성

시작하기 전에 사용자에게 알린다: Claude Code는 `.claude/` 폴더와 `.mcp.json`을 보호 경로로 다뤄서, 쓸 때마다 승인을 묻는다. 첫 승인 창에서 "이 세션 동안 이 프로젝트의 .claude 폴더 편집 허용"을 고르면 나머지는 다시 묻지 않는다. 승인이 거부된 파일은 건너뛰고, 4단계 보고에 만들지 못한 파일로 적는다.

### 생성 구조

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
    ├── rules/testing.md    # 테스트 파일을 다룰 때만 적용
    ├── rules/api-design.md # API 코드를 다룰 때만 적용
    ├── hooks/block-secrets.sh   # 위험한 명령 차단 (2중 방어)
    ├── hooks/format-on-save.sh  # 수정한 파일 자동 포맷
    ├── commands/review.md
    ├── commands/test-fix.md
    ├── output-styles/teaching.md # 설명을 붙이는 응답 스타일 (직접 켜야 함)
    ├── skills/
    └── agents/
```

`skills/`와 `agents/`는 빈 폴더다. Git이 빈 폴더를 추적하지 않으므로 각각 빈 `.gitkeep` 파일을 넣는다.

만들지 않는 것: `.claude/agent-memory/`(서브에이전트가 메모리를 쓸 때 Claude Code가 직접 만든다), `.claude/workflows/`(`/workflows`에서 Claude가 작성해 저장한다). 빈 틀을 미리 만들어도 쓸모가 없다.

이 절의 기본 파일(settings, `.gitignore`, commands, `CLAUDE.md`)을 만든 뒤, 나머지 파일은 [references/templates.md](references/templates.md)를 읽고 그 템플릿대로 만든다. 훅 스크립트는 이 스킬의 `assets/hooks/`에 있는 파일을 그대로 복사한다.

**훅 순서:** 훅 스크립트를 먼저 복사하고 실행 권한까지 확인한 다음에 `settings.json`에 `hooks`를 등록한다. 스크립트 없이 등록만 되면 Bash를 실행하거나 파일을 고칠 때마다 훅 오류가 난다. 그래서 `settings.json`은 처음에 `permissions`만 넣어 쓰고, 훅 확인이 끝난 뒤 `hooks`를 추가한다.

### 보안 기본값 (스택과 무관하게 항상 적용)

아래 차단 규칙은 `.claude/settings.json`의 `permissions.deny`에 **반드시** 넣는다. `CLAUDE.md` 같은 마크다운 규칙 파일에만 적으면 Claude가 참고만 할 뿐 실제로 막히지 않는다. 실제 차단은 settings.json의 deny 규칙이 하고, deny가 놓치는 형태는 `block-secrets.sh` 훅이 한 번 더 막는다.

```json
"deny": [
  "Read(./.env*)",
  "Read(!.env.example)",
  "Read(**/*.pem)",
  "Read(**/*.key)",
  "Bash(rm -rf *)",
  "Bash(rm -fr *)",
  "Bash(git push --force*)",
  "Bash(git push * --force*)",
  "Bash(git push -f*)",
  "Bash(git push * -f)",
  "Bash(sh)",
  "Bash(bash)",
  "Bash(zsh)",
  "Bash(sh -s *)",
  "Bash(bash -s *)",
  "Bash(zsh -s *)"
]
```

규칙 문법에 대한 근거 (Claude Code 권한 문서 기준):
- `Read(...)`는 gitignore 패턴이다. `./.env*`는 현재 디렉터리의 `.env`, `.env.local` 등을, `**/*.pem`, `**/*.key`는 모든 깊이의 키 파일을 막는다.
- `Read(!.env.example)`는 gitignore 부정 패턴으로, 같은 파일의 `deny` 목록에서 **앞에 나온** 규칙에서만 `.env.example`을 빼 준다. 그래서 반드시 `Read(./.env*)` 뒤에 둔다. `.env.example`은 비밀값이 없는 템플릿이라 커밋하고(`.gitignore`의 `!.env.example`), Claude도 변수 이름을 알려면 읽을 수 있어야 한다.
- `Bash(rm -rf *)`처럼 끝의 ` *`(앞에 공백)는 인자 없는 형태도 함께 막는다. `Bash(git push --force*)`는 `*` 앞에 공백이 없어 `--force-with-lease`도 막는다. 플래그가 뒤에 오는 `git push origin main --force`와 `-f` 형태는 별도 규칙으로 막는다.
- **파이프 실행 차단**: Claude Code는 `|`, `&&`, `;` 등에서 명령을 하위 명령으로 나눠 규칙을 맞춰 보고, deny는 하위 명령 중 하나만 맞아도 적용된다. 그래서 `Bash(curl * | sh)`처럼 파이프를 포함한 패턴은 어떤 명령에도 맞지 않아 효과가 없다. 대신 파이프를 받는 쪽인 `sh`, `bash`, `zsh`(인자 없이 또는 `-s`로 표준 입력을 실행하는 형태)를 막는다. 이렇게 하면 `curl ... | sh`, `wget -qO- ... | bash`가 차단되고, `bash scripts/build.sh` 같은 일반 스크립트 실행은 막지 않는다.

### `.claude/settings.json`

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [ <references/stacks/<스택>.md의 allow 목록> ],
    "deny": [ <위 보안 기본값 전체> ]
  },
  "hooks": { <references/templates.md의 hooks 설정> }
}
```

팀 공유 여부에 따라 `allow`를 둘 위치를 정한다.
- **팀 공유**: 스택 `allow` 목록을 `settings.json`에 넣는다. 팀 전체가 같은 명령을 승인 없이 쓴다.
- **개인 사용**: 스택 `allow` 목록을 `settings.local.json`에 넣고, `settings.json`의 `allow`는 빈 배열로 둔다.
- 어느 쪽이든 `deny`는 항상 `settings.json`에 둔다.

### `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": []
  }
}
```

개인 사용이면 위 `allow`에 스택 목록을 넣는다. 이 파일에는 deny를 옮기지 않는다(커밋되지 않아 팀원에게 적용되지 않기 때문).

### `.gitignore`에 추가할 줄

```
# Claude Code
.claude/settings.local.json
.claude/*.bak-*
.claude/worktrees/
CLAUDE.local.md
CLAUDE.md.bak-*

# 환경 변수
.env
.env.*
!.env.example
```

### `.claude/commands/review.md`

```markdown
---
description: 현재 변경 사항을 리뷰한다
---

현재 작업 중인 변경 사항을 리뷰해줘.

1. `git diff`와 `git diff --staged`로 변경 내용을 확인한다.
2. 다음 관점에서 문제를 찾는다:
   - 버그, 에러 처리, 테스트 누락, CLAUDE.md의 규칙 위반
   - 보안: 인증·세션·토큰 처리, 응답에 불필요한 데이터 노출, 입력값 검증(SQL 인젝션, XSS 포함), 하드코딩된 비밀값, 알려진 취약점이 있는 의존성
   - 인증, 비밀값, 개인정보를 다루는 부분은 사람이 직접 한 번 더 확인해야 한다고 따로 표시한다. 이 리뷰는 1차 점검일 뿐이다.
3. `<린트 명령>`을 실행해 결과를 함께 본다.
4. 발견한 문제를 심각도 순으로 `파일:줄` 형식과 함께 정리한다. 고치지는 말고 보고만 한다.
```

### `.claude/commands/test-fix.md`

```markdown
---
description: 테스트를 실행하고 실패를 고친다
---

테스트를 실행하고 실패하는 테스트를 고쳐줘.

1. `<테스트 명령>`을 실행한다.
2. 실패가 있으면 원인을 찾아 코드를 고친다. 테스트를 지우거나 건너뛰게 만들어 통과시키지 않는다.
3. 다시 `<테스트 명령>`을 실행해 통과를 확인한다. 모두 통과할 때까지 반복한다.
4. 마지막에 `<린트 명령>`도 실행한다.
5. 무엇을 왜 고쳤는지 요약한다.
```

`<테스트 명령>`, `<린트 명령>`은 1단계에서 확정한 명령으로 바꾼다.

### `CLAUDE.md`

**200줄을 넘기지 않는다.** CLAUDE.md는 매 세션 컨텍스트에 통째로 들어가므로 길수록 비용이 들고 중요한 규칙이 묻힌다. 프로젝트 구조를 아직 모르면 비워 두고, 지어내서 채우지 않는다. 세션마다 내용이 늘어나는 "작업 로그" 같은 섹션은 만들지 않는다. 시간이 지나면 200줄 제한을 반드시 넘기기 때문이다.

```markdown
# <프로젝트 이름>

<AGENTS.md가 있을 때만 이 줄을 @AGENTS.md 로 바꾼다(백틱 없이). 없으면 이 줄을 지운다.>

<한두 줄 설명. 모르면 사용자에게 묻거나 비워 둔다.>

## 스택
- <스택>

## 명령
- 빌드: `<빌드 명령>`
- 테스트: `<테스트 명령>`
- 린트: `<린트 명령>`

## 작업 규칙
- 코드를 바꾼 뒤에는 테스트와 린트를 실행해 통과를 확인한다.
- 커밋 전에 `/review`로 변경 사항을 점검한다.
- 테스트가 실패하면 `/test-fix`를 사용한다.
- 새 라이브러리나 의존성을 추가하기 전에 먼저 묻는다.

## 의도적으로 안 하는 것
- <지금 단계에서 일부러 만들지 않는 기능. 모르면 사용자에게 묻거나 비워 둔다.>

## 보안
- `.env`, `*.pem`, `*.key` 파일은 읽지 않는다. (settings.json deny와 block-secrets 훅으로 차단됨)
- `rm -rf`, `git push --force`, `curl ... | sh` 같은 파이프 실행은 쓰지 않는다. (deny와 훅으로 차단됨)

## Claude Code 설정
- `.claude/settings.json`: 팀 공유 권한과 훅 등록 (커밋)
- `.claude/settings.local.json`, `CLAUDE.local.md`: 개인 설정과 지침 (커밋 제외)
- `.claude/rules/`: 테스트·API 파일을 다룰 때만 적용되는 규칙
- `.claude/hooks/`: 위험한 명령 차단, 수정한 파일 자동 포맷
- `.claude/commands/`: `/review`, `/test-fix`
- `.claude/output-styles/`: `/output-style teaching`으로 켜는 설명형 응답
- `.claude/skills/`, `.claude/agents/`: 프로젝트 전용 스킬과 에이전트
- `.mcp.json`: 팀 공유 MCP 서버
```

## 4단계: 확인과 보고

파일을 다 쓴 뒤 다음을 확인한다.
- `settings.json`, `settings.local.json`, `.mcp.json`이 올바른 JSON인지 (예: `python3 -m json.tool <파일>`)
- `settings.json`의 `deny`에 보안 기본값이 모두 있고, `hooks`에 두 훅이 등록됐는지
- 훅 스크립트에 실행 권한이 있고 실제로 막는지:
  `echo '{"tool_input":{"command":"cat \u002eenv"}}' | .claude/hooks/block-secrets.sh; echo $?` 가 `2`이고,
  `echo '{"tool_input":{"command":"ls"}}' | .claude/hooks/block-secrets.sh; echo $?` 가 `0`인지
  (`\u002e`는 점(.)의 JSON 표기다. 확인 명령에 `.env`를 그대로 쓰면 이미 켜진 훅이 이 확인 명령 자체를 막는다.)
- `CLAUDE.md`가 200줄 이하인지 (`wc -l CLAUDE.md`)

그리고 사용자에게 다음을 알린다.
- 만든 파일, 병합한 파일, 백업 파일 경로, 건너뛴 파일 (`AGENTS.md`를 `@AGENTS.md`로 불러오게 했다면 그 사실도)
- 적용한 스택과 명령
- 프로젝트 `settings.json`의 `allow` 규칙과 훅은 폴더를 신뢰(workspace trust)한 뒤에 적용된다. `deny`는 바로 적용된다.
- `teaching` 응답 스타일은 `/output-style teaching`으로 직접 켜야 한다.
- 차단의 한계: deny 규칙과 훅 모두 명령 텍스트를 보고 판단하므로 변수나 스크립트 파일 안에 숨긴 명령까지 막지는 못한다. 더 강한 보장이 필요하면 Claude Code의 샌드박스를 검토하라고 안내한다.
