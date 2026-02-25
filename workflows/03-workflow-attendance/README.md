# n8n템플릿
___
#n8n #자동화 #노코드 #근태관리 #슬랙봇
## Slack 근태 기록 자동 정리 시스템 
___
### 프로젝트 개요
   기존 근태관리는 직원들이 Slack 스레드에 '출근완', '퇴근완'  직접 입력하면 수동으로 확인하는 방식입니다.  
   이러한 방식은 데이터 관리의 비효율성을 초래하며, 체계적인 근태 내역 확인 및 데이터 누적 관리가 어렵습니다.  
   이에 근태 확인 절차를 자동화하여 근태 관리의 효율성을 높이고자 본 워크플로를 기획하게 되었습니다.  

   ### 문제정의 (What)
   Slack 기반의 근태 관리(출퇴근) 프로세스를 자동화하는 봇을 개발합니다.   

   ### 목표 (Why)
   체계적인 데이터 누적 관리를 통해 출퇴근 데이터 관리의 효율 증대

   ### 방법 (How) 
   - n8n 자동화 툴과 Slack API를 연동합니다.
   - 사용자가 Slack 출퇴근 채널에 특정 키워드 ('출근', '퇴근') 입력합니다.
   - n8n 노드가 해당 메시지의 사용자 정보, 기록 시간, 스레드 내용 등을 수집합니다.
   - 수집된 데이터를 Google Sheets에 자동으로 추가하여 누적시킵니다.

   ### 결과 (Result)

![n8n_Slack_Attendance_Bot_v2](https://github.com/user-attachments/assets/ee8b6b4d-0330-4f6c-8e08-83569ec150f4)



<img width="350" height="400" alt="Attendance_slack" src="https://github.com/user-attachments/assets/735eaf08-12fb-425f-a125-b5afe980d761" />


<img width="650" height="400" alt="Attendance_GoogleSheet" src="https://github.com/user-attachments/assets/4ea49b54-724e-4898-a97b-eaaf60d54180" />




### 예상 사용자/ 부서
   - Slack을 이미 도입했거나 도입하려는 조직
   - 인사팀(HR): 근태 내역을 취합하고 급여 정산, 휴가 관리에 활용합니다.
   - 각 팀 리더/ 매니저: 팀원의 출퇴근 현황을 파악하고 리소스를 관리합니다.

### 기술 검토 
   - 주요 사용 노드 (n8n):
     * Slack(: 특정 채널의 '출근', '퇴근' 키워드를 감지합니다.
     * Set/ Function: 수집된 데이터(사용자 ID, 시간 등)를 Google Sheets 형식에 맞게 가공합니다.  
     (예: 사용자 ID를 이름으로 변환)
     * Google Sheets: 가공된 데이터를 저장된 Google Sheets 문서에 행(row)으로 추가합니다.
   - 연동 API  
      - Slack API (Bot Tokken): 메시지 수신 및 사용자 정보 조회(users.info)
      - Google Sheets API: 시트에 접근하여 추가, 수정, 삭제하기

### 참조문서
   - [n8n 공식홈페이지](https://n8n.io/)
   - [n8n 공식 문서](https://docs.n8n.io/integrations/)
   - [n8n 한글 가이드북 slack api 챕터](https://wikidocs.net/290920)


