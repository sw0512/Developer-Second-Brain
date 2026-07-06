# Architecture

Developer Second Brain은 Claude Code의 확장 지점(Skill · Command · Hook · Template)을
조합한 플러그인입니다.

## 큰 그림

```
Claude Code
   │
   ▼
Skill (second-brain)         ← 역할: Documentation Engineer
   │   ├─ references/         ← 판단 근거 (탐지 규칙 · 중요도 · 유형 · vault)
   │   └─ templates/          ← 유형별 출력 형식
   ▼
Classification & Scoring      ← 기록 가치 판단 + 유형 선택 + ⭐ 점수
   │
   ▼
User Approval (필수)          ← 자동 저장 금지
   │
   ▼
Local Vault (Markdown)        ← v0.1 저장소
   │
   ▼
Notion MCP (v0.3+)            ← 장기 Second Brain
```

## 컴포넌트별 역할

### 1. Skill — `skills/second-brain/SKILL.md`
시스템의 두뇌. Claude에게 Documentation Engineer 역할을 부여하고 워크플로를 정의합니다.
- 언제 발동할지: 비자명한 개발 문제 해결 이후 (버그·기술선택·라이브러리·성능·인증·DB·API·아키텍처).
- 무엇을 하는지: 판단 → 유형 선택 → 점수 → 제안 → (승인 시) 작성.

### 2. References — `skills/second-brain/references/`
Skill이 필요할 때 읽어들이는 판단 기준. Skill 본문을 얇게 유지하고 세부 규칙을 분리합니다.
- `detection-rules.md` — 기록/비기록 판단.
- `doc-types.md` — 유형 선택.
- `importance-score.md` — ⭐ 점수 산정.
- `vault-layout.md` — 저장 위치·파일명 규칙.

### 3. Templates — `skills/second-brain/templates/`
유형별 한국어 출력 형식. frontmatter에 `type/importance/tags` 등 메타데이터를 담아
향후 Resume Score·Knowledge Graph의 기반이 됩니다.
템플릿을 **스킬 폴더 안에 두어** 스킬이 자기 완결적이 됩니다 — `~/.claude/skills/`로
심링크 하나만 걸어도 references·templates가 모두 따라오므로 즉시 테스트가 가능합니다.

### 4. Command — `commands/document.md`
`/document` 수동 트리거. 자동 제안을 놓쳤거나 과거 작업을 정리할 때 사용.

### 5. Hooks — `hooks/` (v0.4)
대화 종료(Stop) 등 이벤트에 자동으로 "기록할까요?" 판단을 붙이는 자리.
v0.1에서는 비활성 (자리만 확보).

## 설계 원칙이 구조에 반영된 방식

- **자동 저장 금지** → 저장은 항상 User Approval 이후 단계로 분리.
- **한국어 출력 / 영어 프롬프트** → Skill·references는 영어, templates·산출물은 한국어.
- **확장 가능** → 저장소 추상화(local → Notion), 메타데이터 frontmatter, 훅 자리 확보.
- **프로젝트 독립** → vault는 전역 위치. 소스 저장소와 데이터 저장소를 분리.

## 확장 이음새 (Extension Seams)

로드맵의 기능들이 **구조를 갈아엎지 않고** 어디에 붙는지 미리 정의합니다. 핵심 개념은
세 가지 축입니다:

1. **Capture side (쓰기)** — 경험을 문서로 만든다. (현재 `second-brain` 스킬)
2. **Storage layer (저장)** — 문서가 어디에 사는가. (현재 로컬 vault, `vault-layout.md`가 유일한 결합점)
3. **Read side (읽기·생성)** — 쌓인 문서를 읽어 새 산출물을 만든다. (리포트·면접 준비 등, 아직 없음)

문서 frontmatter의 메타데이터(`type/importance/tags/date`)가 세 축을 잇는 계약입니다.

| 미래 기능 | 어디에 붙나 | 왜 재구조화가 불필요한가 |
|-----------|-------------|--------------------------|
| **Notion MCP** (v0.3) | Storage layer | 저장 결합점이 `vault-layout.md` 한 곳. 로컬 대신 Notion 어댑터를 추가하면 됨. 문서 형식(frontmatter+Markdown)은 그대로. |
| **Hooks** (v0.4) | Capture 트리거 | `hooks/hooks.json` 추가만. 판단 로직은 기존 `references/`를 재사용. 스킬 본체 무변경. |
| **ADR 생성** | Capture (기존 유형) | 이미 `adr` 유형·템플릿 존재. 추가 작업 없음. |
| **Resume material 생성** | Capture (기존 유형) + Read side | `resume-material` 유형 존재. STAR 확장은 템플릿 frontmatter(`resume_score` 등)로 확장. |
| **Interview 준비** | Read side (신규 스킬) | vault의 `resume-material`·`troubleshooting`을 읽어 예상 질문 생성하는 별도 스킬/명령. 캡처 스킬 불변. |
| **Weekly/Monthly Report** | Read side (신규 스킬) | frontmatter의 `date/type/importance`를 집계하는 읽기 전용 스킬. vault 스키마가 이미 이를 지원. |

원칙: **캡처 스킬은 커지지 않는다.** 새 "생성" 기능은 vault를 *읽는* 별도 스킬/명령으로
추가하고, 저장소 교체는 storage layer 한 곳에서만 일어납니다.
