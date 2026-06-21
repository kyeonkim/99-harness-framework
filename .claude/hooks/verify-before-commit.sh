#!/usr/bin/env bash
# verify-before-commit — harness의 단 하나의 강제 장치(Stop hook).
#
# 목적: "검증(테스트/타입체크)을 실제로 통과했는가" 라는 양보 불가 invariant 하나만
#       보장한다. 마크다운 지침(SKILL.md)은 권고라 모델이 건너뛸 수 있지만, hook은
#       deterministic하게 동작을 보장한다.
#
# 설정 방법:
#   1) 이 파일을 프로젝트 .claude/hooks/ 로 복사한다.
#   2) 아래 VERIFY_CMD 를 프로젝트의 실제 검증 커맨드로 바꾼다.
#      (또는 환경변수 HARNESS_VERIFY_CMD 로 지정)
#   3) .claude/settings.json 에 Stop hook으로 등록한다:
#        {
#          "hooks": {
#            "Stop": [
#              { "hooks": [ { "type": "command",
#                "command": "bash .claude/hooks/verify-before-commit.sh" } ] }
#            ]
#          }
#        }
#
# 동작:
#   - VERIFY_CMD 미설정 → 통과(exit 0). 복사 직후 깨지지 않게 하기 위함.
#   - VERIFY_CMD 설정 + 통과 → exit 0.
#   - VERIFY_CMD 설정 + 실패 → exit 2 로 turn 종료를 차단하고 stderr로 사유 전달.
#     (모델이 검증을 고치고 다시 시도하도록 유도)

set -uo pipefail

VERIFY_CMD="${HARNESS_VERIFY_CMD:-}"

# ── 프로젝트별 검증 커맨드를 여기에 직접 적어도 된다 (환경변수가 우선) ──
# 예: VERIFY_CMD="pnpm --filter @app/backend test"
# VERIFY_CMD="${VERIFY_CMD:-<프로젝트 검증 커맨드>}"

if [ -z "$VERIFY_CMD" ]; then
  # 미설정: 강제하지 않고 통과. (안내만)
  echo "verify-before-commit: HARNESS_VERIFY_CMD 미설정 — 검증 생략(통과)." >&2
  exit 0
fi

if eval "$VERIFY_CMD"; then
  exit 0
else
  echo "verify-before-commit: 검증 실패 — '$VERIFY_CMD' 가 통과하지 않았다. 커밋 전에 고쳐라." >&2
  exit 2
fi
