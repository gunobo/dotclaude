# 스택별 기본값

모든 스택에 적용하는 공통 원칙과 스택별 파일 목록이다. 이 파일을 먼저 읽고, 그다음 고른 스택의 파일 하나만 읽는다. 명령은 기본값이므로 사용자에게 먼저 제안하고 수정을 받는다.

## 스택별 파일

| 스택 | 파일 |
| --- | --- |
| Python | [stacks/python.md](stacks/python.md) |
| Node/TypeScript | [stacks/node-typescript.md](stacks/node-typescript.md) |
| React/Vite | [stacks/react-vite.md](stacks/react-vite.md) |
| Next.js | [stacks/nextjs.md](stacks/nextjs.md) |
| Go | [stacks/go.md](stacks/go.md) |
| 기타 | [stacks/other.md](stacks/other.md) |

새 스택을 추가할 때는 `stacks/`에 같은 형식(기본 명령, `allow` 목록)의 파일을 만들고 위 표에 한 줄을 더한다.

## 공통 원칙

- 보안 차단(`deny`)은 여기서 다루지 않는다. SKILL.md의 보안 기본값을 모든 스택에 똑같이 적용한다.
- `allow`에는 빌드·테스트·린트·포맷처럼 자주 쓰고 되돌리기 쉬운 명령만 넣는다. 의존성 설치(`npm install`, `pip install`, `go get` 등)는 넣지 않는다.
- 규칙은 `Bash(<명령> *)` 형식으로 쓴다. 끝의 ` *`(앞에 공백)는 인자 없는 형태도 함께 허용한다. `*`는 하위 명령 뒤에 둬야 범위가 좁아진다. 예: `Bash(npm run test *)`는 `npm run test`만, `Bash(npm *)`는 모든 npm 명령을 허용한다.
- `npx`, `uv run`, `poetry run`처럼 인자를 그대로 실행하는 러너는 `Bash(npx *)`처럼 열어 두지 않는다. 러너와 실제 명령을 함께 적는다. 예: `Bash(npx tsc *)`.
- 사용자가 명령을 바꾸면 `allow`도 같은 명령으로 바꾼다.
- 패키지 매니저가 npm이 아니면(pnpm, yarn, bun) Node 계열 스택 파일(Node/TypeScript, React/Vite, Next.js)의 명령과 `allow`의 `npm run`을 해당 매니저 명령으로 바꾼다. 예: `pnpm run test`, `yarn test`, `bun run test`.
