# 3장. OpenWeatherMap 날씨 알림

> 서울의 현재 날씨와 내일 예보를 자동으로 Discord 채널에 전송하는 워크플로우

## 워크플로우 개요

| 항목 | 내용 |
|------|------|
| 트리거 | 매일 오전 6시 스케줄 |
| 주요 서비스 | OpenWeatherMap API, Discord Webhook |
| 출력 | 현재 날씨 + 내일 예보가 담긴 Discord 메시지 |

## 워크플로우 흐름

```
                    ┌→ OpenWeatherMap (현재 날씨) ─┐
Schedule Trigger ──┤                               ├→ Merge → Discord
                    └→ OpenWeatherMap1 (5일 예보) ──┘
```

## 노드 구성

1. **Schedule Trigger** — 매일 오전 6시에 워크플로우를 자동 실행합니다.
2. **OpenWeatherMap** — 서울의 현재 날씨 데이터(기온, 상태, 일출/일몰 등)를 조회합니다.
3. **OpenWeatherMap1** — 서울의 5일간 예보 데이터를 조회합니다.
4. **Merge** — 현재 날씨와 예보 데이터를 위치 기반으로 병합합니다.
5. **Discord** — 정리된 날씨 리포트를 Discord Webhook으로 전송합니다.

## 메시지 템플릿

Discord 노드에서 사용하는 n8n expression입니다.

```text
={{ $json.dt.toDateTime('s').format('yyyy-MM-dd HH:mm') }} 기준 날씨 리포트

📍 현재 서울 날씨
- 상태: {{ $json.weather[0].description }}
- 기온: {{ $json.main.temp }}°C (체감 {{ $json.main.feels_like }}°C)
- 일출: {{ $json.sys.sunrise.toDateTime('s').format('HH:mm') }} / 일몰: {{ $json.sys.sunset.toDateTime('s').format('HH:mm') }}

🌥️ 내일 예보 (오전 9시)
- 상태: {{ $json.list[11].weather[0].description }}
- 기온: {{ $json.list[11].main.temp }}°C (체감 {{ $json.list[11].main.feels_like }}°C)
```

## 실습 안내

### 사전 준비

1. **OpenWeatherMap API 키** — [OpenWeatherMap](https://openweathermap.org/)에서 무료 계정을 생성하고 API 키를 발급받습니다. n8n의 OpenWeatherMap 자격 증명에 등록합니다.
2. **Discord Webhook URL** — Discord 서버에서 채널 설정 → 연동 → 웹후크에서 Webhook URL을 생성합니다. n8n의 Discord Webhook 자격 증명에 등록합니다.
3. 도시를 변경하려면 OpenWeatherMap 노드의 `cityName` 파라미터를 수정합니다.
