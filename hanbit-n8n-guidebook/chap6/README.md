# 6장. OCR — 영수증 인식 자동화

> 영수증 이미지를 업로드하면 OCR로 텍스트를 추출하고, AI가 구매 날짜·카드번호·총금액을 정제하여 Google Sheets에 자동 기록하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | 폼 제출 (이미지 업로드) |
| 주요 서비스 | Upstage OCR API, Google Gemini, Google Sheets |
| 출력 | Google Sheets에 정제된 영수증 데이터(날짜, 카드번호, 금액) 기록 |

## 워크플로우 흐름

```
Form Trigger → HTTP Request (Upstage OCR) → Edit Fields → Basic LLM Chain (Gemini) → Google Sheets
                                                                │
                                                    ┌───────────┴───────────┐
                                                    │                       │
                                            Google Gemini         Structured Output Parser
                                            Chat Model            (JSON 스키마)
```

## 노드 구성

1. **On form submission** — 이미지 업로드 폼을 제공합니다. 사용자가 영수증 이미지를 업로드하면 워크플로우가 시작됩니다.
2. **HTTP Request (Upstage OCR)** — 업로드된 이미지를 Upstage Document Digitization API로 전송하여 OCR 텍스트를 추출합니다.
3. **Edit Fields** — OCR 결과에서 `text`(전체 텍스트)와 `timestamp`(처리 시각)를 추출합니다.
4. **Basic LLM Chain** — OCR 텍스트를 Gemini에 전달하여 3가지 핵심 정보를 정제합니다.
5. **Google Gemini Chat Model** — LLM Chain의 언어 모델로 사용됩니다.
6. **Structured Output Parser** — LLM 출력을 JSON 스키마에 맞게 구조화합니다.
7. **Append row in sheet** — 정제된 데이터를 Google Sheets에 새 행으로 추가합니다.

## 프롬프트

Basic LLM Chain에서 사용하는 프롬프트입니다.

```text
3가지를 정제해

1. 구매 날짜(시분초)
2. 카드번호
3. 총금액
```

## Structured Output Parser JSON 스키마

LLM 출력을 구조화하기 위한 JSON 스키마 예시입니다.

```json
{
    "timestamp": "YYYY-MM-DD HH:MM:SS",
    "amt": "총 금액",
    "card": "카드번호"
}
```

## 실습 안내

### 사전 준비

1. **Upstage API 키** — [Upstage](https://www.upstage.ai/)에서 API 키를 발급받고 n8n의 HTTP Bearer Auth 자격 증명에 등록합니다.
2. **Google Gemini API 키** — Google AI Studio에서 API 키를 발급받고 n8n에 등록합니다.
3. **Google Sheets OAuth2 자격 증명** — 결과를 기록할 Google Sheets에 접근할 수 있도록 설정합니다.
4. **Google Sheets 시트 준비** — `timestamp`, `cardnumber`, `amt` 컬럼이 있는 시트를 미리 생성합니다.
5. **테스트용 영수증 이미지** — `chap6_카드영수증_예시.jpg` 또는 `chap6_카드영수증_예시2.jpeg` 파일을 사용하여 테스트합니다.
