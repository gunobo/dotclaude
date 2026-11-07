# 추가 파일 템플릿

SKILL.md 3단계에서 기본 파일(CLAUDE.md, settings, commands)을 만든 뒤 이 파일의 템플릿으로 나머지를 만든다. 모든 파일은 이미 있으면 덮어쓰지 않고 건너뛴다.

## 목차
- [CLAUDE.local.md](#claudelocalmd)
- [.claude/rules/](#clauderules)
- [.claude/hooks/ 와 settings.json 등록](#claudehooks-와-settingsjson-등록)
- [.mcp.json](#mcpjson)
- [.worktreeinclude](#worktreeinclude)
- [.claude/output-styles/teaching.md](#claudeoutput-stylesteachingmd)

## CLAUDE.local.md

이 프로젝트에서 나만 쓰는 개인 지침이다. `CLAUDE.md`와 함께 읽히지만 커밋하지 않는다(`.gitignore`에 추가). 내용을 지어내지 말고 빈 틀만 만든다.

```markdown
# 개인 메모 (커밋하지 않음)

<!-- 이 프로젝트에서 나만 쓰는 지침을 적는다. 예: 로컬 테스트 URL, 선호하는 테스트 데이터 -->
```

## .claude/rules/

특정 파일을 다룰 때만 불러오는 규칙이다. `paths` frontmatter의 글롭에 맞는 파일을 Claude가 읽거나 수정할 때만 컨텍스트에 들어가므로, CLAUDE.md를 짧게 유지하는 데 도움이 된다.

`paths` 값은 `references/stacks/<스택>.md`의 "rules paths"를 그대로 쓴다. 스택 파일에 `api-design` 경로가 없으면(예: API가 없는 프로젝트) `api-design.md`는 만들지 않는다.

### `.claude/rules/testing.md`

```markdown
---
paths:
  - "<스택 파일의 testing 경로 1>"
  - "<스택 파일의 testing 경로 2>"
---

# 테스트 규칙

- 테스트를 바꾼 뒤에는 `<테스트 명령>`으로 통과를 확인한다.
- 실패하는 테스트를 지우거나 건너뛰게 만들어 통과시키지 않는다. 원인을 고친다.
- 새 기능이나 버그 수정에는 그 동작을 확인하는 테스트를 함께 추가한다.
- 테스트는 실행 순서, 현재 시각, 외부 네트워크에 의존하지 않게 쓴다.
```

### `.claude/rules/api-design.md`

```markdown
---
paths:
  - "<스택 파일의 api-design 경로 1>"
  - "<스택 파일의 api-design 경로 2>"
---

# API 규칙

- 모든 입력값을 검증한다. 검증 실패는 일관된 에러 응답 형식으로 돌려준다.
- 응답에 비밀번호 해시, 토큰, 내부 ID 같은 불필요한 데이터를 넣지 않는다.
- 인증이 필요한 엔드포인트는 권한 확인을 빠뜨리지 않는다.
- 응답 형식과 에러 형식은 기존 엔드포인트와 맞춘다. 정해진 형식이 없으면 사용자에게 묻는다.
```

## .claude/hooks/ 와 settings.json 등록

Claude Code는 `.claude/hooks/` 폴더를 자동으로 실행하지 않는다. 스크립트를 복사하는 것만으로는 아무 일도 일어나지 않고, **`settings.json`의 `hooks`에 등록해야** 동작한다.

**순서가 중요하다.** 스크립트 파일이 없는데 `settings.json`에 훅을 등록하면, Bash를 실행하거나 파일을 고칠 때마다 훅 오류가 난다. 그래서 반드시 스크립트를 먼저 만들고 확인한 뒤에 등록한다.

1. 이 스킬의 `assets/hooks/` 아래 두 파일을 프로젝트의 `.claude/hooks/`로 그대로 복사한다. 내용을 고치거나 다시 쓰지 않는다(테스트를 거친 파일이다).
   - `block-secrets.sh`: Bash 실행 전에 위험한 명령을 막는다. deny 규칙이 못 막는 `/bin/rm -rf`, `bash -c '...'`, `| sudo bash`, `cat .env`, `git push origin main --force` 같은 형태를 잡는 2중 방어다.
   - `format-on-save.sh`: Claude가 파일을 수정한 뒤 프로젝트에 설치된 포매터(ruff, 프로젝트의 prettier, gofmt)로 정리한다. 포매터가 없으면 아무것도 하지 않고, 실패해도 작업을 막지 않는다.
2. 실행 권한을 준다: `chmod +x .claude/hooks/*.sh`
3. 두 파일이 실제로 있고 실행 권한이 있는지 확인한다(`ls -l .claude/hooks/`). 하나라도 만들지 못했으면 그 훅은 등록하지 않고, 4단계 보고에 "훅 미등록"으로 적는다.
4. 확인된 훅만 `.claude/settings.json`에 아래 `hooks` 키로 넣는다. 기존 `hooks`가 있으면 같은 이벤트 배열에 항목을 추가하고, 같은 명령이 이미 있으면 넣지 않는다.

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/block-secrets.sh" }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/format-on-save.sh" }
      ]
    }
  ]
}
```

`${CLAUDE_PROJECT_DIR}`를 큰따옴표로 감싸는 이유: 프로젝트 경로에 공백이 있어도 스크립트를 찾게 하기 위해서다.

프로젝트 `settings.json`의 훅은 사용자가 폴더를 신뢰(workspace trust)한 뒤에 실행된다. 결과 보고에 이 점을 적는다.

## .mcp.json

팀이 함께 쓰는 MCP 서버(외부 도구 연결) 목록이다. 서버를 지어내지 말고 빈 목록으로 만든다. 사용자가 쓸 서버를 말하면 그때 넣는다.

```json
{
  "mcpServers": {}
}
```

서버를 넣을 때 토큰이나 키는 파일에 직접 쓰지 말고 `${API_KEY}`처럼 환경 변수로 참조하게 안내한다. 프로젝트 `.mcp.json`의 서버는 처음 쓸 때 사용자 승인을 받는다.

## .worktreeinclude

Claude가 git worktree를 만들 때 함께 복사할 파일 목록이다(gitignore 문법). git이 무시하는 파일만 복사되므로 커밋된 파일은 중복되지 않는다. worktree에서도 로컬 환경 변수 파일이 필요하기 때문에 넣는다.

```
.env
.env.*
```

## .claude/output-styles/teaching.md

설명을 더 붙여서 답하는 응답 스타일이다. **파일을 만드는 것만으로는 아무것도 바뀌지 않는다.** 사용자가 `/output-style teaching`으로 직접 켜야 한다. `settings.json`에 `outputStyle`을 넣어 강제로 켜지 않는다.

```markdown
---
name: teaching
description: 변경할 때마다 이유와 배경을 짧게 설명한다
keep-coding-instructions: true
---

코드를 바꾸거나 명령을 실행할 때 다음을 덧붙인다.

- 왜 이렇게 했는지 한두 문장으로 설명한다. 다른 방법이 있었다면 왜 이 방법을 골랐는지도 적는다.
- 처음 보는 사람이 모를 수 있는 용어는 짧게 풀어 쓴다.
- 설명은 대화에만 쓰고, 코드 주석으로 넣지 않는다.
```
