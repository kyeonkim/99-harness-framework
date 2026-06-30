# Start Prompt — 새 프로젝트 부트스트랩

이 파일을 읽은 에이전트는 아래 단계를 순서대로 처리한 뒤, **마지막에 이 파일(`start-prompt.md`)을 삭제**하세요. 이 파일은 새 프로젝트를 초기화하기 위한 일회성 안내입니다.

## 처리할 일

0. **baseline 복사** — 이 harness 저장소의 baseline(`CLAUDE.md`, `.claude/`, `docs/`, `README.md`)을 **현재 작업 폴더(새 프로젝트 폴더)로 복사**합니다. `.git` 과 이 `start-prompt.md` 는 복사하지 않습니다. 현재 폴더가 아직 git 저장소가 아니면 `git init` 합니다. (이미 현재 폴더가 baseline으로 채워져 있다면 이 단계는 건너뜁니다.) 이후 단계의 placeholder 채우기·hook 설정은 모두 **현재 폴더** 기준으로 진행하며, harness 원본 저장소는 수정하지 않습니다.

1. **프로젝트 정보 수집** — 사용자에게 이 프로젝트가 무엇인지 묻습니다: 목적, 기술 스택, 핵심 아키텍처 규칙, 주요 요구사항. 이미 알 수 있는 정보(기존 코드, package.json 등)는 먼저 읽어 파악하고, 모르는 것만 묻습니다.

2. **`CLAUDE.md` 채우기** — `{...}` placeholder를 실제 내용으로 바꿉니다. 기술 스택, CRITICAL 아키텍처 규칙, 개발 프로세스, 실제 명령어를 정확히 반영합니다.

3. **`docs/` 채우기** — 아래 세 문서의 `{...}` placeholder를 채웁니다.
   - `docs/PRD.md` — 목표, 사용자, 핵심 기능, MVP 제외 사항.
   - `docs/ARCHITECTURE.md` — 디렉토리 구조, 패턴, 데이터 흐름, 상태 관리.
   - `docs/ADR.md` — 철학, 주요 의사결정(결정/이유/트레이드오프).

4. **`README.md` 를 프로젝트용으로 변경** — 현재 README는 하네스 프레임워크 자체를 설명합니다. 이 프로젝트를 소개하는 내용으로 다시 씁니다. (하네스 사용법은 `.claude/skills/` 에 있으므로 README에 중복할 필요 없습니다.)

5. **검증 hook 설정** — `.claude/hooks/verify-before-commit.sh` 의 검증 커맨드(`VERIFY_CMD` 또는 환경변수 `HARNESS_VERIFY_CMD`)를 이 프로젝트의 실제 검증 커맨드로 설정하고, `.claude/settings.json` 에 Stop hook을 등록합니다.

6. **이 파일 삭제** — 위 단계를 모두 마쳤으면 `start-prompt.md` 를 삭제합니다.

## 주의

- placeholder를 추측으로 채우지 마세요. 불확실하면 사용자에게 확인합니다.
- 위 작업이 끝나기 전에는 docs가 비어 있어 harness/review 스킬이 제대로 동작하지 않습니다.
