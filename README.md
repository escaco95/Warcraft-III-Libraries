# Warcraft-III-Libraries

워크래프트 3 맵 제작에 필요한 라이브러리 목록

## 배포 버전 요약

| 라이브러리 이름 | 소스 | 요약 |
| -- | -- | -- |
| 해시리스트 | [hashlist.j](src/hashlist.j) | 정수 전용 해시테이블 + 인덱스 조회 |
| 이벤트 래퍼 | [event-wrapper.j](src/event-wrapper.j) | 워크래프트 기본 이벤트 래퍼 |
| 유클리드 | [euclid.j](src/euclid.j) | 거리, 각도, 좌표 계산 유틸리티 (구 Angle Distance Polar) |
| 핸들 프로파일러 | [handle-profiler.j](src/handle-profiler.j) | 누수체크, 핸들값 모니터링 유틸리티 |
| 틱 | [tick.j](src/tick.j) | 타이머 재사용 및 인덱싱 유틸리티 |
| 틱 구조체 템플릿 | [tick-struct.j](src/tick-struct.j) | [tick.j](src/tick.j) 기반 구조체 템플릿 |
| 데미지 받음 엔진 | [damage-engine-base.j](src/damage-engine-base.j) | 데미지 받음 시스템 개발용 밑바탕 엔진 |
| 데미지 받음 시스템 (기본형) | [damage-system-basic.j](src/damage-system-basic.j) | 어떤 유닛이든, 유닛 타입이, 아이템을 들고... 데미지 이벤트 제공 |
