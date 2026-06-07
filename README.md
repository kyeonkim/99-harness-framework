# Harness Framework

이 저장소는 AI 코딩 에이전트가 큰 구현 작업을 여러 phase와 step으로 나누어 수행하도록 돕는 하네스 프레임워크 모음입니다.

완성된 애플리케이션 소스가 아니라, 새 프로젝트에 복사해서 사용할 작업 관리 골격을 담고 있습니다. 핵심 아이디어는 특정 에이전트에 묶이지 않습니다. `claude_code/`와 `codex/`는 같은 phase/step 실행 모델을 각 에이전트 환경에 맞게 구현한 템플릿입니다.

## 공통 개념

Harness Framework는 다음 흐름을 기준으로 작업을 관리합니다.

1. 프로젝트 지침과 설계 문서를 먼저 작성합니다.
2. 큰 작업을 하나 이상의 phase로 나눕니다.
3. 각 phase를 독립 실행 가능한 step 파일로 쪼갭니다.
4. 실행기는 pending step을 순서대로 실행합니다.
5. 각 step은 결과에 따라 `completed`, `error`, `blocked` 중 하나로 상태를 기록합니다.
6. 완료된 step의 `summary`는 다음 step의 컨텍스트로 누적됩니다.
7. 실행기는 출력, 타임스탬프, 커밋, 선택적 push를 관리합니다.

이 구조 덕분에 긴 구현 작업을 한 번의 대화나 한 번의 에이전트 실행에 의존하지 않고, 작고 검증 가능한 단위로 진행할 수 있습니다.

## 폴더 구성

두 템플릿은 거의 같은 구조를 공유합니다. 공통 구조는 아래와 같습니다.

```text
<agent-template>/
├── <workflow-dir>/
│   └── commands/
│       ├── harness.md
│       └── review.md
├── <agent-config-file>
├── docs/
│   ├── ADR.md
│   ├── ARCHITECTURE.md
│   ├── PRD.md
│   └── UI_GUIDE.md
├── scripts/
│   ├── execute.py
│   └── test_execute.py
├── .gitignore
└── <agent-guidance-file>
```

에이전트별 차이는 다음 정도입니다.

| 항목 | Claude Code | Codex |
|------|-------------|-------|
| 템플릿 폴더 | `claude_code/` | `codex/` |
| 프로젝트 지침 파일 | `CLAUDE.md` | `AGENTS.md` |
| 워크플로우 폴더 | `.claude/` | `.agents/` |
| 반복 워크플로우 | `.claude/commands/` | `.agents/commands/` |
| 설정/훅 파일 | `.claude/settings.json` | `.codex/hooks.json` |
