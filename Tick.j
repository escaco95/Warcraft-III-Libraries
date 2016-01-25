/*  버전 1.0.0.0, escaco

    설명
        워크래프트에서 지원하는 원시 객체인 타이머를 Wrap해 1~8191의 핸들값을 사용하도록 유도하는 타이머 유틸입니다.

    기능 목록
        정적 메소드
            tick myTick = tick.create( integer 커스텀 값 ) // 새 틱에 '커스텀 값'을 주고 생성합니다
                - 특수한 목적이 아닌 이상 일반적으로 0의 커스텀 값을 사용하시면 됩니다
                
            integer howMany = tick.count() // 현재 맵 상에서 사용중인 틱의 갯수를 반환합니다
                - 일정 시간마다 tick.count() 메소드로 값을 받아 누수 여부를 체크할 수 있습니다
                
            tick expiredTick = tick.getExpired() // GetExpiredTimer()의 tick 버전입니다
            
        멤버
            timer myTimer = myTick.super // 해당 tick의 부모 timer를 반환합니다
                - tick에 타이머 창을 씌우고 싶을 때 유용하게 사용할 수 있습니다
            
            integer myData = myTick.data // 해당 tick의 커스텀 값을 반환합니다
                - tick.create에서 설정한 값으로 핸들값과는 아무런 관계가 없습니다
                
            set myTick.data = 정수 // 해당 tick의 커스텀 값을 변경합니다
                
            real time = myTick.elapsed // 현재 tick의 지나간 시간을 반환합니다
                - 5초 틱을 돌리던 중 2초가 경과된 다음 이 멤버의 값 = 2
                
            real time = myTick.remaining // 현재 tick의 남은 시간을 반환합니다
                - 5초 틱을 돌리던 중 2초가 경과된 다음 이 멤버의 값 = 3
                
            real time = myTick.timeout // 현재 tick에게 설정된 격발 간격을 반환합니다
                - 5초 틱을 돌리던 중 2초가 경과된 다음 이 멤버의 값 = 5
        
        메소드
            myTick.start( real 격발 간격, boolean 반복 여부, code 목표 함수 )
                - 틱을 일정 간격으로 격발시킵니다
            
            myTick.pause()
                - 틱을 일시 정지시킵니다
            
            myTick.resume()
                - 일시 정지 상태인 틱을 재시작합니다
            
            myTick.destroy()
                - 사용을 마친 틱 리소스의 사용을 해제하여 다른 장소에서 쓰일 수 있게 합니다
            
*/


library Tick
    struct tick
        private static integer MAX = 0
        private static hashtable H = InitHashtable(  )
        private timer T
        integer data
        static method operator count takes nothing returns integer
            return MAX
        endmethod
        static method getExpired takes nothing returns thistype
            return LoadInteger( H, 0, GetHandleId(GetExpiredTimer()) )
        endmethod
        static method create takes integer userData returns thistype
            local thistype this = thistype.allocate(  )
            set MAX = MAX + 1
            if .T == null then
                set .T = CreateTimer(  )
                call SaveInteger( H, 0, GetHandleId(T), this )
            endif
            set .data = userData
            return this
        endmethod
        method operator super takes nothing returns timer
            return .T
        endmethod
        method operator elapsed takes nothing returns real
            return TimerGetElapsed( .T )
        endmethod
        method operator remaining takes nothing returns real
            return TimerGetRemaining( .T )
        endmethod
        method operator timeout takes nothing returns real
            return TimerGetTimeout( .T )
        endmethod
        method pause takes nothing returns nothing
            call PauseTimer( .T )
        endmethod
        method resume takes nothing returns nothing
            call ResumeTimer( .T )
        endmethod
        method start takes real r, boolean flag, code c returns nothing
            call TimerStart( .T, r, flag, c )
        endmethod
        method destroy takes nothing returns nothing
            set MAX = MAX - 1
            call PauseTimer( .T )
            call thistype.deallocate( this )
        endmethod
    endstruct
    
    struct tickUI
        private static integer MAX = 0
        private timerdialog T
        static method operator count takes nothing returns integer
            return MAX
        endmethod
        static method create takes tick t returns thistype
            local thistype this = thistype.allocate(  )
            set MAX = MAX + 1
            set .T = CreateTimerDialog( t.super )
            return this
        endmethod
        method operator super takes nothing returns timerdialog
            return .T
        endmethod
        method operator title= takes string s returns nothing
            call TimerDialogSetTitle( .T, s )
        endmethod
        method operator speed= takes real r returns nothing
            call TimerDialogSetSpeed( .T, r )
        endmethod
        method operator remaining= takes real r returns nothing
            call TimerDialogSetRealTimeRemaining( .T, r )
        endmethod
        method operator visible= takes boolean f returns nothing
            call TimerDialogDisplay( .T, f )
        endmethod
        method operator visible takes nothing returns boolean
            return IsTimerDialogDisplayed( .T )
        endmethod
        method setTimeColor takes integer r, integer g, integer b returns nothing
            call TimerDialogSetTimeColor( .T, r, g, b, 255 )
        endmethod
        method setTitleColor takes integer r, integer g, integer b returns nothing
            call TimerDialogSetTitleColor( .T, r, g, b, 255 )
        endmethod
        method destroy takes nothing returns nothing
            set MAX = MAX - 1
            call DestroyTimerDialog( .T )
            set .T = null
            call thistype.deallocate( this )
        endmethod
    endstruct
endlibrary

