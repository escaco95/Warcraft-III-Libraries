//*****************************************************************
// -stun <숫자> 로 발동됩니다
//*****************************************************************
scope TriggerESCStun initializer OnMapLoad
    //=============================================================
    private function OnChatStun takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        
        local string chat = GetEventPlayerChatString()
        local integer chatLength = StringLength(chat)
        local string command = GetEventPlayerChatStringMatched()
        local integer commandLength = StringLength(command)
        
        local string param = SubString( chat, commandLength, chatLength )
        
        local real time = RMaxBJ(0.03125,S2R(param))
        local group g = CreateGroup()
        local unit u
        call GroupEnumUnitsOfPlayer(g,p,null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g,u)
            call CustomStun.Stun(u,time)
        endloop
        call DestroyGroup(g)
        set g = null
        
        set p = null
    endfunction
    private function OnChatClear takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        local group g = CreateGroup()
        local unit u
        call GroupEnumUnitsOfPlayer(g,p,null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g,u)
            call CustomStun.Clear(u)
        endloop
        call DestroyGroup(g)
        set g = null
        
        set p = null
    endfunction
    //=============================================================
    private function InitChatTrigger takes string word, boolean exact, code act returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        call TriggerAddAction( t, act )
        loop
            exitwhen i == bj_MAX_PLAYER_SLOTS
            call TriggerRegisterPlayerChatEvent( t, Player(i), word, exact )
            set i = i + 1
        endloop
        set t = null
    endfunction
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        call InitChatTrigger( "-stun ", false, function OnChatStun )
        call InitChatTrigger( "-clear", true, function OnChatClear )
    endfunction
    //=============================================================
endscope
//*****************************************************************


//*****************************************************************
// 나만의 커스텀 스턴 시스템을 세팅할 수 있습니다!
//*****************************************************************
scope MyCustomStunSystem initializer OnMapLoad
    //=============================================================
    globals
        private effect array FX_STUN
    endglobals
    //=============================================================
    private function OnAnyStunNew takes nothing returns nothing
        local integer id = CustomStun.GetEventStunId()
        local unit u = CustomStun.GetTriggerUnit()
        set FX_STUN[id] = AddSpecialEffectTarget("Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl",u,"overhead")
        set u = null
    endfunction
    private function OnAnyStunEnd takes nothing returns nothing
        local integer id = CustomStun.GetEventStunId()
        call DestroyEffect(FX_STUN[id])
    endfunction
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        call CustomStun.RegisterStunNewEvent( function OnAnyStunNew )
        call CustomStun.RegisterStunEndEvent( function OnAnyStunEnd )
    endfunction
    //=============================================================
endscope
//*****************************************************************


//*****************************************************************
// 나만의 커스텀 스턴 시스템을 세팅할 수 있습니다!
//*****************************************************************
scope MyCustomStunSystemS2 initializer OnMapLoad
    //=============================================================
    globals
        private texttag array TG_STUN
    endglobals
    //=============================================================
    private function OnAnyStunNew takes nothing returns nothing
        local integer id = CustomStun.GetEventStunId()
        local unit u = CustomStun.GetTriggerUnit()
        set TG_STUN[id] = CreateTextTag()
        call SetTextTagText(TG_STUN[id],"기절함!",0.03)
        call SetTextTagPos(TG_STUN[id],GetUnitX(u),GetUnitY(u),GetUnitFlyHeight(u)+120.0)
        call SetTextTagPermanent(TG_STUN[id],true)
        call SetTextTagVisibility(TG_STUN[id],true)
        set u = null
    endfunction
    private function OnAnyStunTimeout takes nothing returns nothing
        local integer id = CustomStun.GetEventStunId()
        local unit u = CustomStun.GetTriggerUnit()
        local real remaining = CustomStun.GetRemaining()
        local string text = R2S(remaining)
        if remaining < 3.0 then
            set text = "|c00FF8000" + text
        else
            set text = "|c00FF0000" + text
        endif
        call SetTextTagText(TG_STUN[id],text,0.02+remaining*0.001)
        call SetTextTagPos(TG_STUN[id],GetUnitX(u),GetUnitY(u),GetUnitFlyHeight(u)+120.0)
        set u = null
    endfunction
    private function OnAnyStunEnd takes nothing returns nothing
        local integer id = CustomStun.GetEventStunId()
        call DestroyTextTag(TG_STUN[id])
    endfunction
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        call CustomStun.RegisterStunNewEvent( function OnAnyStunNew )
        call CustomStun.RegisterStunTimeoutEvent( function OnAnyStunTimeout )
        call CustomStun.RegisterStunEndEvent( function OnAnyStunEnd )
    endfunction
    //=============================================================
endscope
//*****************************************************************
