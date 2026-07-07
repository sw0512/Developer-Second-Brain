---
title: "{{제목}}"
date: {{YYYY-MM-DD}}
status: accepted   # proposed | accepted | superseded
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
    type: adr
    alternates: []
  explanation: "{{evidence 신호에서 렌더된 한 줄}}"
# 다른 목적(resume/interview/portfolio) Assessment는 이후 버전에서 필요 시 계산
---

# ADR: {{제목}}

## 📌 배경 / 문제
어떤 결정을 내려야 했는가? 어떤 제약과 요구사항이 있었는가?

## 🔀 후보들
| 후보 | 장점 | 단점 |
|------|------|------|
| A | | |
| B | | |
| C | | |

## ✅ 최종 선택
무엇을 선택했는가.

## ⚖️ Trade-off
이 선택으로 무엇을 얻고 무엇을 포기했는가.

## 📈 결과 / 영향
(가능하면 측정치: 지연시간, 처리량, 에러율, 비용 등)

## 🎤 면접 활용 포인트
"왜 {{선택한 기술}}을 선택했나요?"에 대한 답의 핵심.
