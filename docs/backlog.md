# Backlog

로드맵 버전에 아직 배정되지 않았거나, 배정은 됐지만 착수 전인 확정 작업들을 기록합니다.
`docs/roadmap.md`가 "어떤 버전에 무엇이 들어가는가"라면, 여기는 "합의는 끝났고 아직 안 한 것"의 목록입니다.
완료된 항목은 지우지 않고 **상태만 완료로 바꿔** 남깁니다 — 결정의 근거가 코드에는 남지 않기 때문입니다.

---

## 1. 프로젝트 축을 폴더가 아닌 메타데이터로 추가

- **상태**: 완료 (2026-07-30) — 아래 작업 항목 4건 모두 반영. 근거는 기록용으로 남긴다.
- **결정일**: 2026-07-26
- **관련 버전**: v0.3 (Notion 연동 시 property로 매핑되므로 그 전에 필드가 존재해야 함)

### 결정

문서를 프로젝트별로 나누되, **디렉터리 계층이 아니라 frontmatter 필드 `project`로** 표현한다.
vault 디렉터리 구조는 지금의 "타입 = 폴더, 예외 없음" 1단 규칙을 그대로 유지한다.

### 근거

1. **vault의 존재 이유와 충돌.** `references/vault-layout.md`는 vault가 단일 프로젝트 바깥에
   살아서 모든 repo의 지식이 한 곳에 쌓이는 것을 전제로 한다. 프로젝트별 디렉터리는 그 통합을
   되돌려서, A 프로젝트에서 얻은 교훈이 B 프로젝트 작업 중에 보이지 않게 만든다.
2. **축이 둘인데 폴더는 하나만 고를 수 있다.** `project/type`이든 `type/project`든 반대 방향
   조회가 불편해진다. 현재의 "타입 이름 = 폴더 이름" 불변식(룩업 테이블 불필요)도 깨진다.
3. **v0.3에서 폴더는 어차피 사라진다.** Notion에서 프로젝트는 중첩 DB가 아니라 property다.
   폴더로 만들면 동기화 시점에 평탄화가 필요하고, 이는 원칙 7(백엔드 교체는 한 곳만 바뀐다)
   위반이다.
4. **원칙 8이 이미 답을 정해뒀다.** "Metadata is the contract between capabilities." v1.0의
   Knowledge Graph·Weekly Report는 프로젝트 축으로 질의해야 하는데, 경로가 아니라 필드로 푸는
   것이 맞다. 프로젝트 rename·모노레포 분리 시에도 필드는 한 줄 수정, 경로는 전체 이동이다.

### 작업 항목

- [x] 템플릿 6종 frontmatter에 `project` 추가
      (`troubleshooting`, `adr`, `til`, `retrospective`, `resume-material`, `study-note`)
- [x] `references/vault-layout.md`에 "프로젝트는 폴더가 아니라 메타데이터" 근거 한 단락 추가
      — 이 규칙의 단일 authoritative 위치 (원칙 5, one concept one home)
- [x] 프로젝트 이름 추출 규칙 명시: `git remote` origin의 repo 이름 → 없으면 작업 디렉터리명
      → 둘 다 애매하면 `unknown`
- [x] `docs/architecture.md`의 vault 설명이 frontmatter 스키마를 언급한다면 동기화
      (원칙 5, documentation mirrors architecture)

### 정하지 않은 것

- 물리적으로 vault를 완전히 분리하고 싶은 경우(회사/개인 repo 분리 등)는 이미 있는
  `SECOND_BRAIN_VAULT` 환경변수로 vault 루트를 갈아끼우면 된다. 별도 기능을 만들지 않는다.
