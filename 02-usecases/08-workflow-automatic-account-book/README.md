# AI Household Account Book: 자동 가계부


> **실시간 지출 데이터 전처리 및 분류 시스템**
> 
> 결제 문자 메시지를 표준 JSON 포맷으로 변환하여 노션 데이터베이스에 즉시 동기화하여 자동으로 가계부 기입
>

- n8n 화면

![image](https://github.com/ggplab/n8n-playbook/blob/main/08-workflow-automatic-account-book/screenshot/%EA%B0%80%EA%B3%84%EB%B6%80%20%EC%9B%8C%ED%81%AC%ED%94%8C%EB%A1%9C%EC%9A%B0.gif)

- 실제 결과물 화면

<div align="center">
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/08-workflow-automatic-account-book/screenshot/%EC%9E%90%EB%8F%99%20%EA%B0%80%EA%B3%84%EB%B6%80(1).png?raw=true" alt="자동 가계부 화면 1" width="350px"/>
  
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/08-workflow-automatic-account-book/screenshot/%EC%9E%90%EB%8F%99%20%EA%B0%80%EA%B3%84%EB%B6%80(2).png?raw=true" alt="자동 가계부 화면 2" width="350px"/>
</div>

## 📋 1. 목차


- 문제 정의
- 예상 사용자/부서
- 사용 방법
- 사용 비용
- 참고 문헌

## 🎯 2. 문제 정의


### **비효율적인 수동 입력과 재정 관리의 한계**

결제 발생 시마다 앱 푸시, SMS 등 다양한 채널에 산재된 내역을 일일이 확인하고, 이를 가계부나 스프레드시트에 수동으로 입력 및 분류하는 과정은 매우 비효율적이며 반복적인 노동입니다. 이러한 단순 반복 작업은 사용자에게 피로감을 주어 다음과 같은 문제들을 야기하며, 결과적으로 체계적인 자산 관리를 저해하는 주된 원인이 됩니다.

- **기록의 중단 (지속성 결여):** 번거로운 입력 과정에 지친 사용자가 가계부 작성을 중도에 포기하게 만들어, 지출 데이터의 연속성이 끊기고 기록이 누락됩니다.
- **인사이트 부재:** 단순 데이터 입력에 시간을 뺏겨, 정작 중요한 개인의 소비 패턴을 분석하거나 재정적 개선점을 도출하는 의미 있는 인사이트 확보에 실패합니다.

### **달성 가치**

반복적이고 소모적인 수동 입력 작업을 AI 기반 자동화로 완벽하게 대체함으로써, 사용자는 데이터 관리의 부담에서 벗어나 핵심적인 재정 계획 수립에 온전히 집중할 수 있습니다. 다양한 경로로 유입되는 **비정형 결제 텍스트를 실시간으로 수집 및 분석하여, 정확한 결제 정보(가맹점, 금액, 날짜)와 최적화된 소비 카테고리로 자동 구조화**합니다. 이를 통해 노션(Notion) 등의 데이터베이스에 오류 없는 데이터를 즉시 적재하여, 사용자가 언제든 정확한 지출 현황을 파악하고 데이터 기반의 재정 관리를 실현하도록 돕습니다.

## 📌 3. 예상 사용자/부서


> 본 워크플로우는 개인의 꼼꼼한 지출 관리부터 번거로운 법인 경비 처리까지, 스마트한 소비 기록이 필요한 모든 분을 위해 설계되었습니다.
> 
- **실시간 소비 트래킹이 필요한 사용자:** 결제 즉시 지출 흐름을 파악하여 계획적인 소비 습관을 형성하고자 하는 분
- **경비 처리가 번거로운 직장인:** 식대나 비품 등 법인 카드 사용 내역을 자동으로 분류하고 기록하여 업무 효율을 높이고 싶은 분
- **기록의 자동화를 원하는 모든 이:** 반복적인 수동 입력의 피로감에서 벗어나, 데이터 누락 없는 정확한 가계부를 유지하고 싶은 분

## 💬 4. 사용 방법


<details>
  <summary>필요한 API 연결</summary>
  <ul>
    <li>Google Sheets API 발급 및 Credential 연결</li>
    <li>Gemini API 발급 및 Credential 연결</li>
    <li>Notion API 발급 및 Credential 연결</li>
</details>


<details>
  <summary>워크플로우 상세 과정</summary>
  <ul>
    <li><strong>Webhook (Trigger)</strong>: MacroDroid에서 전송한 결제 문자 및 앱 푸시 알림 데이터를 실시간으로 수신하는 HTTP 엔드포인트</li>
    <li><strong>Google Sheets (Raw Data Logging)</strong>: 수신된 비정형 원본 텍스트(Raw Data)를 구글 시트에 즉시 적재하여 데이터 유실 방지 및 로그 확보</li>
    <li><strong>Edit Fields (Preprocessing)</strong>: 전체 웹훅 페이로드 중 분석에 필요한 핵심 텍스트 필드(body)만 추출하여 AI 입력 데이터로 가공하는 전처리 단계</li>
    <li><strong>AI Agent (LLM Analysis)</strong>: Google Gemini 모델을 활용해 비정형 텍스트를 파싱(Parsing)하고, 문맥 기반으로 소비 카테고리를 자동 분류하여 구조화</li>
    <li><strong>Code in JavaScript (Data Sanitization)</strong>: AI 응답 데이터에 포함된 마크다운 기호(```json) 등 불필요한 노이즈를 제거하고 순수 JSON 객체로 변환하는 후처리</li>
    <li><strong>Notion (Final Storage)</strong>: 최종 정제된 결제 데이터(날짜, 금액, 가맹점, 카테고리 등)를 노션 데이터베이스 스키마에 맞춰 매핑 및 저장</li>
  </ul>
</details>


<details>
  <summary>안드로이드 자동화 앱 설정: MacroDroid 앱 사용 (무료)</summary>
  <strong>공통 사항</strong>:

1. Play 스토어에서 `MacroDroid` 앱을 설치하고, '접근성', '알림 접근' 등 초기 권한을 모두 허용합니다.
2. `MacroDroid` 메인 화면에서 '매크로 추가'를 선택합니다.
  <ul>
      <details>
        <summary><strong>앱 푸시 알람</strong></summary>
        <br>

1. **트리거 (Triggers / 빨간색)** 섹션의 '+' 버튼을 누릅니다.
    - `기기 관련 변동` > `알림` > `알림을 받으면` > 확인
    - `앱 선택` > `알림을 보낼 앱` (광고 알림이 아닌 '결제' 알림을 보내는 앱을 선택)
    - `별도의 제목 및 텍스트 필터 사용` 체크
    - `제목` > `포함하면` > 결제`*` (카드사 알림 중 "결제" 단어가 포함된 알림만 감지하기 위함)
    - `메시지 내용` > `조건없음` > 확인
2. **액션 (Actions / 파란색)** 섹션의 '+' 버튼을 누릅니다.
    - `웹 접속` > `HTTP 요청`
    - `요청 종류`: `POST`
    - `URL 입력`: n8n `Webhook` 노드에서 복사한 **URL 붙여넣기**
    - `Body 내용` > `컨텐츠 타입` > `text/plain`
    - `Body 내용 (텍스트)`:
        
        ```
        {
          "text": "{notification}",
          "sender": "{not_title}",
          "time": "{system_time}"
        }
        ```
        
        (여기서 `[Body 내용]`은 MacroDroid의 '매직 텍스트' 버튼(…)을 눌러 `Body 내용` 변수를 선택합니다.)
        
3. 우측 하단의 '저장' 버튼을 누르고 매크로 이름을 (예: `가계부 전송`) 지정합니다.

  </details>
      <details>
        <summary><strong>SMS 문자</strong></summary>
        <br>

1. **트리거 (Triggers / 빨간색)** 섹션의 '+' 버튼을 누릅니다.
    - `기기 관련 변동` > `알림` > `알림을 받으면` > 확인
    - `앱 선택` > `알림을 보낼 앱` (메시지 앱을 선택)
    - `텍스트 내용` > `포함하면` > `승인` > 확인
2. **액션 (Actions / 파란색)** 섹션의 '+' 버튼을 누릅니다.
    - `웹 접속` > `HTTP 요청`
    - `요청 종류`: `POST`
    - `URL 입력`: n8n `Webhook` 노드에서 복사한 **URL 붙여넣기**
    - `Body 내용` > `컨텐츠 타입` > `text/plain`
    - `Body 내용 (텍스트)`:
        
        ```
        {
          "text": "{notification}",
          "sender": "{not_title}",
          "time": "{system_time}"
        }
        ```
        
        (여기서 `[Body 내용]`은 MacroDroid의 '매직 텍스트' 버튼(…)을 눌러 `Body 내용` 변수를 선택합니다.)
        
3. 우측 하단의 '저장' 버튼을 누르고 매크로 이름을 (예: `가계부 전송`) 지정합니다.
  </details>
  </ul>
  </details>

<details>
  <summary>프롬프트 예시</summary>
  <ul>

# Role
당신은 금융 결제 알림 텍스트를 분석하여 데이터베이스에 저장할 JSON 데이터를 추출하는 전문 AI 비서입니다.

# Task
텍스트를 분석하여 아래 5가지 필드를 추출하고, 반드시 지정된 JSON 형식으로만 출력하십시오. (부연 설명 금지)

# Output JSON Format
{
    "merchant": "String",      // 가맹점 이름 (특수문자 제거)
    "date": "YYYY-MM-DD",      // 결제 날짜
    "amount": Integer,         // 결제 금액 (숫자만)
    "card_company": "String",  // 카드사 이름
    "category": "String"       // 지출 카테고리
}

# Parsing Rules (중요)
1. **merchant (사용처)**: 
   - 텍스트에서 가맹점 이름을 찾으세요. (예: "카페아이엠티 지타워*")
   - 이름 뒤에 붙은 특수문자(*, #)나 불필요한 지점명, 법인 표기((주))는 상황에 맞춰 깔끔하게 정리하세요.
   - 예: "카페아이엠티 지타워*" -> "카페아이엠티"

2. **amount (금액)**:
   - '내용'뿐만 아니라 **'제목'**에 적힌 금액도 반드시 확인하세요. (특히 토스, 카카오페이 등은 제목에 금액이 있습니다.)
   - "3,200원" -> 3200 (쉼표와 '원' 제거, 정수형 반환)
   - '취소' 문자가 포함된 경우 음수(-)로 표기하세요.

3. **date (날짜)**:
   - 텍스트에 있는 날짜(예: 10/29)를 최우선으로 사용하세요.
   - 연도가 없다면 현재 연도인 **2025년**을 붙여서 "2025-10-29" 형식으로 만드세요.
   - (참고: 입력된 '시간' 타임스탬프는 무시하고 텍스트 날짜를 따르세요.)

4. **card_company (카드사)**:
   - "우리(3743)" -> "우리카드" (숫자나 괄호 제거)

5. **category (카테고리)**:
   - merchant(사용처)와 문맥을 분석하여 아래 기준에 따라 가장 적절한 카테고리를 하나만 선택하세요.

   - **[식비]**: 일반 음식점, 배달 앱(배달의민족, 요기요, 쿠팡이츠), 식재료 장보기(이마트, 홈플러스, 마켓컬리, 롯데마트), 반찬가게, 주점/술집
   - **[카페]**: 커피 전문점(스타벅스, 메가커피, 이디야 등), 베이커리(파리바게뜨, 뚜레쥬르), 디저트 가게, 아이스크림
   - **[교통]**: 택시(카카오T, 우티), 대중교통(코레일, 티머니), 주유소, 하이패스, 주차장, 킥보드/자전거 대여
   - **[쇼핑]**: 온라인 쇼핑몰(쿠팡, 네이버쇼핑, 11번가), 백화점, 아울렛, 다이소, 올리브영, 의류/잡화 매장, 가전제품
   - **[의료]**: 병원, 의원, 약국, 한의원, 건강검진센터, 동물병원
   - **[공과금]**: 아파트 관리비, 전기요금(한국전력), 도시가스, 수도세, 지방세/국세, 과태료
   - **[문화]**: 영화관(CGV, 롯데시네마), OTT 구독(넷플릭스, 유튜브, 멜론), 서점(교보문고), 전시회/공연 관람, PC방, 노래방
   - **[교육]**: 학원비, 인터넷 강의(클래스101, 인프런), 독서실/스터디카페, 학습지
   - **[통신]**: 통신요금(SKT, KT, LGU+), 인터넷/TV 요금, 알뜰폰 요금
   - **[기타]**: 위 분류에 속하지 않는 항목, 회비, 경조사비, 현금인출, 수수료, 기부금

# Few-Shot Examples
Input:
내용: [Web발신] 삼성(1234) 승인 홍길동 15,400원 11/24 12:30 (주)맥도날드강남점
보낸곳: 1588-8700
시간: 1763959619779

Output:
{
    "merchant": "맥도날드",
    "date": "2025-11-24",
    "amount": 15400,
    "card_company": "삼성카드",
    "category": "식비"
}

# Output Rules (Strict)
- **절대로** 마크다운 코드 블록(```json ... ```)을 사용하지 마십시오.
- 앞뒤에 설명이나 공백 없이 **오직 순수 JSON 텍스트(Raw JSON)**만 출력하십시오.
    
  </ul>
</details>


<details>
  <summary>코드 예시</summary>
  <ul>

// 1. AI가 준 데이터(output) 가져오기
const aiText = $input.first().json.output;

// 2. ```json 같은 마크다운 기호 다 지우고, { 와 } 사이의 내용만 발라내기
const jsonStart = aiText.indexOf('{');
const jsonEnd = aiText.lastIndexOf('}') + 1;
const cleanJson = aiText.substring(jsonStart, jsonEnd);

// 3. 진짜 JSON 데이터로 변환해서 내보내기
return JSON.parse(cleanJson);
    
  </ul>
</details>


## 💵 5. 사용 비용


|  | **Cost** |
| --- | --- |
| **Gemini 2.5 Flash** | $0.50 |
| **Notion API** | free |
| **MacroGroid App** | AVOD (Advertising-based Video on Demand) |

## 🗃️ 6. 참고 문헌


https://community.n8n.io/t/trigger-from-android-phone/179222/2
