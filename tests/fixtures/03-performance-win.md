# Fixture 03 — Measured performance improvement

## Category
positive

## Transcript
- User: 목록 API가 느려요. p95가 1.8초.
- 분석: N+1 쿼리 발견. fetch join + 인덱스 추가.
- 재측정: p95 1.8s → 240ms.
- User: 훨씬 빨라졌어요.

## Gold — Evidence
- signals: [difficulty, domain]         # 성능 진단 + performance 도메인 (측정치 존재)
- resolution: confirmed
- explicit_request: false
- negatives: []

## Gold — Assessment
- should_document: true
- type: troubleshooting (alternates: [adr])
- importance_band: ⭐⭐⭐⭐        # 측정 가능한 임팩트 → 포트폴리오 가치
- confidence: high
- expected_action: propose
