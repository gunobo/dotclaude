#!/usr/bin/env bash
# PostToolUse(Edit|Write) 훅: Claude가 수정한 파일을 프로젝트 포매터로 정리한다.
# - 포매터가 설치돼 있을 때만 실행하고, 없으면 아무것도 하지 않는다 (설치나 다운로드를 하지 않는다).
# - 포맷 실패가 작업을 막으면 안 되므로 항상 exit 0으로 끝낸다.

IFS= read -r -d '' input || true

get_field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null && return
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c 'import json,sys
keys=sys.argv[1].lstrip(".").split(".")
try:
  v=json.load(sys.stdin)
  for k in keys: v=v.get(k,"") if isinstance(v,dict) else ""
  print(v or "")
except Exception: pass' "$1" 2>/dev/null && return
  fi
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$input" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{let v=JSON.parse(s);for(const k of process.argv[1].replace(/^\./,"").split("."))v=(v||{})[k];process.stdout.write(v?String(v):"")}catch(e){}})' "$1" 2>/dev/null && return
  fi
}

file="$(get_field '.tool_input.file_path')"
[ -n "$file" ] && [ -f "$file" ] || exit 0

root="${CLAUDE_PROJECT_DIR:-$(get_field '.cwd')}"
[ -n "$root" ] || root="$(pwd)"

case "$file" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format --quiet "$file" >/dev/null 2>&1
    elif [ -x "$root/.venv/bin/ruff" ]; then
      "$root/.venv/bin/ruff" format --quiet "$file" >/dev/null 2>&1
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.html|*.vue|*.svelte)
    # npx는 패키지를 내려받을 수 있으므로 쓰지 않는다. 프로젝트에 설치된 prettier만 쓴다.
    if [ -x "$root/node_modules/.bin/prettier" ]; then
      "$root/node_modules/.bin/prettier" --write --log-level silent "$file" >/dev/null 2>&1
    fi
    ;;
  *.go)
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$file" >/dev/null 2>&1
    fi
    ;;
esac

exit 0
