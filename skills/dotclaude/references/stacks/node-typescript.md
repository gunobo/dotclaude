# Node/TypeScript

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

기본 명령:
- 빌드: `npm run build`
- 테스트: `npm test`
- 린트: `npm run lint`
- 타입 검사: `npx tsc --noEmit`

`allow`:
```json
[
  "Bash(npm run build *)",
  "Bash(npm test *)",
  "Bash(npm run test *)",
  "Bash(npm run lint *)",
  "Bash(npx tsc *)"
]
```

`package.json`의 `scripts`에 `build`, `test`, `lint`가 없으면 사용자에게 알리고 실제 스크립트 이름으로 바꾼다.

rules paths (`.claude/rules/`의 `paths` 값):
- testing: `"**/*.{test,spec}.{ts,js}"`, `"**/__tests__/**/*"`, `"tests/**/*"`
- api-design: `"src/api/**/*"`, `"src/routes/**/*"`, `"src/server/**/*"`
