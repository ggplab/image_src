# 5장. 회의록 STT — AssemblyAI 음성 인식 자동화

> iOS 단축어(Shortcut)로 녹음한 음성 파일을 n8n Webhook으로 전달하면, AssemblyAI가 음성을 전사하고 AI가 교정·윤문 후 JSON 형식 회의록을 자동 생성하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | Webhook (iOS 단축어에서 오디오 파일 전송) |
| 주요 서비스 | AssemblyAI, Google Gemini |
| 출력 | JSON 형식 회의록 (날짜, 제목, 한줄 요약, 참석자, 상세 요약) |

## 워크플로우 흐름

```
Webhook → HTTP Request (파일 업로드) → HTTP Request (전사 요청) → Wait
                                                                    │
                                                       HTTP Request (전사 결과 조회)
                                                                    │
                                                              Edit Fields
                                                                    │
                                               Basic LLM Chain (교정·윤문) ← Google Gemini Chat Model
                                                                    │
                                              Basic LLM Chain (회의록 생성) ← Google Gemini Chat Model
                                                                    │
                                                       Respond to Webhook
```

## 노드 구성

1. **Webhook** — iOS 단축어에서 전송된 오디오 파일(바이너리)을 수신합니다.
2. **HTTP Request (파일 업로드)** — 오디오 파일을 AssemblyAI 스토리지에 업로드하고 `upload_url`을 받습니다.
3. **HTTP Request (전사 요청)** — `upload_url`을 포함한 전사 작업을 AssemblyAI에 요청하고 `transcript_id`를 받습니다.
4. **Wait** — AssemblyAI 전사 처리가 완료될 때까지 일정 시간 대기합니다.
5. **HTTP Request (전사 결과 조회)** — `transcript_id`로 완료된 전사 결과를 조회합니다.
6. **Edit Fields** — 전사 결과에서 전사 텍스트(`text`)를 추출합니다.
7. **Basic LLM Chain (교정·윤문)** — STT 전사 텍스트를 교정 에디터 페르소나 AI로 교정·윤문합니다.
8. **Google Gemini Chat Model** — LLM Chain의 언어 모델로 사용됩니다. (교정·윤문 및 회의록 생성에 공통 사용)
9. **Basic LLM Chain (회의록 생성)** — 교정된 텍스트를 바탕으로 JSON 형식 회의록을 생성합니다.
10. **Respond to Webhook** — 생성된 회의록 JSON을 iOS 단축어에 응답으로 반환합니다.

## 프롬프트

### 5-3-1 AI에 페르소나 부여하기

교정·윤문 LLM Chain (노드 7)에서 사용하는 시스템 프롬프트입니다.

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

### 5-3-2 회의록 요약하기

회의록 생성 LLM Chain (노드 9)에서 사용하는 시스템 프롬프트입니다.

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
- 형식:
- 이름: 주요 발언 요약


3. 담당자별 액션 아이템 (Action Items by Assignee)
- 회의에서 도출된 할 일을 담당자별로 그룹화하여 정리하세요.
- 공동 작업이거나 담당자가 불명확할 경우 '공통' 또는 '팀 전체'로 분류하세요.
- 형식:
- 담당자명
- [ ] 할 일 내용 (마감: 문맥상 날짜가 유추될 경우 기입하고, 그렇지 않다면 빈칸 유지, 보통 마감일은 {{ $now.toFormat('yyyy-MM-dd') }} 보다 이후 날짜가 맞으므로 {{ $now.toFormat('yyyy-MM-dd') }} 이후 날짜라면 마감일 생략.)
- [ ] 할 일 내용
- 위험 고지]** 액션 아이템의 마감 기한은 문맥상 명확하게 언급되었을 때만 기입하며, 유추된 마감일에는 더블 체크가 필요함을 상기하세요.


[주의사항]
- 응답은 오직 JSON 데이터만 출력하세요.
- meeting_summary 필드에 마크다운 줄바꿈(\n)을 포함하여 텍스트로 넣으세요.

```

## 실습 안내

### 사전 준비

1. **AssemblyAI API 키** — [AssemblyAI](https://www.assemblyai.com/)에서 무료 계정을 생성하고 API 키를 발급받습니다. n8n의 HTTP Header Auth 자격 증명에 등록합니다.
2. **Google Gemini API 키** — Google AI Studio에서 API 키를 발급받고 n8n에 등록합니다.
3. **iOS 단축어 설치** — `audio-transcribe.shortcut`(직접 실행용) 또는 `audio-transcribe(share).shortcut`(공유 시트에서 실행용)을 iPhone에 설치합니다.
4. **Webhook URL 설정** — n8n에서 Webhook 노드를 활성화한 후, 생성된 URL을 iOS 단축어의 URL 항목에 붙여넣습니다.
5. **테스트용 오디오 파일** — `chap5_STT_example_audio.mp3` 파일로 워크플로우를 테스트합니다.
