# Python

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

기본 명령:
- 빌드: `python -m build`
- 테스트: `pytest`
- 린트: `ruff check .`
- 포맷: `ruff format .`

`allow`:
```json
[
  "Bash(python -m build *)",
  "Bash(pytest *)",
  "Bash(python -m pytest *)",
  "Bash(ruff check *)",
  "Bash(ruff format *)"
]
```

uv를 쓰는 프로젝트(`uv.lock` 있음)면 명령 앞에 `uv run`을 붙이고 `allow`도 `Bash(uv run pytest *)`, `Bash(uv run ruff check *)`, `Bash(uv run ruff format *)`, `Bash(uv build *)`로 바꾼다.

rules paths (`.claude/rules/`의 `paths` 값):
- testing: `"tests/**/*.py"`, `"**/test_*.py"`, `"**/*_test.py"`
- api-design: `"**/api/**/*.py"`, `"**/routers/**/*.py"`, `"**/routes/**/*.py"`
