# Roadmap

각 버전은 이전 버전의 구조를 깨지 않고 확장합니다.

## v0.1 — Documentation Skill  ✅
- `second-brain` 스킬: 판단 → 유형 선택 → ⭐ 점수 → 제안 → (승인 시) 작성.
- 6종 한국어 템플릿, `/document` 명령.
- 로컬 Markdown vault 출력 (`~/DeveloperSecondBrain/`).
- 플러그인 + 마켓플레이스 패키징.

## v0.2 — Importance Score 정교화
- 점수 산정 기준 세분화, 캘리브레이션 예시 확장.
- 유형 자동 추천 정확도 개선.

## v0.3 — Notion Integration
- Notion MCP 연동. vault → Notion Developer Wiki 동기화.
- 유형별 Notion DB 매핑, 저장소 추상화(local ↔ Notion) 확정.

## v0.4 — Hooks  ✅ (현재)
- `PostToolUse` 훅으로 자동 "기록할까요?" 판단 부착 (`hooks/detect-on-edit.sh`).
- v0.4.0의 `Stop` + `decision:block` 방식은 폐기 — 차단 사유가 사용자 화면에 렌더링돼
  "조용한 경로"가 구조적으로 존재하지 않았음. `Stop`은 `hookSpecificOutput` union 멤버가
  아니라 `additionalContext`를 쓸 수 없다는 것이 근본 원인.
- 훅은 "작업이 일어났나"만 값싸게 판정하고, 가치 판단은 `references/`가 단독으로 수행.
- 여전히 자동 저장은 하지 않음 (제안까지만 자동).
- 순서 변경: v0.3(Notion)보다 먼저 진행. Notion 동기화는 문서가 쌓여야 의미가 있는데,
  제안이 뜨지 않아 애초에 문서가 쌓이지 않는 상태였음.

## v0.5 — Resume Material
- STAR 확장 강화, Resume Score(0–100) 산출.
- 예상 면접 질문 자동 생성.

## v1.0 — Developer Second Brain
- **Resume Score** — 면접 활용 가치 점수화.
- **Interview Candidate** — 예상 질문 세트.
- **Knowledge Graph** — 기술 간 연결 (JWT → Spring Security → Redis → Refresh Token).
- **Weekly / Monthly Report** — 성장 리포트.

## 확장을 견디는 설계 결정 (지금 잡아둔 것)
- 템플릿 frontmatter에 메타데이터 → Resume Score·Knowledge Graph 기반.
- vault를 전역·추상화 → Notion 전환이 저장소 교체로 끝남.
- hooks/ 자리 확보 → v0.4에서 스킬 변경 없이 훅만 추가.
