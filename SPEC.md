# dotclaude 스킬 명세

## 배포 정보
- 저장소: `gunobo/dotclaude`
- 공개 여부: 공개 (Public)
- 설명 (Repo description): Claude Code 프로젝트용 `.claude` 폴더와 `CLAUDE.md`를 스택별 표준 구조로 만드는 스킬
- 라이선스: MIT
- 토픽: `claude-code`, `claude-skills`, `project-setup`

## 목적
새 프로젝트에서 Claude Code를 바로 쓸 수 있도록 `.claude` 폴더와 `CLAUDE.md`를 표준 구조로 만든다.

## 대상
스택을 가리지 않는 범용 공개 스킬.

## 입력
- 프로젝트 이름
- 스택 (Python, Node/TypeScript, React/Vite, Next.js, Go, 기타)
- 빌드·테스트·린트 명령 (스택 기본값 제안 후 수정)
- 팀 공유 여부

## 출력
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

## 규칙
- 보안 차단은 스택과 무관하게 항상 적용한다 (`.env`, 키 파일, `rm -rf`, 강제 푸시, 파이프 실행).
- 스택별 명령과 허용 목록은 `references/stacks.md`를 따른다.
- 기존 `CLAUDE.md`, `settings.json`은 덮어쓰지 않는다. 백업, 병합, 건너뛰기 중 하나를 묻는다.
- `CLAUDE.md`는 200줄을 넘기지 않는다.

## 범위 밖
- 프로젝트 코드 생성
- 의존성 설치 실행
- Git 원격 저장소 설정

## 파일 구성
- `SKILL.md`: 실행 절차
- `references/stacks.md`: 스택별 기본값
- `README.md`: 설치와 사용 안내
- `LICENSE`: MIT 라이선스 전문
