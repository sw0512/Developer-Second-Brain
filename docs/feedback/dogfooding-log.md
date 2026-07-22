# Dogfooding Log

실제 개발에서 `second-brain` 스킬을 써보며 남기는 관찰 기록. 목표는 감상이 아니라 **튜닝 가능한 신호**를
모으는 것. 모든 오작동은 이상적으로 `tests/fixtures/`의 회귀 케이스가 된다.

## 루프

```
개발 → 스킬 제안(또는 침묵) → 여기 한 줄 기록 → 트리아지 → (오작동이면) fixture화 → references 수정 → v0.2.x
```

## 트리아지 범주 → 튜닝 대상

| 범주 | 뜻 | 고칠 곳 |
|------|-----|---------|
| `false-positive` | 기록할 것 아닌데 제안함 | `references/detection-rules.md` (게이트/신호) |
| `miss` | 기록할 만한데 조용함 | `references/detection-rules.md` (신호 taxonomy) |
| `timing` | 작업 중간에 끼어듦 | `references/interruption-policy.md` (확신도) |
| `classification` | 유형을 잘못 고름 | `references/doc-types.md` |
| `score` | ⭐가 과하거나 부족 | `references/importance-score.md` (앵커) |
| `explanation` | 설명이 Evidence와 안 맞음 | 렌더 규칙 |
| `content` | 판단은 맞았는데 **쓰인 문서가 부실** (재현 불가·근거 없는 숫자·표기 불일치) | `references/writing-rules.md` + `templates/` |
| `good` | 잘 작동함 (긍정 확인) | — (회귀 방지용 fixture 후보) |

## 기록 템플릿 (복사해서 아래 Entries에 추가)

```
### YYYY-MM-DD — <한 줄 제목>
- 상황: <무슨 작업을 하고 있었나>
- 엔진 동작: <제안함 / 침묵 / 유형 X로 분류 / ⭐N / hold ...>
- 기대: <맞았다면 good, 틀렸다면 무엇이 맞았어야 하나>
- 범주: false-positive | miss | timing | classification | score | explanation | good
- 조치: fixture화? / references 수정? / 관찰만
```

---

## Entries

<!-- 최신 항목을 위로. 아래는 형식 예시이며 실제 기록으로 대체하세요. -->

### 2026-07-22 — 로그인 공 바운스 문서: 탐지는 정확, 내용이 재현 불가
- 상황: 오늘의 터 로그인 인트로(CSS 키프레임 → rAF 물리 전환 + 연쇄 디버깅)를 다른 세션에서 문서화
- 엔진 동작: 제안함 / troubleshooting / ⭐4 / confidence high — **탐지·분류·점수는 모두 정확**
- 기대: 판단은 good. 다만 저장된 문서 자체에 3가지 결함
  1. 코드 스니펫에 `GRAVITY`·`VX`·`SQUASH_DUR`이 **이름만 있고 값이 없어** 문서만으로 재현 불가
  2. 반발계수 `0.66`의 **출처가 없음** (계산인지 감인지 불명) → 재사용 시 가장 먼저 막히는 지점
  3. "오늘의터"/"오늘의 터" 표기 불일치
- 범주: `content` (신설 — 기존 표에 해당 칸이 없었음)
- 조치: `references/writing-rules.md` 신설(R1~R5 + 자체 검수 체크리스트), `SKILL.md`에 워크플로
  6단계 "자체 검수" 추가, `templates/troubleshooting.md`에 상수 블록 + "이 숫자들은 어떻게 정했나"
  절 추가. 원문 문서는 실제 소스에서 값을 읽어와 보강 완료.
- 추가 관찰: 값을 채우다 **반발계수와 수평속도가 서로 물려 있다**(e가 3회째 접지 시각을 정하고 →
  거기서 VX를 역산)는 걸 발견. 이런 커플링은 원 세션에서도 놓쳤던 정보 → R3로 규칙화.
- 후속 후보: 문서 품질은 fixture(입력→판단)로는 안 잡힌다. 산출물 검증용 별도 하니스가 필요한지 검토.

### 2026-07-07 — (예시) 오타 수정에는 조용했음
- 상황: 변수명 오타 하나 고침
- 엔진 동작: 침묵
- 기대: good (게이트가 정상적으로 제외)
- 범주: good
- 조치: 관찰만 (fixture 06과 동일 케이스, 이미 커버됨)
