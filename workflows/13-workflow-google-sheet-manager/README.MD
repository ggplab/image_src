# Google Sheets 버전 관리 시스템

> 이 시스템은 **Google Sheets의 Git 같은 버전 관리**를 제공합니다. 
> 실수로 데이터를 삭제하거나 잘못 수정해도, 5분 단위로 자동 저장된 버전 중 아무 때나 복구할 수 있습니다. 
> OpenAI가 모든 변경사항을 자동으로 분석하여 "119개 행 추가됨"처럼 이해하기 쉽게 요약해주고, 중요한 변경사항은 Slack으로 즉시 알려줍니다. 

## 🎉 주요 기능
<details>
  <summary>✅ 자동 버전 관리</summary>

- 5분마다 자동으로 시트 변경 감지
- AI가 변경사항을 한글로 요약
- 중요 변경사항 자동 감지 및 알림
</details>

<details>
  <summary> ✅ 원클릭 복구</summary>

- 클릭 한 번으로 이전 버전 복구
- 복구 전 자동 백업 (v9999)
- 실수해도 백업에서 재복구 가능
</details>

<details>
  <summary> ✅ 완전한 이력 추적</summary>

- 모든 버전 영구 저장
- 변경 이력 자동 기록
- 복구 로그 저장
</details>

<details>
  <summary> ✅ 실시간 협업</summary>

- Slack 실시간 알림
- 팀원 모두 동일한 최신 버전 확인
- 데이터 손실 걱정 제로
</details>

## 📋 1. 목차

- 문제 정의
- 예상 사용자
- 사용 방법
- 사용 비용
- 참고 문헌

## 🎯 2. 문제 정의

### 비효율적인 수동 백업과 데이터 손실 위험

Google Sheets에서 중요한 데이터를 관리하는 과정에서 실수로 데이터를 삭제하거나, 누군가 의도치 않게 중요한 정보를 수정했을 때, 이를 되돌릴 방법이 없어 프로젝트 진행에 치명적인 영향을 미칩니다. 수동으로 백업을 관리하는 것은 번거로울 뿐만 아니라, 다음과 같은 문제들이 발생합니다:

- **데이터 손실**: 실수로 삭제된 데이터를 복구할 방법이 없어 업무가 중단됩니다.
- **변경 추적 불가**: 누가, 언제, 무엇을 변경했는지 알 수 없어 책임 소재가 불명확합니다.
- **수동 백업의 한계**: 일일이 복사본을 만드는 것은 비효율적이며, 최신 버전을 놓치기 쉽습니다.
- **복구 시간 소요**: 문제 발생 시 이전 상태를 찾고 복구하는 데 많은 시간이 소요됩니다.

### 달성 가치

반복적이고 비효율적인 수동 백업 작업을 완전히 자동화하여, 구성원들은 데이터 관리 걱정 없이 핵심 업무에 집중할 수 있습니다. 5분마다 자동으로 버전을 저장하고, AI가 변경사항을 분석하여 중요한 수정사항은 실시간으로 알려줍니다. 실수로 데이터를 삭제해도 클릭 한 번으로 이전 버전을 복구할 수 있어, 데이터 손실에 대한 불안감을 완전히 제거합니다.

## 📌 3. 예상 사용자/부서

본 워크플로우는 Google Sheets에서 중요한 데이터를 관리하고, 데이터 손실 없이 안전하게 협업해야 하는 모든 사용자에게 유용합니다.

- **PM (프로젝트 관리자)**: 프로젝트 진행 상황과 리소스를 추적하는 시트의 버전 관리
- **데이터 분석가**: 판매 데이터, 재고 관리, 성과 지표 등 중요 데이터의 변경 이력 추적
- **재무팀**: 예산 및 회계 데이터의 안전한 버전 관리 및 감사 추적
- **마케팅팀**: 캠페인 성과 데이터와 KPI 시트의 자동 백업
- **모든 팀**: 협업 시트에서 실수로 인한 데이터 손실 걱정 없이 작업

<img width="500" height="500" alt="google sheet" src="https://github.com/user-attachments/assets/79cd6836-248a-480d-a8df-a83e51e9c2cb" />

google sheet

## 💬 4. 사용 방법

### 필요한 API 및 Credential 연결

<details>
  <summary> Google Sheets OAuth2</summary>

```
Google Cloud Console → OAuth 2.0 클라이언트 생성
→ n8n에서 Google Sheets Credential 추가
→ 시트 접근 권한 부여
```
</details>

<details>
  <summary> Supabase API</summary>

```
Supabase 프로젝트 생성
→ Project URL 및 service_role key 확인
→ n8n에서 Supabase Credential 추가
```
</details>

<details>
  <summary> OpenAI API</summary>

```
https://platform.openai.com/ → API 키 발급
→ n8n에서 OpenAI Credential 추가
⚠️ 주의: API 키를 워크플로우에 직접 입력 금지! Credential만 사용!
```
</details>

<details>
  <summary> Slack Bot Token (선택사항)</summary>

```
Slack App 생성 → Bot Token 발급
→ 채널에 Bot 초대
→ n8n에서 Slack Credential 추가
```
</details>

### 데이터베이스 설정

<details>
  <summary> Supabase SQL Editor</summary>

### database/schema.sql 전체 실행

```sql
-- 전체 스키마를 복사하여 SQL Editor에 붙여넣고 RUN
-- 자동으로 3개 테이블 생성:
-- ✅ sheet_versions (버전 저장)
-- ✅ change_history (변경 이력)
-- ✅ restore_log (복구 로그)
```

<details>
  <summary> v0 초기 데이터 생성 (필수!)</summary>

```sql
INSERT INTO sheet_versions (
  sheet_id,
  sheet_name,
  version_number,
  data,
  row_count,
  data_hash,
  summary,
  created_by
) VALUES (
  'YOUR_GOOGLE_SHEET_ID',  -- 실제 Sheet ID로 변경
  '판매 데이터',            -- 시트 이름
  0,
  '[]'::jsonb,
  0,
  'initial',
  '시스템 초기화',
  'manual_setup'
);
```
</details>

</details>

<details>
  <summary> 추적 워크플로우 (자동 버전 저장)</summary>

<img width="1500" height="300" alt="traking workflow" src="https://github.com/user-attachments/assets/8c86120d-a78c-4630-ab48-587fbe082402" />

n8n 워크플로우 구조

**1단계: Import**

```
n8n 메인 화면 → Import from File
→ workflows/tracking.json 선택
```

**2단계: Credentials 연결**

```
✅ Google Sheets OAuth2
✅ Supabase API
✅ OpenAI API
✅ Slack OAuth2 (선택)
```

**3단계: 설정 확인 및 수정**

```
📍 Read Current Sheet 노드:
   - Document ID: 실제 Google Sheets ID로 변경
   - Sheet Name: 실제 시트 탭 이름으로 변경

📍 Prepare Data 노드:
   - sheetId 변수: 실제 Sheet ID로 변경
   - sheetName 변수: 실제 시트 이름으로 변경

📍 Get Last Version 노드:
   - Options > Sort 확인: id, desc (필수!)

📍 OpenAI HTTP Request 노드:
   - Authentication: predefinedCredentialType
   - Credential 선택 (API 키 직접 입력 ❌)
```

**4단계: 활성화**

```
Save (Ctrl+S) → Active 토글 ON
```
</details>

<details>
  <summary> 복구 워크플로우 (버전 복구)</summary>

<img width="1500" height="320" alt="restore workflow" src="https://github.com/user-attachments/assets/9392dc38-f520-496f-b4c5-64ad17d8e673" />

### n8n 워크플로우 구조

**1단계: Import**

```
n8n 메인 화면 → Import from File
→ workflows/restore.json 선택
```

**2단계: Credentials 연결**

```
✅ Google Sheets OAuth2
✅ Supabase API
```

**3단계: 설정 확인**

```
📍 Backup Current Data / Clear Sheet / Write Restored Data:
   - Document ID: 실제 Google Sheets ID로 변경
   - Sheet Name: 실제 시트 이름으로 변경

📍 Prepare Restore Data 노드:
   - Code 확인: row_number 제거 로직 포함
```

**4단계: Webhook URL 확인**

```
Webhook Restore 노드 클릭
→ Production URL 복사
예: https://your-n8n.com/webhook/restore-sheet-version
```

**5단계: 활성화**

```
Save (Ctrl+S) → Active 토글 ON
```
</details>

### 워크플로우 상세 과정

<details>
  <summary> 🔄 추적 워크플로우 (Tracking)</summary>

```
Every 5 Minutes (스케줄 트리거)
  ↓
Read Current Sheet (시트 데이터 읽기)
  ↓
Prepare Data (데이터 준비 및 해시 생성)
  ↓
Get Last Version (이전 버전 조회)
  ↓
OpenAI HTTP Request (AI에게 변경사항 분석 요청)
  ↓
Parse AI Response (AI 응답 파싱)
  ↓
IF Changes Detected (변경 감지 시)
  ↓
Save Version (Supabase에 새 버전 저장)
  ↓
Save Change History (변경 이력 기록)
  ↓
IF Important Change (중요 변경 시)
  ↓
Send Slack Notification (Slack 알림 발송)
```

**주요 기능:**

- **자동 실행**: 5분마다 시트 변경 감지
- **AI 분석**: OpenAI가 변경사항을 한글로 자동 요약
- **중요도 판단**: AI가 중요한 변경사항 자동 감지
- **실시간 알림**: 중요 변경 시 Slack으로 즉시 알림
</details>

<details>
  <summary>🔄 복구 워크플로우 (Restore)</summary>

```
Webhook Restore (HTTP 요청 수신)
  ↓
Parse Request (요청 파싱)
  ↓
Get Version to Restore (복구할 버전 조회)
  ↓
IF Version Exists (버전 존재 확인)
  ↓
Backup Current Data (현재 데이터 백업)
  ↓
Prepare Backup (백업 준비)
  ↓
Save Backup (v9999로 백업 저장)
  ↓
Clear Sheet (시트 비우기)
  ↓
Prepare Restore Data (복구 데이터 준비)
  ↓
Write Restored Data (데이터 복원)
  ↓
Log Restore (복구 로그 저장)
  ↓
Success Response (성공 응답)
```

**주요 기능:**

- **자동 백업**: 복구 전 현재 데이터를 v9999로 자동 백업
- **안전한 복구**: 실수해도 백업에서 다시 복구 가능
- **로그 기록**: 모든 복구 작업 이력 저장
</details>

### 실제 사용법

<img width="500" height="500" alt="notify slack" src="https://github.com/user-attachments/assets/254cf37c-da77-4dac-a3c9-c87071157b34" />

slack 알림

<details>
  <summary> 자동 추적 (설정 후 자동)</summary>

```
워크플로우 Active 상태 유지
→ 5분마다 자동 실행
→ Supabase에서 버전 확인:
  SELECT * FROM sheet_versions
  ORDER BY id DESC LIMIT 10;
```
</details>

<details>
  <summary> 수동 복구 (필요 시)</summary>

**Step 1: 복구할 버전 찾기**

```sql
-- Supabase SQL Editor에서 실행
SELECT
  id,
  version_number,
  row_count,
  summary,
  created_at
FROM sheet_versions
WHERE sheet_id = 'YOUR_GOOGLE_SHEET_ID'
ORDER BY id DESC
LIMIT 20;
```

**Step 2: 복구 실행**

방법 1 - PowerShell (Windows):

```powershell
Invoke-RestMethod -Uri "https://your-n8n.com/webhook/restore-sheet-version" -Method POST -ContentType "application/json" -Body '{"version_id": 3}'
```

방법 2 - curl (Mac/Linux):

```bash
curl -X POST https://your-n8n.com/webhook/restore-sheet-version \
  -H "Content-Type: application/json" \
  -d '{"version_id": 3}'
```

방법 3 - 브라우저 Console:

```jsx
fetch('https://your-n8n.com/webhook/restore-sheet-version', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({version_id: 3})
})
.then(r => r.json())
.then(d => console.log(d))
```

**Step 3: 결과 확인**

```
성공 응답:
{
  "success": true,
  "message": "버전 복구가 완료되었습니다.",
  "restored_version": 1,
  "row_count": 50,
  "backup_version_id": 11
}

Google Sheets 새로고침 (F5) → 데이터 복구 완료!
```
</details>

### 프롬프트 예시

<details>
  <summary> OpenAI Prompt: 변경사항 분석</summary>

```
System: 당신은 데이터 분석 전문가입니다. 항상 유효한 JSON 형식으로만 응답합니다.

User: 당신은 Google Sheets 버전 관리 전문가입니다.

현재 시트 정보:
- 행 개수: 119개
- 데이터 해시: 3eddc8bd

이전 버전 정보:
- 버전 번호: 5
- 행 개수: 50개
- 데이터 해시: 4a09c88a

작업:
1. 현재 데이터와 이전 버전을 비교
2. 변경사항이 있는지 확인
3. 변경사항을 한글로 간단히 요약
4. 중요한 변경인지 판단

응답 형식:
{
  "has_changes": true,
  "summary": "69개 행이 추가되었습니다.",
  "is_important": true,
  "next_version": 6
}

중요: 반드시 위 JSON 형식으로만 응답하세요.
```
</details>

## 🚧 5. Troubleshooting

<details>
  <summary> 문제 : "webhook is not registered" 오류</summary>

**증상:**

```json
{"code":404,"message":"The requested webhook is not registered"}
```

**원인:** 워크플로우가 Active 상태가 아님

**해결:**

```
n8n → 워크플로우 → 우측 상단 토글 ON → Save
```
</details>

<details>
  <summary> 문제 : 버전이 계속 1로 고정</summary>

**원인:** Get Last Version 노드에 정렬 없음

**해결:**

```
Get Last Version 노드 클릭
→ Options → Sort 추가
→ Field: id
→ Direction: desc
```
</details>

<details>
  <summary>문제 : 복구 시 빈 행만 생성</summary>

**원인:** row_number 필드가 제거되지 않음

**해결:**

```jsx
// Prepare Restore Data 노드 코드 수정
const versionData = $('Get Version to Restore').first().json;
const restoreData = typeof versionData.data === 'string'
  ? JSON.parse(versionData.data)
  : versionData.data;

// row_number 제거 추가!
const cleanData = restoreData.map(row => {
  const { row_number, ...rest } = row;
  return rest;
});

return cleanData.map(row => ({ json: row }));
```
</details>


<details>
  <summary>문제 : 복구 후 데이터가 다시 사라짐</summary>

**원인:** Tracking 워크플로우가 계속 실행 중

**해결:**

```
방법 1: Tracking 워크플로우 임시 OFF
방법 2: 복구 완료 후 10분 대기
방법 3: Tracking 간격을 15분으로 늘리기
```
</details>

<details>
  <summary>문제 : OpenAI API 키 오류</summary>

**원인:** API 키가 하드코딩되어 있거나 잘못됨

**해결:**

```
1. OpenAI HTTP Request 노드
2. sendHeaders: false (Header 섹션 제거)
3. Authentication: "predefinedCredentialType"
4. Node Credential Type: "openAiApi"
5. Credential 선택
⚠️ 절대 API 키를 직접 입력하지 마세요!
```
</details>

## 💵 6. 사용 비용

| 항목 | 비용 | 설명 |
| --- | --- | --- |
| **OpenAI API** | $0.50~$1.00/월 | gpt-4o-mini, 5분 간격 기준 |
| **Supabase** | 무료 | Free tier (500MB, 충분함) |
| **Google Sheets API** | 무료 | 무제한 |
| **n8n** | 무료 | Self-hosted |
| **Slack API** | 무료 | 선택사항 |

## 🗃️ 7. 참고 문헌

- [n8n workflow](https://n8n.io/workflows/9934-keep-rag-system-updated-with-google-drive-file-changes-to-supabase-vector-db/)
- [Git Version Control](https://git-scm.com/)
- [Google Sheets Version History](https://support.google.com/docs/answer/190843)
