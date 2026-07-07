# Fixture 12 — Topic already in the vault (de-duplication)

## Category
hard-negative

## Transcript
- User: 저번에 해결한 그 JWT refresh 401 무한루프, 같은 게 또 났는데 같은 방식으로 고쳤어요.
- (vault에 troubleshooting/…-jwt-refresh-401-loop.md 이미 존재)
- User: 그때랑 똑같네요.

## Gold — Evidence
- signals: [difficulty, domain]
- resolution: confirmed
- explicit_request: false
- negatives: [already-in-vault]

## Gold — Assessment
- should_document: false               # 이미 기록됨 → 재제안 금지
- type: troubleshooting (alternates: [])
- importance_band: ⭐⭐⭐⭐ (원본 기준)
- confidence: high
- expected_action: silent              # 최대 "이미 기록돼 있어요" 한 번
