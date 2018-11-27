/*
    //
    // 기초 사용예시(유닛 정보가 딸린 틱)
    //
    struct UnitTick
        //
        // 이 틱에 딸린 유닛 정보입니다 (과거 tick은 tick.data밖에 없었죠)
        //
        unit Dummy
        //
        // 구조체를 틱으로 변환합니다 (반드시 struct ~ endstruct 사이 '최하단'에 사용되어야 합니다)
        //
        //! runtextmacro Struct2TickVJ()
    endstruct

    //
    // 유닛 정보가 딸린 틱(UnitTick)의 사용 예시
    //
    function CallBack takes nothing returns nothing
        local UnitTick t = UnitTick.GetExpired()
        call KillUnit(t.Dummy)
        set t.Dummy = null
        call t.Destroy()
    endfunction

    function TestFunction takes nothing returns nothing
        local UnitTick t = UnitTick.Create()
        set t.Dummy = CreateUnit(Player(0),'hfoo',0,0,270)
        call t.Start( 1.00, false, function CallBack )
    endfunction



    //=========================================================================
    //  숙련자용 사용예시 (내용은 위와 동일)
    //=========================================================================

    struct UnitTick
        unit Dummy
        //
        // 틱이 DestroyCall 되면 자동으로 격발되는 내장 메소드, 자매품으로 OnCreate가 있습니다
        //
        private method OnDestroy takes nothing returns nothing
            set this.Dummy = null
        endmethod
        //! runtextmacro Struct2TickVJ()
    endstruct

    function CallBack takes nothing returns nothing
        local UnitTick t = UnitTick.GetExpired()
        call KillUnit(t.Dummy)
        call t.Destroy() // 자동 OnDestroy call -> null -> 누수해결
    endfunction

    function TestFunction takes nothing returns nothing
        local UnitTick t = UnitTick.Create()
        set t.Dummy = CreateUnit(Player(0),'hfoo',0,0,270)
        call t.Start( 1.00, false, function CallBack )
    endfunction
*/
globals
    hashtable STRUCT_2_TICK_TABLE = InitHashtable()
endglobals
//! textmacro Struct2TickVJ
        private static integer MAX = 0
        private timer T
        static method operator Count takes nothing returns integer
            return MAX
        endmethod
        static method GetExpired takes nothing returns thistype
            return LoadInteger( STRUCT_2_TICK_TABLE, 0, GetHandleId(GetExpiredTimer()) )
        endmethod
        static method Create takes nothing returns thistype
            local thistype this = thistype.allocate(  )
            set MAX = MAX + 1
            if .T == null then
                set .T = CreateTimer(  )
                call SaveInteger( STRUCT_2_TICK_TABLE, 0, GetHandleId(T), this )
            endif
            static if thistype.OnCreate.exists then
                call this.OnCreate()
            endif
            return this
        endmethod
        method operator Base takes nothing returns timer
            return .T
        endmethod
        method operator Elapsed takes nothing returns real
            return TimerGetElapsed( .T )
        endmethod
        method operator Remaining takes nothing returns real
            return TimerGetRemaining( .T )
        endmethod
        method operator Timeout takes nothing returns real
            return TimerGetTimeout( .T )
        endmethod
        method Pause takes nothing returns nothing
            call PauseTimer( .T )
        endmethod
        method Resume takes nothing returns nothing
            call ResumeTimer( .T )
        endmethod
        method Start takes real r, boolean flag, code c returns nothing
            call TimerStart( .T, r, flag, c )
        endmethod
        method Destroy takes nothing returns nothing
            static if thistype.OnDestroy.exists then
                call this.OnDestroy()
            endif
            set MAX = MAX - 1
            call PauseTimer( .T )
            call thistype.deallocate( this )
        endmethod
//! endtextmacro
