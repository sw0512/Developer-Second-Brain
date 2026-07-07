# Fixture 01 — Hard bug, diagnosed and fixed

## Category
positive

## Transcript
- User: 배포하면 이미지 업로드가 가끔 500이 나요. 로컬에선 재현이 안 돼요.
- (몇 차례 시도) 로그 확인 → nginx `client_max_body_size` 기본값 1m에 걸림.
- 설정 8m으로 올리고 재배포 → 업로드 정상. 실패 재현 안 됨.
- User: 오 이제 되네요.

## Gold — Evidence
- signals: [difficulty, domain]        # 재현 어려움 + 배포/인프라
- resolution: confirmed
- explicit_request: false
- negatives: []

## Gold — Assessment
- should_document: true
- type: troubleshooting (alternates: [])
- importance_band: ⭐⭐⭐
- confidence: high
- expected_action: propose
