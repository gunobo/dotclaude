# 기타

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

위 스택에 해당하지 않으면 기본값을 지어내지 않는다.

1. 사용자에게 빌드·테스트·린트 명령을 직접 받는다. 없다고 하면 그 항목은 비워 둔다.
2. 받은 명령마다 `Bash(<명령> *)` 형식의 `allow` 규칙을 만든다. 예: `make test` → `Bash(make test *)`, `cargo test` → `Bash(cargo test *)`.
3. 명령이 러너(`npx`, `uv run`, `docker exec` 등)로 시작하면 러너만 열지 말고 실제 명령까지 포함한다.
4. 의존성 설치 명령은 받더라도 `allow`에 넣지 않는다.
5. rules paths: 사용자에게 테스트 파일과 API 코드가 있는 위치를 묻고 글롭으로 만든다. 예: `"tests/**/*"`, `"src/api/**/*"`. API가 없으면 `api-design.md`는 만들지 않는다.
