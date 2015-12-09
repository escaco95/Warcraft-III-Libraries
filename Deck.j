/*
  랜덤 '값'을 중복 없이 추첨하고 싶을 때 사용할 용도로 제작된 라이브러리입니다.
  워크래프트에서 기본 제공하는 pool의 하위 호환입니다.
  
  local integerdeck myDeck = integerdeck.create()
  call myDeck.add(1) // deck에 1을 추가합니다
  call myDeck.add(2) // " 2을 추가합니다
  call myDeck.add(3) // " 3을 추가합니다
  call myDeck.remove(3)
  call BJDebugMsg(I2S(myDeck.pick(false))) //추첨한 내용을 deck에서 제거하지 않습니다.(남아 있습니다)
  call BJDebugMsg(I2S(myDeck.pick(true))) //추첨한 내용을 deck에서 제거합니다.(중복 없는 추첨 시)
  call myDeck.destroy() //deck을 파괴합니다
  
  기타 기능
  call myDeck.clear() //deck을 초기화합니다
*/

//! textmacro DECKS takes TYPE, HASH, ERROR
    struct $TYPE$deck
        private static hashtable H = InitHashtable(  )
        private integer S
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate(  )
            set .S = 0
            return this
        endmethod
        method add takes $TYPE$ dst returns nothing
            call Save$HASH$( H, 0, this*8192 + .S, dst )
            set .S = .S + 1
        endmethod
        method remove takes $TYPE$ dst returns nothing
            local integer i = 0
            loop
                exitwhen i >= .S
                if Load$HASH$( H, 0, this*8192+i ) == dst then
                    set .S = .S - 1
                    if .S > 0 then
                        call Save$HASH$( H, 0, this*8192+i, Load$HASH$( H, 0, this*8192+.S ) )
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
        method pick takes boolean rem returns $TYPE$
            local integer s
            local integer l
            local $TYPE$ tmp
            if .S == 0 then
                return $ERROR$
            endif
            set s = this*8192+GetRandomInt( 0, .S-1 )
            if not rem then
                return Load$HASH$( H, 0, s )
            endif
            set .S = .S - 1
            set l = this*8192+.S
            set tmp = Load$HASH$( H, 0, l )
            call Save$HASH$( H, 0, l, Load$HASH$( H, 0, s ) )
            call Save$HASH$( H, 0, s, tmp )
            set tmp = $ERROR$
            return Load$HASH$( H, 0, l )
        endmethod
        method clear takes nothing returns nothing
            set .S = 0
        endmethod
        method destroy takes nothing returns nothing
            call clear()
            call thistype.deallocate( this )
        endmethod
    endstruct
//! endtextmacro
library Decks
    //! runtextmacro DECKS( "integer", "Integer", "0" )
endlibrary

