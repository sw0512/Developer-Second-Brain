# Fixture 15 — A repeatable setup, with a small choice inside it

## Category
positive

## Transcript
- User: BE가 아직 배포 전이라 프론트를 못 붙이고 있어요. 목으로 먼저 갈까요?
- Assistant: 대기보다 MSW로 선개발하는 게 낫겠습니다. 핸들러를 Swagger 스키마대로 두고
  `onUnhandledRequest: 'bypass'`로 잡으면, 배포 후엔 핸들러만 지워도 실 API로 넘어갑니다.
- 진행: MSW 설치 → 도메인별 핸들러 작성 → dev 환경에서만 worker 시작 → 네트워크 탭에서
  목 응답 확인. 추측으로 채운 스키마는 파일을 분리해 표시.
- User: 잘 되네요. 배포되면 핸들러 폴더만 지우면 되는 거죠?

## Gold — Evidence
- signals: [decision, novelty, domain]   # 대기 vs 목 선택 + 첫 목 인프라 도입 + API 연동
- resolution: confirmed
- explicit_request: false
- negatives: []

## Gold — Assessment
- should_document: true
- type: how-to (alternates: [adr])       # 절차가 본론, 대기 vs 목 선택은 그 안의 한 줄
- importance_band: ⭐⭐⭐
- confidence: high
- expected_action: propose

## Why not the neighbors
- **troubleshooting** — 아무것도 깨지지 않았다. 증상도 근본 원인도 없다.
- **adr** — 선택이 있지만 대안 비교가 문서의 값어치가 아니다. 다시 읽는 이유는 "어떻게 세팅하고
  어떻게 걷어내나"이다.
- **study-note** — MSW 일반 설명이 아니라 이 프로젝트가 실제로 밟은 경로와 실제 값이다.
