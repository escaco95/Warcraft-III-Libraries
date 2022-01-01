# Warcraft-III-Libraries
워크래프트 3 맵 제작에 필요한 라이브러리 목록

# 명심해
- scope
  - ForForce(bj_FORCE_PLAYER[0], 초기화 함수) 로 초기화하기! OpLimit로 고통받기 싫다면!
- function
  - 웬만한 local 변수는 차라리 takes에 선언해서 쓰는 게 더 빠르고 깔끔함
- timer
  - call PauseTimer() && call DestroyTimer() 반드시 같이 사용하기, 안그럼 버그날수도있음
