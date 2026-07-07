# Fixture 11 — One weak signal only (< 2 signals rule)

## Category
hard-negative

## Transcript
- User: 이 라이브러리 버전 하나 올리고 빌드 되는지 봐줘.
- Assistant: 올렸고 빌드 통과합니다.
- User: 오케이.

## Gold — Evidence
- signals: [novelty]                    # 의존성 버전업 1개, 결정·어려움 없음
- resolution: confirmed
- explicit_request: false
- negatives: [single-weak-signal]

## Gold — Assessment
- should_document: false               # 신호 2개 미만 → unprompted 제안 불가
- type: til (alternates: [])
- importance_band: ⭐
- confidence: medium
- expected_action: silent
