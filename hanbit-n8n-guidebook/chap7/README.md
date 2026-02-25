# 7장. 주식 시세 — AI 투자 리포트 메일링

> 매주 코스피 지수와 관심 종목의 시세를 조회하고, AI가 투자 리포트를 작성하여 HTML 이메일로 발송하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | 매주 월요일 오후 1시 스케줄 |
| 주요 서비스 | 공공데이터포털 주식 API, Google Gemini, Gmail |
| 출력 | HTML 형식의 주식 투자 리포트 이메일 |

## 워크플로우 흐름

```
                    ┌→ HTTP Request (코스피 API) → Edit Fields (코스피) ──┐
Schedule Trigger ──┤                                                     ├→ Merge → Aggregate → Basic LLM Chain → Edit Fields → Code (JS) → Gmail
                    └→ DataTable (종목 목록) → HTTP Request (개별종목) → Edit Fields (주식) ─┘
```

## 노드 구성

1. **Schedule Trigger** — 매주 월요일 오후 1시에 워크플로우를 자동 실행합니다.
2. **HTTP Request - 코스피** — 공공데이터포털 API로 코스피 지수 데이터를 조회합니다.
3. **Get row(s)** — n8n DataTable에서 관심 종목 목록(종목명)을 가져옵니다.
4. **HTTP Request** — 각 종목별로 공공데이터포털 주가 API를 호출합니다.
5. **Edit Fields - 코스피** — 코스피 데이터에서 종목명, 현재가, 등락, 등락률을 추출합니다.
6. **Edit Fields - 주식** — 개별 종목 데이터에서 종목명, 현재가, 등락, 등락률을 추출합니다.
7. **Merge** — 코스피 데이터와 개별 종목 데이터를 하나로 병합합니다.
8. **Aggregate** — 병합된 모든 데이터를 하나의 배열로 집계합니다.
9. **Basic LLM Chain** — 집계된 시장 데이터를 Gemini에 전달하여 투자 리포트를 생성합니다.
10. **Edit Fields** — LLM 분석 결과와 코스피/주식 데이터를 다음 단계에 맞게 정리합니다.
11. **Code in JavaScript** — 최종 데이터를 HTML 이메일 템플릿으로 변환합니다.
12. **Gmail (Send a message)** — 완성된 HTML 리포트를 이메일로 발송합니다.


## cURL - 7.2.2 [Task] HTTP Request - 코스피 
```curl -X GET
“https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/
getStockPriceInfo?serviceKey=본인의_인증키&numOfRows=10&pageNo=1&resultType=-
json&mrktCls=KOSPI"
```

## Expression - 7.4.3 [Task] Edit 노드로 핵심 정보 추출하기

### 05
```
{{ $(‘Merge’).all().map(i => i.json).find(s => s.종목명 === ‘코스피’) }}
```

### 06
```
{{ $(‘Merge’).all().map(i => i.json).filter(s => s.종목명 !== ‘코스피’) }}
```

## 프롬프트

Basic LLM Chain에서 사용하는 투자 전략가 프롬프트입니다.

```text
당신은 대한민국 최고의 주식 투자 전략가입니다. 아래 제공되는 오늘의 시장 데이터를 분석하여 투자 리포트를 작성해 주세요.

## 시장 데이터

{{ $json.data }}

## 작성 지침:
1. **시장 총평**: 코스피 지수의 움직임을 바탕으로 오늘 시장의 전반적인 분위기를 한 문장으로 요약하세요.
2. **종목별 분석**: 관심 종목(삼성전자, SK하이닉스 등) 각각에 대해 현재 상태와 간단한 기술적 의견을 제시하세요.
3. **투자 전략**: 위 데이터를 종합해 볼 때, 내일 시장에서 주의 깊게 봐야 할 포인트나 대응 전략을 전문가답게 조언해 주세요.
4. **말투**: 신뢰감 있고 전문적인 어조(~입니다, ~할 것으로 보입니다)를 사용하세요.
5. **주의**: HTML 태그를 쓰지 말고 순수 텍스트로만 답변하세요. (줄바꿈은 사용 가능)
```

## 코드 노드

Code in JavaScript 노드에서 사용하는 HTML 이메일 생성 코드입니다.

```javascript
const data = $input.all()[0].json;

// 데이터 파싱 (문자열일 경우 파싱, 이미 객체/배열이면 그대로 사용)
const parseData = (val) => {
  if (typeof val === 'string') return JSON.parse(val);
  return val;
};

const kospi = parseData(data['코스피']);
const stockData = parseData(data['주식']);

// 종목이 하나여도 배열로 변환하여 처리
const stocks = Array.isArray(stockData) ? stockData : [stockData];

// 숫자 포맷팅 헬퍼
const formatNumber = (num) => {
  return Number(num).toLocaleString('ko-KR');
};

// 색상 결정 헬퍼
const getColor = (value) => {
  const num = parseFloat(String(value).replace(/[+%]/g, ''));
  if (num > 0) return '#d32f2f'; // 상승: 빨강
  if (num < 0) return '#1976d2'; // 하락: 파랑
  return '#666';
};

// 등락 표시 헬퍼
const formatChange = (value) => {
  const num = parseFloat(String(value).replace(/[+%]/g, ''));
  if (num > 0) return '+' + formatNumber(num);
  return formatNumber(num);
};

const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Malgun Gothic', sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f5f5f5; }
    .container { background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    h1 { color: #1a237e; border-bottom: 3px solid #1a237e; padding-bottom: 10px; margin-bottom: 20px; }
    h2 { color: #283593; margin-top: 30px; margin-bottom: 15px; font-size: 1.2em; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; background-color: white; }
    th { background-color: #3f51b5; color: white; padding: 12px; text-align: left; font-weight: bold; font-size: 14px; }
    td { padding: 12px; border-bottom: 1px solid #e0e0e0; font-size: 14px; }
    .analysis { background-color: #f8f9fa; padding: 20px; border-left: 4px solid #3f51b5; margin-top: 20px; white-space: pre-wrap; line-height: 1.8; font-size: 14px; }
    .date { color: #666; font-size: 0.9em; margin-bottom: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>📈 주식 시장 일일 리포트</h1>
    <div class="date">${data.today}</div>

    <h2>🔷 코스피 지수</h2>
    <table>
      <tr><th>지수명</th><th>현재가</th><th>등락</th><th>등락률</th></tr>
      <tr>
        <td>${kospi.종목명}</td>
        <td>${formatNumber(kospi.현재가)}</td>
        <td style="color: ${getColor(kospi.등락)}">${formatChange(kospi.등락)}</td>
        <td style="color: ${getColor(kospi.등락률)}">${formatChange(kospi.등락률)}%</td>
      </tr>
    </table>

    <h2>📊 관심 종목</h2>
    <table>
      <tr><th>종목명</th><th>현재가</th><th>등락</th><th>등락률</th></tr>
      ${stocks.map(s => `
      <tr>
        <td><strong>${s.종목명}</strong></td>
        <td>${formatNumber(s.현재가)}</td>
        <td style="color: ${getColor(s.등락)}">${formatChange(s.등락)}</td>
        <td style="color: ${getColor(s.등락률)}">${formatChange(s.등락률)}%</td>
      </tr>
      `).join('')}
    </table>

    <h2>💡 전문가 분석</h2>
    <div class="analysis">${data.analysis}</div>
  </div>
</body>
</html>
`;

const subject = `[주식 리포트] ${data.today} - 시장 요약`;

return [{ json: { subject, html } }];
```

## 실습 안내

### 사전 준비

1. **공공데이터포털 API 키** — [공공데이터포털](https://www.data.go.kr/)에서 주식 시세 API 활용 신청 후 서비스 키를 발급받습니다.
2. **Google Gemini API 키** — Google AI Studio에서 API 키를 발급받고 n8n에 등록합니다.
3. **Gmail OAuth2 자격 증명** — n8n에서 Gmail OAuth2 연결을 설정합니다.
4. **n8n DataTable 설정** — 관심 종목명(예: 삼성전자, SK하이닉스 등)을 `name` 컬럼에 입력한 DataTable을 생성합니다.
5. Gmail 노드의 `sendTo` 필드에 수신할 이메일 주소를 입력합니다.
