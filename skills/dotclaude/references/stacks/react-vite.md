# React/Vite

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

기본 명령:
- 빌드: `npm run build` (`vite build`)
- 테스트: `npx vitest run`
- 린트: `npm run lint` (ESLint)
- 개발 서버: `npm run dev`

`allow`:
```json
[
  "Bash(npm run build *)",
  "Bash(npm run dev *)",
  "Bash(npm run preview *)",
  "Bash(npm run lint *)",
  "Bash(npm test *)",
  "Bash(npm run test *)",
  "Bash(npx vitest *)",
  "Bash(npx tsc *)"
]
```

rules paths (`.claude/rules/`의 `paths` 값):
- testing: `"**/*.{test,spec}.{ts,tsx,js,jsx}"`, `"**/__tests__/**/*"`
- api-design: `"src/api/**/*"`, `"src/services/**/*"`
