//! textmacro CommandSetting
private struct SettingCMD extends array
  트리거 실행 조건 - 입력된 채팅 명령어의 0~매칭 문자열 길이의 문자열이 키워드가 아니라면 실행 안함
endstruct
//! endtextmacro
private struct CMD$NAME$ extends array
  onHelp
  onCommand
endstruct
//! textmacro DebugCommand takes KEYWORD, STRUCT
  키워드 길이
  트리거 조건은 pre 선언된 함수로 등록
  트리거 액션은 함수로 등록
//! endtextmacro

어떤 플레이어든 채팅 입력 시, 이어지는 단어 배열에 따라 해시테이블의 명령어 수행??
OR 깡으로 이벤트에 추가.
