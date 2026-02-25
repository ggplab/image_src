# 📧 AI Email Automation System

> **AI 기반 이메일 자동 분류 및 일정 관리 시스템**
Gmail 안읽은 이메일을 자동으로 분석하고, 일정을 캘린더에 등록하며, 구조화된 데이터로 저장하는 지능형 워크플로우
> 



## 📸 시스템 스크린샷

### n8n 워크플로우 구조

<img width="1235" height="710" alt="n8n_workflow" src="https://github.com/user-attachments/assets/74724e2a-4036-4fd1-b2d2-5264eea4b3df" />


### 실제 결과물

**Google Sheets 자동 기록**

<img width="1272" height="420" alt="google sheets" src="https://github.com/user-attachments/assets/a4ae5cc8-ba64-4fd4-bdbd-78579810db43" />


**Google Calendar 자동 등록**

<img width="410" height="330" alt="calendar" src="https://github.com/user-attachments/assets/d3b50e0d-a581-4cf8-8ec4-58dcb63df2f3" />

<img width="508" height="214" alt="calendar2" src="https://github.com/user-attachments/assets/ca320b85-7a8c-4ba1-a4f4-c2c8c2db67a8" />



## 📋 목차

- 문제 정의
- 예상 사용자/부서
- 사용 방법
- 사용 비용
- 참고 문헌



## 🎯 1. 문제 정의

### Gmail의 한계와 반복적인 수동 작업

매일 수십 통의 이메일을 확인하고, 중요한 일정을 수동으로 캘린더에 입력하며, 광고와 업무 메일을 구분하는 과정은 비효율적이고 반복적인 작업입니다. 이 과정에서 다음과 같은 문제들이 발생합니다:

- **정보 손실**: 일정이 포함된 이메일을 놓치거나, 중요한 마감일을 캘린더에 입력하지 못함
- **시간 낭비**: 매일 이메일을 수동으로 분류하고 정리하는 데 30분 이상 소요
- **불명확한 우선순위**: 어떤 이메일이 긴급하고 중요한지 판단하기 어려움
- **수동 데이터 입력**: 이메일 → 캘린더 → 스프레드시트 반복 작업

### Gmail 기본 기능의 한계

| 기능 | Gmail | 본 시스템 |
| --- | --- | --- |
| 라벨링 | ✅ 가능 | ✅ 더 정교한 AI 분류 |
| 일정 캘린더 등록 | ❌ 불가능 | ✅ **자동 등록** |
| 내용 요약 | ❌ 없음 | ✅ **AI 자동 요약** |
| 우선순위 판단 | ❌ 수동 | ✅ **AI 자동 판단** |
| 필요한 행동 파악 | ❌ 수동 | ✅ **AI 자동 추출** |

### 달성 가치

반복적이고 비효율적인 작업을 제거함으로써 **월 10시간 이상 절약**하고, AI 기반 자동 분석으로 다음을 실현합니다:

- ✅ **자동 일정 추출 & 캘린더 등록**: "12월 8일 오후 2시 회의" → Google Calendar 자동 등록
- ✅ **AI 기반 카테고리 분류**: 공지/업무/광고/스팸/자동알림 정확한 분류
- ✅ **핵심 내용 자동 요약**: 긴 이메일 → 1~3문장 핵심 요약
- ✅ **우선순위 자동 판단**: 높음/보통/낮음 자동 분류
- ✅ **스마트 필터링**: API 비용 30% 절감



## 👥 2. 예상 사용자/부서

본 워크플로우는 정기적으로 이메일을 관리하고 일정을 추적해야 하는 모든 사용자에게 유용합니다.

- **PM (프로젝트 관리자)**: 프로젝트 일정과 마감일 자동 트래킹
- **마케터 / 기획자**: 캠페인 일정 및 파트너사 미팅 관리
- **영업 / CS 담당자**: 고객 미팅 및 팔로업 일정 자동 정리
- **팀 리더 / 임원**: 주요 회의 및 결정 사항 신속 파악
- **모든 사무직 종사자**: 이메일 정리 및 일정 관리 업무에서 해방



## 💻 3. 사용 방법

### 3.1 필요한 API 및 Credential

다음 서비스들의 API를 발급받고 n8n에 연결해야 합니다:

1. **Gmail API** (OAuth2)
    - 안읽은 이메일 수집 및 읽음 처리
2. **OpenAI API**
    - 모델: GPT-4o-mini
    - 이메일 내용 분석 및 일정 추출
3. **Google Sheets API** (OAuth2)
    - 이메일 데이터 자동 저장
4. **Google Calendar API** (OAuth2)
    - 일정 자동 등록

### 3.2 워크플로우 설치

1. **JSON 파일 import**
    
    ```bash
    # GitHub에서 워크플로우 다운로드
    git clone https://github.com/your-repo/email-automation.git
    
    # n8n에서 Import
    n8n > Workflows > Import from File > email_automation_workflow.json
    
    ```
    
2. **Credential 설정**
    - Gmail OAuth2 연결
    - OpenAI API Key 입력
    - Google Sheets OAuth2 연결
    - Google Calendar OAuth2 연결
3. **Google Sheets 설정**
    - 새 스프레드시트 생성
    - Sheet 이름: `email-log`
    - 워크플로우의 `YOUR_GOOGLE_SHEETS_ID`를 실제 ID로 교체
4. **Calendar 설정**
    - 워크플로우의 `your-email@gmail.com`을 실제 Gmail 주소로 교체

### 3.3 워크플로우 상세 설명

### 전체 흐름

```
Schedule Trigger (매일 오전 8시)
  ↓
안읽은 이메일 가져오기 (Gmail API)
  ↓
이메일 전처리 (본문 추출, HTML 제거)
  ↓
Sender Filter (VIP/화이트/블랙리스트 분류)
  ↓
분석 제외 필터 (블랙리스트 스킵)
  ↓
OpenAI 분석 (카테고리, 우선순위, 요약, 일정)
  ↓
JSON 파싱 (구조화)
  ↓
schedule_start 생성 (정확한 날짜/시간 추출)
  ↓
Google Sheets 기록
  ↓
일정 여부 확인 (IF)
  ↓
Google Calendar 등록 / 이메일 읽음 처리

```

### 노드별 기능

<details><summary><b>1. Schedule Trigger</b></summary>

**기능**: 워크플로우 자동 실행

**설정**: 

- 매일 아침 8*시에 하려고 할 때!
- Trigger Interval : Days 로 설정*
- Days Between Triggers : 1 (며칠 마다 실행할건지)
- Trigger at Hour : 8am(하고 싶은 시간)
- Trigger at Minute : 0 (하고싶은 분)

**용도**: 매일 아침 이메일 자동 처리

</details><details><summary><b>2. 안읽은 이메일 가져오기 (Gmail)</b></summary>

**기능**: Gmail API로 UNREAD 이메일 수집

**설정**:

- Resource: Message
- Operation: Get Many
- Filters: `is:unread`
- Limit: 20개(설정 가능)

**출력**: 안읽은 이메일 목록

</details><details><summary><b>3. 이메일 전처리 (Code Node)</b></summary>

**기능**: 이메일 원본 데이터를 AI가 분석 가능한 형태로 가공

**처리 내용**:

1. 본문 추출 (text/html 필드)
2. HTML 태그 제거
3. 3000자 제한 (OpenAI 토큰 절약)
4. 오늘 날짜 생성
5. 첨부파일 정보 추출

**출력**: `cleanBody`, `today`, `hasAttachments` 등

</details><details><summary><b>4. Sender Filter (Code Node)</b></summary>

**기능**: 발신자 이메일 주소로 처리 우선순위 결정

**필터 분류**:

- **VIP**: 최우선 처리 (항상 AI 분석)
- **Whitelist**: 신뢰 발신자 (처리)
- **Blacklist**: 차단 발신자 (스킵)
- **일반**: 기타 모든 이메일

**효과**: **API 비용 ~30% 절감**

</details><details><summary><b>5. 분석 제외 필터 (IF Node)</b></summary>

**기능**: 블랙리스트 이메일 OpenAI 분석 제외

**조건**: `{{ $json.isValid === true }}`

**용도**: 불필요한 API 호출 방지

</details><details><summary><b>6. OpenAI로 이메일 분석 (OpenAI Node)</b></summary>

**기능**: GPT-4o-mini로 이메일 내용 AI 분석

**분석 항목**:

- `category`: 공지/업무/광고/스팸/파일전송/자동알림
- `priority`: 높음/보통/낮음
- `summary`: 1~3문장 핵심 요약
- `has_schedule`: 일정 여부 (true/false)
- `schedule_info`: 일정 설명 (한국어)
- `schedule_start/end`: ISO8601 날짜 형식
- `action_required`: 필요한 행동
- `days_until`: D-day

**모델 설정**:

- Model: `gpt-4o-mini`
- Temperature: 0.3

</details><details><summary><b>7. JSON 파싱 (Code Node)</b></summary>

**기능**: OpenAI 응답을 JSON으로 파싱하고 이메일 정보와 통합

**처리**:

1. Markdown 코드 블록 제거
2. JSON 파싱
3. 원본 데이터와 통합

</details><details><summary><b>8. schedule_start 생성 (Code Node) ⭐</b></summary>

**기능**: `schedule_info` 텍스트에서 정확한 날짜/시간 추출

**인식 패턴**:

- "2026년 1월 1일 오전 11시" → `2026-01-01T11:00:00+09:00`
- "11월 18일" → `2025-11-18T09:00:00+09:00`
- "11월 18일 ~ 24일" → start + end 모두 생성
- "12월 8일 오후 2시" → `2025-12-08T14:00:00+09:00`

**중요성**: OpenAI가 놓친 날짜도 100% 추출 → 정확한 캘린더 등록!

</details><details><summary><b>9. Google Sheets 기록</b></summary>

**기능**: 모든 이메일 정보를 스프레드시트에 저장

**저장 컬럼**:

- date, sender, subject
- category, priority, summary
- has_schedule, schedule_info
- sender_type, action_required
- days_until, processed_at

</details><details><summary><b>10. 캘린더 등록 여부 확인 (IF Node)</b></summary>

**기능**: 일정이 있는 이메일만 Google Calendar로 분기

**조건**: `{{ $json.has_schedule === true }}`

</details><details><summary><b>11. Google Calendar 등록</b></summary>

**기능**: 이메일 일정을 캘린더 이벤트로 자동 생성

**설정**:

- Calendar: `primary`
- Start: `{{ $json.schedule_start }}`
- End: `{{ $json.schedule_end || $json.schedule_start }}`
- Summary: `{{ $json.subject }}`
- Timezone: `Asia/Seoul`

</details><details><summary><b>12. 이메일 읽음 표시 (Gmail Node)</b></summary>

**기능**: 처리 완료된 이메일을 읽음으로 처리

**용도**: 중복 처리 방지

</details>

### 3.4 프롬프트 예시

<details><summary><b>OpenAI System Prompt (이메일 분석)</b></summary>

```
너는 이메일 비서야. 아래 이메일을 읽고 JSON 하나를 만들어줘.

**중요: 반드시 아래 형식의 순수 JSON만 반환해.**

오늘 날짜: {{ $json.today }}

필드 정의:
- category: "공지" | "업무" | "광고" | "스팸" | "파일전송" | "자동알림"
- priority: "높음" | "보통" | "낮음"
- summary: 한국어로 1~3문장 핵심 요약
- has_schedule: 날짜와 시간이 명확히 숫자로 표현된 경우에만 true
- schedule_info: 사람이 읽기 좋은 한국어 일정 설명
- schedule_start: ISO8601 형식 시작 시각 (KST, UTC+9)
- schedule_end: ISO8601 형식 종료 시각 (없으면 null)
- action_required: 수신자가 해야 할 행동
- days_until: 오늘 기준 일정까지 남은 날짜 수

---

**날짜/시간 인식 규칙**

1. 단일 날짜: "12월 8일 오후 2시" → "2025-12-08T14:00:00+09:00"
2. 기간: "11월 18일 ~ 24일"
   → start: "2025-11-18T09:00:00+09:00"
   → end: "2025-11-24T23:59:59+09:00"
3. 시간 기본값: 09:00 (시간 명시 없으면)

---

**JSON 예시**

{
  "category": "업무",
  "priority": "높음",
  "summary": "12월 8일 오후 2시 한강 떼러기 대회 참가 안내",
  "has_schedule": true,
  "schedule_info": "12월 8일 오후 2시",
  "schedule_start": "2025-12-08T14:00:00+09:00",
  "schedule_end": null,
  "action_required": "참석 여부 회신",
  "days_until": 19
}
```
</details>


## 💰 4. 사용 비용

### API 사용량 및 비용

| 항목 | 비용 | 비고 |
| --- | --- | --- |
| **OpenAI API** | $0.45/월 | GPT-4o-mini, 하루 20개 이메일 기준 |
| **Gmail API** | 무료 | Google Workspace 기본 제공 |
| **Google Sheets API** | 무료 | Google Workspace 기본 제공 |
| **Google Calendar API** | 무료 | Google Workspace 기본 제공 |
| **n8n Hosting** | 무료 ~ $20/월 | Self-hosted 시 무료 |

### 비용 세부 계산

**OpenAI API (GPT-4o-mini)**:

- 가격: $0.15 / 1M input tokens, $0.60 / 1M output tokens
- 이메일 1개당: ~500 tokens (input) + ~200 tokens (output)
- 하루 20개 처리 시: 10,000 input + 4,000 output tokens
- **월 비용**: 약 $0.45 (약 600원)

**절감 효과**:

- 발신자 필터링으로 **30% 절감**
- 실제 월 비용: **약 420원**

### 시간 절약 가치

- 이메일 수동 분류: 하루 30분 → **0분**
- 캘린더 입력: 하루 10분 → **0분**
- **월 20시간 절약** (시급 1만원 기준 = 월 20만원 가치)



## 📚 5. 참고 문헌

### 관련 링크

- [n8n 공식 문서](https://docs.n8n.io/)
- [OpenAI API 문서](https://platform.openai.com/docs)
- [Gmail API 가이드](https://developers.google.com/gmail/api/guides)
- [Google Calendar API 가이드](https://developers.google.com/calendar/api/guides/overview)

### 영감을 받은 워크플로우

- https://n8n.io/workflows/5678-automate-email-filtering-and-ai-summarization-100percent-free-and-effective-works-724/
- https://n8n.io/workflows/4807-smart-email-responder-workflow-using-ai/


## 🎯 주요 기능 요약

### Gmail vs 본 시스템 비교

| 기능 | Gmail | 본 시스템 |
| --- | --- | --- |
| 라벨링 | ✅ 가능 | ✅ AI 정교한 분류 |
| 일정 캘린더 등록 | ❌ 불가능 | ✅ **자동 등록** ⭐ |
| 내용 요약 | ❌ 없음 | ✅ **AI 자동 요약** ⭐ |
| 우선순위 판단 | ❌ 수동 | ✅ **AI 자동 판단** ⭐ |
| 필요한 행동 파악 | ❌ 수동 | ✅ **AI 자동 추출** ⭐ |
| API 비용 최적화 | - | ✅ **스마트 필터링 30% 절감** |

### 핵심 차별점

1. **🗓️ 자동 일정 추출 & 캘린더 등록**
    - "12월 8일 오후 2시 회의" → Google Calendar 자동 등록
    - Gmail에서는 **불가능**한 기능!
2. **🤖 AI 기반 카테고리 자동 분류**
    - 공지/업무/광고/스팸/자동알림 정확한 분류
    - Gmail 라벨보다 **훨씬 정교**
3. **📝 핵심 내용 자동 요약**
    - 긴 이메일 → 1~3문장 핵심 요약
    - 이메일 열지 않고도 내용 파악 가능
4. **⚡ 우선순위 자동 판단**
    - 높음/보통/낮음 자동 분류
    - 긴급 이메일 놓치지 않음
5. **💰 스마트 필터링 (비용 절감)**
    - VIP/화이트/블랙리스트 필터링
    - API 비용 30% 절감


## 🚀 시작하기

```bash
# 1. 저장소 클론
git clone https://github.com/your-repo/email-automation.git

# 2. n8n에서 워크플로우 import
# n8n > Workflows > Import from File > email_automation_workflow.json

# 3. Credentials 설정
# Gmail, OpenAI, Google Sheets, Google Calendar API 연결

# 4. 워크플로우 활성화
# Activate 버튼 클릭

# 5. 테스트 실행
# Execute Workflow 버튼 클릭

```



## 📊 기대 효과

- ⏱️ **시간 절약**: 월 20시간 이상
- 📅 **일정 관리**: 자동 캘린더 등록으로 일정 놓침 방지
- 🎯 **우선순위**: AI 자동 분류로 중요 이메일 즉시 파악
- 💰 **비용 효율**: 월 500원으로 완전 자동화
- 📈 **생산성**: 반복 작업 제거, 핵심 업무 집중
