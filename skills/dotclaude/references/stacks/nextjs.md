# Next.js

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

기본 명령:
- 빌드: `npm run build` (`next build`)
- 테스트: `npm test` (테스트 도구가 설정된 경우)
- 린트: `npm run lint` (ESLint)
- 개발 서버: `npm run dev`

`allow`:
```json
[
  "Bash(npm run build *)",
  "Bash(npm run dev *)",
  "Bash(npm run start *)",
  "Bash(npm run lint *)",
  "Bash(npm test *)",
  "Bash(npm run test *)",
  "Bash(npx tsc *)"
]
```

최신 Next.js는 `next lint`를 지원하지 않을 수 있다. `package.json`의 `lint` 스크립트가 무엇을 실행하는지 확인하고 그대로 쓴다. 테스트 스크립트가 없으면 테스트 명령을 비워 두고 사용자에게 알린다.
