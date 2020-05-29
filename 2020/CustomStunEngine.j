scope SampleStunSystem initializer OnMapInit

    globals
        // 스턴을 표시할 유동 텍스트
        private texttag array STUN_TAG
    endglobals

    // 새로 스턴에 걸리면, 스턴의 고유 ID 값을 가져와서 그 값으로 유동텍스트 세팅
    private function OnStunNew takes nothing returns nothing
        local integer stunId = CustomStun.GetEventStunId()
        local real x = GetUnitX(CustomStun.GetTriggerUnit())
        local real y = GetUnitY(CustomStun.GetTriggerUnit())
        local real z = GetUnitFlyHeight(CustomStun.GetTriggerUnit())
        set STUN_TAG[stunId] = CreateTextTag()
        call SetTextTagColor(STUN_TAG[stunId],255,0,0,255)
        call SetTextTagText(STUN_TAG[stunId],"기절함!",0.03)
        call SetTextTagPos(STUN_TAG[stunId],x,y,z+120.0)
        call SetTextTagPermanent(STUN_TAG[stunId],true)
        call SetTextTagVisibility(STUN_TAG[stunId],true)
    endfunction
    
    // 중첩 알림
    private function OnStunBeforeStack takes nothing returns nothing
        local integer stunId = CustomStun.GetEventStunId()
        local real remaining = CustomStun.GetRemaining()
        local real newTime = CustomStun.GetStackDuration()
        // 새로운 시간이 남은 시간보다 짧다면 
        if newTime < remaining then
            // ...더 이상 시간을 추가하지 않습니다
            call CustomStun.SetStackDuration(0.0)
        else
            // 연장된 시간만큼 더합니다
            call CustomStun.SetStackDuration(newTime-remaining)
        endif
    endfunction
    
    // 남은 스턴 시간으로 텍스트 내용 및 위치 갱신
    private function OnStunTimeout takes nothing returns nothing
        local integer stunId = CustomStun.GetEventStunId()
        local real x = GetUnitX(CustomStun.GetTriggerUnit())
        local real y = GetUnitY(CustomStun.GetTriggerUnit())
        local real z = GetUnitFlyHeight(CustomStun.GetTriggerUnit())
        call SetTextTagText(STUN_TAG[stunId],R2S(CustomStun.GetRemaining()),0.03)
        call SetTextTagPos(STUN_TAG[stunId],x,y,z+120.0)
    endfunction
    
    // 유동텍스트 파괴
    private function OnStunEnd takes nothing returns nothing
        local integer stunId = CustomStun.GetEventStunId()
        call DestroyTextTag(STUN_TAG[stunId])
        set STUN_TAG[stunId] = null
    endfunction

    private function OnMapInit takes nothing returns nothing
            call CustomStun.RegisterStunNewEvent( function OnStunNew )
            call CustomStun.RegisterStunBeforeStackEvent( function OnStunBeforeStack )
            //call CustomStun.RegisterStunStackEvent( function 액션함수 ) // (사용 안함)
            //call CustomStun.RegisterStunStartEvent( function 액션함수 ) // (사용 안함)
            call CustomStun.RegisterStunTimeoutEvent( function OnStunTimeout )
            call CustomStun.RegisterStunEndEvent( function OnStunEnd )
    endfunction
                
endscope
