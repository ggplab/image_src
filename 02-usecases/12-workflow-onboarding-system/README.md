# Onboarding System: 새 직원 온보딩 자동화


> **신규 입사자 온보딩 자동화 시스템**
> 
> 직원 데이터베이스에 새로 추가된 신규 직원을 대상으로 자동으로 진행되는 온보딩 워크플로우
>

- n8n 화면
 ![image](https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/00%20%EC%98%A8%EB%B3%B4%EB%94%A9%20%EC%9E%90%EB%8F%99%ED%99%94%20%EC%9B%8C%ED%81%AC%ED%94%8C%EB%A1%9C%EC%9A%B0.gif)

- 실제 결과물 화면
온보딩 0일차 입사 환영 및 첫 출근 안내 이메일 & 노션 온보딩 체크리스트 페이지 생성
<div align="center">
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/01%20%EC%9E%85%EC%82%AC%20%EC%B6%95%ED%95%98%20%EC%9D%B4%EB%A9%94%EC%9D%BC.png" width="350px"/>
  
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/02%20%EC%98%A8%EB%B3%B4%EB%94%A9%20%EC%B2%B4%ED%81%AC%EB%A6%AC%EC%8A%A4%ED%8A%B8%20%EC%83%9D%EC%84%B1.png" width="350px"/>
</div>


온보딩 1일차 입사 환영 슬랙 메세지 전송 & 온보딩 시작 중간 기록
<div align="center">
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/03%20%EC%9E%85%EC%82%AC%20%EC%B2%AB%EB%82%A0%20%ED%99%98%EC%98%81%20%EC%8A%AC%EB%9E%99.png" width="350px"/>
  
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/04%20%EC%98%A8%EB%B3%B4%EB%94%A9%20%EC%A7%84%ED%96%89%20%EA%B8%B0%EB%A1%9D.png" width="350px"/>
</div>


온보딩 30일차 후속 관리 이메일 전송 & 온보딩 완료 기록
<div align="center">
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/05%20%EC%98%A8%EB%B3%B4%EB%94%A9%20%EC%99%84%EB%A3%8C%20%ED%9B%84%20%ED%9B%84%EC%86%8D%20%EA%B4%80%EB%A6%AC%20%EC%9D%B4%EB%A9%94%EC%9D%BC.png" width="350px"/>
  
  <img src="https://github.com/ggplab/n8n-playbook/blob/main/12-workflow-onboarding-system/screenshot/06%20%EC%98%A8%EB%B3%B4%EB%94%A9%20%EC%99%84%EB%A3%8C%20%EA%B8%B0%EB%A1%9D.png" width="350px"/>
</div>




## 📋 1. 목차



- 문제 정의
- 예상 사용자/부서
- 사용 방법
- 사용 비용
- 참고 문헌




## 🎯 2. 문제 정의



### 비효율적인 수동 관리와 기업 리소스 낭비

신규 직원의 입사는 회사에 활력을 불어넣는 중요한 이벤트이지만, 인사(HR) 담당자 및 팀 리더에게는 **고도로 반복적이고 시간이 많이 소요되는 초기 설정 작업**을 의미합니다. 결원이 발생하거나 동시에 여러 명이 입사할 경우, 이 수동 작업은 담당자에게 큰 업무 부담을 안겨 다음과 같은 기업 리소스 낭비와 관리 부실을 야기합니다.

- **반복 작업으로 인한 시간 낭비 (Time Drain):** 신규 직원마다 환영 이메일 발송, 팀 소개 메시지 작성, 노션/슬랙/구글 드라이브 등 시스템의 **계정 생성 및 권한 부여** 등 비반복적인 작업에 귀중한 업무 시간이 낭비됩니다.
- **높은 인적 오류 위험:** 수동으로 여러 시스템에 정보를 입력하거나 권한을 부여하는 과정에서 **필수 시스템 접근 권한이 누락**되거나, **잘못된 자료가 전달**되는 인적 오류(Human Error)가 발생할 위험이 높습니다. 이는 보안 문제나 초기 업무 지연으로 직결됩니다.
- **신규 직원 경험 품질 저하:** 정보 전달이 지연되거나 매끄럽지 못하면, 신규 직원은 첫 출근부터 회사 시스템에 대한 불신을 갖거나 **소속감을 느끼기 어려워** 이탈률이 높아질 수 있습니다.

### 달성 가치

반복적이고 시간이 소모되는 온보딩 초기 설정을 n8n 기반의 자동화 파이프라인으로 대체함으로써, **HR 담당자는 반복 노동에서 해방**되고 **신규 직원은 체계적인 환영**을 경험합니다.

이 자동화 파이프라인은 Google Sheets에 입력된 직원의 정보를 실시간으로 감지하여, 입사일에 맞춰 **Slack 팀 소개** 및 **개인별 맞춤 환영 이메일**을 발송하고, **Notion 온보딩 체크리스트 페이지를 템플릿 기반으로 자동 생성**합니다. 이를 통해 다음과 같은 가치를 실현합니다.

- **제로 에러(Zero Error) 온보딩:** 계정 및 권한 설정의 누락 없이 정해진 절차대로 정확하게 진행되어, 담당자가 매번 점검할 필요가 없습니다.
- **데이터 기반의 체계적인 경험:** 입사일, 30일 차 피드백 요청 등 모든 후속 조치가 정해진 일정에 맞춰 자동으로 진행되어 **신규 직원의 초기 이탈률을 낮추고** 만족도를 높입니다.
- **HR 리소스의 전략적 활용:** HR 담당자가 단순 행정 업무가 아닌, **인재 교육 및 문화 구축**과 같은 전략적인 업무에 집중할 수 있도록 핵심 리소스를 확보합니다.





## 📌 3. 예상 사용자/부서



> 본 워크플로우는 인사팀의 반복적인 업무 부담을 해소하고, 신규 입사자에게 체계적이고 오류 없는 입사 경험을 제공하는 모든 조직을 위해 설계되었습니다.
> 
- **주요 사용자:**
    - **HR/인사팀:** 신규 채용 및 온보딩 프로세스를 담당하며, 워크플로우의 트리거(새 직원 정보 입력)를 담당합니다.
- **간접적 수혜 부서:**
    - **각 부서(팀 리더):** 신규 팀원 맞이에 필요한 **초기 설정 시간이 단축**되어 핵심 업무에 집중할 수 있습니다.





## 💬 4. 사용 방법


<details>
  <summary>필요한 API 연결</summary>
  <ul>
    <li>Google Sheets API 발급 및 Credential 연결</li>
    <li>Gemini API 발급 및 Credential 연결</li>
    <li>Notion API 발급 및 Credential 연결</li>
    <li>Slack API 발급 및 Credential 연결</li>
</details>


<details>
  <summary>워크플로우 상세 과정</summary>
  <ul>
    <li><strong>Trigger (Google Sheets Trigger)</strong>: Google Sheets의 New Hires 시트에 새로운 행이 추가되는 이벤트를 감지하여 워크플로우를 실행합니다.</li>
    <li><strong>데이터 확보 (Get row(s) in sheet)</strong>: 트리거가 감지된 행을 포함하여 시트에서 신규 직원의 상세 정보 (이름, 이메일, 입사일, 부서 등)를 모두 가져옵니다.</li>
    <li><strong>IF 노드</strong>: 데이터 확보 노드에서 가져온 데이터 중, 온보딩 상태 컬럼이 비어있는(nan) 항목만 다음 단계로 보내는 필터 역할을 수행합니다.(중복 방지)</li>
    <li><strong>중간 기록 (Update row in sheet)</strong>: IF 노드를 통과한 항목들의 온보딩 상태 값을 "진행 중"과 같은 임시 상태로 즉시 업데이트하여, 워크플로우의 동시 실행으로 인한 중복 처리를 원천적으로 방지합니다.</li>
    <li><strong>입사 환영 (Send a message)</strong>: 신규 직원에게 개인화된 환영 및 첫 출근 안내 이메일을 즉시 발송합니다.</li>
    <li><strong>Notion DB 생성 (Create a database page)</strong>: Notion의 온보딩 데이터베이스에 템플릿을 기반으로 한 개인별 온보딩 체크리스트 페이지를 생성하고, 직원 정보를 속성에 기록합니다.</li>
    <li><strong>Wait Node (입사일까지 대기)</strong>: 신규 직원의 실제 입사일까지 워크플로우 실행을 일시 정지시킵니다.</li>
    <li><strong>데이터 통합 (Aggregate)</strong>: Notion DB 생성 노드를 통과한 개별 아이템(직원)들을 하나의 아이템 묶음으로 합쳐서 다음 Slack 노드가 한 번만 실행되도록 데이터를 준비합니다.</li>
    <li><strong>데이터 정제 (Code in JavaScript)</strong>: Aggregate 노드의 복잡한 출력 데이터에서 이름, 팀, 직무 필드만 추출하여 다음 노드에서 사용하기 쉬운 newHires 배열로 정제합니다.</li>
    <li><strong>팀 소개 (Send a message 1)</strong>: Aggregate와 Code 노드 덕분에 하나의 메시지에 모든 신규 입사자 정보를 담아 Slack 채널에 게시합니다.</li>
    <li><strong>Wait Node 1 (30일 대기)</strong>: 팀 소개 메시지 발송 후, 온보딩 기간인 30일 동안 워크플로우 실행을 정지합니다.</li>
    <li><strong>후속 관리 (Send a message 2)</strong>: 30일 대기 후, 신규 직원에게 온보딩 경험에 대한 피드백 설문조사 링크를 포함한 이메일을 발송합니다.</li>
    <li><strong>최종 기록 (Update row in sheet)</strong>: 모든 온보딩 프로세스가 완료되었음을 표시하기 위해 Google Sheets의 온보딩 상태 컬럼 값을 "완료" 상태로 최종 업데이트합니다.</li>
  </ul>
</details>


<details>
  <summary>코드 예시</summary>
  <ul>

// 입력으로 들어온 데이터(Aggregate 노드의 출력)를 가져옵니다.
const incomingData = $input.item.json.data;

// 최종적으로 Slack 메시지 생성을 위해 가공된 데이터를 저장할 배열입니다.
const processedData = [];

// incomingData 배열을 순회하며 필요한 필드만 추출합니다.
for (const item of incomingData) {
    processedData.push({
        팀: item['팀'],
        이름: item['이름'],
        직무: item['직무']
    });
}

// 다음 노드(Slack)로 전달할 때, 이 가공된 데이터를 하나의 아이템으로 묶어 전달합니다.
return [{
    json: {
        newHires: processedData // "newHires"라는 새로운 키에 가공된 데이터 배열을 담습니다.
    }
}];
    
  </ul>
</details>





## 💵 5. 사용 비용



|  | **Cost** |
| --- | --- |
| **Gemini 2.5 Flash** | $0.50  |
| **Notion API** | free |
| **Slack API** | free |
| **Google Sheets API** | free |





## 🗃️ 6. 참고 문헌



https://n8n.io/workflows/7809-automate-multi-step-onboarding-with-google-sheets-forms-and-gmail-notifications/

https://n8n.io/workflows/3860-automate-employee-onboarding-with-slack-jira-and-google-workspace-integration/

https://docs.n8n.io/flow-logic/splitting/

https://docs.n8n.io/flow-logic/merging/
