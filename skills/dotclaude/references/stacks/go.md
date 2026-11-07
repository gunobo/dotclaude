# Go

공통 원칙은 [../stacks.md](../stacks.md)를 따른다.

기본 명령:
- 빌드: `go build ./...`
- 테스트: `go test ./...`
- 린트: `go vet ./...` (golangci-lint를 쓰면 `golangci-lint run`)
- 포맷: `gofmt -l .`

`allow`:
```json
[
  "Bash(go build *)",
  "Bash(go test *)",
  "Bash(go vet *)",
  "Bash(gofmt *)",
  "Bash(golangci-lint run *)"
]
```
