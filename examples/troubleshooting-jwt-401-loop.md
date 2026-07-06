---
type: troubleshooting
title: "JWT Refresh Token 재발급 시 401 무한루프 해결"
date: 2026-07-06
importance: ⭐⭐⭐⭐
tags: [JWT, Spring Security, Refresh Token, 인증]
---

# JWT Refresh Token 재발급 시 401 무한루프 해결

> 이 파일은 산출물 예시입니다. 실제로는 vault(`~/DeveloperSecondBrain/troubleshooting/`)에 저장됩니다.

## 🐞 문제
Access Token 만료 후 프론트엔드가 `/auth/refresh`로 재발급을 요청하면, 재발급 응답까지
401이 반환되며 클라이언트가 refresh 요청을 무한 반복했다.

```
GET /api/me        → 401
POST /auth/refresh → 401   ← 여기가 문제
POST /auth/refresh → 401
... (무한 반복)
```

## 🔍 원인
Spring Security 필터 체인에서 `/auth/refresh` 경로도 JWT 인증 필터를 통과하도록 되어 있었다.
Access Token이 만료된 상태라 refresh 엔드포인트 자체가 인증 실패로 401을 반환했고,
클라이언트 인터셉터는 그 401을 다시 "토큰 만료"로 해석해 refresh를 재시도 → 무한루프.

## 🛠 시도한 것들
- 클라이언트 인터셉터에 재시도 횟수 제한 추가 → 증상은 멎지만 근본 원인 아님.
- refresh 응답 상태코드를 200 고정 → 실제 실패를 숨겨 더 위험.

## ✅ 최종 해결
`/auth/refresh`를 JWT 인증 필터의 예외 경로로 지정하고, refresh는 **Refresh Token만으로**
검증하도록 분리했다.

```java
http.securityMatcher("/**")
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/auth/refresh", "/auth/login").permitAll()
        .anyRequest().authenticated());
```

## 💡 배운 점
- 인증 "우회 경로"(refresh/login)는 반드시 인증 필터에서 제외해야 한다.
- 401을 재시도 트리거로 쓸 때는 **refresh 엔드포인트 자신의 401**을 구분해야 무한루프를 피한다.

## 🎤 면접 활용 포인트
- "JWT 인증에서 토큰 만료를 어떻게 처리했나요?"
- "무한루프 같은 장애를 디버깅한 경험이 있나요?"
