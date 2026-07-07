---
title: "{{제목}}"
date: {{YYYY-MM-DD}}
scope: {{task | sprint | project}}
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
    type: retrospective
    alternates: []
  explanation: "{{evidence 신호에서 렌더된 한 줄}}"
# 다른 목적(resume/interview/portfolio) Assessment는 이후 버전에서 필요 시 계산
---

# 회고: {{제목}}

## 👍 잘한 점
효과가 있었던 결정과 행동.

## 👎 아쉬운 점
잘 안 됐던 것, 시간을 낭비한 부분.

## 🔧 개선점
다음에 다르게 할 것. 구체적인 액션으로.

## 🎯 다음 액션
- [ ] {{할 일}}
