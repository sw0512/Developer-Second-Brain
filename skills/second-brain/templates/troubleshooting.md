---
title: "{{제목}}"
date: {{YYYY-MM-DD}}
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
    type: troubleshooting
    alternates: []
  explanation: "{{evidence 신호에서 렌더된 한 줄}}"
# 다른 목적(resume/interview/portfolio) Assessment는 이후 버전에서 필요 시 계산
---

# {{제목}}

## 🐞 문제
무슨 일이 있었는가? 증상, 에러 메시지, 재현 조건을 구체적으로.

```
(실제 에러 로그 / 스택트레이스)
```

## 🔍 원인
왜 발생했는가? 근본 원인(root cause)을.

## 🛠 시도한 것들
- 시도 1 → 결과
- 시도 2 → 결과

## ✅ 최종 해결
어떻게 해결했는가? 핵심 변경 사항과 코드.

```
(핵심 코드 / 설정)
```

## 💡 배운 점
다음에 같은 상황을 만나면 무엇을 기억해야 하는가? 재사용 가능한 교훈.

## 🎤 면접 활용 포인트
이 경험이 답이 될 수 있는 예상 질문. (있으면)
