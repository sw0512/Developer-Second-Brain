# Fixture 10 — Pure exploration, nothing settled

## Category
hard-negative

## Transcript
- User: 나중에 검색 기능 붙일 건데 Elasticsearch랑 Postgres FTS 뭐가 나을까요?
- 가볍게 장단점만 얘기. 결정은 안 함, 아직 요구사항도 확정 전.
- User: 음 나중에 더 정해서 다시 얘기해요.

## Gold — Evidence
- signals: [decision]                   # 대안 언급은 있으나 결정/해결 없음
- resolution: none
- explicit_request: false
- negatives: [no-decision-made, exploration-only]

## Gold — Assessment
- should_document: false
- type: adr (alternates: [])           # 나중에 결정되면 adr 후보
- importance_band: ⭐⭐
- confidence: low
- expected_action: silent
