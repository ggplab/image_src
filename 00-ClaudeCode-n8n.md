# CLAUDE.md — n8n 워크플로우 개발 전용 가이드

> **이 파일은 무엇인가?**
> Claude Code(`claude.ai/code`)가 저장소에서 작업할 때 자동으로 읽는 **행동 지침 파일**입니다.
> 저장소 루트에 이 파일을 두면 Claude가 워크플로우를 설계하거나 파일을 생성하기 전에 규칙을 먼저 확인합니다.
>
> **누가 쓰나요?**
> n8n 워크플로우를 Claude Code로 설계·자동 생성하려는 개발자 및 실무자.
> 일반 인터넷 환경(n8n Cloud / self-hosted)과 폐쇄망 환경 모두 지원합니다.
>
> **커스터마이징 방법**
> `## 환경 설정` 섹션에서 현재 팀 환경에 해당하는 항목만 활성화하세요.

---

## 기본 작업 원칙

- 구현 전 반드시 계획을 먼저 수립한다
- 접근 방법이 합의되기 전까지 코딩, 파일 생성, API 호출을 시작하지 않는다
- 사용자 승인을 받은 후 실행한다
- 논리적 체크포인트마다 명확한 커밋 메시지로 git에 저장한다

---

## n8n 워크플로우 작성 규칙

- 워크플로우는 JSON 파일이므로 편집 시 전체 노드/연결 구조를 보존한다
- JavaScript 템플릿 리터럴 대신 n8n 표현식 문법(`{{ $json.fieldName }}`)을 사용한다
- 배포·공유 전 로컬(`http://localhost:5678`) 또는 개발 인스턴스에서 반드시 테스트한다
- **Code 노드 사용 제한**: Set, Aggregate, HTTP Request 등 내장 노드로 먼저 해결하고, 불가능한 경우에만 Code 노드(JavaScript/Python)를 최후 수단으로 사용한다

### n8n 공식 템플릿 검색 API

워크플로우 패턴이 필요할 때 아래 API로 먼저 검색한다:

```
https://n8n.io/api/product-api/workflows/search?search=[검색어]&apps=[앱]&rows=15&page=0
```

| 파라미터 | 설명 | 예시 |
|----------|------|------|
| `search` | 검색 키워드 | `pdf+rag`, `rss+summary`, `ai+agent` |
| `apps` | 앱 필터 (선택) | `openai`, `slack`, 비우면 전체 |
| `rows` | 결과 수 | `15` (기본값) |
| `page` | 페이지 번호 | `0`부터 시작 |

---

## 환경 설정

> 현재 환경에 맞게 아래 항목을 수정하세요. 주석 처리된 항목은 비활성화된 것입니다.

### 인터넷 환경 (n8n Cloud / self-hosted + 외부망)

사용 가능한 서비스:
- n8n 내장 노드 전체
- OpenAI API (`gpt-4o-mini` 기본, `gpt-4o` 필요 시)
- n8n Data Table, 로컬 파일 I/O
- Slack, Notion, Airtable 등 외부 SaaS 연동
- 공개 RSS 피드, 외부 Webhook 수신

### 폐쇄망 환경 (인터넷 차단)

사용 가능한 서비스:
- n8n 내장 노드 전체
- 내부망에서 접근 가능한 LLM API (사내 OpenAI 엔드포인트 또는 ollama 등)
- n8n Data Table, 로컬 파일 I/O
- 내부 SMTP, 내부 DB (방화벽 오픈 확인 필요)
- 내부 트리거 전용: Schedule, Manual, Form Trigger

사용 불가 서비스:
- Google Sheets, Drive, Calendar, Gmail, BigQuery
- 외부 Webhook 수신 (외부 → 내부 방향)
- 인터넷 연결이 필요한 모든 서드파티 노드
- npm/pip 패키지 실시간 설치

> **폐쇄망 대체 패턴**
> - Google Sheets → n8n Data Table
> - 외부 Webhook → Schedule Trigger 또는 Form Trigger
> - 외부 파일 다운로드 → 로컬 경로 직접 참조

---

## 워크플로우 설계 원칙

### 결과물 유형 (3가지 권장)

| 유형 | 구현 방법 | 환경 |
|------|-----------|------|
| **보고서형** | HTML 생성 → Convert to File | 양쪽 모두 |
| **데이터 저장형** | n8n Data Table Upsert | 양쪽 모두 |
| **대화형** | Chat Trigger + AI Agent + Memory | 양쪽 모두 (LLM 엔드포인트 필요) |

### 복잡도 기준

- 메인 노드 수: **7개 이내** 권장
- 노드 하나에 역할 하나 — 단일 책임 원칙
- 선형 구조 우선, 분기(IF/Switch)는 필요할 때만 사용

### AI 연동 기준

- 기본 모델: `gpt-4o-mini` (비용·속도 균형) / 폐쇄망은 내부 LLM 엔드포인트로 교체
- AI 출력이 구조화 데이터인 경우: **Structured Output Parser** + **Auto-fixing Output Parser** 필수
- 시스템 프롬프트에 출력 형식(JSON 스키마, 숫자 포맷 등)을 명시한다
- AI 없이 구현 가능한 경우 LLM 미사용 버전을 먼저 설계한다

---

## 파일 구조 규칙

```
workflows/
  usecase-1.json              # n8n Import용 워크플로우 JSON
  usecase-2.json

docs/
  usecases/
    uc1/
      usecase-1-node-guide.md # 노드별 설정 가이드
  assets/
    sample-data/              # 실습·테스트용 더미 데이터
```

- 실제 개인정보·사내 데이터를 샘플 데이터로 사용 금지 (구조만 맞추고 수치는 임의값)
- 데이터 수집 실패 시 추정값·플레이스홀더 사용 금지 — 실패 사실을 명시적으로 표기

---

## 트러블슈팅 메모

**Upsert 중복 방지**
날짜 필터 대신 고유 식별자(`link`, `id` 등)를 `matchingColumns`로 설정한다. 날짜 필터는 해당 날짜에 데이터가 없을 때 신규 데이터까지 차단하는 부작용이 있다.

**PDF Binary 처리**
Binary Input Loader 사용 시 `loader: "pdfLoader"` 명시 필수. 미설정 시 `Mime type doesn't match` 오류 발생.
Form Trigger의 `fieldLabel` 값과 Binary Input Loader의 `dataPropertyName` 값이 반드시 일치해야 한다.

**폐쇄망 Webhook 수신 불가 시 대안**
외부에서 n8n으로 들어오는 Webhook은 네트워크 오픈이 필요하다. 불가능한 경우 Schedule Trigger(주기적 폴링) 또는 Form Trigger(내부 사용자 입력)로 대체 설계한다.
