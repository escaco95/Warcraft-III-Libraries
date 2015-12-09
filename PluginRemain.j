/*
  디펜스/랜디류 게임에서 라이프로 사용하기 좋은 플러그인입니다.
  현재 라이프/최대 라이프가 아니라, 감소된 라이프/최대 라이프로 운영됩니다.
  
  local remain myLife = remain.create( 플레이어 ) //create라고 쓰고 그냥 플레이어의 라이프를 초기화한다고 읽습니다.
  myLife.isPerfect() // 라이프가 최대치인지 확인합니다
  myLife.isOverflowed() // 라이프가 0이하인지 확인합니다
  myLife.life // 최대 라이프 - 감소수치를 반환합니다
  myLife.fix // 감소수치를 설정합니다
  myLife.add // 감소수치를 추가합니다
  myLife.fixMax // 최대 라이프를 설정합니다
  myLife.addMax // 최대 라이프를 추가합니다
*/

library PluginRemain
    globals
        integer array MAX_LIFE
        integer array SUB_LIFE
    endglobals
    struct remain extends array
        static method create takes player p returns thistype
            local thistype this = GetPlayerId( p )
            set MAX_LIFE[this] = 0
            set SUB_LIFE[this] = 0
            return this
        endmethod
        method isPerfect takes nothing returns boolean
            return SUB_LIFE[this] == 0
        endmethod
        method isOverflowed takes nothing returns boolean
            return MAX_LIFE[this] <= SUB_LIFE[this]
        endmethod
        method fix takes integer i returns nothing
            set SUB_LIFE[this] = i
            //call eventCustom.evaluate( CUSTOM_REMAIN_CHANGE, Player(this), null, null, this )
        endmethod
        method operator life takes nothing returns integer
            return MAX_LIFE[this] - SUB_LIFE[this]
        endmethod
        method add takes integer i returns nothing
            set SUB_LIFE[this] = SUB_LIFE[this] + i
            //call eventCustom.evaluate( CUSTOM_REMAIN_CHANGE, Player(this), null, null, this )
        endmethod
        method fixMax takes integer i returns nothing
            set MAX_LIFE[this] = i
            //call eventCustom.evaluate( CUSTOM_REMAIN_CHANGE, Player(this), null, null, this )
        endmethod
        method addMax takes integer i returns nothing
            set MAX_LIFE[this] = MAX_LIFE[this]+i
            //call eventCustom.evaluate( CUSTOM_REMAIN_CHANGE, Player(this), null, null, this )
        endmethod
    endstruct
endlibrary

