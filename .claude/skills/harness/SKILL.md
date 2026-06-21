---
name: harness
description: 큰 구현 작업을 task 단위로 쪼개 진행하는 하네스 워크플로우. "harness로 진행", "이 작업 task로 쪼개줘", "구현 계획 세워줘", "이 티켓/이슈 진행" 같이 실제 코드 변경이 따르는 작업 요청이면 트리거. docs(PRD/ARCHITECTURE/ADR)를 읽고 → 논의 → task 설계 → task 파일 생성 → 하나씩 순차 실행하며 상태를 기록한다. 사소한 1줄 변경엔 쓰지 않는다.
---

이 프로젝트는 Harness 프레임워크를 사용한다. 아래 워크플로우에 따라 작업을 진행하라.

---

## 워크플로우

### A. 탐색

`/docs/` 하위 문서(PRD, ARCHITECTURE, ADR 등)를 읽고 프로젝트의 기획·아키텍처·설계 의도를 파악한다. 필요시 Explore 에이전트를 병렬로 사용한다.

### B. 논의

구현을 위해 구체화하거나 기술적으로 결정해야 할 사항이 있으면 사용자에게 제시하고 논의한다.

### C. Task 설계

사용자가 구현 계획 작성을 지시하면 여러 task으로 나뉜 초안을 작성해 피드백을 요청한다.

설계 원칙:

1. **Scope 최소화** — 하나의 task에서 하나의 레이어 또는 모듈만 다룬다. 여러 모듈을 동시에 수정해야 하면 task을 쪼갠다.
2. **자기완결성** — 각 task 파일은 독립된 Claude 세션에서 실행된다. "이전 대화에서 논의한 바와 같이" 같은 외부 참조는 금지한다. 필요한 정보는 전부 파일 안에 적는다.
3. **사전 준비 강제** — 관련 문서 경로와 이전 task에서 생성/수정된 파일 경로를 명시한다. 세션이 코드를 읽고 맥락을 파악한 뒤 작업하도록 유도한다.
4. **시그니처 수준 지시** — 함수/클래스의 인터페이스만 제시하고 내부 구현은 에이전트 재량에 맡긴다. 단, 설계 의도에서 벗어나면 안 되는 핵심 규칙(멱등성, 보안, 데이터 무결성 등)은 반드시 명시한다.
5. **AC는 실행 가능한 커맨드** — "~가 동작해야 한다" 같은 추상적 서술이 아닌 `npm run build && npm test` 같은 실제 실행 가능한 검증 커맨드를 포함한다.
6. **주의사항은 구체적으로** — "조심해라" 대신 "X를 하지 마라. 이유: Y" 형식으로 적는다.
7. **네이밍** — task name은 kebab-case slug로, 해당 task의 핵심 모듈/작업을 한두 단어로 표현한다 (예: `project-setup`, `api-layer`, `auth-flow`).

### D. 파일 생성

사용자가 승인하면 아래 파일들을 생성한다.

#### D-1. `tasks/index.json` (전체 현황)

여러 task를 관리하는 top-level 인덱스. 이미 존재하면 `tasks` 배열에 새 항목을 추가한다.

```json
{
  "tasks": [
    {
      "dir": "0-mvp",
      "status": "pending"
    }
  ]
}
```

- `dir`: task 디렉토리명.
- `status`: `"pending"` | `"completed"` | `"error"` | `"blocked"`. 진행하며 업데이트한다.
- 타임스탬프(`completed_at`, `failed_at`, `blocked_at`)는 상태 변경 시 기록한다. 생성 시 넣지 않는다.

#### D-2. `tasks/{task-name}/index.json` (task 상세)

```json
{
  "project": "<프로젝트명>",
  "phase": "<task-name>",
  "tasks": [
    { "task": 0, "name": "project-setup", "status": "pending" },
    { "task": 1, "name": "core-types", "status": "pending" },
    { "task": 2, "name": "api-layer", "status": "pending" }
  ]
}
```

필드 규칙:

- `project`: 프로젝트명 (CLAUDE.md 참조).
- `phase`: task 이름. 디렉토리명과 일치시킨다.
- `tasks[].task`: 0부터 시작하는 순번.
- `tasks[].name`: kebab-case slug.
- `tasks[].status`: 초기값은 모두 `"pending"`.

상태 전이와 기록 필드 (Claude 세션이 기록한다):

| 전이 | 기록되는 필드 |
|------|-------------|
| → `completed` | `completed_at`, `summary` |
| → `error` | `failed_at`, `error_message` |
| → `blocked` | `blocked_at`, `blocked_reason` |

`summary`는 task 완료 시 산출물을 한 줄로 요약한 것으로, 다음 task의 컨텍스트로 활용한다. 따라서 다음 task에 유용한 정보(생성된 파일, 핵심 결정 등)를 담아야 한다.

#### D-3. `tasks/{task-name}/task{N}.md` (각 task마다 1개)

```markdown
# Task {N}: {이름}

## 읽어야 할 파일

먼저 아래 파일들을 읽고 프로젝트의 아키텍처와 설계 의도를 파악하라:

- `/docs/ARCHITECTURE.md`
- `/docs/ADR.md`
- {이전 task에서 생성/수정된 파일 경로}

이전 task에서 만들어진 코드를 꼼꼼히 읽고, 설계 의도를 이해한 뒤 작업하라.

## 작업

{구체적인 구현 지시. 파일 경로, 클래스/함수 시그니처, 로직 설명을 포함.
코드 스니펫은 인터페이스/시그니처 수준만 제시하고, 구현체는 에이전트에게 맡겨라.
단, 설계 의도에서 벗어나면 안 되는 핵심 규칙은 명확히 박아넣어라.}

## Acceptance Criteria

```bash
npm run build   # 컴파일 에러 없음
npm test        # 테스트 통과
```

## 검증 절차

1. 위 AC 커맨드를 실행한다.
2. 아키텍처 체크리스트를 확인한다:
   - ARCHITECTURE.md 디렉토리 구조를 따르는가?
   - ADR 기술 스택을 벗어나지 않았는가?
   - CLAUDE.md CRITICAL 규칙을 위반하지 않았는가?
3. 결과에 따라 `tasks/{task-name}/index.json`의 해당 task을 업데이트한다:
   - 성공 → `"status": "completed"`, `"summary": "산출물 한 줄 요약"`
   - 수정 3회 시도 후에도 실패 → `"status": "error"`, `"error_message": "구체적 에러 내용"`
   - 사용자 개입 필요 (API 키, 외부 인증, 수동 설정 등) → `"status": "blocked"`, `"blocked_reason": "구체적 사유"` 후 즉시 중단

## 금지사항

- {이 task에서 하지 말아야 할 것. "X를 하지 마라. 이유: Y" 형식}
- 기존 테스트를 깨뜨리지 마라
```

### E. 실행

task를 하나씩 순서대로 진행한다. 각 task는 위 task 파일의 검증 절차를 따라 상태를
업데이트한다.

에러 복구:

- **error 발생 시**: `tasks/{task-name}/index.json`에서 해당 task의 `status`를 `"pending"`으로 바꾸고 `error_message`를 삭제한 뒤 재실행한다.
- **blocked 발생 시**: `blocked_reason`에 적힌 사유를 해결한 뒤, `status`를 `"pending"`으로 바꾸고 `blocked_reason`을 삭제한 뒤 재실행한다.