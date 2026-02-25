# Reservation System(공실예약 시스템)

> **공실사용 예약 및 알림 시스템**
웹앱을 이용하여 예약을 진행하고 n8n을 이용하여 예약 알림 자동화
> 

(주의! 웹앱의 구글시트ID와 웹훅의 url을 정확하게 입력해 주셔야 작동)

- **n8n화면**

<img width="1459" height="730" alt="image" src="https://github.com/user-attachments/assets/ad5bccad-21f2-4588-9e22-799f617ad9a8" />


- **예약화면**

<img width="1896" height="915" alt="image 1" src="https://github.com/user-attachments/assets/93f49205-894d-4032-b739-0ef2fdbd1b37" />

<img width="1063" height="256" alt="image 2" src="https://github.com/user-attachments/assets/7f00df71-d1e8-46de-ade1-0e3b19786845" />

## 📃 목차

---

- 개요
- 주요 기능
- 비용
- API연동
- 세팅방법

## 1. 개요

---

웹앱과 n8n을 결합하여 따로 예약관리를 하지 않아도 관리자가 예약 확인/취소 알림과 캘린더 등록 및 삭제 서비스를 받을 수 있고 예약자에게도 예약완료 및 취소 알림을 발송하는 시스템입니다.

회사나 공공기관에서 공실을 운영할 때 따로 예약 사이트에서 구독을 하지 않고 자체적으로 비용없이 간단하게 예약을 관리할 수 있습니다.

### 1. 장점

- 비용이 발생 ❌
- 활용성 면에서 유용 : 웹앱 폼을 조금만 수정하면 카페나 스터디 카페, 미용실 예약 등 공실 예약 뿐만 아니라 예약을 운용하는 모든 분야에서 이용가능

### 2. 단점

- 슬랙을 이용한 알림으로 활용성 저하
    - 카카오톡 채널을 이용하여 알림발송 시 사업자 등록 필요, 비용발생

## 2. 비용(n8n이용 비용 제외)

### 1. 슬랙이용 시

- 비용 발생X

### 2. 카카오 채널 이용 시

- 건당 10원의 비용 발생
    - 노드를 카카오톡 채널에 맞춰서 수정도 필요

## 3. 주요기능

---

### 1. 예약 완료 알림

- 예약 시 예약 내역을 조회하여 해당 예약자에게 예약완료 알림 발송
- 예약자에게 알림 발송 후 관리채널(관리자)에 예약완료 알림 발송 및 관리 캘린더에 자동 등록

### 2. 예약 취소 알림

- 예약 취소 시 취소 내역을 조회하여 해당 예약자에게 취소완료 알림 발송
- 예약자에게 알림 발송 후 관리채널(관리자)에 취소완료 알림 발송 및 관리 캘린더에서 자동 삭제

## 4. API 연동

---

### 1. 구글 스프레드 시트/ 캘린더 Credential

- 구글 클라우드에서 콘솔을 이용하여 OAuth계정을 만들고 클라이언트ID와 비번을 통해 연결
- 라이브러리에서 구글 스트레드 시트와 캘린더 사용 신청 필수

### 2. slack 챗봇 토큰

- 슬랙 사이트에서 챗봇을 만들고 챗봇의 토큰과 signing secret을 통해 연결
- 스코프 users:read.email, chat:write 추가 필수
- 워크스페이스와 관리 채널에 챗봇이 초대되어 있어야 알림 발송 가능

## 5. 세팅방법

---

1. n8n 클라우드 로그인(회원가입 시 14일 무료)
2. reservation system.json파일 업로드
3. 구글스프레드시트, 캘린더, 슬랙 챗봇 Credential / API 발급 및 해당 노드에 연결
4. 구글 클라우드에 reservation system_DB파일 업로드 및 구글 스프레드 시트 노드에 연결
5. reservation system_DB에서 확장프로그램을 통해 App Script 작성
    - reservation system_script.txt, reservation system_HTML.txt 속 내용 복사 붙여넣기
6. reservation system_script내용 수정
    - 구글 스프레드 시트 연결
        - const SPREADSHEET_ID = 'reservation system_DB 구글스프레드시트 ID'
    - 웹훅 연결
        - const N8N         = '예약등록 트리거 웹훅 url’
        - const N8N_CANCEL  = '예약취소 트리거 웹훅 url'
7. 배포를 통해 앱 배포
