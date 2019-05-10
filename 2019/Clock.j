// Copyright (c) 2019 escaco95
// Distributed under the BSD License, Version 1.0.
// See original source at github https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/Clock.j
library Clock
    globals
        private hashtable IN_H = InitHashtable()
        private timer array IN_T
        private timerdialog array IN_TD
    endglobals
    // 타이머와 타이머 창을 통합한 시계 인스턴스입니다
    struct clock
        //! ====[    EVENT RESPONSE    ]====
        // 함수 또는 이벤트를 작동시킨 clock 객체를 보고받습니다
        static method operator expired takes nothing returns thistype
            return LoadInteger(IN_H,0,GetHandleId(GetExpiredTimer()))
        endmethod
        static method getExpired takes nothing returns thistype
            return LoadInteger(IN_H,0,GetHandleId(GetExpiredTimer()))
        endmethod
        //! ====[    CONSTRUCTOR/DESTRUCTOR    ]====
        // 새로운 clock 객체를 생성합니다
        static method create takes nothing returns thistype
            local thistype this = allocate()
            set IN_T[this] = CreateTimer()
            call SaveInteger(IN_H,0,GetHandleId(IN_T[this]),this)
            set IN_TD[this] = CreateTimerDialog(IN_T[this])
            return this
        endmethod
        // clock 객체를 파괴합니다
        method destroy takes nothing returns nothing
            call DestroyTimerDialog(IN_TD[this])
            call DestroyTimer(IN_T[this])
            call RemoveSavedInteger(IN_H,0,GetHandleId(IN_T[this]))
            set IN_TD[this] = null
            set IN_T[this] = null
            call deallocate()
        endmethod
        //! ====[    TIME HANDLER    ]====
        // 개체의 시간을 설정하고 시간을 흐르게 합니다
        method start takes real timeout, boolean periodic, code handlerFunc returns nothing
            call TimerStart(IN_T[this],timeout,periodic,handlerFunc)
        endmethod
        // 개체의 시간을 멈춥니다
        method pause takes nothing returns nothing
            call PauseTimer(IN_T[this])
        endmethod
        // 멈춰진 개체의 시간을 다시 흐르게 합니다
        method resume takes nothing returns nothing
            call ResumeTimer(IN_T[this])
        endmethod
        // 시계의 작동 간격을 보고받습니다
        method operator timeout takes nothing returns real
            return TimerGetTimeout(IN_T[this])
        endmethod
        method getTimeout takes nothing returns real
            return TimerGetTimeout(IN_T[this])
        endmethod
        // 현재 시점에서 흘러간 시간을 보고받습니다
        method operator elapsed takes nothing returns real
            return TimerGetElapsed(IN_T[this])
        endmethod
        method getElapsed takes nothing returns real
            return TimerGetElapsed(IN_T[this])
        endmethod
        // 현재 시점에서 종료까지 남은 시간을 보고받습니다
        method operator remaining takes nothing returns real
            return TimerGetRemaining(IN_T[this])
        endmethod
        method getRemaining takes nothing returns real
            return TimerGetRemaining(IN_T[this])
        endmethod
        //! ====[    CLOCK VISIBILITY    ]====
        // clock 객체를 표시합니다(모든 플레이어에게) : 연산자 오버라이딩
        method operator visible= takes boolean flag returns nothing
            call TimerDialogDisplay(IN_TD[this],flag)
        endmethod
        // clock 객체를 화면에 표시합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method display takes boolean flag returns nothing
            call TimerDialogDisplay(IN_TD[this],flag)
        endmethod
        method displayForPlayer takes player whichPlayer, boolean flag returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogDisplay(IN_TD[this],flag)
            endif
        endmethod
        method displayForForce takes force whichForce, boolean flag returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogDisplay(IN_TD[this],flag)
            endif
        endmethod
        // 객체를 보여줍니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method show takes nothing returns nothing
            call TimerDialogDisplay(IN_TD[this],true)
        endmethod
        method showForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogDisplay(IN_TD[this],true)
            endif
        endmethod
        method showForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogDisplay(IN_TD[this],true)
            endif
        endmethod
        // 객체를 숨깁니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method hide takes nothing returns nothing
            call TimerDialogDisplay(IN_TD[this],false)
        endmethod
        method hideForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogDisplay(IN_TD[this],false)
            endif
        endmethod
        method hideForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogDisplay(IN_TD[this],false)
            endif
        endmethod
        //! ====[    CLOCK TITLE    ]====
        // 객체의 타이머 창 제목을 설정합니다(모든 플레이어에게) : 연산자 오버라이딩
        method operator title= takes string title returns nothing
            call TimerDialogSetTitle(IN_TD[this],title)
        endmethod
        // 객체의 타이머 창 제목을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setTitle takes string title returns nothing
            call TimerDialogSetTitle(IN_TD[this],title)
        endmethod
        method setTitleForPlayer takes player whichPlayer, string title returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogSetTitle(IN_TD[this],title)
            endif
        endmethod
        method setTitleForForce takes force whichForce, string title returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogSetTitle(IN_TD[this],title)
            endif
        endmethod
        // 객체의 타이머 창 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setColor takes integer red, integer green, integer blue returns nothing
            call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
            call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
        endmethod
        method setColorForPlayer takes player whichPlayer, integer red, integer green, integer blue returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
                call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
        method setColorForForce takes force whichForce, integer red, integer green, integer blue returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
                call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
        // 객체의 타이머 창 제목 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setTitleColor takes integer red, integer green, integer blue returns nothing
            call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
        endmethod
        method setTitleColorForPlayer takes player whichPlayer, integer red, integer green, integer blue returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
        method setTitleColorForForce takes force whichForce, integer red, integer green, integer blue returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogSetTitleColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
        // 객체의 타이머 창 시간 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setTimeColor takes integer red, integer green, integer blue returns nothing
            call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
        endmethod
        method setTimeColorForPlayer takes player whichPlayer, integer red, integer green, integer blue returns nothing
            if GetLocalPlayer() == whichPlayer then
                call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
        method setTimeColorForForce takes force whichForce, integer red, integer green, integer blue returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call TimerDialogSetTimeColor(IN_TD[this],red,green,blue,255)
            endif
        endmethod
    endstruct
    //! ====[    CUSTOM EVENT    ]====
    // 이벤트 - clock 객체가 만료될 때마다 실행됩니다
    function TriggerRegisterClockExpireEvent takes trigger whichTrigger, clock whichClock returns event
        return TriggerRegisterTimerExpireEvent(whichTrigger, IN_T[whichClock])
    endfunction
    //! ====[    EVENT RESPONSE    ]====
    // 함수 또는 이벤트를 작동시킨 clock 객체를 보고받습니다
    function GetExpiredClock takes nothing returns clock
        return LoadInteger(IN_H,0,GetHandleId(GetExpiredTimer()))
    endfunction
    //! ====[    TIME HANDLER    ]====
    // 개체의 시간을 설정하고 시간을 흐르게 합니다
    function ClockStart takes clock whichClock, real timeout, boolean periodic, code handlerFunc returns nothing
        call TimerStart(IN_T[whichClock],timeout,periodic,handlerFunc)
    endfunction
    // 개체의 시간을 멈춥니다
    function PauseClock takes clock whichClock returns nothing
        call PauseTimer(IN_T[whichClock])
    endfunction
    // 멈춰진 개체의 시간을 다시 흐르게 합니다
    function ResumeClock takes clock whichClock returns nothing
        call ResumeTimer(IN_T[whichClock])
    endfunction
    // 시계의 작동 간격을 보고받습니다
    function ClockGetTimeout takes clock whichClock returns real
        return TimerGetTimeout(IN_T[whichClock])
    endfunction
    // 현재 시점에서 흘러간 시간을 보고받습니다
    function ClockGetElapsed takes clock whichClock returns real
        return TimerGetElapsed(IN_T[whichClock])
    endfunction
    // 현재 시점에서 종료까지 남은 시간을 보고받습니다
    function ClockGetRemaining takes clock whichClock returns real
        return TimerGetRemaining(IN_T[whichClock])
    endfunction
    //! ====[    CONSTRUCTOR/DESTRUCTOR    ]====
    // 새로운 clock 객체를 생성합니다
    function CreateClock takes nothing returns clock
        return clock.create()
    endfunction
    // clock 객체를 파괴합니다
    function DestroyClock takes clock whichClock returns nothing
        call whichClock.destroy()
    endfunction
    //! ====[    CLOCK VISIBILITY    ]====
    // clock 객체를 표시합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ClockDisplay takes clock whichClock, boolean flag returns nothing
        call TimerDialogDisplay(IN_TD[whichClock],flag)
    endfunction
    function ClockDisplayForPlayer takes clock whichClock, player whichPlayer, boolean flag returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogDisplay(IN_TD[whichClock],flag)
        endif
    endfunction
    function ClockDisplayForForce takes clock whichClock, force whichForce, boolean flag returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogDisplay(IN_TD[whichClock],flag)
        endif
    endfunction
    // 객체를 보여줍니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ShowClock takes clock whichClock returns nothing
        call TimerDialogDisplay(IN_TD[whichClock],true)
    endfunction
    function ShowClockForPlayer takes clock whichClock, player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogDisplay(IN_TD[whichClock],true)
        endif
    endfunction
    function ShowClockForForce takes clock whichClock, force whichForce returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogDisplay(IN_TD[whichClock],true)
        endif
    endfunction
    // 객체를 숨깁니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function HideClock takes clock whichClock returns nothing
        call TimerDialogDisplay(IN_TD[whichClock],false)
    endfunction
    function HideClockForPlayer takes clock whichClock, player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogDisplay(IN_TD[whichClock],false)
        endif
    endfunction
    function HideClockForForce takes clock whichClock, force whichForce returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogDisplay(IN_TD[whichClock],false)
        endif
    endfunction
    //! ====[    CLOCK TITLE    ]====
    // 객체의 타이머 창 제목을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ClockSetTitle takes clock whichClock, string title returns nothing
        call TimerDialogSetTitle(IN_TD[whichClock],title)
    endfunction
    function ClockSetTitleForPlayer takes clock whichClock, player whichPlayer, string title returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogSetTitle(IN_TD[whichClock],title)
        endif
    endfunction
    function ClockSetTitleForForce takes clock whichClock, force whichForce, string title returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogSetTitle(IN_TD[whichClock],title)
        endif
    endfunction
    // 객체의 타이머 창 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ClockSetColor takes clock whichClock, integer red, integer green, integer blue returns nothing
        call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
        call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
    endfunction
    function ClockSetColorForPlayer takes clock whichClock, player whichPlayer, integer red, integer green, integer blue returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
            call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
    function ClockSetColorForForce takes clock whichClock, force whichForce, integer red, integer green, integer blue returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
            call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
    // 객체의 타이머 창 제목 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ClockSetTitleColor takes clock whichClock, integer red, integer green, integer blue returns nothing
        call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
    endfunction
    function ClockSetTitleColorForPlayer takes clock whichClock, player whichPlayer, integer red, integer green, integer blue returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
    function ClockSetTitleColorForForce takes clock whichClock, force whichForce, integer red, integer green, integer blue returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogSetTitleColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
    // 객체의 타이머 창 시간 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
    function ClockSetTimeColor takes clock whichClock, integer red, integer green, integer blue returns nothing
        call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
    endfunction
    function ClockSetTimeColorForPlayer takes clock whichClock, player whichPlayer, integer red, integer green, integer blue returns nothing
        if GetLocalPlayer() == whichPlayer then
            call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
    function ClockSetTimeColorForForce takes clock whichClock, force whichForce, integer red, integer green, integer blue returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call TimerDialogSetTimeColor(IN_TD[whichClock],red,green,blue,255)
        endif
    endfunction
endlibrary
