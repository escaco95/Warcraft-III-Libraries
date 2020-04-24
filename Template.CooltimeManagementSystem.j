//*****************************************************************
/* 쿨감 매니지먼트 시스템 */
library CoolTimeSystem initializer OnMapLoad
    //=============================================================
    // 디버그용 출력 기능
    private function DebugMsg takes string s returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[CT] "+s)
    endfunction
    //=============================================================
    globals
        private integer DEBUG_COUNT = 0
    endglobals
    function CooltimeInstanceCount takes nothing returns integer
        return DEBUG_COUNT
    endfunction
    //=============================================================
    globals
        /* 공용 접근 가능한 변수 */
        hashtable TABLE_HERO_SKILL = InitHashtable() /* 액티브 능력의 쿨타임이 저장된 테이블 */
        
        /* 시스템 런타임 참조용 변수 & 상수 */
        private constant real MIN_COOL = 0.03125 /* MIN_COOL이하의 쿨타임을 가진 스킬은 쿨감시스템이 다루지 않습니다! */
        private constant real MIN_TIMEOUT = 0.03125 /* 이 간격이 짧을수록 네트워크 동기화 부하가 커지지만, 쿨감이 보다 정밀해집니다 */
        
        private hashtable RUNTIME_TABLE = InitHashtable() /* 시스템 런타임 테이블(특정 유닛의 쿨감현황 참조) */
        
        /* 쿨감 이벤트 처리용 변수 & 상수 */
        key EVENT_COOLDOWN_START
        key EVENT_COOLDOWN_RUNNING
        key EVENT_COOLDOWN_END
        
        private hashtable EVENT_ABIL = InitHashtable()
        private integer EVENT_ABIL_TYPE = 0
        private real EVENT_ABIL_OCOOL = 0.0
        private real EVENT_ABIL_COOL = 0.0
        private real EVENT_ABIL_ELAPSING = 0.0
        private integer EVENT_ABIL_ID = 0
        private unit EVENT_ABIL_UNIT = null
    endglobals
    //=============================================================
    private function FireAbilEvent takes integer eventId, unit u, integer id, real ocoold, real coold, real elapsing returns real
        local integer pE = EVENT_ABIL_TYPE
        local unit pU = EVENT_ABIL_UNIT
        local integer pI = EVENT_ABIL_ID
        local real pOC = EVENT_ABIL_OCOOL
        local real pC = EVENT_ABIL_COOL
        local real pL = EVENT_ABIL_ELAPSING
        local real result
        set EVENT_ABIL_TYPE = eventId
        set EVENT_ABIL_UNIT = u
        set EVENT_ABIL_ID = id
        set EVENT_ABIL_OCOOL = ocoold
        set EVENT_ABIL_COOL = coold
        set EVENT_ABIL_ELAPSING = elapsing
        call TriggerEvaluate(LoadTriggerHandle(EVENT_ABIL,eventId,0))
        call TriggerEvaluate(LoadTriggerHandle(EVENT_ABIL,eventId,id))
        set result = EVENT_ABIL_COOL
        set EVENT_ABIL_TYPE = pE
        set EVENT_ABIL_UNIT = pU
        set EVENT_ABIL_ID = pI
        set EVENT_ABIL_OCOOL = pOC
        set EVENT_ABIL_COOL = pC
        set EVENT_ABIL_ELAPSING = pL
        set pU = null
        return result
    endfunction
    //=============================================================
    private struct CooltimeInstance
        boolean Exists
        unit Unit
        integer Ability
        integer Level
        real Cooldown
        real OriginCooldown
        real Elapsed
        timer Timer
        private static method onTimerExpired takes nothing returns nothing
            local thistype this = LoadInteger(RUNTIME_TABLE,GetHandleId(GetExpiredTimer()),0)
            if .Elapsed < .Cooldown then
                set .Elapsed = .Elapsed + MIN_COOL
                /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[초기화] 전 .Elapsed: "+R2S(.Elapsed)+" Cooldown: "+R2S(.Cooldown))
                set .Cooldown = FireAbilEvent(EVENT_COOLDOWN_RUNNING,.Unit,.Ability,.OriginCooldown,.Cooldown,RMinBJ(.Elapsed,.Cooldown))
                /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[초기화] 후 .Elapsed: "+R2S(.Elapsed)+" Cooldown: "+R2S(.Cooldown))
                if .Elapsed < .Cooldown then
                    return
                endif
            endif
            /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[초기화] 능력 쿨타임이 도는 중 쿨타임 초기화 발동")
            set .Exists = false
            call RemoveSavedInteger(RUNTIME_TABLE,GetHandleId(.Unit),.Ability)
            call FireAbilEvent(EVENT_COOLDOWN_END,.Unit,.Ability,.OriginCooldown,.Cooldown,.Elapsed)
            set .Unit = null
            call FlushChildHashtable(RUNTIME_TABLE,GetHandleId(.Timer))
            call DestroyTimer(.Timer)
            set .Timer = null
            set DEBUG_COUNT = DEBUG_COUNT - 1
            call .destroy()
        endmethod
        static method create takes unit u, integer id, integer lev, real coold returns thistype
            local thistype this
            set coold = FireAbilEvent(EVENT_COOLDOWN_START,u,id,coold,coold,0.0)
            /*if coold < MIN_COOL then
                debug call DebugMsg( "쿨감 이벤트 계산 결과, 즉시쿨초." )
                call FireAbilEvent(EVENT_COOLDOWN_END,u,id,coold,coold,0.0)
                return 0
            endif*/
            debug call DebugMsg( "쿨감 이벤트 계산 결과: "+R2S(coold)+"s" )
            set this = thistype.allocate()
            set DEBUG_COUNT = DEBUG_COUNT + 1
            set .Exists = true
            call SaveInteger(RUNTIME_TABLE,GetHandleId(u),id,this)
            set .Unit = u
            set .Ability = id
            set .Level = lev
            set .Cooldown = coold
            set .OriginCooldown = coold
            set .Elapsed = 0.0
            set .Timer = CreateTimer()
            call SaveInteger(RUNTIME_TABLE,GetHandleId(.Timer),0,this)
            call TimerStart(.Timer,MIN_COOL,true,function thistype.onTimerExpired)
            return this
        endmethod
    endstruct
    //=============================================================
    function GetTriggerCooldownEvent takes nothing returns integer
        return EVENT_ABIL_TYPE
    endfunction
    function GetTriggerCooldownAbility takes nothing returns integer
        return EVENT_ABIL_ID
    endfunction
    function GetTriggerCooldownUnit takes nothing returns unit
        return EVENT_ABIL_UNIT
    endfunction
    function GetTriggerDefaultCooldown takes nothing returns real
        return EVENT_ABIL_OCOOL
    endfunction
    function GetTriggerCooldownElapsed takes nothing returns real
        return EVENT_ABIL_ELAPSING
    endfunction
    function GetTriggerCooldown takes nothing returns real
        return EVENT_ABIL_COOL
    endfunction
    function SetTriggerCooldown takes real coold returns nothing
        set EVENT_ABIL_COOL = coold
    endfunction
    function TriggerRegisterAnyCooldownEvent takes integer eventId, code c returns triggercondition
        if not HaveSavedHandle(EVENT_ABIL,eventId,0) then
            call SaveTriggerHandle(EVENT_ABIL,eventId,0,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(EVENT_ABIL,eventId,0),Condition(c))
    endfunction
    function TriggerRegisterCooldownEvent takes integer eventId, integer abilId, code c returns triggercondition
        if not HaveSavedHandle(EVENT_ABIL,eventId,abilId) then
            call SaveTriggerHandle(EVENT_ABIL,eventId,abilId,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(EVENT_ABIL,eventId,abilId),Condition(c))
    endfunction
    //=============================================================
    /* 특정 능력 쿨타임 즉시 초기화 */
    function ResetUnitAbilityCooldown takes unit u, integer id returns nothing
        local CooltimeInstance cti = LoadInteger(RUNTIME_TABLE,GetHandleId(u),id)
        local integer lev
        /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"쿨타임 초기화 시도")
        if cti == 0 then
            /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[초기화] 능력 쿨타임이 안 돌고 있음")
            set lev = GetUnitAbilityLevel(u,id)
            if lev > 0 then
                call UnitRemoveAbility(u,id)
                call UnitAddAbility(u,id)
                call SetUnitAbilityLevel(u,id,lev)
            endif
            return
        endif
        /*DEBUG*/ debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[초기화] 능력 쿨타임이 돌고 있음")
        set cti.Cooldown = 0.0
    endfunction
    /* 고정(초) 만큼 특정 능력 쿨타임 감소 */
    function ReduceUnitAbilityCooldown takes unit u, integer id, real time returns nothing
        local CooltimeInstance cti
        if time < 0.0 then
            return
        endif
        set cti = LoadInteger(RUNTIME_TABLE,GetHandleId(u),id)
        if cti == 0 then
            return
        endif
        set cti.Cooldown = cti.Cooldown - time
    endfunction
    //=============================================================
    /* 쿨감시스템을 사용할 능력 등록 함수 (SaveReal을 통해 전역 테이블에 바로 접근할 수 있지만, 전역 변수의 무분별한 접근 방지용 함수) */
    function RegisterUnitAbilityCooldown takes integer id, real cooldown returns nothing
        call SaveReal(TABLE_HERO_SKILL,id,-1,cooldown)
    endfunction
    /* 쿨감시스템을 사용할 능력 등록 함수 (SaveReal을 통해 전역 테이블에 바로 접근할 수 있지만, 전역 변수의 무분별한 접근 방지용 함수) */
    function RegisterUnitAbilityCooldownEx takes integer id, integer lev, real cooldown returns nothing
        call SaveReal(TABLE_HERO_SKILL,id,lev,cooldown)
    endfunction
    //=============================================================
    private function OnAnyUnitSpellEffect takes nothing returns nothing
        local unit abUnit = GetTriggerUnit()
        local integer abId = GetSpellAbilityId()
        local integer abLev = GetUnitAbilityLevel(abUnit,abId)
        local real abCool
        
        if HaveSavedReal(TABLE_HERO_SKILL,abId,abLev) then
            set abCool = LoadReal(TABLE_HERO_SKILL, abId, abLev)
        else
            set abCool = LoadReal(TABLE_HERO_SKILL, abId, -1)  /* 미등록 스킬은 0.0초 */
        endif
        
        if abCool < MIN_COOL then
            debug call DebugMsg("미처리 능력 '|cff808080"+GetObjectName(abId)+"|r'의 효과 시작 감지")
            set abUnit = null
            return
        endif
        
        debug call DebugMsg("등록된 능력 '|cffff8000"+GetObjectName(abId)+"|r'("+R2S(abCool)+"초)의 효과 시작 감지")
        call CooltimeInstance.create(abUnit,abId,abLev,abCool)
        set abUnit = null
    endfunction
    private function InitSpellEffectListener takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t, function OnAnyUnitSpellEffect)
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        set t = null
    endfunction
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        debug call DebugMsg( "시스템 초기화 중..." )
        call InitSpellEffectListener( ) /* 유닛의 능력 사용 시점을 자동 감지하는 감지기 초기화 */
        debug call DebugMsg( "시스템 초기화 완료!" )
    endfunction
    //=============================================================
endlibrary
//*****************************************************************
