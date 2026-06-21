# Harness Framework

이 저장소는 AI 코딩 에이전트가 큰 구현 작업을 여러 task로 나누어 수행하도록 돕는 하네스 프레임워크입니다.

완성된 애플리케이션 소스가 아니라, 새 프로젝트에 복사해서 사용할 작업 관리 골격을 담고 있습니다. 외부 실행기로 워크플로우를 강제하지 않고, 에이전트가 따르는 마크다운 지침(Skill)으로 작업을 유도합니다. 모델이 바뀌어도 지침은 그대로 살아남습니다.

> **새 프로젝트에 복사한 직후라면** `start-prompt.md` 를 먼저 처리하세요 (처리 후 그 파일은 삭제됩니다).

## 공통 개념

Harness Framework는 다음 흐름을 기준으로 작업을 관리합니다.

1. 프로젝트 지침(`CLAUDE.md`)과 설계 문서(`docs/`)를 먼저 작성합니다.
2. 큰 작업을 독립 실행 가능한 task 파일로 쪼갭니다.
3. 각 task는 읽어야 할 파일, 작업 지시, 실행 가능한 Acceptance Criteria를 자기완결적으로 담습니다.
4. task를 하나씩 순서대로 진행합니다.
5. 각 task는 결과에 따라 `completed`, `error`, `blocked` 중 하나로 상태를 기록합니다.
6. 완료된 task의 `summary`는 다음 task의 컨텍스트로 누적됩니다.
7. 양보 불가 invariant("커밋 전 검증 통과")는 Stop hook으로 보장합니다.

이 구조 덕분에 긴 구현 작업을 한 번의 대화나 한 번의 에이전트 실행에 의존하지 않고, 작고 검증 가능한 단위로 진행할 수 있습니다.

## 폴더 구성

```text
99-harness-framework/
├── CLAUDE.md                          # 프로젝트 지침 (placeholder 뼈대 — 새 프로젝트에서 채움)
├── docs/
│   ├── ADR.md                         # 의사결정 기록 (뼈대)
│   ├── ARCHITECTURE.md                # 아키텍처 (뼈대)
│   └── PRD.md                         # 요구사항 (뼈대)
└── .claude/
    ├── skills/
    │   ├── harness/SKILL.md           # 작업 워크플로우 (탐색→논의→task 설계→실행)
    │   └── review/SKILL.md            # 변경사항 리뷰 체크리스트
    ├── hooks/
    │   └── verify-before-commit.sh    # 커밋 전 검증 강제 (Stop hook)
    └── reference/
        └── claude-code-toolbox.md     # "언제 무슨 기능 쓰나" 참조표
```

`tasks/` 는 작업을 시작하면 런타임에 생성됩니다. harness 스킬이 task별 인덱스(`tasks/index.json`)와 task 파일(`tasks/{task-name}/task{N}.md`)을 만듭니다.

## 새 프로젝트에 적용하는 법

1. 이 저장소를 새 프로젝트의 baseline으로 복사합니다 (`CLAUDE.md`, `.claude/`, `docs/`).
2. `CLAUDE.md` / `docs/` 의 `{...}` placeholder를 실제 프로젝트 내용으로 채웁니다.
3. `.claude/hooks/verify-before-commit.sh` 의 검증 커맨드(`VERIFY_CMD` 또는 환경변수 `HARNESS_VERIFY_CMD`)를 프로젝트에 맞게 설정합니다.
4. `.claude/settings.json` 에 Stop hook을 등록합니다.

설정을 마치면 작업을 시작할 때 harness 스킬이, 변경사항 리뷰를 요청하면 review 스킬이 발동합니다.
