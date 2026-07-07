# Fixture 09 — Mid-debugging, not yet solved (hold, do not interrupt)

## Category
hard-negative

## Transcript
- User: 결제 콜백에서 가끔 서명 검증이 실패해요. 원인 찾는 중.
- 로그 몇 개 확인, 아직 재현 조건 불명확. 인코딩 이슈 의심 중.
- User: 일단 여기까지 보고 내일 더 볼게요.

## Gold — Evidence
- signals: [difficulty, domain]         # 어려움 + 결제/보안 도메인
- resolution: none                      # 아직 해결 안 됨
- explicit_request: false
- negatives: [still-debugging]

## Gold — Assessment
- should_document: false               # 높은 가치여도 미완결 → 확신도 낮음
- type: troubleshooting (alternates: [])
- importance_band: ⭐⭐⭐⭐ (잠재적)
- confidence: low
- expected_action: hold                # 다음 자연스러운 종료 지점에서 재평가
