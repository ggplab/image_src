# 5장. 회의록 STT

> 음성 파일을 n8n으로 전달하면, Gemini가 음성을 전사하고 AI가 교정·요약 후 Google Drive 저장 및 Notion 회의록을 자동 생성하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | Webhook (iOS), Google Drive 트리거 또는 Telegram 봇 (Android) |
| 주요 서비스 | Google Gemini 2.5 Flash, Google Drive, Notion |
| 출력 | Google Drive 전사 텍스트 파일 + Notion 회의록 DB 페이지 |

## 워크플로우 흐름

```
Webhook
  │
  ▼
Transcribe a recording(gemini)   ← Gemini 2.5 Flash로 음성 → 텍스트 변환 (STT)
  │
  ▼
meeting_transcript_text_file     ← 전사 텍스트를 .txt 파일로 변환
  │
  ▼
Upload file                      ← Google Drive meeting 폴더에 업로드
  │
  ▼
Check Typo                       ← Gemini: STT 오류 교정·윤문
  │
  ▼
Summarize                        ← Gemini: JSON 형식 회의록 생성
  │
  ▼
Create a database page(meeting)  ← Notion DB에 회의록 페이지 생성
```

## 노드 구성

1. **Webhook** — iOS 단축어에서 전송된 오디오 파일(바이너리)을 POST로 수신합니다. path: `audio-transcribe`
2. **Transcribe a recording(gemini)** — Gemini 2.5 Flash의 audio 리소스로 바이너리 음성 파일을 텍스트로 전사(STT)합니다.
3. **meeting_transcript_text_file** — 전사 결과를 `.txt` 파일로 변환합니다. 파일명은 원본 오디오 파일명 기반으로 동적 생성합니다.
4. **Upload file** — 변환된 텍스트 파일을 Google Drive의 `meeting` 폴더에 업로드합니다.
5. **Check Typo** — Gemini 2.5 Flash로 STT 전사 텍스트의 맞춤법·문맥 오류를 교정하고 윤문합니다.
6. **Summarize** — 교정된 텍스트를 바탕으로 Gemini가 JSON 형식 회의록(날짜, 제목, 한줄 요약, 참석자, 상세 요약)을 생성합니다.
7. **Create a database page(meeting)** — 생성된 회의록 JSON을 파싱하여 Notion 데이터베이스에 페이지를 생성하고 Google Drive 파일 링크를 첨부합니다.

---

## 표현식 (Expressions)

n8n 표현식(`={{ }}`)은 이전 노드의 데이터를 현재 노드에서 동적으로 참조할 때 사용합니다.

### meeting_transcript_text_file — 파일명 동적 생성

```
={{ $('Webhook').item.binary.data.fileName.replace(/\.[^.]+$/, '') }}_회의록.txt
```

| 표현식 요소 | 목적 |
|---|---|
| `$('Webhook').item.binary.data.fileName` | Webhook으로 수신된 원본 오디오 파일명 참조 |
| `.replace(/\.[^.]+$/, '')` | 확장자 제거 (예: `meeting.m4a` → `meeting`) |
| `+ '_회의록.txt'` | 텍스트 파일 식별을 위한 접미사 추가 |

**목적:** 업로드된 오디오 파일과 대응되는 전사 텍스트 파일을 일관된 이름으로 저장합니다.

---

### Check Typo — 이전 노드 전사 결과 참조

```
=[음성 인식 텍스트]
{{ $('Transcribe a recording(gemini)').item.json.content.parts[0].text }}
```

| 표현식 요소 | 목적 |
|---|---|
| `$('Transcribe a recording(gemini)')` | 노드명으로 특정 이전 노드를 직접 참조 (직전 노드가 아닌 경우 사용) |
| `.item.json.content.parts[0].text` | Gemini API 응답 구조에서 전사 텍스트 추출 |

**목적:** 직전 노드가 아닌 특정 노드(Upload file 이후지만, Transcribe 결과가 필요)의 데이터를 가져옵니다. `$('노드명')`으로 워크플로우 어디서든 과거 노드 결과를 참조할 수 있습니다.

---

### Summarize — 교정 결과 참조

```
={{ $json.content.parts[0].text }}
```

| 표현식 요소 | 목적 |
|---|---|
| `$json` | 직전 노드(Check Typo)의 출력 JSON 참조 |
| `.content.parts[0].text` | Gemini 응답에서 교정된 텍스트 추출 |

**목적:** Check Typo 노드가 바로 직전 노드이므로 `$json`으로 간결하게 참조합니다.

---

### Summarize — 시스템 프롬프트 내 현재 날짜 동적 삽입

```
{{ $now.setZone('Asia/Seoul').toFormat('yyyy-MM-dd') }}
```

| 표현식 요소 | 목적 |
|---|---|
| `$now` | 워크플로우 실행 시점의 현재 시각 |
| `.setZone('Asia/Seoul')` | 한국 시간대(KST)로 변환 |
| `.toFormat('yyyy-MM-dd')` | YYYY-MM-DD 형식으로 포맷팅 |

**목적:** 회의 날짜 정보가 스크립트에 없을 때 오늘 날짜를 기본값으로 사용하도록 AI에게 지시합니다. 프롬프트 안에 표현식을 넣어 실행 시점마다 다른 날짜가 주입됩니다.

---

### Create a database page — JSON 파싱 및 필드 추출

Summarize 노드가 반환하는 `content.parts[0].text`는 **JSON 형식의 문자열(string)** 입니다. 그대로 `.meeting_title` 같은 키로 접근할 수 없기 때문에, **`JSON.parse()`로 한 번 파싱**해서 객체로 만든 뒤 필드를 꺼내야 합니다.

#### 왜 파싱이 필요한가

Summarize 노드의 출력 예시:

```jsonc
{
  "content": {
    "parts": [
      {
        // ↓ 이 text 값은 "객체"가 아니라 "문자열"입니다
        "text": "{\"meeting_date\":\"2026-04-29\",\"meeting_title\":\"주간 미팅\",...}"
      }
    ]
  }
}
```

Gemini가 JSON 모드로 응답해도 n8n에 전달될 때는 **이스케이프된 문자열**로 들어옵니다. 그래서 한 단계 파싱이 필요합니다.

#### 파싱 표현식 패턴

```js
{{ JSON.parse($json.content.parts[0].text).meeting_title }}
```

| 표현식 요소 | 역할 |
|---|---|
| `$json.content.parts[0].text` | Summarize 노드가 반환한 JSON 문자열 |
| `JSON.parse(...)` | 문자열을 실제 JS 객체로 변환 |
| `.meeting_title` | 파싱된 객체에서 원하는 키만 추출 |

> **Tip.** n8n에는 `.parseJson()` 같은 헬퍼도 있지만, **`JSON.parse(...)`가 표준 자바스크립트 문법이라 더 안전하고 읽기 쉽습니다.** 책/강의에서는 `JSON.parse(...)`로 통일합니다.

#### Notion 노드 필드별 표현식

위 패턴을 그대로 6개 필드에 동일하게 적용합니다. 각 필드 입력란에 그대로 복붙하세요.

| Notion 필드 | 표현식 | 의미 |
|---|---|---|
| 페이지 제목 (Title) | `=[{{ $now.setZone('Asia/Seoul').toFormat('yyyy-MM-dd') }}]{{ JSON.parse($json.content.parts[0].text).meeting_title }}` | `[YYYY-MM-DD]회의 제목` 형태로 결합 |
| 회의 날짜 (Date) | `={{ JSON.parse($json.content.parts[0].text).meeting_date }}` | JSON에서 `meeting_date` 추출 |
| 회의 주제 (Title 속성) | `={{ JSON.parse($json.content.parts[0].text).meeting_title }}` | JSON에서 `meeting_title` 추출 |
| 한줄 요약 (Rich text) | `={{ JSON.parse($json.content.parts[0].text).meeting_oneline }}` | JSON에서 `meeting_oneline` 추출 |
| 파일 이름 (Files) | `={{ $('meeting_transcript_text_file').first().binary.data.fileName }}` | 텍스트 파일명 참조 |
| 파일 URL (Files) | `={{ $('Upload file').item.json.webContentLink }}` | Google Drive 직접 다운로드 링크 |
| 본문 블록 (Block) | `={{ JSON.parse($json.content.parts[0].text).meeting_summary }}` | 마크다운 상세 요약 |

#### 실수하기 쉬운 포인트

- **앞에 `=` 빼먹지 않기**: n8n 입력란에서 표현식 모드로 동작하려면 값 맨 앞에 `=`가 있어야 합니다 (페이지 제목 표현식처럼 `=` 뒤에 일반 텍스트 + `{{ }}` 표현식을 섞을 수 있음).
- **중괄호는 두 개씩**: `{{ }}` 표현식 안에 다시 `{}`가 들어가도 그대로 두면 됩니다 (`JSON.parse(...)` 결과 객체 자체를 출력하는 게 아니라 `.key`로 꺼내 쓰기 때문).
- **속성 키 형식**: `회의 날짜|date`처럼 `이름|타입` 형태로 적습니다. Notion DB의 실제 속성명과 정확히 일치해야 합니다.

---

## 프롬프트

### Check Typo — 교정·윤문 프롬프트 (role: model)

> **목적:** STT(음성→텍스트) 과정에서 발생하는 오인식 단어, 맞춤법 오류, 어색한 흐름을 교정합니다. 요약이나 축약 없이 **원문 길이를 유지**하는 것이 핵심입니다.

```
당신은 전문적인 교정 및 편집 에디터입니다.
아래 제공되는 [음성 인식 텍스트]를 바탕으로 다음의 [작업 지침]을 엄격히 준수하여 텍스트를 다듬어 주세요.

[작업 지침]
1. 교정 및 윤문: 맞춤법, 띄어쓰기, 문법 오류를 수정하고 문장의 흐름이 자연스럽게 이어지도록 매끄럽게 다듬으세요.
2. 길이 유지 (요약 금지): 내용을 요약하거나 축약하지 마세요. 원문의 정보량과 길이를 그대로 유지해야 합니다.
3. 누락 방지: 텍스트의 시작부터 끝까지, 어떤 문장도 누락되지 않도록 꼼꼼하게 검토하여 변환하세요.
4. 문맥 수정: 음성 인식(STT) 과정에서 잘못 인식된 것으로 보이는 단어나 문맥상 어색한 표현은 상황에 가장 적합한 단어로 수정하세요.
5. 출력 형식: 교정이 완료된 텍스트만 출력하세요. (인사말이나 부가 설명 생략)
```

> **포인트:** `role: model`로 설정되어 있어 이 프롬프트는 AI의 발언(응답)처럼 동작합니다. 즉, "나는 교정 에디터다"라는 컨텍스트를 AI 스스로 선언하게 합니다.

---

### Summarize — 회의록 생성 프롬프트 (system message)

> **목적:** 교정된 전사 텍스트를 분석하여 구조화된 JSON 회의록을 생성합니다. 날짜·참석자·액션 아이템까지 추출하여 Notion에 바로 업로드할 수 있는 형태로 만듭니다.

```
당신은 비즈니스 문서 정리에 특화된 '수석 서기'입니다.
제공된 회의 스크립트(타임코드 포함)를 분석하여, 다음 JSON 포맷으로 정리된 회의록을 작성하세요.

[출력 포맷 - JSON]
{
  "meeting_date": "미팅 날짜 (YYYY-MM-DD 형식. 값이 없는 경우 {{ $now.setZone('Asia/Seoul').toFormat('yyyy-MM-dd') }} 를 기본값으로 설정)",
  "meeting_title": "회의 주제",
  "meeting_oneline": "한줄 요약",
  "meeting_attendee": ["참석자1", "참석자2"],
  "meeting_summary": "미팅 요약 (아래 작성 지침에 따른 마크다운 형식의 텍스트, 2000자 미만)"
}

[meeting_summary 작성 지침 - 엄격 준수]

1. 3줄 요약 (Executive Summary)
   - 회의의 핵심 목적과 결론을 가장 중요한 순서대로 딱 3문장으로 요약하세요.

2. 발언자별 핵심 발언 (Who Said What)
   - 담당 업무는 제외하고, 각 참여자가 회의에서 논의한 주요 의견만 간결하게 요약하세요.
   - 형식: **이름**: 주요 발언 요약

3. 담당자별 액션 아이템 (Action Items by Assignee)
   - 회의에서 도출된 할 일을 담당자별로 그룹화하여 정리하세요.
   - 공동 작업이거나 담당자가 불명확할 경우 '공통' 또는 '팀 전체'로 분류하세요.
   - 형식:
     - **담당자명**
       - [ ] 할 일 내용 (마감: 문맥상 날짜가 유추될 경우 기입, 아니면 빈칸)
   - [위험 고지] 액션 아이템의 마감 기한은 문맥상 명확하게 언급되었을 때만 기입하며, 유추된 마감일에는 더블 체크가 필요함을 상기하세요.

[주의사항]
- 응답은 오직 JSON 데이터만 출력하세요.
- meeting_summary 필드에 마크다운 줄바꿈(\n)을 포함하여 텍스트로 넣으세요.
```

> **포인트:** 프롬프트 안에 `{{ $now.setZone('Asia/Seoul').toFormat('yyyy-MM-dd') }}` 표현식이 포함되어 있어, 실행 시점의 날짜가 AI 지시문에 직접 주입됩니다. AI는 이 날짜를 "오늘"로 인식하고 마감일 판단에 활용합니다.

---

## Android 사용자를 위한 대안 트리거

이 워크플로우의 핵심 처리 단계(전사 → 교정 → 요약 → Notion 업로드)는 동일합니다. Android에서는 **트리거 노드만 교체**하면 동일한 파이프라인을 사용할 수 있습니다.

---

### 방법 1: Google Drive 트리거

녹음 앱에서 저장한 오디오 파일을 Google Drive의 특정 폴더에 업로드하면 워크플로우가 자동 실행됩니다.

**변경되는 워크플로우 앞부분:**

```
[Android 녹음 앱] → Google Drive 특정 폴더에 수동 업로드
                                │
                                ▼
         Google Drive Trigger   ← 새 파일 감지 (폴링 방식, 1분 간격)
                                │
                                ▼
         Google Drive (Download)← 감지된 파일을 바이너리로 다운로드
                                │
                                ▼
         Transcribe a recording(gemini)  ← 이후 동일
```

**노드 설정 포인트:**

| 노드 | 설정 |
|---|---|
| Google Drive Trigger | Event: `File Created`, 감시 폴더: 오디오 업로드용 폴더 지정 |
| Google Drive (Download) | Operation: `Download`, File ID: `={{ $json.id }}` |

- Webhook처럼 파일을 바이너리로 받는 것과 달리, Drive Trigger는 파일 메타데이터(id, name 등)를 전달합니다.
- 때문에 **Download 노드를 추가**하여 바이너리 파일을 명시적으로 가져와야 Gemini STT 노드에서 처리할 수 있습니다.
- `meeting_transcript_text_file` 노드의 파일명 표현식은 `$('Webhook')` 대신 `$('Google Drive Trigger')`로 변경합니다.

---

### 방법 2: Telegram 봇 트리거

Telegram 봇에 음성 메시지를 전송하면 워크플로우가 즉시 실행됩니다. 별도 앱 설치 없이 Telegram만으로 동작하며, 즉시성이 Google Drive 방식보다 뛰어납니다.

**변경되는 워크플로우 앞부분:**

```
[Android Telegram 앱] → 봇에 음성 메시지(Voice) 전송
                                │
                                ▼
         Telegram Trigger       ← 봇에 수신된 메시지 감지
                                │
                                ▼
         HTTP Request           ← Telegram File API로 바이너리 다운로드
                                │  URL: https://api.telegram.org/file/bot{TOKEN}/{{ $json.message.voice.file_path }}
                                ▼
         Transcribe a recording(gemini)  ← 이후 동일
```

**노드 설정 포인트:**

| 노드 | 설정 |
|---|---|
| Telegram Trigger | 봇 자격 증명 연결, Updates: `message` |
| HTTP Request (파일 경로 조회) | `GET https://api.telegram.org/bot{TOKEN}/getFile?file_id={{ $json.message.voice.file_id }}` |
| HTTP Request (다운로드) | `GET https://api.telegram.org/file/bot{TOKEN}/{{ $json.result.file_path }}`, Response: Binary |

- Telegram Voice 메시지는 OGG 포맷으로 전달됩니다. Gemini는 OGG도 지원하므로 변환 없이 STT 노드에 바로 넘길 수 있습니다.
- 파일 다운로드는 2단계(파일 경로 조회 → 실제 다운로드)로 이루어집니다.

---

### 트리거 방식 비교

| 항목 | iOS 단축어 (Webhook) | Google Drive 트리거 | Telegram 봇 |
|---|---|---|---|
| 지원 기기 | iOS 전용 | iOS / Android | iOS / Android |
| 트리거 방식 | 즉시 (Push) | 폴링 (최대 1분 지연) | 즉시 (Push) |
| 추가 노드 | 없음 | Download 노드 추가 | HTTP Request 2개 추가 |
| 파일 형식 | m4a (iOS 기본) | 녹음 앱에 따라 다름 | OGG (Telegram 기본) |
| 적합한 상황 | 회의 직후 즉시 처리 | 정해진 폴더 관리 선호 | 메신저 중심 업무 환경 |

---

## 실습 안내

### 사전 준비

1. **Google Gemini API 키** — Google AI Studio에서 API 키를 발급받고 n8n에 Google Gemini(PaLM) Api 자격 증명으로 등록합니다.
2. **Google Drive OAuth** — Google Drive 노드용 OAuth2 자격 증명을 등록하고, 회의록을 저장할 폴더 ID를 확인합니다.
3. **Notion API 키** — Notion에서 Integration을 생성하고, 회의록 데이터베이스에 연결 권한을 부여합니다.
4. **iOS 단축어 설치** — [단축어 파일 다운로드](https://www.icloud.com/shortcuts/9767e709c79e40d1827c39cb4cc9dbce) 후 iPhone에 설치합니다. (iOS 전용)
5. **Webhook URL 설정** — 워크플로우를 `Publish(활성화)`한 후 Production URL을 복사하여 iOS 단축어의 URL 항목에 붙여넣습니다.
6. **테스트용 오디오 파일** — `chap5_STT_example_audio.mp3` 파일로 워크플로우를 테스트합니다.

> **주의:** Webhook 트리거는 반드시 워크플로우가 `Publish` 상태여야 실제 요청을 처리합니다. Test 모드에서는 동작하지 않습니다.
