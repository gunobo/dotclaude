#!/usr/bin/env bash
# PreToolUse(Bash) 훅: settings.json deny 규칙이 놓치는 위험한 명령을 한 번 더 막는다.
# - deny는 Claude가 쓴 명령 텍스트를 하위 명령 단위로 맞춰 보므로 /bin/rm, sh -c '...',
#   | sudo bash, cat .env 같은 형태는 통과할 수 있다. 이 훅이 그 빈틈을 메운다.
# - 막을 때는 exit 2 + stderr 메시지 (Claude Code가 호출을 차단하고 이유를 Claude에게 보여 준다).
# - 검사는 bash 내장 정규식([[ =~ ]])만 쓴다. grep 같은 외부 명령이 없어도 차단이 풀리지 않게 하기 위해서다.
# - 명령 추출은 jq, python3, node 중 있는 것을 쓰고, 모두 없으면 입력 전체를 검사한다.

IFS= read -r -d '' input || true

extract_command() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null && return
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: pass' 2>/dev/null && return
  fi
  if command -v node >/dev/null 2>&1; then
    printf '%s' "$input" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write((JSON.parse(s).tool_input||{}).command||"")}catch(e){}})' 2>/dev/null && return
  fi
  return 1
}

cmd="$(extract_command)"
# 명령을 꺼내지 못하면 입력 전체를 검사한다 (놓치는 것보다 과하게 막는 편이 안전하다).
#     이때 JSON의 따옴표·역슬래시·중괄호·쉼표를 공백으로 바꿔야 단어 경계 검사가 제대로 동작한다.
if [ -z "$cmd" ]; then
  cmd="${input//[\"\\\{\},]/ }"
fi

block() {
  echo "dotclaude block-secrets 훅이 차단함: $1" >&2
  echo "필요한 작업이면 사용자에게 직접 실행해 달라고 요청하세요." >&2
  exit 2
}

has() { [[ $cmd =~ $1 ]]; }

# 1) rm 재귀+강제 삭제 (-rf, -fr, -r -f, --recursive --force, /bin/rm 포함)
if has '(^|[^[:alnum:]_.-])rm[[:space:]]'; then
  if has '[[:space:]](-[[:alnum:]]*[rR][[:alnum:]]*|--recursive)([[:space:]]|$)' \
     && has '[[:space:]](-[[:alnum:]]*f[[:alnum:]]*|--force)([[:space:]]|$)'; then
    block "rm 재귀 강제 삭제(rm -rf 계열)"
  fi
fi

# 2) git push 강제 푸시 (--force, --force-with-lease, -f, git -C 경로 push 포함)
if has '(^|[^[:alnum:]_.-])git[[:space:]]([^;&|]*[[:space:]])?push([[:space:]]|$)'; then
  if has 'push([[:space:]][^;&|]*)?[[:space:]](--force[[:alnum:]=-]*|-[[:alnum:]]*f[[:alnum:]]*)([[:space:]]|$)'; then
    block "git 강제 푸시"
  fi
fi

# 3) 내려받은 스크립트를 바로 실행 (| sh, | sudo bash, sh -c "$(curl ...)", bash <(curl ...))
shells='(sh|bash|zsh|dash|ksh)'
if has "\|[[:space:]]*(sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*)?(env[[:space:]]+)?(/usr/local/bin/|/usr/bin/|/bin/)?${shells}([[:space:]]|$)" \
   || has "${shells}[[:space:]]+-c[[:space:]]+[\"']?[^\"']*\\$\\([[:space:]]*(curl|wget)" \
   || has "<\\([[:space:]]*(curl|wget)"; then
  block "다운로드한 스크립트를 셸로 바로 실행(curl/wget | sh 계열)"
fi

# 4) 셸 명령으로 비밀 파일 읽기 (.env, *.pem, *.key). .env.example/.sample/.template/.dist는 허용.
readers='(cat|less|more|head|tail|grep|egrep|fgrep|rg|sed|awk|source|base64|xxd|od|strings|nl|bat|cp|scp|rsync|tar|zip|curl|open|vi|vim|nano)'
if has "(^|[;&|[:space:](])(\\.|${readers})[[:space:]]"; then
  # 비밀값이 없는 템플릿 파일 이름을 먼저 지운 뒤 남은 .env 를 찾는다.
  # 예: .env.example, .env.local.example, .env.production.sample
  rest="$cmd"
  safe_re='(\.env[[:alnum:]_.-]*\.(example|sample|template|dist))'
  while [[ $rest =~ $safe_re ]]; do rest="${rest//"${BASH_REMATCH[1]}"/ }"; done
  env_re="(^|[[:space:]/'\"=<@])\\.env(\\.[[:alnum:]_.-]+)?([[:space:]'\";|&)>]|$)"
  key_re="[^[:space:]'\"]\\.(pem|key)([[:space:]'\";|&)>]|$)"
  if [[ $rest =~ $env_re ]] || has "$key_re"; then
    block "셸 명령으로 비밀 파일(.env, *.pem, *.key) 읽기"
  fi
fi

exit 0
