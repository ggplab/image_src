# 2장. 구글 RSS 피드 뉴스 메일링

> 구글 뉴스 RSS에서 n8n 관련 최신 뉴스 5건을 수집하여 매일 Gmail로 발송하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | 매일 오전 6시 스케줄 |
| 주요 서비스 | Google News RSS, Gmail |
| 출력 | 뉴스 제목·링크가 포함된 이메일 |

## 워크플로우 흐름

```
Schedule Trigger → RSS Read → Limit → Edit Fields → Aggregate → Gmail
```

## 노드 구성

1. **Schedule Trigger** — 매일 오전 6시에 워크플로우를 자동 실행합니다.
2. **RSS Read** — 구글 뉴스 RSS 피드(`n8n` 키워드, 한국어)에서 뉴스 목록을 가져옵니다.
3. **Limit** — 상위 5건만 남기고 나머지를 제거합니다.
4. **Edit Fields** — 각 뉴스 아이템에서 `title`(제목)과 `link`(링크)만 추출합니다.
5. **Aggregate** — 5건의 개별 아이템을 하나의 배열(`data`)로 집계합니다.
6. **Gmail (Send a message)** — 집계된 뉴스를 이메일 본문에 담아 발송합니다.

## 메시지 템플릿

Gmail 노드에서 사용하는 n8n expression입니다.

**제목:**

```text
={{ $today.format("DD") }}의 뉴스
```

**본문:**

```text
오늘의 n8n뉴스

{{ $json.data.map(item => `${item.title}\n${item.link}`).join('\n\n') }}
```

## 실습 안내

### 사전 준비

1. **Gmail OAuth2 자격 증명** — n8n에서 Gmail OAuth2 연결을 설정합니다.
2. **RSS 피드 URL** — 기본값은 `https://news.google.com/rss/search?q=n8n&hl=ko&gl=KR&ceid=KR%3Ako`이며, 검색 키워드를 변경하여 원하는 주제의 뉴스를 받을 수 있습니다.
3. Gmail 노드의 `sendTo` 필드에 수신할 이메일 주소를 입력합니다.
