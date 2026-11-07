---
name: dotclaude
description: 새 프로젝트에서 Claude Code를 바로 쓸 수 있도록 `.claude` 폴더(settings.json, settings.local.json, commands, skills, agents)와 `CLAUDE.md`, `.gitignore` 항목을 스택별 표준 구조로 만든다. Python, Node/TypeScript, React/Vite, Next.js, Go, 기타 스택의 빌드·테스트·린트 명령과 권한 허용 목록을 넣고, `.env`·키 파일 읽기, `rm -rf`, 강제 푸시, 파이프 실행 차단을 항상 settings.json에 적용한다. "프로젝트 초기화", "프로젝트 초기화해줘", ".claude 만들어줘", ".claude 폴더 세팅", "새 프로젝트 세팅", "CLAUDE.md 만들어줘", "Claude Code 설정 잡아줘"처럼 프로젝트에 Claude Code 설정을 처음 갖추려는 요청이면 사용자가 스킬 이름을 말하지 않아도 이 스킬을 사용한다.
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
- `settings.json`: JSON으로 읽어 `permissions.allow`, `permissions.deny` 배열을 합집합으로 만든다(중복 제거). `Read(!.env.example)`은 `Read(./.env*)` 뒤에 오도록 순서를 지킨다. 기존의 다른 키는 그대로 둔다. 아래 보안 차단 항목은 병합 결과의 `deny`에 반드시 있어야 한다. 기존 `allow`에 보안 차단과 겹치는 규칙이 있으면 지우지 말고 사용자에게 알린다(deny가 allow보다 우선하므로 차단은 유지된다).
- `CLAUDE.md`: 기존 내용은 그대로 두고, 아래 템플릿에서 기존 파일에 없는 섹션만 끝에 덧붙인다. 병합 결과도 200줄을 넘기면 안 된다. 넘으면 덧붙일 섹션을 줄이고 그 사실을 알린다.
- 건너뛰기를 고른 `settings.json`에 보안 차단 항목이 빠져 있으면, 빠진 항목을 목록으로 보여 주고 직접 추가하라고 안내한다.

그 밖의 파일:
- `.gitignore`: 있으면 빠진 줄만 끝에 추가하고, 없으면 새로 만든다.
- `.claude/settings.local.json`, `.claude/commands/review.md`, `.claude/commands/test-fix.md`: 이미 있으면 덮어쓰지 않고 건너뛴 뒤 결과 보고에 적는다.

## 3단계: 파일 생성

### 생성 구조

```
<project>/
├── CLAUDE.md
├── .gitignore              # settings.local.json, .env 제외 추가
└── .claude/
    ├── settings.json       # 권한 (커밋)
    ├── settings.local.json # 개인 설정 (커밋 제외)
    ├── commands/review.md
    ├── commands/test-fix.md
    ├── skills/
    └── agents/
```

`skills/`와 `agents/`는 빈 폴더다. Git이 빈 폴더를 추적하지 않으므로 각각 빈 `.gitkeep` 파일을 넣는다.

### 보안 기본값 (스택과 무관하게 항상 적용)

아래 차단 규칙은 `.claude/settings.json`의 `permissions.deny`에 **반드시** 넣는다. `CLAUDE.md` 같은 마크다운 규칙 파일에만 적으면 Claude가 참고만 할 뿐 실제로 막히지 않는다. 실제 차단은 settings.json의 deny 규칙이 한다.

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
  }
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
2. 다음 관점에서 문제를 찾는다: 버그, 보안(비밀값 노출, 입력 검증), 에러 처리, 테스트 누락, CLAUDE.md의 코드 규칙 위반.
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

**200줄을 넘기지 않는다.** CLAUDE.md는 매 세션 컨텍스트에 통째로 들어가므로 길수록 비용이 들고 중요한 규칙이 묻힌다. 프로젝트 구조를 아직 모르면 비워 두고, 지어내서 채우지 않는다.

```markdown
# <프로젝트 이름>

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

## 보안
- `.env`, `*.pem`, `*.key` 파일은 읽지 않는다. (`.claude/settings.json`의 deny로 차단됨)
- `rm -rf`, `git push --force`, `curl ... | sh` 같은 파이프 실행은 쓰지 않는다. (deny로 차단됨)

## Claude Code 설정
- `.claude/settings.json`: 팀 공유 권한 (커밋)
- `.claude/settings.local.json`: 개인 설정 (커밋 제외)
- `.claude/commands/`: `/review`, `/test-fix`
- `.claude/skills/`, `.claude/agents/`: 프로젝트 전용 스킬과 에이전트
```

## 4단계: 확인과 보고

파일을 다 쓴 뒤 다음을 확인한다.
- `settings.json`, `settings.local.json`이 올바른 JSON인지 (예: `python3 -m json.tool <파일>`)
- `settings.json`의 `deny`에 보안 기본값이 모두 있는지
- `CLAUDE.md`가 200줄 이하인지 (`wc -l CLAUDE.md`)

그리고 사용자에게 다음을 알린다.
- 만든 파일, 병합한 파일, 백업 파일 경로, 건너뛴 파일
- 적용한 스택과 명령
- deny 규칙의 한계: Bash 규칙은 Claude가 쓴 명령 텍스트에 맞춰 보는 것이라 `/bin/rm -rf`, `sh -c '...'` 같은 다른 형태는 막지 못한다. 더 강한 보장이 필요하면 Claude Code의 샌드박스나 PreToolUse 훅을 검토하라고 안내한다.
