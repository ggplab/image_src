# 🗂️ AI 기반 로컬 파일 자동 정리 시스템

> n8n + OpenAI + Docker Compose로 구현한 지능형 파일 분류 및 자동 정리 워크플로우
> 
### n8n 워크플로우 구조

<img width="1600" height="520" alt="workflow" src="https://github.com/user-attachments/assets/88a17d2d-f9b2-426f-bddf-7672dd24f048" />

### 실제 결과물
**Google Sheets 자동 기록** **Documents 자동 분류**
<img width="1500" height="480" alt="google sheets" src="https://github.com/user-attachments/assets/4df1c4a0-228a-49e1-a5d0-3e3a9186df6f" />
<img width="700" height="360" alt="documents" src="https://github.com/user-attachments/assets/92cd74c9-7dc7-4a8b-8c67-23db5ab250cb" />


## 📑 목차

- 문제 정의
- 예상 사용자/부서
- 사용 방법
- 사용 비용
- 참고 문헌


## 🎯 문제 정의

### 현재 문제점

**다운로드 폴더의 무분별한 파일 누적**

- 매일 수십 개의 파일이 다운로드 되지만 정리되지 않음
- 파일 하나하나 열어보고 적절한 폴더를 찾아 이동하는 반복 작업
- 일관성 없는 폴더 구조로 인한 혼란
- 계약서, 영수증 등 중요 파일이 다운로드 폴더에 묻혀 놓침

### 솔루션

**AI가 파일명, 확장자, 기존 폴더 구조를 분석하여 지능적으로 최적의 위치를 제안하고 자동 이동**

```
📥 Downloads 폴더에 파일 추가
         ↓
🔍 매 5분마다 자동 스캔
         ↓
🤖 AI가 파일명 + 확장자 분석
         ↓
📊 기존 폴더 구조 학습
         ↓
🎯 최적 위치 결정
         ↓
📂 자동으로 폴더 생성 및 이동
         ↓
📝 Google Sheets에 로그 기록
```

### 워크플로우 구조

```
┌─────────────────────────────────────────────────────────┐
│         🗂️ AI 기반 파일 자동 정리 시스템                 │
└─────────────────────────────────────────────────────────┘

⏰ Schedule Trigger → 📂 폴더 스캔 → 🔍 파일 정보 추출 →
📊 기존 폴더 조회 → 🤖 OpenAI 분석 → 📋 JSON 파싱 →
🚚 파일 이동 → 📝 Google Sheets 로그
```

## 👥 예상 사용자/부서

### 개인 사용자

- **직장인**: 매일 10개 이상의 파일을 다운로드하는 사람
- **학생**: 강의 자료, 과제, 논문 등을 체계적으로 관리해야 하는 사람
- **프리랜서**: 클라이언트별로 파일을 정리해야 하는 사람

### 조직/부서

- **연구팀**: 논문, 데이터, 보고서 등 다양한 파일을 다루는 팀
- **CS팀**: 고객 문의 관련 파일을 정리해야 하는 부서
- **재무팀**: 계약서, 영수증, 세금계산서 등을 관리하는 부서

## 📖 사용 방법

<details>
  <summary>1️⃣ 폴더 구조 생성</summary>

```
C:\Users\YOUR_USERNAME\Desktop\
├── N8N\                    ← Docker Compose 설정 파일 위치
├── test\
│   ├── Downloads\          ← 파일이 들어올 폴더
│   └── Documents\          ← 정리된 파일이 저장될 폴더
└── n8n_data\               ← n8n 데이터 저장 (자동 생성됨)
```
</details>

<details>
  <summary>2️⃣ Docker Compose 설정</summary>
         
**`C:\Users\YOUR_USERNAME\Desktop\N8N\docker-compose.yml` 파일 생성:**

```yaml
version: '3.8'

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - NODE_FUNCTION_ALLOW_BUILTIN=fs,path
      - NODE_FUNCTION_ALLOW_EXTERNAL=
    volumes:
      - C:/Users/YOUR_USERNAME/Desktop/test:/data/test
      - C:/Users/YOUR_USERNAME/Desktop/n8n_data:/home/node/.n8n
```

⚠️ **중요:** `YOUR_USERNAME`을 실제 Windows 사용자 이름으로 변경!

**PowerShell에서 실행:**

```powershell
# N8N 폴더로 이동
cd C:\Users\YOUR_USERNAME\Desktop\N8N

# Docker Compose로 n8n 시작
docker-compose up -d
```

**브라우저에서 접속:** `http://localhost:5678`

</details>

<details>
  <summary>3️⃣ n8n 워크플로우 Import</summary>

- n8n 웹 인터페이스 접속
- **Workflows** → **Import from File**
- `file_organizer_github.json` 파일 선택
- Import 완료
</details>

<details>
  <summary>4️⃣ Credential 연결</summary>

### OpenAI API 설정

- [OpenAI Platform](https://platform.openai.com/api-keys)에서 API Key 발급
- `5. OpenAI 파일 분석` 노드 클릭
- **Credential** → **Create New**
- API Key 입력 후 저장

### Google Sheets API 설정

- [Google Cloud Console](https://console.cloud.google.com/) 접속
- 새 프로젝트 생성 → **Google Sheets API** 활성화
- **OAuth 2.0 Client ID** 생성
- n8n에서 `8. Google Sheets 로그` 노드 클릭
- **Credential** → **Create New** → OAuth2 인증

**Google Sheets 구조 (첫 번째 행):**

| timestamp | original_path | filename | extension | file_type | category | target_folder | confidence | reasoning | moved | action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

</details>

<details>
  <summary>5️⃣ 경로 설정 (중요!)</summary>

**3곳의 경로를 일치시켜야 합니다:**

| 위치 | 경로 |
| --- | --- |
| **Docker Compose** | `C:/Users/YOUR_USERNAME/Desktop/test:/data/test` |
| **노드 2 (폴더 스캔)** | `const downloadsPath = '/data/test/Downloads';` |
| **노드 4 (기존 폴더 조회)** | `const documentsPath = '/data/test/Documents';` |
| **노드 7 (파일 이동)** | `const baseDir = '/data/test/Documents';` |

</details>

<details>
  <summary>6️⃣ 저장 및 활성화</summary>

- 워크플로우 우측 상단 **Save** 클릭
- **Active** 토글 켜기 ✅
- 자동 실행 시작!

</details>

<details>
  <summary>7️⃣ 실행 확인</summary>

**Downloads 폴더에 파일 추가** → **5분 대기** → **Documents 폴더에서 정리된 파일 확인**

**수동 실행:** n8n에서 **Execute Workflow** 버튼 클릭

### 🔄 Docker Compose 관리

```powershell
# N8N 폴더로 이동 (항상 먼저!)
cd C:\Users\YOUR_USERNAME\Desktop\N8N

# 시작
docker-compose up -d

# 중지
docker-compose down

# 재시작
docker-compose restart

# 로그 보기
docker-compose logs -f n8n

```

### 🎯 AI 분류 예시

| 파일명 | AI 분류 결과 |
| --- | --- |
| `2024_계약서_최종본.pdf` | Documents/계약서/ |
| `meeting_notes_20241124.txt` | Documents/회의록/ |
| `invoice_202411.xlsx` | Documents/재무/영수증/ |
| `screenshot_bug.png` | Documents/스크린샷/ |
| `machine_learning_paper.pdf` | Documents/논문/ |

</details>

## 💰 사용 비용

### OpenAI API 비용 (GPT-4o-mini)

| 일일 파일 수 | 월 예상 비용 |
| --- | --- |
| 10개 | **$0.30** |
| 30개 | **$0.90** |
| 100개 | **$3.00** |

**계산 근거:**

- Input: $0.150 / 1M tokens
- Output: $0.600 / 1M tokens
- 평균 1회 호출: ~500 input + ~150 output tokens

### 무료 구성 요소

- ✅ n8n Self-hosted (오픈소스)
- ✅ Docker Compose (무료)
- ✅ Google Sheets API (무료)

## 🔧 트러블슈팅

<details>
  <summary>❌ "Module 'fs' is disallowed"</summary>

**해결:** `docker-compose.yml`에 환경 변수 확인

```yaml
environment:
  - NODE_FUNCTION_ALLOW_BUILTIN=fs,path
```

컨테이너 재시작:

```powershell
docker-compose restart
```

</details>

<details>
  <summary>❌ "ENOENT: no such file or directory"</summary>

**해결:** Docker 볼륨 마운트 경로 확인

1. `docker-compose.yml`에서 경로 확인
2. 실제 폴더 존재 여부 확인
3. 컨테이너 재시작

</details>

<details>
  <summary>❌ 재부팅 후 n8n이 자동 시작 안 됨</summary>

**해결:**

1. **Docker Desktop 자동 시작 설정**
    - Docker Desktop 설정 → General
    - ✅ "Start Docker Desktop when you log in" 체크
2. **restart 정책 확인**
    
    ```yaml
    restart: unless-stopped  # 이게 있어야 함
    ```
</details>


## 📚 참고 문헌

### 공식 문서

- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [Google Sheets API](https://developers.google.com/sheets/api)

### 레퍼런스
- [n8n Community Workflows](https://n8n.io/workflows/2334-organise-your-local-file-directories-with-ai/)
- [n8n Code Node Guide](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.code/)


## 🎁 파일 목록

```
📦 file-organizer/
├── 📄 README.md                      ← 이 파일
├── 📄 docker-compose.yml             ← Docker Compose 설정
├── 📄 file_organizer_github.json     ← n8n 워크플로우
└── 📄 NODE_COMMENTS.md               ← 노드별 상세 설명
```
