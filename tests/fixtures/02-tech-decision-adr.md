# Fixture 02 — Technology decision between alternatives

## Category
positive

## Transcript
- User: refresh token 저장을 in-memory로 할지 Redis로 할지 고민이에요.
- 논의: in-memory는 단순하지만 다중 인스턴스에서 공유 안 됨, 재시작 시 유실.
  Redis는 운영 비용이 있지만 수평 확장·TTL 관리가 깔끔.
- User: 확장성 생각하면 Redis가 맞겠네요. Redis로 갈게요.

## Gold — Evidence
- signals: [decision, domain]           # 대안 비교/트레이드오프 + 인증
- resolution: confirmed
- explicit_request: false
- negatives: []

## Gold — Assessment
- should_document: true
- type: adr (alternates: [])
- importance_band: ⭐⭐⭐⭐
- confidence: high
- expected_action: propose
