# AI Meeting Assistant: 회의 요약봇



> **AI 회의록 구조화 전문 에이전트**
> 
> 실시간 음성 기록을 기반으로 한 회의 구조 분석과 담당자별 행동 계획 자동 추출
> 
- n8n 화면: ![AI 회의 요약 워크플로우 다이어그램](https://github.com/ggplab/n8n-playbook/blob/main/04-workflow-meeting-assistant/screenshot/%ED%9A%8C%EC%9D%98%EC%9A%94%EC%95%BD%EB%B4%87%20%EC%9B%8C%ED%81%AC%ED%94%8C%EB%A1%9C%EC%9A%B0.png)



- 실제 결과물 화면:
  <div align="center">
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/04-workflow-meeting-assistant/screenshot/%ED%9A%8C%EC%9D%98%EB%A1%9D%20%EC%9A%94%EC%95%BD%20%EC%8A%AC%EB%9E%99.png" alt="Slack 요약 결과 화면" width="400px"/>
  
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/04-workflow-meeting-assistant/screenshot/%ED%9A%8C%EC%9D%98%EB%A1%9D%20%EC%9A%94%EC%95%BD%20%EB%85%B8%EC%85%98.png" alt="Obsidian 요약 결과 화면" width="400px"/>
</div>



## 📋 1. 목차



- 문제 정의
- 예상 사용자/부서
- 사용 방법
- 사용 비용
- 참고 문헌



## 🎯 2. 문제 정의



### 비효율적인 반복 작업과 핵심 정보 손실

회의가 끝난 후, 녹음된 음성 파일을 다시 듣고, 핵심 내용을 정리하며, 담당자별 할 일을 분리하여 협업 툴에 분배하는 일련의 과정은 **비효율적이며 반복적인 수동 데이터 변환 작업**입니다. 이 과정에 막대한 시간이 소요될 뿐만 아니라, 다음과 같은 문제들이 발생하여 프로젝트 진행에 병목 현상을 일으킵니다.

- **정보 손실:** 수동 타이핑 중 **핵심 결정 사항**이 누락되거나, 오기되어 기록의 신뢰성이 저하됩니다.
- **행동 불명확:** **'누가', '무엇을', '언제까지'** 해야 하는지가 불분명하게 전달되어, 팀원들의 **행동 항목(Action Items)** 이행이 지연됩니다.

### 달성 가치

반복적이고 비효율적인 작업을 제거함으로써 구성원들은 핵심 업무에 더 집중할 수 있으며, 회의 종료 직후 음성 데이터를 정확하게 분석합니다. **발언자별 핵심 발언, 마감 기한이 명확한 액션 아이템, 시간대별 타임라인**을 자동으로 구조화하고, Obsidian 및 Slack에 최적화된 포맷으로 즉시 전달하여 팀의 효율성과 행동력을 극대화합니다.



## 📌 3. 예상 사용자/부서



> 본 워크플로우는 정기적/비정기적 회의를 진행하고 회의록을 관리해야 하는 모든 사용자에게 유용합니다.
> 
- **PM (프로젝트 관리자)**: 프로젝트 진행 상황과 결정 사항을 명확히 트래킹
- **마케터 / 기획자**: 아이데이션(idea+action) 회의나 기획 회의의 핵심 내용을 빠르게 정리
- **팀 리더 및 임원**: 주요 회의의 결정 사항을 신속하게 파악
- **모든 사무직 종사자**: 단순 회의록 작성 업무에서 해방



## 💬 4. 사용 방법


<details>
  <summary>필요한 API 연결</summary>
  <ul>
    <li>Google Drive API 발급 및 Credential 연결</li>
    <li>CloudConvert API 발급 및 Credential 연결</li>
    <li>OPENAI API 발급 및 Credential 연결</li>
    <li>Gemini API 발급 및 Credential 연결</li>
    <li>Slack API 발급 및 Credential 연결</li>
    <li>Slack Bot 발급 및 Credential 연결</li>
</details>


<details>
  <summary>워크플로우 상세 과정</summary>
  <ul>
    <li><strong>Google Drive Trigger & Download</strong>: Google Drive에 새로운 녹음 파일이 업로드되는 것을 감지하고, 해당 <strong>대용량 파일</strong>을 n8n의 메모리로 다운로드합니다.</li>
    <li><strong>CloudConvert</strong>: <strong>OpenAI Whisper의 25MB 제한</strong>을 우회하기 위해, 다운로드된 오디오 파일의 음질을 <strong>손실 없이 압축</strong>하여 파일 크기를 줄입니다.</li>
    <li><strong>Transcribe a recording (OpenAI Whisper)</strong>: 압축된 오디오를 듣고, 내용의 <strong>원시 텍스트(Raw Transcript)</strong>로 변환합니다.</li>
    <li><strong>AI Agent 1 (Correction)</strong>: <strong>Proofreader</strong> 역할로, Whisper가 생성한 원시 텍스트의 맞춤법, 문법, 그리고 <strong>팀원 이름 등의 고유명사 오류를 수정</strong>하여 텍스트를 정제합니다.</li>
    <li><strong>Convert to File 2 & Upload file 2</strong>: (백업 경로) 정제된 원본 텍스트를 <code>.txt</code> 파일로 만들어 <strong>Google Drive에 안전하게 백업</strong>합니다.</li>
    <li><strong>AI Agent 2 (Summarization)</strong>: <strong>구조 분석가</strong> 역할로, 정제된 텍스트를 기반으로 <strong>Executive Summary, 담당자별 액션 아이템, 타임라인 표</strong> 등 최종 아카이빙 포맷(Markdown)으로 요약하고 구조화합니다.</li>
    <li><strong>AI Agent(Length Controller) (Summarization)</strong>: <strong>포맷 변환기</strong> 역할로, 옵시디언용으로 만든 복잡한 마크다운(표, #헤더)을 <strong>Notion에서 깨지지 않고 보기 쉬운 리스트 형식(mrkdwn)</strong>으로 변환합니다.</li>
    <li><strong>Create a database page (Summarization)</strong>: 최종적으로 가독성이 최적화된 <strong>액션 아이템 및 요약 메시지</strong>strong>를 Notion Database에 페이지를 형성하여 회의록 요약 내용을 업로드합니다.</li>
    <li><strong>Convert to File 3 & Upload file 3</strong>: 최종적으로 구조화된 요약본을 <code>.md</code> 파일로 변환하여 <strong>Obsidian 또는 Google Drive에 영구 보관/아카이빙</strong>합니다.</li>
    <li><strong>AI Agent 3 (Slack Converter)</strong>: <strong>포맷 변환기</strong> 역할로, 옵시디언용으로 만든 복잡한 마크다운(표, #헤더)을 <strong>Slack에서 깨지지 않고 보기 쉬운 리스트 형식(mrkdwn)</strong>으로 변환합니다.</li>
    <li><strong>Send a message</strong>: 최종적으로 가독성이 최적화된 <strong>액션 아이템 및 요약 메시지</strong>를 팀 협업 채널인 Slack으로 즉시 발송합니다.</li>
  </ul>
</details>


<details>
  <summary>프롬프트 예시</summary>
  <br>
  <ul>
      <details>
        <summary><strong>AI Agent1: 문맥 교정</strong></summary>
        <br>

당신은 전문적인 교정 및 편집 에디터입니다.
아래 제공되는 [음성 인식 텍스트]를 바탕으로 다음의 [작업 지침]을 엄격히 준수하여 텍스트를 다듬어 주세요.

[작업 지침]
1. **교정 및 윤문**: 맞춤법, 띄어쓰기, 문법 오류를 수정하고 문장의 흐름이 자연스럽게 이어지도록 매끄럽게 다듬으세요.
2. **길이 유지 (요약 금지)**: 내용을 요약하거나 축약하지 마세요. 원문의 정보량과 길이를 그대로 유지해야 합니다.
3. **누락 방지**: 텍스트의 시작부터 끝까지, 어떤 문장도 누락되지 않도록 꼼꼼하게 검토하여 변환하세요.
4. **문맥 수정**: 음성 인식(STT) 과정에서 잘못 인식된 것으로 보이는 단어나 문맥상 어색한 표현은 상황에 가장 적합한 단어로 수정하세요.
5. **출력 형식**: 교정이 완료된 텍스트만 출력하세요. (인사말이나 부가 설명 생략)

[음성 인식 텍스트]
{{ $json.text }}

  </details>
      <details>
        <summary><strong>AI Agent2: 회의 내용 파악 및 요약</strong></summary>
        <br>

당신은 비즈니스 문서 정리에 특화된 '수석 서기'입니다.
제공된 회의 스크립트(타임코드 포함)를 분석하여, **바쁜 팀원들이 1분 만에 파악할 수 있는 가독성 최상의 회의록**을 작성하세요.

[참여자 및 주요 용어 사전]
- 팀원: 팀원 이름1, 팀원 이름2, 팀원 이름3, 팀원 이름4, 팀원 이름5
- 기술용어: n8n, Obsidian, Webhook

[작업 지침 - 엄격 준수]

1. **📝 3줄 요약 (Executive Summary)**
   - 회의의 핵심 목적과 결론을 가장 중요한 순서대로 딱 3문장으로 요약하세요.

2. **🗣️ 발언자별 핵심 발언 (Who Said What)**
   - **담당 업무는 제외하고**, 각 참여자가 회의에서 논의한 **주요 의견만** 간결하게 요약하세요.
   - **형식:**
     - **이름**: 주요 발언 요약

3. **✅ 담당자별 액션 아이템 (Action Items by Assignee)**
   - 회의에서 도출된 할 일을 담당자별로 그룹화하여 정리하세요.
   - 공동 작업이거나 담당자가 불명확할 경우 '공통' 또는 '팀 전체'로 분류하세요.
   - **형식:**
     - **담당자명**
       - [ ] 할 일 내용 (⚠️ 마감: 문맥상 날짜가 유추될 경우 기입하고, 그렇지 않다면 빈칸 유지)
       - [ ] 할 일 내용
   - **[위험 고지]** 액션 아이템의 마감 기한은 **문맥상 명확하게 언급되었을 때만 기입**하며, 유추된 마감일에는 **더블 체크가 필요함**을 상기하세요.

4. **⏰ 타임라인 챕터 (Chapter Timeline)**
   - 주요 주제가 전환되는 시점 위주로 굵직하게 요약하세요.
   - **시간 표기:** 반드시 **시간:분 (`hh:mm`) 형식**을 준수하며, **초는 드롭**하세요. (예: 0시간 5분 -> 00:05, 0시간 30분 -> 00:30)
   - **형식:** Markdown 표(Table) 사용
   | 시간 | 주제 | 핵심 내용 |
   | :--- | :--- | :--- |
   | 00:00 | 오프닝 | 금주 일정 및 근황 공유 |
   | 00:15 | 비용 가이드 | OpenAI API 키 분리 논의 |

[출력 스타일]
- 서론/결론 없이 본문만 출력.
- Obsidian 호환 Markdown 문법 사용 (볼드체, 표, 체크박스 등).

[입력 데이터]
{{ $('AI Agent1').item.json.output }}

  </details>
      <details>
        <summary><strong>AI Agent3: Slack에 맞게 형식 변환</strong></summary>
        <br>

당신은 내용에 일절 손댈 수 없는 '불변 포맷 변환기'입니다.
귀하의 유일한 임무는 입력된 원본 텍스트의 내용을 한 글자도 바꾸지 않고 오직 형식(Format)만 슬랙에 최적화하는 것입니다.

[변환 규칙 - 엄격 준수]
1. **🔥 내용 불변의 원칙 (Non-Negotiable)**: 원본 텍스트의 단어나 문장 구조, 내용을 절대로 변경하거나 요약, 삭제, 추가하지 마세요. 오직 형식(마크다운 → 슬랙 mrkdwn) 변환만 허용됩니다.
2. **상단 날짜**: 최상단에 `📅 {{ $now.toFormat('yyyy-MM-dd') }} 회의 요약`을 **굵게(*제목*)** 작성하고 빈 줄을 추가하세요.

3. **🔥 행 시작 기호 완벽 제거 (Aggressive Strip)**:
   - 모든 행(Line)의 맨 앞에서 발견되는 `*`, `•`, `-` 기호 및 들여쓰기 공백을 완전히 제거하세요. 텍스트를 왼쪽으로 정렬하세요.

4. **체크박스/리스트 정리 (New)**:
   - **체크박스 제거**: 내용 내에 남아있는 **`[ ]`** 또는 **`[x]`** 같은 마크다운 체크박스 기호는 **모두 삭제**하세요. (슬랙에 불필요한 문자 제거)
   - **액션 아이템 재구성**: 모든 액션 아이템은 **글머리 기호(•)**를 사용하여 슬랙 리스트로 만드세요.

5. **헤더 변환**: `#`, `##` 헤더는 제거하고, 해당 줄을 **굵게(*제목*)** 처리하세요.

6. **구조적 요소 불렛 금지 (New)**:
   - 타임라인(`[hh:mm]`)이나 담당 업무 화살표 (`→`)가 시작되는 줄에는 **글머리 기호(`•`)를 절대 붙이지 마세요.** (화살표가 리스트 기호 역할을 대체함)

7. **구분감**: 각 섹션 사이에는 빈 줄을 하나씩 넣어주세요.

[입력 데이터]
{{ $('AI Agent2').item.json.output }}

  </details>
      <details>
        <summary><strong>AI Agent(Length Controller): Notion에 맞게 형식 변환</strong></summary>
        <br>

당신은 'Notion 데이터베이스용 핵심 정보 추출 전문가'입니다.
입력된 전체 회의록 마크다운 텍스트를 분석하여, *내용의 핵심과 구조를 최대한 유지*하며, 최종 출력 글자 수를 **공백 포함 1,800자 이하**로 줄이세요.

[필수 추출 섹션]
1.  3줄 핵심 요약 섹션
2.  발언자별 핵심 발언 섹션
3.  담당자별 액션 아이템 섹션 (체크박스 포맷 유지)

[작업 지침]
1. **발언 내용 제한**: '발언자별 핵심 발언' 섹션을 추출할 때, **각 참여자의 발언 내용은 최대 3문장 이내**로 요약하여 간결함을 유지해야 합니다.
2.  **글자 수 제한**: 최종 출력의 전체 글자 수가 공백 포함 **1,800자를 넘지 않도록** 엄격하게 제한해야 합니다.
3.  **구조 보존**: 추출한 섹션의 Markdown 형식은 최대한 그대로 유지하세요.
4.  **불필요한 섹션 제거**: 위 [필수 추출 섹션] 외의 모든 내용(타임라인, 상세 논의 등)은 완전히 제외하고 출력하세요.

[입력 데이터]
{{ $json.output }}

  </details>
  </ul>
  </details>



## 🚧 5. Troubleshooting: 대용량 오디오 파일 (25MB 제한) 문제 해결



**1. 문제 발생 (Problem Statement)**

OpenAI Whisper API는 처리할 수 있는 파일 크기를 **최대 25MB**로 제한

이로 인해 30분 이상의 긴 회의 녹음 파일이 이 제한을 초과하여 **'413 Request Entity Too Large'** 에러와 함께 워크플로우가 중단됩니다.

**2. 진단 및 해결 전략 (Diagnosis & Solution Strategy)**

음성 인식(STT)은 고음질 오디오(음악용)를 필요로 하지 않습니다. 오디오의 **비트레이트(Bitrate)**를 낮추면 청취 품질의 손실 없이 파일 용량을 획기적으로 줄여 API 제한을 통과할 수 있습니다.

**전략:** CloudConvert 노드를 활용하여 파일을 **전송 전에 압축**하는 파이프라인을 구축합니다.

**3. n8n 구현 상세 (CloudConvert Compression)**

| **워크플로우 위치** | **Google Drive (Download) ➔ CloudConvert ➔ Transcribe** |
| --- | --- |
| **노드 이름** | **CloudConvert** |
| **작업 내용** | **`Convert File`** |
| **Output Format** | `mp3` (용량 효율이 좋음) |
| **핵심 설정: Audio Bitrate** | `32` 또는 `48` kbit/s 입력 |
| **달성 효과** | 파일 크기가 약 1/4~1/3로 감소하여 (예: 1시간 파일 → 약 14MB) **25MB 제한을 우회**하고 안정적으로 STT를 수행 |
| **비고** | CloudConvert 노드의 `Additional Options`에 `Audio Bitrate`를 설정 |



## 💵 6. 사용 비용



|  | **Cost** |
| --- | --- |
| **OPENAI API**  | $0.13 |
| **Gemini 2.5 Flash** | $0.50 |
| **Slack API** | free |
| **CloudConvert API** | free for 10 times per day |



## 🗃️ 7. 참고 문헌



https://n8n.io/workflows/6139-transcribe-and-summarize-audio-with-whisper-and-gpt-from-google-drive-to-notion/
