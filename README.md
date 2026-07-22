# Developer Second Brain

> **This is not a Notion automation tool. It is a system for turning your development experience into a lasting asset.**
> 이것은 노션 자동화 도구가 아니라, **개발 경험을 자산으로 만드는 시스템**입니다.

Developer Second Brain은 Claude Code를 위한 개인 개발 지식관리(PKM) 프레임워크입니다.
코드를 짜는 데서 끝나지 않고, 개발 과정에서 나온 **지식 · 기술적 의사결정 · 트러블슈팅 · 회고 · 면접 소재**를
자동으로 수집·분류·기록해 **면접과 포트폴리오 자산**으로 축적합니다.

Claude는 단순한 어시스턴트가 아니라 **Documentation Engineer**로 동작합니다.

```
질문 → 개발 → 문제 해결 → 기록 가치 판단 → 문서화 → 저장 → 면접·포트폴리오 자산 축적
```

## 설계 기준 (딱 하나만 기억하세요)

모든 기능은 이 질문 하나로 판단합니다:

> **"이 기능이 개발자의 지식 축적에 기여하는가?"**

기여하지 않으면 넣지 않습니다. 그래서 방향이 흔들리지 않습니다.
이 원칙들의 헌법 격 문서는 [PROJECT_PRINCIPLES.md](PROJECT_PRINCIPLES.md)입니다 —
아키텍처 판단이 애매할 때의 최종 기준입니다.

## 핵심 원칙

- **Quality over Quantity** — 가치 있는 기록만.
- **절대 자동 저장하지 않음** — 반드시 사용자 승인 후 저장.
- **한국어 출력 / 영어 프롬프트** — 읽는 문서는 한국어, 내부 지침은 영어.
- **Global · 프로젝트 독립적** — 모든 프로젝트에서 하나의 Second Brain에 축적.
- **확장 가능한 구조** — v0.1 → v1.0 로드맵을 따라 성장.

## 무엇을 기록하나 (Documentation Types)

| 유형 | 언제 |
|------|------|
| **Troubleshooting** | 어려운 버그를 진단·해결했을 때 |
| **ADR** | 기술/아키텍처를 후보 중에서 선택했을 때 |
| **TIL** | 작고 독립적인 것을 배웠을 때 |
| **Retrospective** | 작업/스프린트/프로젝트를 회고할 때 |
| **Resume Material** | 면접·이력서 스토리(STAR)가 될 경험일 때 |
| **Study Note** | 기술(Spring/React/Redis/Docker/AI…) 학습 노트 |

기록하지 않는 것: 오타 수정, CSS 미세 조정, 단순 문법 질문, 사소한 변경.

## 중요도 점수 (Importance Score)

```
⭐         기록 불필요
⭐⭐        짧은 TIL
⭐⭐⭐       저장 추천
⭐⭐⭐⭐      강한 추천
⭐⭐⭐⭐⭐     반드시 저장 (면접/포트폴리오 가치 높음)
```

## 설치

두 가지 경로가 있습니다. **일반 사용자는 플러그인**, **이 저장소를 개발/수정하는 사람은 심링크**를 씁니다.

### 1) 플러그인 설치 (배포용 · 권장)

```bash
# 이 저장소를 마켓플레이스로 등록
/plugin marketplace add sw0512/Developer-Second-Brain

# 플러그인 설치
/plugin install developer-second-brain
```

로컬 저장소 경로를 마켓플레이스로 등록해도 됩니다:

```bash
/plugin marketplace add ~/Git/Developer-Second-Brain
/plugin install developer-second-brain
```

이 방식은 `second-brain` 스킬 + `/document` 명령을 모두 제공합니다.

### 2) 심링크 개발 설치 (빠른 반복 테스트용)

저장소를 수정하며 즉시 테스트할 때는 심볼릭 링크가 가장 빠릅니다. 파일을 고치면
복사나 재설치 없이 바로 반영됩니다.

```bash
./scripts/install-dev.sh     # 스킬 + /document 명령을 ~/.claude 로 심링크
./scripts/uninstall-dev.sh   # 심링크 제거 (실제 파일은 건드리지 않음)
```

스킬이 자기 완결적(templates·references를 폴더 안에 소유)이라 링크 하나로 동작합니다.
스크립트가 `/document` 명령까지 링크하므로 **플러그인 설치와 기능이 동일**합니다.
파일을 수정하면 다음 실행 때 바로 반영됩니다. 플러그인 배포 구조는 그대로 유지되므로
두 방식은 충돌하지 않습니다. 자세한 개발 안내는 [CONTRIBUTING.md](CONTRIBUTING.md) 참고.

### Vault 위치

기록은 하나의 전역 vault에 쌓입니다 (프로젝트마다 흩어지지 않음).

- 기본값: `~/DeveloperSecondBrain/`
- 변경: 환경변수 `SECOND_BRAIN_VAULT` 설정

## 사용법

특별히 할 게 없습니다. Claude와 개발하다가 **기록할 가치가 생기면 Claude가 먼저 제안**합니다.

```
📌 기록할 가치가 있어 보여요.
  유형:   Troubleshooting
  중요도: ⭐⭐⭐⭐
기록할까요? (y / 수정 / 취소)
```

수동으로 남기고 싶을 때:

```
/document                      # 최근 작업을 기록
/document Redis 캐시 도입 결정    # 특정 주제를 기록
```

**어떤 경우에도 승인 없이 저장하지 않습니다.**

## 어떻게 동작하나 (Skills 이해하기)

Claude Code의 **Skill**은 특정 상황에서 Claude에게 부여되는 역할·절차입니다. 이 플러그인의
`second-brain` 스킬은 이렇게 동작합니다:

1. **발동** — 개발 문제를 함께 푼 뒤, 스킬 설명(description)에 맞는 상황이면 Claude가 스스로 이 스킬을 켭니다. (또는 `/document`로 수동 실행)
2. **판단 · 점수** — `references/`의 규칙을 읽어 기록 가치를 판단하고, 유형을 고르고, ⭐ 점수를 매깁니다.
3. **제안** — 한국어로 "이거 기록할까요?"를 묻습니다. **승인 없이는 절대 저장하지 않습니다.**
4. **작성** — 승인하면 해당 유형의 템플릿을 채워 vault에 Markdown으로 저장합니다.
5. **자체 검수** — 저장한 문서를 다시 읽고 `references/writing-rules.md`의 체크리스트로 스스로
   점검합니다. 상수에 실제 값이 있는지, 튜닝 숫자에 근거가 붙었는지, 표기가 일관된지 —
   *"6개월 뒤 이 문서만 보고 재현할 수 있는가"* 를 통과해야 완료입니다.

SKILL.md는 얇은 **오케스트레이터**이고, 세부 판단 기준은 `references/`에 분리돼 필요할 때만
읽힙니다. 덕분에 규칙을 늘려도 프롬프트가 비대해지지 않습니다.
전체 구조는 [docs/architecture.md](docs/architecture.md), 철학은
[docs/philosophy.md](docs/philosophy.md) 참고.

## 저장소 구조

```
Developer-Second-Brain/
├── .claude-plugin/        # 플러그인 매니페스트 + 마켓플레이스
├── skills/second-brain/   # 핵심 스킬 (Documentation Engineer, 자기 완결적)
│   ├── references/        #   탐지 규칙 · 중요도 점수 · 유형 · 작성 규칙 · vault 레이아웃
│   └── templates/         #   유형별 한국어 문서 템플릿 (스킬이 소유 → 심링크 1개로 동작)
├── commands/              # /document 슬래시 명령 (플러그인 설치 시)
├── scripts/               # install-dev.sh / uninstall-dev.sh (심링크 개발 설치)
├── docs/                  # 아키텍처 · 철학 · 로드맵
├── examples/              # 산출물 예시
├── hooks/                 # (v0.4) 자동 탐지 훅 자리
├── PROJECT_PRINCIPLES.md  # 헌법 격 문서 (장기 설계 철학·판단 기준)
├── CONTRIBUTING.md        # 기여·개발 가이드
└── CHANGELOG.md           # 버전별 변경 이력
```

## 로드맵

`docs/roadmap.md` 참고.

- **v0.1 (현재)** — Documentation Skill (로컬 Markdown)
- **v0.2** — Importance Score 정교화
- **v0.3** — Notion 연동 (장기 저장소)
- **v0.4** — Hooks (자동 탐지)
- **v0.5** — Resume Material / STAR 확장
- **v1.0** — Developer Second Brain 완성 (Resume Score · Interview Candidate · Knowledge Graph · Weekly/Monthly Report)

## 라이선스

MIT — `LICENSE` 참고.
