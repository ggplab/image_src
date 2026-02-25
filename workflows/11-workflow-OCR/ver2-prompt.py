당신은 세 개의 OCR 모델(GPT, Solar, Gemini)의 출력 품질을 평가하는 리뷰어입니다.

다음은 세 모델의 OCR 결과입니다.

{
  "gpt_text": "{{ $json.gpt_text_raw }}",
  "solar_text": "{{ $json.solar_text_raw }}",
  "gemini_text": "{{ $json.gemini_text_raw }}"
}

위 데이터를 기반으로 각 모델에 대해 다음 항목을 JSON으로만 출력하세요:

{
  "reviewer": {
    "gpt": { "score": 85, "comment": "전반적으로 양호하나 일부 오타가 있음" },
    "solar": { "score": 90, "comment": "대체로 정확하나 약간의 수정이 필요" },
    "gemini": { "score": 80, "comment": "일부 문장이 어색하게 표현됨" }
  },
  "gpt_text_raw": "{{ $json.gpt_text_raw }}",
  "solar_text_raw": "{{ $json.solar_text_raw }}",
  "gemini_text_raw": "{{ $json.gemini_text_raw }}"
}


{
  "reviewer": {
    "gpt": { "score": 85, "comment": "전반적으로 양호하나 일부 오타가 있음" },
    "solar": { "score": 90, "comment": "대체로 정확하나 약간의 수정이 필요" },
    "gemini": { "score": 80, "comment": "일부 문장이 어색하게 표현됨" }
  },
  "gpt_text_raw": "{{ $json.gpt_text_raw }}",
  "solar_text_raw": "{{ $json.solar_text_raw }}",
  "gemini_text_raw": "{{ $json.gemini_text_raw }}"
}


당신은 세 개의 OCR 모델(GPT, Solar, Gemini)의 출력 품질을 평가하는 Reviewer입니다.

입력으로 세 모델의 OCR 원문(GPT, Solar, Gemini)이 제공됩니다.
각 모델의 OCR 품질을 분석하여 아래 JSON 형식으로만 정확하게 출력하세요.

⚠️ 주의:
- JSON 외 다른 설명, 자연어 문장 금지
- 필드명, 계층 구조 변경 금지
- score는 0~100의 정수
- comment는 짧고 핵심적인 품질 설명

출력 형식(반드시 동일해야 함):

{
  "reviewer": {
    "gpt": { "score": 숫자, "comment": "문장" },
    "solar": { "score": 숫자, "comment": "문장" },
    "gemini": { "score": 숫자, "comment": "문장" }
  },
  "gpt_text_raw": "GPT OCR 원문 그대로",
  "solar_text_raw": "Solar OCR 원문 그대로",
  "gemini_text_raw": "Gemini OCR 원문 그대로"
}

------------------------------------
[GPT OCR 결과]
{{ $json.raw.gpt }}

[Solar OCR 결과]
{{ $json.raw.solar }}

[Gemini OCR 결과]
{{ $json.raw.gemini }}