---
title: "{{제목}}"
date: {{YYYY-MM-DD}}
project: {{repo-name}}
tags: [{{기술, 키워드}}]

# Evidence — observed, purpose-independent facts (references/detection-rules.md)
evidence:
  contributing_signals:
    - group: {{difficulty|decision|novelty|domain}}
      support: "{{관찰된 사실 한 줄}}"
  resolution: {{confirmed|partial|none}}
  explicit_request: {{true|false}}
  negatives: []

# Assessment — judgments derived from Evidence for this purpose
assessment:
  purpose: documentation
  should_document: true
  importance: "{{⭐ 개수}}"
  confidence: {{high|medium|low}}
  classification:
    type: how-to
    alternates: []
  explanation: "{{evidence 신호에서 렌더된 한 줄}}"
# 다른 목적(resume/interview/portfolio) Assessment는 이후 버전에서 필요 시 계산
---

# 🧭 {{제목}}

## 상황
왜 이 절차가 필요했는가. 출발점의 전제 조건(무엇이 이미 있었고 무엇이 없었는지)까지.

## 절차
번호를 붙여 순서대로. 각 단계는 **왜 이 단계가 필요한지** 한 줄과 함께.

### 1. {{단계}}

<!-- 스니펫은 이 문서만 보고 재현 가능해야 한다.
     등장하는 상수·경로·설정값은 반드시 실제 값을 함께 적는다 (이름만 두지 말 것). -->

```
(명령 / 설정 / 코드 — 실제 값)
```

### 2. {{단계}}

## 확인
제대로 됐는지 무엇을 보고 판단했는가. 관찰 가능한 신호(로그, 네트워크 탭, 응답 코드)로.

## 되돌리기 / 제거
임시 구조물(목, 프록시, 우회 설정)이면 **언제 걷어내고 무엇을 지우면 되는지**.
영구 구성이면 `(해당 없음)`.

## 주의점 / 함정
이 절차를 다시 밟는 사람이 걸려 넘어질 지점.

## 💡 배운 점
다음에 같은 작업을 만나면 무엇을 기억해야 하는가? 절차가 아니라 재사용 가능한 판단.
