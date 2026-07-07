# Fixture 04 — Release-blocking auth bug (high value)

## Category
positive

## Transcript
- User: access token 만료되면 /auth/refresh 호출하는데 refresh도 401 나면서 무한루프 돌아요.
- (여러 시도) 원인: Spring Security 필터 체인이 /auth/refresh에도 JWT 인증을 요구.
- /auth/refresh를 permitAll 예외 경로로 분리, refresh는 refresh token만으로 검증.
- 재현 안 됨. 릴리스 blocker 해결.
- User: 드디어 됐다.

## Gold — Evidence
- signals: [difficulty, decision, domain]   # 다수 시도 + 필터 설계 결정 + 인증
- resolution: confirmed
- explicit_request: false
- negatives: []

## Gold — Assessment
- should_document: true
- type: troubleshooting (alternates: [adr])
- importance_band: ⭐⭐⭐⭐⭐
- confidence: high
- expected_action: propose
