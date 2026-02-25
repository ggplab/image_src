#n8n #자동화 #노코드 #재고관리 #따릉이 #OpenAI #Seoul_Public_Data API #KakaoTalk  

## 🚲 서울시 공공자전거 따릉이 실시간 재고관리 
이 프로젝트는 서울시 따릉이 실시간 대여소 데이터를 자동으로 수집하고,
특정 대여소의 잔여 재고수량을 카카오톡 메시지로 전송하거나 AI 기반 간단 요약을 생성하여 구글 시트로 자동 발송하는 워크플로우입니다.  
__
### 📌 프로젝트 개요
- 서울시 공공데이터 API 기반 실시간 자전거 대여소 정보 수집
- 특정 대여소 및 지역 기준으로 필터링
- OpenAI 모델을 활용한 핵심 요약 생성
- 카카오톡 “나에게 보내기” API로 메시지 전달

### 🧩 사용 기술 스택
- n8n: 전체 워크플로우 자동화
- OpenAI GPT-4.1 / 5.1 nano: 대여소 데이터 요약 생성 
- 서울시 공공데이터 API: 실시간 따릉이 데이터 수집
- KakaoTalk 메시지 API: 알림 메시지 발송

### 📂 워크플로우 구성
1) Schedule Trigger
30분 주기 실행
필요 시 수동 실행 가능

2) 실시간 데이터 수집 (HTTP Request)
서울시 공공데이터 API 호출
JSON → item 단위 분리

3) 데이터 처리
특정 대여소 필터링
필요한 필드만 추출

4) OpenAI 요약 생성
프롬프트(예시):
```
다음은 00개 정류소를 분석한 중간 요약 결과이다.
전체 요약을 아래 기준으로 생성하라.

1) 잔여 대수 부족 문제 발생이 많은 지역  
2) 잔여 대수가 과도하게 많은 지역  
3) 시간대별 패턴 (출퇴근, 심야, 평일/주말)  
4) 배차가 가장 필요한 정류소 상위 5개  

데이터:
{{ $json["output"] }}

다음은 따릉이 대여소 데이터의 일부(batch)이다.
이 데이터에서 다음을 요약하라:

1) 총 대여소 개수  
2) 잔여 대수 기준으로 위험한 정류소(잔여 3대 이하) 목록  
3) 잔여 대수가 많은 정류소 상위 3개  
4) 전체 잔여 자전거 평균  

데이터:
{{JSON.stringify($json)}}
```

5) 카카오톡 인가토큰 생성 (HTTP Request1)    
카카오톡 나에게 메시지 보내기는 Access Token이 필요    
Access Token을 발급 받기 위해 인가토큰을 생성    
  
6) 데이터 처리 (Merge, Edit)    
따릉이 재고현황에 대한 데이터와 카카오톡 액세스 토큰을 병합      

7) 데이터 전송     
카카오톡으로 나에게 메시지 보내기    

### 결과 (Result)  

![n8n-inventory-bicycle](https://github.com/user-attachments/assets/e9a58e56-b044-40db-9281-db501ad62d68)


<img width="330" height="400" alt="inventory-bicycle-katalk1" src="https://github.com/user-attachments/assets/69e2580d-dac5-4093-b0ad-c29be4f786c6" />  

<img width="340" height="400" alt="inventory-bicycle-katalk2" src="https://github.com/user-attachments/assets/03aff4f6-1ce6-42e1-9900-70fa637e21eb" />

<img width="480" height="280" alt="inventory-bicycle-summary" src="https://github.com/user-attachments/assets/c7e082c1-b5cc-4804-b041-eba033af0e0a" />


### 📊 구조 및 데이터 흐름
```
[Trigger]
   ↓
[서울시 API 수집]
   ↓
[Split Out → Filter]
   ↓
[OpenAI 요약 생성]
   ↓
[카카오톡 메시지 발송]
   ↓
(Optional) Google Sheets 저장
```

### 🔧주요 설정
✔ 카카오톡 토큰 발급

1회용 인가코드 → Access Token 생성
메시지 발송 시 필요한 헤더:
```
Authorization: Bearer {{ $json.access_token }}
Content-Type: application/x-www-form-urlencoded
```
인가코드 생성 [URL](https://kauth.kakao.com/oauth/authorize?client_id=281596886c198c0d285b76bb5880991b&redirect_uri=https://n8n.ggplab.xyz/rest/oauth2-credential/callback&response_type=code&scope=talk_message)
카카오톡 로그인 필요, 1회용이므로 노드 실행시 재발급.  
또는 토큰 발행 실행시 같이 생성되는 REFRESH 토큰(6시간 지속) 사용.

### 예상 사용자/ 부서
   - 특정 시간대에 대여소(지점) 상황을 빠르게 파악해야 하는 운영팀 실무자.
   - 재고·발주를 모니터링하는 기업/부서/자영업자.
   - 특히, 시간대별 수요가 달라지는 업종(카페, 편의점, 배달 전문점 등)

📌 한계와 대안
- **한계**: 카카오톡 메시지 템플릿 구조상의 제한으로 요약 전문 표시 불가
- **대안**: 핵심만 한두 줄 요약 또는 구글 시트를 통해 리포트 생성 가능 

- **한계**: 인가토큰은 1회용이기 때문에 노드 실행시 재발급 필요.  
- **대안**: Refresh Token(6시간 지속) 기반 설계 가능

📝 향후 확장 아이디어
- Google Sheets 누적 저장 후 자동 시각화(선형 그래프/요약 통계)
- 시간대별 패턴 분석 자동 보고서 생성
- 특정 지역 위험도 알림 강화
- n8n 메모리 기반 추세 분석 모델 추가
- Notion API 연동한 자동 리포트 생성

### 참조문서 
   - [카카오톡 개발자센터](https://developers.kakao.com/)
   - [서울열린데이터광장](https://data.seoul.go.kr/)
   - [n8n커뮤니티사이트](https://community.n8n.io/t/)

### 💰 OpenAI API 비용  

n8n 자동화 워크플로우 실행 과정에서 OpenAI GPT 모델을 호출하여
실시간 따릉이 데이터 요약을 생성했습니다.

| 모델 | Input 비용 | Output 비용 | 합계 |
|------|------------|-------------|------|
| gpt-4.1-nano | $0.011 | $0.064 | **$0.075** |
| gpt-5-nano   | $0.002 | $0.232 | **$0.234** |

**총 비용: $0.309 (약 430원)**

